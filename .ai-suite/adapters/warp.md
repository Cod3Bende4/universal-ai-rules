# WARP AI ADAPTER
# PURPOSE: Adapter template for Warp AI terminal — points to canonical rule files in /.ai-suite/
# LOAD WHEN: Setting up the AI rules suite in a project using Warp AI terminal

---

## Setup Instructions

1. Create `.warp/rules.md` in the project root
2. Copy the template below into `.warp/rules.md`
3. Warp AI reads rules from `.warp/rules.md` for project-specific instructions

---

## .warp/rules.md Template

```markdown
# Warp AI — Project Rules

## Rule System
This project uses a modular AI rules suite in `.ai-suite/`.
Read `.ai-suite/MASTER.md` at the start of every session to understand which rules to apply.

## Always Active
- Read and follow `.ai-suite/core/security.md` — security rules are non-negotiable
- Read and follow `.ai-suite/core/code-quality.md` — coding standards
- Read and follow `.ai-suite/core/error-handling.md` — error patterns

## Session Protocol
1. At session start: follow `.ai-suite/workflows/session-start.md`
2. Before delivering code: follow `.ai-suite/workflows/review-gate.md`
3. At session end: follow `.ai-suite/workflows/task-handoff.md`

## Task-Based Rule Loading
Based on the task, load the appropriate file from `.ai-suite/phases/`:
- Project setup → `01-project-init.md`
- Database → `04-database.md`
- API → `05-api-design.md`
- Frontend → `06-frontend.md`
- Backend → `07-backend.md`
- Testing → `08-testing.md`
- CI/CD → `09-cicd.md`
- Monitoring → `10-observability.md`
- Performance → `11-performance.md`
- Refactoring → `12-maintenance.md`
- Documentation → `13-documentation.md`

## Critical Rules
- Never hardcode secrets — use environment variables
- Always use parameterized queries — never concatenate SQL
- Validate all inputs at the API boundary
- Handle all errors explicitly — no empty catch blocks
- Run review gates before delivering code — flag failures to user
```

---

## Warp-Specific Notes

- Warp AI excels at terminal commands — leverage for git, testing, deployment tasks
- Keep rules concise in `.warp/rules.md` — Warp has limited context
- Reference `.ai-suite/` files for full rules — Warp can read project files
- Focus the adapter on command-line relevant rules (git, testing, CI/CD, deployment)
