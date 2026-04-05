# SECURITY.md
# PURPOSE: Non-negotiable security rules enforced in every AI session
# LOAD WHEN: Always — this file is loaded in every session without exception

---

## OWASP Top 10 Checklist

### A01 — Broken Access Control
- [ ] Every endpoint enforces authentication — no anonymous access to protected resources
- [ ] Every endpoint enforces authorization — check user role/permissions before action
- [ ] Use deny-by-default — explicitly grant access, never implicitly allow
- [ ] Disable directory listing on all web servers — prevents file enumeration
- [ ] Rate-limit all authentication and sensitive endpoints — prevents brute force
- [ ] Validate that the authenticated user owns the requested resource — prevents IDOR
- [ ] Log all access control failures — required for audit trail

### A02 — Cryptographic Failures
- [ ] Use TLS 1.2+ for all data in transit — no plaintext HTTP in production
- [ ] Use bcrypt/scrypt/argon2 for password hashing — never MD5/SHA1 for passwords
- [ ] Generate random values with cryptographically secure RNG — never Math.random() for security
- [ ] Never store encryption keys alongside encrypted data — separation of concerns
- [ ] Classify data by sensitivity — apply encryption proportional to classification
- [ ] Disable caching for responses containing sensitive data — prevents local leaks

### A03 — Injection
- [ ] Use parameterized queries for ALL database operations — prevents SQL injection
- [ ] Use ORM methods over raw queries — adds a layer of safety
- [ ] Validate and sanitize all user input at the boundary — before any processing
- [ ] Use allowlists for input validation over denylists — denylists are always incomplete
- [ ] Escape output for the target context (HTML, JS, SQL, OS) — prevents XSS/injection
- [ ] Never pass user input directly to system commands — use safe APIs or allowlists

### A04 — Insecure Design
- [ ] Threat model every new feature before implementation — identify attack surface
- [ ] Define trust boundaries explicitly — document where trusted/untrusted zones meet
- [ ] Limit resource consumption per user/tenant — prevents abuse
- [ ] Use secure design patterns (fail-safe, complete mediation, least privilege)
- [ ] Write abuse-case tests alongside functional tests — validate negative scenarios

### A05 — Security Misconfiguration
- [ ] Remove all default credentials before deployment — change every default password
- [ ] Disable unnecessary features, ports, services — minimize attack surface
- [ ] Send security headers on all responses (CSP, X-Frame-Options, HSTS) — prevents common attacks
- [ ] Review cloud/server permissions quarterly — drift causes vulnerabilities
- [ ] Disable detailed error messages in production — return generic messages to users

### A06 — Vulnerable Components
- [ ] Audit all dependencies at install time — `npm audit` / `pip audit` / equivalent
- [ ] **Dependency Gatekeeper**: Never assume a new dependency is safe. Explicitly scan any newly proposed dependency for known CVEs before adding it to `package.json` or `requirements.txt`.
- [ ] Use lock files always (package-lock.json, Pipfile.lock, etc.) — ensures reproducibility
- [ ] Never install packages from unverified sources — check publisher, stars, maintenance
- [ ] Remove unused dependencies immediately — reduces attack surface
- [ ] Subscribe to security advisories for critical dependencies — stay informed

### A07 — Authentication Failures
- [ ] Enforce minimum password complexity — 12+ chars, mixed case, numbers, symbols
- [ ] Implement account lockout after 5 failed attempts — prevents brute force
- [ ] Use multi-factor authentication for admin accounts — mandatory, not optional
- [ ] Never expose session tokens in URLs — use HTTP-only cookies or auth headers
- [ ] Invalidate sessions on logout, password change, and inactivity — prevents session fixation
- [ ] Generate new session IDs after authentication — prevents session fixation

### A08 — Data Integrity Failures
- [ ] Verify integrity of all downloaded dependencies — check checksums/signatures
- [ ] Use signed commits for production releases — ensures code provenance
- [ ] Validate CI/CD pipeline integrity — no unauthorized modifications
- [ ] Never deserialize untrusted data without validation — prevents RCE

### A09 — Logging & Monitoring Failures
- [ ] Log all authentication events (success and failure) — required for incident response
- [ ] Log all access control failures — detect probing attempts
- [ ] Never log passwords, tokens, PII, or credit card numbers — compliance requirement
- [ ] Include timestamp, user ID, action, resource, IP in every log entry — enables forensics
- [ ] Set up alerting for anomalous patterns — unusual login locations, volume spikes
- [ ] Ensure logs are tamper-evident — write-once storage or append-only logs

### A10 — Server-Side Request Forgery (SSRF)
- [ ] Validate and allowlist all outbound URLs — never let users specify arbitrary URLs
- [ ] Disable HTTP redirects in server-side HTTP clients — prevents redirect-based SSRF
- [ ] Block requests to internal/private IP ranges from user input — prevents internal scanning
- [ ] Use network-level segmentation — limit what backend services can reach

---

## Secrets Management

- [ ] Never hardcode secrets in source code — use environment variables or secret managers
- [ ] Never commit .env files to version control — add to .gitignore immediately
- [ ] Create a .env.example with placeholder values — documents required variables
- [ ] Use a secrets manager in production (AWS Secrets Manager, Vault, etc.) — not env vars in prod
- [ ] Rotate secrets on a defined schedule — 90 days maximum for production credentials
- [ ] Revoke and rotate immediately if a secret is exposed — treat as a P0 incident
- [ ] Never share secrets across environments (dev, staging, prod) — ensures blast radius is contained
- [ ] Audit secret access logs regularly — detect unauthorized access
- [ ] Scan for "Client-Side" secret exposure — check if secrets are prefixed with `NEXT_PUBLIC_`, `VITE_`, or `EXPO_PUBLIC_` unnecessarily.
- [ ] Verify `.env` is NOT tracked by Git — run `git ls-files .env` to confirm.

⚠️ WARNING: If you find a hardcoded secret in the codebase, stop everything and flag it to the user immediately. Do not proceed until it is removed and rotated.

---

## 🛑 Human-in-the-Loop Hard Stops (Destructive Actions)

The AI MUST NEVER autonomously execute destructive actions without explicit user consent.
- [ ] If instructed to delete a database, drop a table, or wipe infra, you must pause and ask: **"Are you absolutely sure?"**
- [ ] Do not execute the destruction until you receive the exact literal text response: **"YES"** from the user.
- [ ] This applies to cloud resource teardowns (`terraform destroy`), database truncations, and directory wiping (`rm -rf /` or similar critical paths).

---

## The "Vibe Coding" Security Axiom

**NEVER TRUST THE CLIENT.** Every price, user ID, role, subscription status, and rate limit counter must be validated or enforced server-side. If it exists only in the browser, mobile bundle, or request body, an attacker controls it.

- [ ] Does this action rely on a client-provided `price`, `role`, or `userId`? If so, look it up server-side.
- [ ] Is sensitive logic (like calculating discounts or checking subscription status) happening only in the UI/frontend? Move it to a secure backend/function.
- [ ] Is an API key (OpenAI, Stripe, SendGrid) exposed for direct calls from the client? Proxy these through your own backend.
- [ ] Are rate limits only enforced via `setTimeout` or UI state? Use Redis, database-based, or IP-based limits on the backend.

---

## Input Validation Rules

- [ ] Validate type, length, format, and range of every input — at the API boundary
- [ ] Use allowlists over denylists — specify what IS allowed, not what isn't
- [ ] Validate on the server side always — client-side validation is for UX only
- [ ] Reject unexpected fields in API requests — prevents mass assignment
- [ ] Sanitize file uploads — validate file type, size, and scan for malware
- [ ] Encode output based on context — HTML-encode for HTML, URL-encode for URLs, etc.

✅ DEFAULT: When unsure whether to validate an input, ALWAYS validate it. Over-validation is a minor performance cost; under-validation is a security breach.

---

## Secure Defaults Checklist

- [ ] Fail closed — deny access by default, require explicit grants
- [ ] Apply least privilege — give minimum permissions needed for the task
- [ ] Defence in depth — don't rely on a single security control
- [ ] Don't trust the client — validate everything server-side
- [ ] Secure by default — no security features should require opt-in
- [ ] Separate privileges — admin functions require separate authentication
- [ ] Minimize data exposure — return only the fields the client needs
- [ ] Use HTTPS everywhere — redirect HTTP to HTTPS, use HSTS

---

## 🛑 STOP: Security Gate

Before writing ANY code that touches authentication, authorization, user data, external APIs, file uploads, database queries, or system commands, answer ALL of these questions:

1. [ ] Have I validated all inputs at the boundary?
2. [ ] Am I using parameterized queries for all database operations?
3. [ ] Are all secrets loaded from environment variables or a secret manager?
4. [ ] Am I enforcing authentication on this endpoint?
5. [ ] Am I enforcing authorization (does this user have permission for this action)?
6. [ ] Am I logging security-relevant events without logging sensitive data?
7. [ ] Am I using HTTPS and secure headers?
8. [ ] Have I checked for injection vectors (SQL, XSS, command, LDAP)?
9. [ ] Am I handling errors without exposing internal details to the user?
10. [ ] Have I considered rate-limiting and budget protection for this feature?

🛑 CRITICAL AUDIT: Could a malicious user bypass this logic by manually calling the API or modifying the frontend bundle? (If "Yes," the design is insecure).

⚠️ WARNING: If ANY answer is NO or UNSURE, do NOT proceed. Fix the issue first, or flag it to the user with a specific recommendation.

✅ DEFAULT: When facing a security judgment call, always choose the more restrictive option.
