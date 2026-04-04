# 07-BACKEND.md
# PURPOSE: Service layer design, dependency injection, config management, and backend patterns
# LOAD WHEN: Writing server-side application code, business logic, or backend services

---

## Service Layer Design

### Layer Architecture
```
Controller/Route → Service → Repository → Database
         ↑              ↑           ↑
     Validates      Business     Data
      input         logic       access
```

### Rules
- [ ] Controllers handle HTTP concerns only — parse request, call service, send response
- [ ] Services contain business logic only — no HTTP objects, no SQL queries
- [ ] Repositories handle data access only — SQL, ORM, external API calls
- [ ] Each layer depends only on the layer below — no skipping layers
- [ ] Interfaces define layer boundaries — program to interfaces, not implementations
- [ ] No circular dependencies between layers — strict unidirectional flow

### Controller Rules
- [ ] Parse and validate request input — whitelist allowed fields, enforce types
- [ ] Call one service method — orchestration belongs in services, not controllers
- [ ] Map service result to HTTP response — status code, headers, body
- [ ] Handle service errors and map to HTTP errors — translate internal errors
- [ ] Max 15 lines per controller method — if longer, extract middleware or service logic
- [ ] No database calls in controllers — always go through service → repository

### Service Rules
- [ ] Accept plain objects/DTOs — not HTTP Request objects
- [ ] Return plain objects/DTOs — not HTTP Response objects
- [ ] Throw typed errors — not generic Error("message")
- [ ] One public method per business operation — `createUser`, `updateOrder`
- [ ] Transaction management lives in services — wrap multi-repo operations
- [ ] Log business events in services — not in controllers or repositories
- [ ] Services can call other services — but avoid deep chains (max 2 levels)

### Repository Rules
- [ ] One repository per data source/entity — `UserRepository`, `OrderRepository`
- [ ] Methods map to data operations — `findById`, `findAll`, `create`, `update`, `delete`
- [ ] Accept and return domain objects — not raw SQL rows
- [ ] Encapsulate query complexity — callers don't know about SQL/ORM internals
- [ ] No business logic in repositories — no if/else based on business rules

---

## Dependency Injection

- [ ] Inject dependencies through constructors — not imported singletons
- [ ] Use a DI container for complex applications — manual DI for simple projects
- [ ] Dependencies are interfaces, not concrete classes — enables testing and swapping
- [ ] No `new` inside business logic — create instances at the composition root
- [ ] Configuration is a dependency — inject it, don't read env vars everywhere

### Composition Root
```
// ONE place where all dependencies are wired together
const db = new Database(config.db);
const userRepo = new UserRepository(db);
const emailService = new EmailService(config.email);
const userService = new UserService(userRepo, emailService);
const userController = new UserController(userService);
```

✅ DEFAULT: For small projects (<5 services), use manual dependency injection. For larger projects, use a DI container (tsyringe, InversifyJS, or equivalent).

---

## Configuration Management

### Rules
- [ ] All config values come from environment variables — never hardcoded
- [ ] Config is loaded once at startup — not read on every request
- [ ] Config is validated at startup — fail fast if required values are missing
- [ ] Config values are typed — parse strings to numbers, booleans, URLs at load time
- [ ] Different config files for different environments — dev, staging, production
- [ ] Secrets are separate from non-secret config — use secrets manager for production

### Config Validation Template
```javascript
const config = {
  port: requireEnv('PORT', { type: 'number', default: 3000 }),
  dbUrl: requireEnv('DATABASE_URL', { type: 'string', required: true }),
  jwtSecret: requireEnv('JWT_SECRET', { type: 'string', required: true, minLength: 32 }),
  logLevel: requireEnv('LOG_LEVEL', { type: 'enum', values: ['debug','info','warn','error'], default: 'info' }),
};
// If any required value is missing, throw immediately — don't start the server
```

- [ ] Every env variable has a type and a required/default annotation — no ambiguity
- [ ] Required variables throw at startup if missing — not at first use
- [ ] Sensitive config is never logged — even at debug level

⚠️ WARNING: Never log your full config at startup. Log config keys, not values. Secrets must never appear in logs.

---

## Middleware / Cross-Cutting Concerns

### Order (applies to most frameworks)
```
1. Request ID injection — trace every request
2. Logging (request start) — method, path, timestamp
3. Security headers — CSP, CORS, HSTS
4. Rate limiting — before any processing
5. Authentication — verify identity
6. Authorization — verify permission
7. Body parsing — parse JSON, form data
8. Input validation — validate against schema
9. Route handler — business logic
10. Error handling — catch-all error formatter
11. Logging (request end) — status, duration
```

### Rules
- [ ] Request ID generated for every request — UUID, present in all logs and responses
- [ ] Request/response logging at INFO level — method, path, status, duration
- [ ] Error handling middleware is the LAST middleware — catches everything
- [ ] Authentication runs before authorization — identity before permission
- [ ] Rate limiting runs before authentication — prevents brute force
- [ ] Body size limits configured — prevent memory exhaustion attacks

---

## Background Jobs & Async Processing

### Rules
- [ ] Long-running operations go to background queues — don't block HTTP requests
- [ ] Jobs are idempotent — safe to retry without side effects
- [ ] Jobs have a maximum retry count — prevent infinite retry loops
- [ ] Jobs have a timeout — prevent zombie jobs
- [ ] Failed jobs go to a dead-letter queue — for manual review
- [ ] Critical jobs have alerting on failure — don't silently fail
- [ ] Job status is trackable — pending, running, completed, failed

### Queue Safety
- [ ] Message acknowledgment after processing — not before
- [ ] At-least-once delivery assumed — design for duplicate messages
- [ ] Poison message handling — don't let one bad message block the queue
- [ ] Queue depth monitoring — alert when backlog grows

✅ DEFAULT: If a task takes >5 seconds, move it to a background job. If a task takes >30 seconds, break it into smaller subtasks.

---

## Health Checks

- [ ] `/health` endpoint — returns 200 if service is running
- [ ] `/health/ready` endpoint — returns 200 if service can handle requests (DB connected, etc.)
- [ ] `/health/live` endpoint — returns 200 if process is alive (for Kubernetes liveness)
- [ ] Health checks are unauthenticated — load balancers need to access them
- [ ] Health checks don't perform heavy operations — fast response, no DB queries
- [ ] Readiness checks verify all critical dependencies — DB, cache, external services

---

## 🛑 STOP: Backend Gate

Before submitting backend code:

1. [ ] Is business logic in services, not controllers or repositories?
2. [ ] Are all dependencies injected, not imported as singletons?
3. [ ] Is config validated at startup with fail-fast behavior?
4. [ ] Is there error handling middleware catching all unhandled errors?
5. [ ] Are background jobs idempotent with retry limits?
6. [ ] Are health check endpoints implemented?
7. [ ] Is request logging in place with request IDs?

---

## Security Checkpoint

- [ ] Authentication middleware on all non-public routes — no anonymous access to protected resources
- [ ] Authorization checked per operation — not just per route
- [ ] Input validation on all endpoints — reject unexpected fields and invalid types
- [ ] Output sanitized — no internal data leaking in responses
- [ ] Rate limiting on all endpoints — at minimum on auth endpoints
- [ ] CORS configured with allowlisted origins — no wildcard in production
- [ ] Request body size limited — prevent memory exhaustion
- [ ] File upload validation — type, size, and content scanning
