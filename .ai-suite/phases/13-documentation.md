# 13-DOCUMENTATION.md
# PURPOSE: README standards, API docs, runbooks, ADRs, changelog, and inline documentation rules
# LOAD WHEN: Writing documentation, creating runbooks, updating README, or documenting architecture

---

## Documentation Types

| Type | Audience | Update Frequency | Location |
|---|---|---|---|
| README | New developers | Every major feature | `README.md` (root) |
| API Docs | API consumers | Every API change | `docs/api/` |
| Architecture Docs | Dev team, architects | Major design changes | `docs/architecture/` |
| ADRs | Dev team, future devs | Each major decision | `docs/adr/` |
| Runbooks | On-call / Ops | Each new alert or procedure | `docs/runbooks/` |
| Changelog | Users, devs | Every release | `CHANGELOG.md` |
| Inline Code Docs | Developers | With code changes | In source files |
| Onboarding Guide | New team members | Quarterly review | `docs/onboarding.md` |

---

## README.md Standards

### Required Sections
```markdown
# Project Name

One-sentence description of what this project does and who it's for.

## Quick Start

Step-by-step instructions to get the project running locally.
Must work for a new developer in <10 minutes.

## Prerequisites

- Runtime: Node.js 20.x
- Database: PostgreSQL 15+
- Other: Redis 7+

## Installation

    git clone [repo]
    cp .env.example .env
    npm install
    npm run db:migrate
    npm run dev

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| DATABASE_URL | Yes | - | PostgreSQL connection string |
| JWT_SECRET | Yes | - | Auth token signing secret |
| PORT | No | 3000 | API server port |

## Available Scripts

| Script | Description |
|---|---|
| npm run dev | Start development server |
| npm run test | Run test suite |
| npm run build | Build for production |
| npm run lint | Run linter |

## Architecture Overview

Brief description + link to detailed docs.

## Contributing

Link to CONTRIBUTING.md or brief guidelines.

## License

[License type]
```

### README Rules
- [ ] Quick Start section works end-to-end — tested by a fresh developer
- [ ] All environment variables documented — with type, required/optional, default
- [ ] All available scripts documented — with clear descriptions
- [ ] Prerequisites list specific versions — not "recent version of Node"
- [ ] No dead links — verify all links work
- [ ] Updated when features or setup change — README is never "done"

⚠️ WARNING: A README that doesn't work is worse than no README. Test the Quick Start steps every month.

---

## API Documentation

### Rules
- [ ] OpenAPI/Swagger spec exists for all endpoints — machine-readable, always current
- [ ] Every endpoint documented: method, path, description, params, responses — no gaps
- [ ] Request/response examples included — copy-paste ready
- [ ] Authentication requirements documented — per endpoint
- [ ] Error responses documented — all possible error codes
- [ ] Rate limits documented — per endpoint if different
- [ ] API versioning strategy documented — how versions are handled
- [ ] Changelog for API changes — what changed between versions

### API Doc Location
- [ ] OpenAPI spec: `docs/api/openapi.yaml` — canonical source of truth
- [ ] Generated docs hosted (Swagger UI, Redoc) — interactive and browsable
- [ ] Spec validated in CI — catch spec errors before merge

---

## Runbooks

### Runbook Template
```markdown
# Runbook: [Alert/Incident Name]

## Severity: [P0/P1/P2/P3]

## Symptoms
- What the alert/user reports
- What metrics show

## Diagnosis Steps
1. Specific check to perform
2. What to look for in logs
3. Query to run / dashboard to check

## Resolution Steps
1. Specific action to take
2. Command to run or configuration to change
3. How to verify the fix worked

## Escalation
- When to escalate and to whom
- Contact information

## Post-Incident
- What to document
- Retrospective required for P0/P1
```

### Runbook Rules
- [ ] Every alert has a linked runbook — no alert without resolution guidance
- [ ] Runbooks are tested regularly — procedures verified quarterly
- [ ] Runbooks use specific commands — not "fix the thing"
- [ ] Runbooks include escalation paths — when to involve others
- [ ] Runbooks updated after every incident — lessons learned incorporated

---

## Architecture Decision Records (ADRs)

### Location: `docs/adr/`
### Filename: `ADR-{number}-{title}.md` (e.g., `ADR-001-use-postgresql.md`)

### Rules
- [ ] ADR created for every major technical decision — see list below
- [ ] ADRs are immutable after acceptance — add new ADRs to supersede, don't edit old ones
- [ ] ADRs include alternatives considered — justify the choice
- [ ] ADRs include consequences — positive, negative, and risks
- [ ] ADRs are linked from architecture docs — discoverable

### Decisions That Require an ADR
- Database selection or major schema decision
- Framework or language selection
- Authentication/authorization strategy
- API design pattern (REST, GraphQL, gRPC)
- Deployment strategy (containers, serverless, PaaS)
- Third-party service integration (payment, email, monitoring)
- Data migration strategy
- Caching strategy
- Message queue / event system adoption
- Breaking changes to public API

---

## Changelog

### Format (Keep a Changelog Standard)
```markdown
# Changelog

## [Unreleased]

### Added
- New feature description

### Changed
- Changed behavior description

### Fixed
- Bug fix description

### Removed
- Removed feature description

### Security
- Security fix description

## [1.2.0] - 2024-01-15

### Added
- User profile editing (PR #123)
- Email notification preferences (PR #125)

### Fixed
- Login redirect loop on expired session (PR #124)
```

### Rules
- [ ] Changelog updated with every PR — not as an afterthought before release
- [ ] Uses standard categories: Added, Changed, Fixed, Removed, Security — consistent
- [ ] Entries reference PR or issue numbers — traceability
- [ ] Written for the end user — not "refactored internals" unless it affects users
- [ ] Unreleased section at the top — accumulates changes between releases
- [ ] Release dates follow ISO 8601 — `YYYY-MM-DD`

---

## Inline Documentation Standards

### Function/Method Documentation
```javascript
/**
 * Calculate the total price including tax and discounts.
 *
 * @param {number} subtotal - The pre-tax price in cents
 * @param {number} taxRate - Tax rate as a decimal (e.g., 0.08 for 8%)
 * @param {number} [discountPercent=0] - Optional discount as a percentage (0-100)
 * @returns {number} Total price in cents after tax and discount
 * @throws {RangeError} If subtotal is negative
 * @throws {RangeError} If taxRate is negative
 *
 * @example
 * calculateTotal(1000, 0.08, 10) // returns 972
 */
```

### Rules
- [ ] All public functions have docstrings — what, params, returns, throws
- [ ] Include at least one @example — demonstrates usage
- [ ] Document edge case behavior — what happens with null, empty, boundary values
- [ ] Update docs when function behavior changes — stale docs are worse than no docs
- [ ] Comment the WHY, not the WHAT — code shows what, comments explain why

---

## Onboarding Guide

### Required Sections
- [ ] Project overview and business context — what does this project do and why?
- [ ] Architecture overview with diagram — high-level system view
- [ ] Local development setup — step-by-step, tested
- [ ] Key code areas and navigation guide — where to find important things
- [ ] Common development tasks — how to add a feature, fix a bug, write a test
- [ ] Team contacts and communication channels — who to ask for help
- [ ] Required access and permissions — what to request on day one

---

## 🛑 STOP: Documentation Gate

Before completing any feature or change:

1. [ ] Is the README still accurate after this change?
2. [ ] Are API docs updated for new/changed endpoints?
3. [ ] Has the changelog been updated?
4. [ ] Do all public functions have docstrings?
5. [ ] If a major decision was made, is there an ADR?

---

## Security Checkpoint

- [ ] Documentation does not contain real credentials — only placeholders
- [ ] Internal-only docs are not publicly accessible — verify access controls
- [ ] Security-sensitive procedures have restricted access — runbooks for security incidents
- [ ] API docs do not expose undocumented internal endpoints — security by obscurity is not sufficient, but don't help attackers
