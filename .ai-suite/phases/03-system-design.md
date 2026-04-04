# 03-SYSTEM-DESIGN.md
# PURPOSE: Architecture decisions, scalability planning, component boundaries, and design patterns
# LOAD WHEN: Designing system architecture, making major technical decisions, or adding new services/modules

---

## Architecture Decision Record (ADR) Template

Before making ANY major design choice, fill out this template:

```markdown
# ADR-[number]: [Decision Title]

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-XXX]

## Context
[What is the problem or situation that requires a decision?]

## Decision
[What is the decision that was made?]

## Alternatives Considered
| Option | Pros | Cons |
|---|---|---|
| Option A | ... | ... |
| Option B | ... | ... |

## Consequences
- Positive: [benefits]
- Negative: [tradeoffs]
- Risks: [potential problems]

## Review Date
[When should this decision be revisited?]
```

### ADR Rules
- [ ] Create an ADR for every decision that would be hard to reverse — databases, frameworks, protocols
- [ ] Store ADRs in `docs/adr/` directory — numbered sequentially (ADR-001, ADR-002)
- [ ] Never delete superseded ADRs — mark as deprecated, link to replacement
- [ ] Include at least 2 alternatives considered — justify why they were rejected
- [ ] Set a review date — revisit in 6-12 months or when conditions change

⚠️ WARNING: Choosing a database, framework, message queue, or cloud provider without an ADR is a critical process failure.

---

## Scalability Questions

Answer these BEFORE designing the architecture:

### Traffic & Load
- [ ] What is the expected number of users at launch? — be specific
- [ ] What is the expected peak traffic (requests/second)? — identify burst patterns
- [ ] What is the growth trajectory? — 10x in 6 months vs 10x in 3 years
- [ ] Are there predictable traffic spikes? — time of day, events, campaigns
- [ ] What is the read-to-write ratio? — determines caching and replication strategy

### Data Volume
- [ ] How much data will be stored in year one? — GB, TB, PB?
- [ ] What is the data growth rate? — per day/month
- [ ] What data must be queryable in real-time? — determines storage tier
- [ ] What data can be archived or deleted? — define retention policy
- [ ] Are there compliance requirements for data residency? — EU, US, etc.

### Availability
- [ ] What is the availability target? — 99.9% = 8.7 hours downtime/year
- [ ] What is the acceptable recovery time (RTO)? — minutes or hours?
- [ ] What is the acceptable data loss (RPO)? — zero or can lose last N minutes?
- [ ] Which components are critical vs degradable? — prioritize uptime

✅ DEFAULT: For new projects without specific requirements, design for 1000 concurrent users, 99.5% uptime, and 100GB data. Scale when approaching 70% of these limits.

---

## Component Boundary Rules

### When to Create a Separate Module
- [ ] The component has a distinct domain responsibility — auth, billing, notifications
- [ ] The component has different scaling requirements — API vs background worker
- [ ] The component has different deployment cadence — frontend vs backend
- [ ] The component has different team ownership — clear organizational boundary
- [ ] The component's failure should NOT cascade — isolation protects other components

### When to Keep Components Together
- [ ] They share the same data model tightly — splitting causes excessive cross-service calls
- [ ] They are always deployed together — separate services with locked deployment is overhead
- [ ] The total codebase is under 10,000 lines — microservices for small projects is overengineering
- [ ] There is only one developer/team — service boundaries add operational complexity

✅ DEFAULT: Start as a modular monolith. Extract services only when a specific scaling or organizational need demands it.

---

## Data Flow Mapping

### Required for Every New Feature
- [ ] Draw a data flow diagram before implementation — showing all systems involved
- [ ] Identify all data entry points — APIs, webhooks, file uploads, scheduled jobs
- [ ] Identify all data storage points — databases, caches, queues, file systems
- [ ] Identify all data exit points — API responses, emails, exports, third-party calls
- [ ] Mark trust boundaries — where does trusted data become untrusted?
- [ ] Mark encryption points — where is data encrypted/decrypted?

### Data Flow Description Format
```
[Source] → [Transport] → [Processing] → [Storage/Destination]
Example:
User Browser → HTTPS/REST → API Gateway → Auth Service → PostgreSQL
```

---

## Over-Engineering Red Flags

🛑 STOP and reconsider if you find yourself doing any of these for a small/medium system:

- [ ] Adding a message queue before you have 100 requests/second — use direct calls
- [ ] Using microservices with fewer than 3 developers — use a modular monolith
- [ ] Adding a caching layer before measuring actual latency — optimize when data shows need
- [ ] Building a custom framework instead of using an existing one — NIH syndrome
- [ ] Implementing CQRS/Event Sourcing for a CRUD application — complex pattern for simple needs
- [ ] Adding GraphQL for internal-only APIs with one consumer — REST is simpler
- [ ] Creating abstraction layers "for future flexibility" — YAGNI (You Aren't Gonna Need It)
- [ ] Using NoSQL because "it scales better" without a specific schema-less need — SQL is usually right
- [ ] Kubernetes for a single-service deployment — use a PaaS instead
- [ ] Distributed transactions across services — redesign boundaries instead

⚠️ WARNING: The most expensive architecture mistake is building for scale you don't have. Start simple, measure, then optimize.

---

## Design Patterns — When to Use

| Pattern | Use When | Don't Use When |
|---|---|---|
| Repository | Abstracting data access | Simple CRUD with ORM |
| Strategy | Multiple interchangeable algorithms | Only one algorithm exists today |
| Observer/Event | Loose coupling between components | Only 1-2 subscribers |
| Factory | Complex object creation logic | Simple constructor is sufficient |
| Middleware/Pipeline | Cross-cutting concerns (logging, auth) | Only one concern |
| Circuit Breaker | Calling unreliable external services | Calling local functions |
| Saga | Distributed multi-step transactions | Single-database transactions |
| CQRS | Read/write models diverge significantly | Read/write models are identical |

---

## 🛑 STOP: Design Gate

Before proceeding to implementation:

1. [ ] Is there an ADR for every major technical decision?
2. [ ] Have scalability questions been answered with specific numbers?
3. [ ] Are component boundaries justified (not arbitrary)?
4. [ ] Has a data flow diagram been created?
5. [ ] Have over-engineering red flags been checked?
6. [ ] Is the design the SIMPLEST solution that meets requirements?

---

## Security Checkpoint

- [ ] Are trust boundaries clearly defined? — where does data cross from untrusted to trusted?
- [ ] Is data encrypted at rest and in transit? — identified where encryption is needed
- [ ] Are authentication and authorization boundaries defined? — which service enforces what?
- [ ] Is the blast radius of a component failure limited? — isolation between components
- [ ] Are external service integrations going through a controlled gateway? — not direct calls
