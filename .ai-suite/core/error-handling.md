# ERROR-HANDLING.md
# PURPOSE: Error taxonomy, logging rules, retry patterns, user-facing error guidelines
# LOAD WHEN: Writing code that can fail — API calls, DB queries, file I/O, external services, user input processing

---

## Error Taxonomy

### Classification Matrix
| Type | Recoverable? | User Visible? | Action |
|---|---|---|---|
| Validation Error | Yes | Yes | Return 400 with field-level errors |
| Authentication Error | Yes | Yes | Return 401, prompt re-login |
| Authorization Error | Yes | Yes | Return 403, explain missing permission |
| Not Found | Yes | Yes | Return 404 with resource type |
| Conflict / Duplicate | Yes | Yes | Return 409 with conflict details |
| Rate Limit | Yes | Yes | Return 429 with retry-after header |
| Business Logic Error | Yes | Yes | Return 422 with explanation |
| Network Timeout | Yes | No (retry first) | Retry with backoff, then surface |
| External Service Down | Yes | Partial | Degrade gracefully, show cached data |
| Database Connection Lost | Yes | No (retry first) | Retry connection, circuit break |
| Unexpected/Unknown Error | No | Generic only | Return 500, log full details, alert |
| Out of Memory | No | Generic only | Log, alert, restart service |
| Data Corruption | No | Generic only | Log, alert, halt affected operations |

### Rules
- [ ] Classify every error before handling it — never catch-all without classification
- [ ] Expected errors get specific handling — each type has its own catch block
- [ ] Unexpected errors get generic handling — catch, log, return 500
- [ ] Never swallow errors silently — every catch block must log or re-throw
- [ ] Never use exceptions for control flow — if/else for expected conditions

---

## Error Handling by Layer

### UI / Frontend Layer
- [ ] Show user-friendly error messages — never raw error objects or codes
- [ ] Provide a clear next action — "Try again", "Contact support", "Check your input"
- [ ] Maintain UI state on error — don't clear form data on validation failure
- [ ] Show loading states to prevent duplicate submissions — disable buttons during requests
- [ ] Handle network errors separately from API errors — different UX for each
- [ ] Display field-level validation errors inline — not just a top-level banner

### API / Controller Layer
- [ ] Return consistent error response format for ALL errors:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable description",
    "details": [
      { "field": "email", "reason": "Invalid email format" }
    ],
    "requestId": "uuid-for-tracing"
  }
}
```
- [ ] Map internal errors to appropriate HTTP status codes — see classification matrix
- [ ] Include a request ID in every error response — enables log correlation
- [ ] Never return stack traces in production — replace with generic message
- [ ] Validate request body before processing — fail fast with 400

### Service / Business Logic Layer
- [ ] Throw typed/custom errors — not generic Error("something went wrong")
- [ ] Include context in errors — what operation failed, what entity, what ID
- [ ] Use error codes, not just messages — codes are machine-parseable
- [ ] Document all possible errors a function can throw — in docstring/JSDoc
- [ ] Prefer Result types over exceptions where language supports it — Rust, Go patterns

### Database Layer
- [ ] Handle connection failures with retry logic — transient failures are common
- [ ] Handle constraint violations with specific errors — unique, foreign key, not null
- [ ] Handle deadlocks with retry — limited retries with backoff
- [ ] Wrap database errors — never expose raw DB error messages to upper layers
- [ ] Use transactions for multi-step operations — rollback on any failure

### External Service Layer
- [ ] Set timeouts on all external calls — never wait indefinitely
- [ ] Implement circuit breaker pattern — stop calling a service that is consistently failing
- [ ] Have fallback behavior — cached data, default values, or degraded mode
- [ ] Log the full external error but return a sanitized version upstream — security

---

## Logging Rules

### What to Log
- [ ] Timestamp (ISO 8601), log level, service name, request ID — every log line
- [ ] Error class/type, error message, stack trace (non-production) — for debugging
- [ ] Operation that failed, entity type, entity ID — for context
- [ ] User ID (if authenticated) — for audit trail
- [ ] Duration of failed operation — for performance analysis

### What NEVER to Log
- [ ] Passwords or password hashes — never, under any circumstances
- [ ] API keys, tokens, or secrets — never, under any circumstances
- [ ] Credit card numbers or financial data — PCI compliance
- [ ] Social Security Numbers or government IDs — PII compliance
- [ ] Full request bodies containing user data — log only non-sensitive fields
- [ ] Health data or biometric data — HIPAA/GDPR compliance

⚠️ WARNING: If you are uncertain whether data is sensitive, DO NOT log it. Ask the user first.

### Log Levels
| Level | Use For | Example |
|---|---|---|
| ERROR | Operation failed, requires attention | DB connection lost, payment failed |
| WARN | Unexpected but handled condition | Rate limit approached, retry succeeded |
| INFO | Significant business events | User registered, order placed |
| DEBUG | Developer troubleshooting data | Function inputs/outputs, query plans |

- [ ] Production runs at INFO level — DEBUG only in development
- [ ] Every ERROR log must trigger an alert — configure alerting system
- [ ] Use structured logging (JSON) — enables machine parsing and search

---

## Retry and Backoff Rules

### When to Retry
- [ ] Network timeouts — transient, likely to succeed on retry
- [ ] HTTP 429 (Rate Limited) — respect Retry-After header
- [ ] HTTP 503 (Service Unavailable) — temporary outage
- [ ] Database connection failures — transient connection issues
- [ ] DNS resolution failures — temporary network issues

### When NOT to Retry
- [ ] HTTP 400 (Bad Request) — request is invalid, retrying won't fix it
- [ ] HTTP 401/403 (Auth failures) — credentials are wrong, retrying won't fix it
- [ ] HTTP 404 (Not Found) — resource doesn't exist
- [ ] HTTP 409 (Conflict) — requires user intervention
- [ ] Validation errors — fix the input first
- [ ] Business logic errors — the operation is intentionally rejected

### Backoff Strategy
```
Attempt 1: wait 100ms
Attempt 2: wait 200ms
Attempt 3: wait 400ms
Attempt 4: wait 800ms
Attempt 5: wait 1600ms (max)
```
- [ ] Use exponential backoff — doubles each attempt
- [ ] Add jitter (random 0-100ms) — prevents thundering herd
- [ ] Set a max retry count (default: 3) — prevents infinite loops
- [ ] Set a max total timeout (default: 30 seconds) — prevents indefinite blocking
- [ ] Log each retry attempt — include attempt number and delay

✅ DEFAULT: Max 3 retries with exponential backoff starting at 100ms. Override only with explicit justification.

---

## Graceful Degradation Patterns

- [ ] Cache last-known-good data — serve stale data over no data when safe
- [ ] Feature flags for non-critical features — disable gracefully when dependencies fail
- [ ] Queue operations for later retry — if the operation is not time-sensitive
- [ ] Provide read-only mode — when write services are down
- [ ] Show partial results — when some Data sources fail but others succeed
- [ ] Health check endpoints — enable load balancers to route around failures

---

## User-Facing Error Messages

### Rules
- [ ] Never show stack traces to users — security risk and poor UX
- [ ] Never show database error messages — exposes schema information
- [ ] Never show internal service names — exposes architecture
- [ ] Always suggest a next step — what can the user do about it?
- [ ] Use plain language — no technical jargon
- [ ] Include a support reference (request ID) — enables support team to investigate

### Templates
| Scenario | Message Template |
|---|---|
| Validation error | "Please check your input: [specific field issue]" |
| Auth required | "Please sign in to continue" |
| No permission | "You don't have permission to [action]. Contact your admin." |
| Not found | "We couldn't find that [resource]. It may have been removed." |
| Rate limited | "You're doing that too fast. Please wait a moment and try again." |
| Server error | "Something went wrong on our end. Please try again. If this persists, contact support with reference [requestId]." |
| Service down | "This feature is temporarily unavailable. We're working on it." |

---

## 🛑 STOP: Error Handling Gate

Before completing any code that involves error paths:

1. [ ] Is every possible error classified (expected/unexpected, recoverable/fatal)?
2. [ ] Does every catch block either handle, re-throw, or log — never swallow?
3. [ ] Are all user-facing error messages free of technical details?
4. [ ] Are all log entries free of PII/secrets?
5. [ ] Are retry-able operations using backoff with max retries?
6. [ ] Is there a circuit breaker for external service calls?
7. [ ] Does the API return consistent error response format?
8. [ ] Are there fallback behaviors for non-critical feature failures?

✅ DEFAULT: When unsure how to handle an error, log it at ERROR level and return a generic 500 to the user. Never fail silently.
