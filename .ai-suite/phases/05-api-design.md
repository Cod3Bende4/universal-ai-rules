# 05-API-DESIGN.md
# PURPOSE: REST conventions, API contracts, status codes, versioning, and OpenAPI requirements
# LOAD WHEN: Designing new API endpoints, modifying existing APIs, or defining service contracts

---

## REST Naming Conventions

### URL Structure
```
[METHOD] /api/v{version}/{resource}/{id}/{sub-resource}
```

### Rules
- [ ] Resource names are plural nouns — `/users`, `/orders`, `/products`
- [ ] Resource names are kebab-case — `/order-items`, `/user-profiles`
- [ ] No verbs in URLs — use HTTP methods instead (`POST /users` not `POST /createUser`)
- [ ] Nest sub-resources max 2 levels deep — `/users/{id}/orders` is OK; `/users/{id}/orders/{id}/items/{id}/reviews` is not
- [ ] Use query params for filtering, not path segments — `/users?status=active`
- [ ] All endpoints start with `/api/` — separate API from static assets
- [ ] Version included in URL path — `/api/v1/users`

### HTTP Methods
| Method | Purpose | Idempotent | Request Body |
|---|---|---|---|
| GET | Read resource(s) | Yes | No |
| POST | Create resource | No | Yes |
| PUT | Replace entire resource | Yes | Yes |
| PATCH | Partial update | Yes | Yes |
| DELETE | Remove resource | Yes | No |

- [ ] GET never modifies data — side-effect free
- [ ] POST is for creation — returns 201 with created resource
- [ ] PUT replaces the entire resource — send all fields
- [ ] PATCH modifies specific fields — send only changed fields
- [ ] DELETE is idempotent — deleting twice returns same result (204 or 404)

⚠️ WARNING: Never use GET requests to modify data. This is a critical API design violation that causes caching bugs and security issues.

---

## Request/Response Contract Template

### Define BEFORE Implementation
```yaml
Endpoint: POST /api/v1/users
Description: Create a new user account

Request:
  Headers:
    Content-Type: application/json
    Authorization: Bearer {token}
  Body:
    email: string (required, valid email format)
    password: string (required, min 12 chars)
    name: string (required, max 100 chars)

Response 201 (Created):
  Body:
    id: string (UUID)
    email: string
    name: string
    createdAt: string (ISO 8601)

Response 400 (Bad Request):
  Body:
    error:
      code: VALIDATION_ERROR
      message: string
      details: array of { field, reason }

Response 409 (Conflict):
  Body:
    error:
      code: DUPLICATE_EMAIL
      message: "A user with this email already exists"
```

### Contract Rules
- [ ] Write the contract before the implementation — API-first design
- [ ] Document all possible response codes — not just the happy path
- [ ] Document all request headers — especially auth requirements
- [ ] Document field constraints — type, required/optional, min/max, format
- [ ] Document rate limits — if applicable to this endpoint
- [ ] Version the contract — include API version in the specification

---

## HTTP Status Code Rules

### Success Codes
| Code | Use When | Response Body |
|---|---|---|
| 200 OK | Successful GET, PUT, PATCH, or DELETE | Resource or confirmation |
| 201 Created | Successful POST creating a resource | Created resource + Location header |
| 204 No Content | Successful DELETE or PUT with no body to return | Empty |

### Client Error Codes
| Code | Use When | Response Body |
|---|---|---|
| 400 Bad Request | Invalid request format, missing required fields | Error with field details |
| 401 Unauthorized | Missing or invalid authentication | Error message |
| 403 Forbidden | Authenticated but lacking permission | Error message |
| 404 Not Found | Resource does not exist | Error message |
| 409 Conflict | Duplicate resource or state conflict | Error with conflict details |
| 422 Unprocessable | Valid format but business rule violation | Error with explanation |
| 429 Too Many Requests | Rate limit exceeded | Error + Retry-After header |

### Server Error Codes
| Code | Use When | Response Body |
|---|---|---|
| 500 Internal Server Error | Unexpected server failure | Generic error + request ID |
| 502 Bad Gateway | Upstream service returned invalid response | Generic error |
| 503 Service Unavailable | Server overloaded or under maintenance | Error + Retry-After header |
| 504 Gateway Timeout | Upstream service timed out | Generic error |

### Rules
- [ ] Never return 200 for an error — 200 means success, always
- [ ] Never return 500 for a client mistake — use 4xx codes
- [ ] Always return a body for error responses — include error code and message
- [ ] Include Retry-After header for 429 and 503 — tells client when to retry
- [ ] Return 404 for nonexistent resources, not an empty 200 — semantically correct

⚠️ WARNING: Returning 200 with an error body (e.g., `{"success": false}`) is an anti-pattern that breaks HTTP caching, client error handling, and monitoring.

---

## Pagination Rules

### Cursor-Based (Preferred)
```json
{
  "data": [...],
  "pagination": {
    "next_cursor": "eyJpZCI6MTAwfQ==",
    "has_more": true
  }
}
```

### Offset-Based (Simple Use Cases)
```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 150,
    "total_pages": 8
  }
}
```

### Rules
- [ ] Default page size: 20 items — reasonable for most UIs
- [ ] Maximum page size: 100 items — prevent abuse
- [ ] Always include pagination metadata in list responses — total, has_more, cursors
- [ ] Use cursor-based for large or frequently updated datasets — offset breaks with concurrent writes
- [ ] Use offset-based for small, stable datasets — simpler for simple UIs
- [ ] Return empty array for no results, not null or 404 — `{"data": [], "pagination": {...}}`

✅ DEFAULT: Use cursor-based pagination with a default page size of 20 and max of 100.

---

## Filtering, Sorting, and Search

### Filtering
```
GET /api/v1/users?status=active&role=admin&created_after=2024-01-01
```
- [ ] Use query parameters for filtering — not request body for GET
- [ ] Validate filter values server-side — reject invalid or unsupported filters
- [ ] Document all supported filters — not every field is filterable

### Sorting
```
GET /api/v1/users?sort=created_at&order=desc
```
- [ ] Support `sort` and `order` params — field name and direction
- [ ] Default sort: `created_at` descending — most recent first
- [ ] Validate sort field server-side — reject unsupported sort fields
- [ ] Only allow sorting on indexed columns — prevent slow queries

### Search
```
GET /api/v1/users?search=john
```
- [ ] Use a `search` or `q` parameter for full-text search — consistent naming
- [ ] Sanitize search input — prevent injection in search queries
- [ ] Limit search results — apply pagination to search results too

---

## API Versioning Strategy

- [ ] Version in URL path: `/api/v1/resource` — most explicit, easiest to route
- [ ] Major versions only (v1, v2) — minor changes don't break clients
- [ ] Support previous version for minimum 6 months after new version — migration time
- [ ] Deprecation warnings in response headers — `Deprecation: true`, `Sunset: date`
- [ ] Breaking changes ONLY in new major versions — never break existing clients
- [ ] Document migration guide between versions — what changed and how to update

### What Counts as a Breaking Change
- Removing a field from a response
- Changing a field's type
- Renaming a field
- Making an optional field required
- Changing error response format
- Removing an endpoint

### What Is NOT a Breaking Change
- Adding a new optional field to a response
- Adding a new endpoint
- Adding a new optional query parameter
- Adding a new error code

---

## OpenAPI/Swagger Specification

- [ ] OpenAPI spec exists before any endpoint is coded — API-first design
- [ ] Spec file lives in `docs/api/openapi.yaml` — standard location
- [ ] Spec is kept in sync with implementation — update spec with every API change
- [ ] All endpoints are documented in the spec — no undocumented endpoints
- [ ] Request/response schemas are defined — with validation rules
- [ ] Examples are included for every endpoint — aids understanding and testing
- [ ] Spec is validated on CI — `swagger-cli validate` or equivalent

---

## Sensitive API & Payment Security

Apps that handle money or expensive AI calls must never trust client-provided data for these operations.

- [ ] **Server-Side Price Lookup** — Never take a `price` or `amount` from the client request. Look up the price in your database or Stripe dashboard using a `productId` or `priceId`.
- [ ] **Webhook Signature Verification** — Always verify the signature of webhooks (Stripe, LemonSqueezy, etc.) before fulfilling an order.
- [ ] **Subscription Status Gate** — Validate subscription status server-side before allowing access to premium features or AI endpoints.
- [ ] **Backend-Only AI Calls** — Never call AI providers (OpenAI, Anthropic, Vertex) directly from the frontend. Proxy all calls through your backend to hide API keys and enforce rate limits.
- [ ] **No Client-Side Secrets** — Ensure no `STRIPE_SECRET_KEY` or `OPENAI_API_KEY` is prefixed with `NEXT_PUBLIC_` or `VITE_`.

⚠️ WARNING: A common hack is to intercept a checkout request and change the price to $0.01. If your backend doesn't re-verify the price, the hacker gets your product for free.

---

## 🛑 STOP: API Design Gate

Before implementing any endpoint:

1. [ ] Is the URL following REST naming conventions?
2. [ ] Has the request/response contract been written?
3. [ ] Are all possible HTTP status codes documented?
4. [ ] Is pagination implemented for list endpoints?
5. [ ] Is this endpoint in the OpenAPI spec?
6. [ ] Are input validation rules defined for all fields?

---

## Security Checkpoint

- [ ] Authentication required on all non-public endpoints — verified, no anonymous access
- [ ] Authorization checked — user can only access their own resources
- [ ] Input validated against contract — reject unexpected fields, enforce types/lengths
- [ ] Rate limiting applied — prevent abuse on all endpoints
- [ ] **Server-side price verification** — for all payment-related endpoints
- [ ] **Backend proxying** — for all sensitive 3rd-party API calls (AI, Email, Payments)
- [ ] CORS configured correctly — allowlisted origins only, not wildcard in production
- [ ] Response does not leak internal data — no debug info, no stack traces, no internal IDs
