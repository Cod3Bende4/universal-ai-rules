# 02-REQUIREMENTS.md
# PURPOSE: Scope definition, user story format, acceptance criteria, and requirements validation
# LOAD WHEN: Defining features, clarifying scope, writing user stories, or planning sprints

---

## Scope Definition Rules

### Before Writing Any Code
- [ ] Define the problem being solved in one sentence — no code without a clear problem
- [ ] Identify the target user/persona — who benefits from this feature?
- [ ] Define success criteria — how will you know this feature is complete?
- [ ] List explicit non-goals — what this feature deliberately does NOT do
- [ ] Identify dependencies — what other features/services must exist first?
- [ ] Estimate complexity (S/M/L/XL) — determines review rigor and testing depth

### Scope Validation Questions
- [ ] Can this be shipped incrementally? — prefer small, shippable increments
- [ ] Is there a simpler alternative that solves 80% of the problem? — build that first
- [ ] Are there edge cases that dramatically increase complexity? — defer or simplify
- [ ] Does this require changes to the data model? — flag for extra review
- [ ] Does this affect other features? — identify blast radius

✅ DEFAULT: When scope is ambiguous, build the smallest useful version first. Expand based on user feedback.

---

## User Story Format

### Template
```
AS A [user type/persona]
I WANT TO [action/capability]
SO THAT [business value/outcome]
```

### Rules
- [ ] Every feature must have at least one user story — no feature without a user
- [ ] Each story describes ONE capability — not a bundle of features
- [ ] The "so that" clause explains business value — not implementation details
- [ ] Stories are written from the user's perspective — not the developer's
- [ ] Stories are independent — not dependent on other stories for delivery

### Examples
```
✅ Good:
AS A registered user
I WANT TO reset my password via email
SO THAT I can regain access to my account when I forget my password

❌ Bad:
AS A developer
I WANT TO implement bcrypt hashing
SO THAT passwords are secure
```

---

## Acceptance Criteria Format

### Template (Given/When/Then)
```
GIVEN [precondition/context]
WHEN [action is performed]
THEN [expected outcome]
```

### Rules
- [ ] Every user story has at least 3 acceptance criteria — happy path + edge cases
- [ ] Each criterion is independently testable — can be verified in isolation
- [ ] Include at least one negative/error case — what happens when things go wrong
- [ ] Include boundary values — minimum, maximum, empty, null
- [ ] Criteria are specific and measurable — not "works correctly"
- [ ] Performance requirements are explicit — "responds within 200ms" not "is fast"

### Acceptance Criteria Checklist Per Story
- [ ] Happy path — the normal successful flow
- [ ] Empty/null input — what happens with no data?
- [ ] Invalid input — what happens with wrong data?
- [ ] Unauthorized access — what happens without permission?
- [ ] Concurrent access — what happens with simultaneous requests?
- [ ] Maximum load — what happens at the limit?
- [ ] Network failure — what happens when a dependency is down?

---

## Requirements Validation

### Before Marking Requirements as Complete
- [ ] All user stories have acceptance criteria — no story without criteria
- [ ] All acceptance criteria are testable — each can become a test case
- [ ] Stakeholders have reviewed and approved — documented approval
- [ ] Technical feasibility confirmed — no impossible requirements
- [ ] Dependencies identified and planned — nothing blocked at start
- [ ] Security implications reviewed — per core/security.md
- [ ] Data privacy impact assessed — GDPR/CCPA implications

### Requirements Red Flags
- [ ] "The system should be fast" — define specific latency targets
- [ ] "Handle all edge cases" — enumerate the specific edge cases
- [ ] "Similar to [competitor]" — specify exactly which aspects
- [ ] "Intuitive UI" — define specific UX requirements and flows
- [ ] "Secure" — specify which security controls are required
- [ ] "Scalable" — define specific load and growth targets

⚠️ WARNING: Ambiguous requirements produce ambiguous code. Never proceed with a requirement you cannot write a test for.

---

## Priority Framework

| Priority | Definition | SLA |
|---|---|---|
| P0 — Critical | System down, data loss, security breach | Fix immediately |
| P1 — High | Core feature broken, significant user impact | Fix within 24 hours |
| P2 — Medium | Feature degraded, workaround exists | Fix within 1 week |
| P3 — Low | Minor issue, cosmetic, nice-to-have | Fix within 1 month |
| P4 — Wishlist | Enhancement, no current impact | Backlog, no SLA |

- [ ] Every requirement has an assigned priority — no unprioritized work
- [ ] P0/P1 items are never deprioritized without explicit approval — critical is critical

---

## 🛑 STOP: Requirements Gate

Before moving to design or implementation:

1. [ ] Is the problem statement clear and agreed upon?
2. [ ] Are all user stories in the correct format with acceptance criteria?
3. [ ] Have edge cases and error scenarios been explicitly documented?
4. [ ] Are performance requirements quantified (latency, throughput, availability)?
5. [ ] Have security implications been reviewed?
6. [ ] Are all dependencies identified and their availability confirmed?
7. [ ] Is the scope small enough to ship in ≤2 weeks?
8. [ ] Has the user/stakeholder approved the requirements?

---

## Security Checkpoint

- [ ] Has the feature been assessed for data sensitivity? — classify data handled
- [ ] Are there authentication/authorization requirements? — document who can access what
- [ ] Does this feature handle user input? — plan validation strategy
- [ ] Does this feature store or transmit PII? — plan encryption and retention
- [ ] Does this feature interact with external systems? — plan secure communication
