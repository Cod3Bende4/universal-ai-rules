# 08-TESTING.md
# PURPOSE: Testing pyramid, naming conventions, coverage gates, flaky test policy, security testing
# LOAD WHEN: Writing tests, fixing tests, setting up test infrastructure, or reviewing test coverage

---

## Testing Pyramid

### Ratio Guidance
```
        /‾‾‾‾‾‾\
       /  E2E   \        ~5-10% of tests — slow, expensive, high confidence
      /  (few)   \
     /────────────\
    / Integration  \      ~20-30% of tests — moderate speed, verify boundaries
   /  (moderate)    \
  /──────────────────\
 /     Unit Tests     \   ~60-70% of tests — fast, cheap, high coverage
/  (the foundation)    \
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
```

### Rules
- [ ] Unit tests are the majority — fast, deterministic, test logic in isolation
- [ ] Integration tests verify boundaries — DB queries, API calls, service interactions
- [ ] E2E tests cover critical user flows — login, checkout, core features
- [ ] No test type replaces another — each catches different bugs
- [ ] Run unit tests on every commit — fast feedback loop
- [ ] Run integration tests on every PR — verify before merge
- [ ] Run E2E tests before deployment — catch regressions in full flow

---

## What MUST Have a Unit Test

- [ ] All pure business logic functions — calculations, transformations, validations
- [ ] All utility/helper functions — used widely, high impact if broken
- [ ] All input validation functions — verify accept/reject behavior
- [ ] All data transformation functions — serialization, mapping, formatting
- [ ] All conditional branches — each if/else path exercised
- [ ] All error handling paths — verify correct error type and message
- [ ] Edge cases: empty input, null, boundary values, overflow — where bugs hide
- [ ] Regular expressions — test match and non-match cases

### What Does NOT Need a Unit Test
- [ ] Framework boilerplate — constructors that just assign properties
- [ ] Direct delegation — function that calls exactly one other function with same args
- [ ] Third-party library behavior — the library has its own tests
- [ ] Constants and configuration — static values don't need testing

---

## What MUST Have an Integration Test

- [ ] All database queries — verify SQL works with real database
- [ ] All external API calls — verify request format and response handling
- [ ] All authentication flows — login, logout, session management, token refresh
- [ ] All authorization checks — verify access control with different roles
- [ ] All file upload/download operations — verify storage integration
- [ ] All message queue producers/consumers — verify message format and handling
- [ ] All cache interactions — verify cache hit/miss/invalidation behavior

---

## Test Naming Convention

### Format: Given_When_Then
```
describe('UserService.createUser')
  it('given valid email and password, when creating user, then returns user with ID')
  it('given duplicate email, when creating user, then throws DuplicateEmailError')
  it('given missing password, when creating user, then throws ValidationError')
```

### Rules
- [ ] Test name describes the scenario, not the implementation — what, not how
- [ ] Start with the precondition (Given) — sets up context
- [ ] Include the action (When) — what operation is being tested
- [ ] End with the expected outcome (Then) — what should happen
- [ ] Use natural language — readable by non-developers
- [ ] Group related tests with describe blocks — by function or feature
- [ ] One assertion per test (ideal) — max 3 closely related assertions

---

## Test Structure (AAA Pattern)

```javascript
it('given valid input, when processing, then returns expected result', () => {
  // Arrange — set up test data and dependencies
  const input = { email: 'test@example.com', name: 'Test User' };
  const mockRepo = { create: vi.fn().mockResolvedValue({ id: '123', ...input }) };
  const service = new UserService(mockRepo);

  // Act — execute the operation being tested
  const result = await service.createUser(input);

  // Assert — verify the outcome
  expect(result.id).toBe('123');
  expect(result.email).toBe('test@example.com');
  expect(mockRepo.create).toHaveBeenCalledWith(input);
});
```

### Rules
- [ ] Arrange, Act, Assert sections are clearly separated — with comments if needed
- [ ] Arrange: create only the data needed for THIS test — no shared global state
- [ ] Act: call exactly ONE function/method — single operation under test
- [ ] Assert: verify outcome, not implementation — check results, not how it was done
- [ ] No logic in tests (no if/else, no loops) — tests are linear
- [ ] No try/catch in tests — let the test framework handle failures
- [ ] Independent tests — no test depends on another test's result or order

⚠️ WARNING: Tests that share mutable state are a guaranteed source of flaky tests. Each test creates its own data.

---

## Coverage Gates

### Minimum Thresholds
| Layer | Line Coverage | Branch Coverage |
|---|---|---|
| Business Logic / Services | 90% | 85% |
| Utilities / Helpers | 95% | 90% |
| Controllers / Routes | 80% | 75% |
| Data Access / Repositories | 80% | 75% |
| Overall Project | 80% | 75% |

### Rules
- [ ] Coverage is measured and reported on every PR — no blind spots
- [ ] Coverage cannot decrease — new code must meet or exceed current coverage
- [ ] 100% coverage is NOT the goal — focus on meaningful tests, not gaming metrics
- [ ] Uncovered code is reviewed manually — is it untestable or just untested?
- [ ] Coverage report excludes generated code, test files, and config — accurate measurement

✅ DEFAULT: Target 80% overall line coverage. Increase gradually. Never sacrifice test quality for coverage numbers.

---

## Flaky Test Policy — Zero Tolerance

### Definition
A flaky test is one that passes and fails on the same code without changes.

### Rules
- [ ] Flaky tests are fixed within 24 hours or quarantined — never left in the suite
- [ ] Quarantined tests are tracked with issue tickets — not forgotten
- [ ] Max quarantine period: 1 week — then fix or delete
- [ ] Root cause analysis required for every flaky test — document what caused it
- [ ] No sleep/delay in tests — use polling, waitFor, or deterministic approaches
- [ ] No dependency on system time — use mock clocks
- [ ] No dependency on execution order — tests run in any order
- [ ] No dependency on external services — use mocks or in-memory alternatives

### Common Flaky Test Causes
| Cause | Fix |
|---|---|
| Timing/race conditions | Use deterministic waits (waitFor, polling) |
| Shared mutable state | Isolate test data, reset between tests |
| External service dependency | Use mocks or test containers |
| System time dependency | Inject/mock the clock |
| Random data without seed | Use fixed seed or deterministic data |
| Port conflicts | Use random available ports |
| File system race conditions | Use temp directories per test |

---

## Security Testing Checklist

- [ ] Test authentication bypass — access protected endpoints without auth tokens
- [ ] Test authorization bypass — access resources belonging to other users
- [ ] Test SQL injection — send `' OR '1'='1` in all string inputs
- [ ] Test XSS injection — send `<script>alert('xss')</script>` in all text fields
- [ ] Test command injection — send `; rm -rf /` in inputs that touch system commands
- [ ] Test boundary values — max int, empty string, null, extremely long strings
- [ ] Test rate limiting — send 100+ rapid requests to auth endpoints
- [ ] Test file upload restrictions — upload .exe, .php, oversized files
- [ ] Test CORS — requests from non-allowlisted origins should be blocked
- [ ] Test session management — verify sessions expire and tokens can be revoked

---

## Mock and Stub Rules

- [ ] Mock at service/module boundaries — not internal functions
- [ ] Prefer fakes over mocks for complex dependencies — in-memory DB, test email server
- [ ] Reset all mocks between tests — prevent state leakage
- [ ] Verify mock interactions only when the interaction IS the test — not for every call
- [ ] Never mock what you don't own — wrap third-party libraries, mock the wrapper
- [ ] Document mock behavior that differs from real implementation — avoid false confidence

---

## 🛑 STOP: Testing Gate

Before submitting code with tests:

1. [ ] Does every business logic function have at least one unit test?
2. [ ] Does every test have a clear Given_When_Then name?
3. [ ] Are all tests independent — no shared mutable state?
4. [ ] Does the test suite run in under 5 minutes locally?
5. [ ] Is coverage meeting the minimum thresholds?
6. [ ] Are there no flaky tests in the suite?
7. [ ] Have security test cases been included for auth/input handling?
8. [ ] Do integration tests use realistic data, not just happy path?
9. [ ] Are mocks reset between tests?
10. [ ] Can the full test suite run with a single command?

---

## Security Checkpoint

- [ ] Tests include authentication bypass attempts — verify 401 responses
- [ ] Tests include authorization bypass attempts — verify 403 responses
- [ ] Tests include injection payloads — SQL, XSS, command injection
- [ ] Test data does not contain real PII — use fake/generated data
- [ ] Test credentials are not production credentials — separate test secrets
- [ ] Test database is separate from production — isolated environment
