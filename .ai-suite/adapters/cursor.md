# CURSOR ADAPTER
# PURPOSE: Adapter template for Cursor IDE — points to canonical rule files in /.ai-suite/
# LOAD WHEN: Setting up the AI rules suite in a project using Cursor IDE

---

## Setup Instructions

### Option A: Single .cursorrules File (Simple)

Create `.cursorrules` in the project root with the content below.

### Option B: Multiple .cursor/rules/*.mdc Files (Recommended)

Create individual files in `.cursor/rules/` for granular control:
- `.cursor/rules/security.mdc`
- `.cursor/rules/code-quality.mdc`
- `.cursor/rules/session-start.mdc`
- etc.

---

## .cursorrules Template (Option A)

```markdown
# AI Rules — Powered by .ai-suite

## Session Initialization
At the start of every session:
1. Read `.ai-suite/MASTER.md` to understand the rule system
2. ALWAYS load `.ai-suite/core/security.md` — no exceptions
3. Read `.ai-suite/workflows/session-start.md` and follow its instructions
4. Based on my first message, load the appropriate phase files from MASTER.md

## Core Rules (Always Active)
- Follow all rules in `.ai-suite/core/security.md` — security is non-negotiable
- Follow all rules in `.ai-suite/core/code-quality.md` when writing any code
- Follow all rules in `.ai-suite/core/error-handling.md` when handling errors

## Before Delivering Code
- Run through `.ai-suite/workflows/review-gate.md` — all 5 gates must pass
- Flag any gate failures to me before delivering code
- Never silently skip a review gate item

## Phase-Specific Rules
Load phase files from `.ai-suite/phases/` based on the task:
- Starting a new project → `01-project-init.md`
- Database work → `04-database.md`
- API work → `05-api-design.md`
- Frontend work → `06-frontend.md`
- Backend work → `07-backend.md`
- Writing tests → `08-testing.md`
- CI/CD setup → `09-cicd.md`
- Monitoring/logging → `10-observability.md`
- Performance work → `11-performance.md`
- Refactoring → `12-maintenance.md`
- Documentation → `13-documentation.md`

## Session End
Follow `.ai-suite/workflows/task-handoff.md` to save context for the next session.
```

---

## .cursor/rules/security.mdc Template (Option B)

```markdown
---
description: Security rules that must be applied to ALL code changes
globs: ["**/*.ts", "**/*.tsx", "**/*.js", "**/*.jsx", "**/*.py", "**/*.go"]
alwaysApply: true
---

# Security Rules

Read and follow ALL rules in `.ai-suite/core/security.md`.

Key non-negotiable rules:
- Never hardcode secrets — use environment variables
- Always use parameterized queries — never concatenate SQL
- Validate all inputs at the API boundary
- Never expose stack traces or internal errors to users
- Always check authentication and authorization
- Run the Security Gate (10 questions) before any security-sensitive code
```

---

## .cursor/rules/code-quality.mdc Template (Option B)

```markdown
---
description: Code quality standards for all code changes
globs: ["**/*.ts", "**/*.tsx", "**/*.js", "**/*.jsx", "**/*.py", "**/*.go"]
alwaysApply: true
---

# Code Quality Rules

Read and follow ALL rules in `.ai-suite/core/code-quality.md`.

Key rules:
- Functions: max 20 lines, ≤4 parameters, single responsibility
- Names: descriptive, verbs for functions, booleans start with is/has/can
- No magic numbers — extract to named constants
- No commented-out code — delete it, git has history
- File organization: one module/component per file, max 300 lines
- Every public function has a docstring
```

---

## .cursor/rules/review.mdc Template (Option B)

```markdown
---
description: Pre-delivery review checklist
globs: ["**/*"]
alwaysApply: false
---

# Review Gate

Before delivering any code, run through `.ai-suite/workflows/review-gate.md`.

If any gate item fails:
1. Flag it to the user explicitly
2. Explain the risk
3. Propose a fix
4. Never silently skip
```

---

## Notes for Cursor Users

- Cursor supports both `.cursorrules` (project-level) and `.cursor/rules/*.mdc` (granular)
- `.mdc` files support frontmatter with `globs` and `alwaysApply` for conditional loading
- Set `alwaysApply: true` for security and code quality rules
- Set `alwaysApply: false` for phase-specific rules and load them based on context
- The `.ai-suite/` directory contains the canonical rules — adapters just point to them
