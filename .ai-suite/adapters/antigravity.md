# ANTIGRAVITY IDE ADAPTER
# PURPOSE: Ready-to-use GEMINI.md template that integrates with the .ai-suite rule system
# LOAD WHEN: Setting up the AI rules suite in a project using Antigravity IDE (Google Deepmind)

---

## Setup Instructions

1. Copy the template below into `GEMINI.md` at the project root
2. Ensure the `.ai-suite/` directory exists with all rule files
3. Antigravity IDE reads GEMINI.md and companion rule files automatically
4. Optionally create companion skill files in `.gemini/` for specialized behaviors

---

## GEMINI.md Template

Copy everything between the `---START---` and `---END---` markers into your project's `GEMINI.md`:

```markdown
---START---
# GEMINI.md — Project Rules for Antigravity IDE

## Overview
This project uses a modular AI rules suite stored in `.ai-suite/`.
Follow the rules in these files to produce secure, reliable, production-quality code.

## 🔒 Security (Always Active)
Read and enforce `.ai-suite/core/security.md` in EVERY session.
Never skip security rules regardless of task type or urgency.

## 📋 Session Initialization
1. Read `.ai-suite/MASTER.md` — understand the rule system and file mapping
2. Read `.ai-suite/workflows/session-start.md` — follow Steps 1-5
3. Check for `dev-log.md` — read last session's handoff
4. Load phase-specific files based on the user's first message (see MASTER.md)

## 📚 Companion Rule Files
This project uses the following companion rule file pattern:

### Core Rules (Always Active)
- `.ai-suite/core/security.md` — Security controls, OWASP Top 10, secrets management
- `.ai-suite/core/code-quality.md` — Naming, function design, refactoring triggers
- `.ai-suite/core/error-handling.md` — Error taxonomy, logging, retry patterns

### Phase Rules (Load by Task)
Load from `.ai-suite/phases/` based on current task:
- `01-project-init.md` — Project scaffolding and setup
- `02-requirements.md` — Scope, user stories, acceptance criteria
- `03-system-design.md` — Architecture decisions, ADRs, component boundaries
- `04-database.md` — Schema design, migrations, indexing
- `05-api-design.md` — REST conventions, contracts, status codes
- `06-frontend.md` — Components, state, accessibility, responsiveness
- `07-backend.md` — Services, DI, config, middleware
- `08-testing.md` — Test pyramid, coverage, flaky test policy
- `09-cicd.md` — Pipelines, environment promotion, rollback
- `10-observability.md` — Logging, metrics, alerting, tracing
- `11-performance.md` — Profiling, caching, load testing
- `12-maintenance.md` — Tech debt, dependencies, deprecation
- `13-documentation.md` — README, API docs, runbooks, ADRs

### Workflow Rules
- `.ai-suite/workflows/session-start.md` — Session initialization procedure
- `.ai-suite/workflows/task-handoff.md` — Context preservation between sessions
- `.ai-suite/workflows/review-gate.md` — Pre-delivery self-review checklist

## 🚦 Pre-Delivery Review
Before delivering ANY code:
1. Complete ALL gates in `.ai-suite/workflows/review-gate.md`
2. Security gate (10 questions) — blocking if failed
3. Quality gate (10 questions)
4. Testing gate (10 questions)
5. Performance gate (5 questions)
6. Documentation gate (5 questions)
7. Flag all failures to the user — never skip silently

## ⚠️ Non-Negotiable Rules
- NEVER hardcode secrets in source code
- NEVER use string concatenation in SQL queries
- NEVER expose internal error details to users
- NEVER skip the security review gate
- ALWAYS validate user input server-side
- ALWAYS handle errors explicitly
- ALWAYS use parameterized database queries
- ALWAYS check authentication and authorization

## 🛠️ Project-Specific Configuration
<!-- Add project-specific rules, tech stack preferences, and overrides below -->

---END---
```

---

## Antigravity Skill Files (Optional)

For deeper integration, create skill files in `.gemini/skills/`:

### .gemini/skills/security/SKILL.md
```yaml
---
name: security-review
description: Run comprehensive security review on code changes
---
```
Point to `.ai-suite/core/security.md` and `.ai-suite/workflows/review-gate.md` Gate 1.

### .gemini/skills/testing/SKILL.md
```yaml
---
name: test-driven-development
description: TDD workflow with proper test structure and coverage
---
```
Point to `.ai-suite/phases/08-testing.md` for test writing rules and patterns.

### .gemini/skills/frontend/SKILL.md
```yaml
---
name: frontend-development
description: Frontend component design, accessibility, and responsive rules
---
```
Point to `.ai-suite/phases/06-frontend.md` for component and UI rules.

### .gemini/skills/project-init/SKILL.md
```yaml
---
name: project-initialization
description: New project scaffolding with proper structure and tooling
---
```
Point to `.ai-suite/phases/01-project-init.md` for scaffolding checklist.

### .gemini/skills/servers/SKILL.md
```yaml
---
name: backend-server-development
description: Backend service design, middleware, and server configuration
---
```
Point to `.ai-suite/phases/07-backend.md` for service layer patterns.

---

## Antigravity-Specific Features

| Feature | How to Use |
|---|---|
| GEMINI.md | Project-level rules, auto-loaded |
| .gemini/skills/ | Specialized skill files with SKILL.md |
| Knowledge Items (KIs) | Persistent context from past sessions |
| Conversation logs | Historical context for ongoing projects |
| Planning mode | Automatic for complex tasks |
| Artifacts | Implementation plans, walkthroughs, tasks |

---

## Notes

- Antigravity supports both Gemini and Claude models — rules are model-agnostic
- The `.ai-suite/` directory is the single source of truth — GEMINI.md is just the entry point
- Skill files extend capabilities for specific domains — optional but recommended
- Keep GEMINI.md concise — detailed rules live in `.ai-suite/` files
- Use Antigravity's planning mode for multi-phase tasks — it creates implementation plans automatically
