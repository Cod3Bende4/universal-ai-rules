# CLAUDE CODE ADAPTER
# PURPOSE: Ready-to-use CLAUDE.md template that integrates with the .ai-suite rule system
# LOAD WHEN: Setting up the AI rules suite in a project using Claude Code (Anthropic)

---

## Setup Instructions

1. Copy the template below into `CLAUDE.md` at the project root
2. Ensure the `.ai-suite/` directory exists with all rule files
3. Claude Code will automatically read CLAUDE.md at the start of every session

---

## CLAUDE.md Template

Copy everything between the `---START---` and `---END---` markers into your project's `CLAUDE.md`:

```markdown
---START---
# CLAUDE.md — Project Rules for Claude Code

## 🔒 Mandatory: Security Rules
ALWAYS read and follow `.ai-suite/core/security.md` in every session.
This is non-negotiable — do not skip regardless of task type.

## 📋 Session Start Protocol
At the start of every session:
1. Read `.ai-suite/MASTER.md` to understand the full rule system
2. Read `.ai-suite/workflows/session-start.md` and follow its Step 1-5 sequence
3. Check `dev-log.md` if it exists — understand prior session context
4. Based on my first message, load the relevant phase files from `.ai-suite/MASTER.md`

## 📚 Rule Loading Guide
Load additional rule files from `.ai-suite/` based on the current task:

### Always Loaded
- `.ai-suite/core/security.md` — security rules (ALWAYS)

### Load by Task Type
| If I ask about... | Also load... |
|---|---|
| New project setup | `phases/01-project-init.md` |
| Requirements/scope | `phases/02-requirements.md` |
| Architecture/design | `phases/03-system-design.md`, `core/code-quality.md` |
| Database/schema | `phases/04-database.md`, `core/error-handling.md` |
| API endpoints | `phases/05-api-design.md`, `core/error-handling.md` |
| Frontend/UI/React | `phases/06-frontend.md`, `core/code-quality.md` |
| Backend/services | `phases/07-backend.md`, `core/code-quality.md`, `core/error-handling.md` |
| Tests | `phases/08-testing.md` |
| CI/CD/deploy | `phases/09-cicd.md` |
| Logging/monitoring | `phases/10-observability.md` |
| Performance | `phases/11-performance.md` |
| Refactoring/debt | `phases/12-maintenance.md`, `core/code-quality.md` |
| Documentation | `phases/13-documentation.md` |
| Code review/PR | `workflows/review-gate.md`, `core/code-quality.md` |
| Bug fix/debugging | `core/error-handling.md`, `core/code-quality.md` |

## 🚦 Before Delivering Code
Before completing ANY code task:
1. Run through ALL gates in `.ai-suite/workflows/review-gate.md`
2. If any gate item fails, flag it to me with:
   - What failed
   - Why it matters
   - How to fix it
3. NEVER silently skip a failed gate item
4. Security gate failures are blocking — fix before delivering

## 🔄 Session End Protocol
Before ending a session:
1. Follow `.ai-suite/workflows/task-handoff.md`
2. Update `dev-log.md` with session summary
3. List all files changed with descriptions
4. Document any in-progress work with exact next steps

## 📏 Code Standards
When writing any code:
- Follow `.ai-suite/core/code-quality.md` for naming, structure, and style
- Follow `.ai-suite/core/error-handling.md` for error patterns
- Max 20 lines per function, ≤4 parameters
- No magic numbers, no commented-out code
- Every public function has a docstring
- All TODOs reference issue ticket numbers

## ⚠️ Critical Rules
- NEVER hardcode secrets — use environment variables
- NEVER use string concatenation in database queries — use parameterized queries
- NEVER expose stack traces or internal errors to users
- NEVER skip the security review gate
- NEVER deliver code with known security vulnerabilities without explicit user acknowledgment
- ALWAYS validate user input at the API boundary
- ALWAYS handle errors explicitly — no empty catch blocks

## 🛠️ Project-Specific Overrides
<!-- Add project-specific rules below this line -->
<!-- These override the defaults in .ai-suite/ when there's a conflict -->

---END---
```

---

## Claude Code Memory/Context Tips

- Claude Code reads `CLAUDE.md` automatically at session start
- For large projects, Claude Code also reads `CLAUDE.local.md` for developer-specific settings
- Keep CLAUDE.md under 200 lines — point to `.ai-suite/` files for details
- Use CLAUDE.md for what to load, `.ai-suite/` for the actual rules
- Claude Code supports `@file` references in conversation — reference `.ai-suite/` files directly

---

## Project-Level vs User-Level

| File | Scope | Committed to Git? |
|---|---|---|
| `CLAUDE.md` | Project-level rules | Yes |
| `CLAUDE.local.md` | Developer-specific overrides | No (add to .gitignore) |
| `.ai-suite/*` | Canonical rule files | Yes |
