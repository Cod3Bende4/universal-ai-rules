# MASTER.md
# PURPOSE: Central index mapping task types to the rule files the AI must load
# LOAD WHEN: Always load this file at the start of every session — it is the routing table

---

## How to Use This File

1. Read the user's first message carefully
2. Identify which task type(s) it matches from the table below
3. Load ALL files listed for that task type — never skip security.md
4. If the task spans multiple types, load the union of all listed files
5. If unsure which task type applies, ask the user before proceeding

---

## Task Type → Files to Load

| Task Type | Files to Load |
|---|---|
| **Starting a new project** | `core/security.md`, `phases/01-project-init.md`, `workflows/session-start.md` |
| **Gathering/refining requirements** | `core/security.md`, `phases/02-requirements.md` |
| **Designing system architecture** | `core/security.md`, `phases/03-system-design.md`, `core/code-quality.md` |
| **Database design or migrations** | `core/security.md`, `phases/04-database.md`, `core/error-handling.md` |
| **API design or implementation** | `core/security.md`, `phases/05-api-design.md`, `core/error-handling.md`, `core/code-quality.md` |
| **Frontend development** | `core/security.md`, `phases/06-frontend.md`, `core/code-quality.md` |
| **Backend development** | `core/security.md`, `phases/07-backend.md`, `core/code-quality.md`, `core/error-handling.md` |
| **Writing or fixing tests** | `core/security.md`, `phases/08-testing.md` |
| **CI/CD pipeline setup** | `core/security.md`, `phases/09-cicd.md` |
| **Adding logging/monitoring** | `core/security.md`, `phases/10-observability.md`, `core/error-handling.md` |
| **Performance optimization** | `core/security.md`, `phases/11-performance.md` |
| **Refactoring / tech debt** | `core/security.md`, `phases/12-maintenance.md`, `core/code-quality.md` |
| **Writing documentation** | `phases/13-documentation.md` |
| **Code review / PR review** | `core/security.md`, `core/code-quality.md`, `workflows/review-gate.md` |
| **Resuming a previous session** | `core/security.md`, `workflows/session-start.md`, `workflows/task-handoff.md` |
| **Bug fix / debugging** | `core/security.md`, `core/error-handling.md`, `core/code-quality.md` |
| **Security audit / hardening** | `core/security.md`, `phases/08-testing.md` |
| **Deployment / release** | `core/security.md`, `phases/09-cicd.md`, `workflows/review-gate.md` |

---

## File Reference (Quick Index)

### Core (load frequently)
| File | Purpose |
|---|---|
| `core/security.md` | Security rules — loaded in EVERY session without exception |
| `core/code-quality.md` | Naming, structure, function design, refactoring triggers |
| `core/error-handling.md` | Error taxonomy, logging rules, retry patterns, user-facing errors |

### Phases (load based on task)
| File | Purpose |
|---|---|
| `phases/01-project-init.md` | Scaffolding, env setup, git init, first-PR checklist |
| `phases/02-requirements.md` | Scope definition, user stories, acceptance criteria format |
| `phases/03-system-design.md` | ADR template, scalability questions, component boundaries |
| `phases/04-database.md` | Schema design, migrations, indexing, data integrity rules |
| `phases/05-api-design.md` | REST conventions, contracts, status codes, versioning |
| `phases/06-frontend.md` | Component design, state management, accessibility, responsiveness |
| `phases/07-backend.md` | Service layer, dependency injection, config management |
| `phases/08-testing.md` | Test pyramid, naming, coverage gates, flaky test policy |
| `phases/09-cicd.md` | Pipeline design, environment promotion, rollback strategy |
| `phases/10-observability.md` | Structured logging, metrics, alerting, dashboards |
| `phases/11-performance.md` | Profiling, caching, query optimization, load testing |
| `phases/12-maintenance.md` | Tech debt tracking, deprecation, upgrade strategy |
| `phases/13-documentation.md` | README, API docs, runbooks, ADRs, changelog |

### Workflows (load based on context)
| File | Purpose |
|---|---|
| `workflows/session-start.md` | What to do at the beginning of every AI session |
| `workflows/task-handoff.md` | How to preserve context between AI sessions |
| `workflows/review-gate.md` | Mandatory self-review before submitting any code |

### Adapters (load once during setup)
| File | Purpose |
|---|---|
| `adapters/cursor.md` | Cursor IDE adapter template |
| `adapters/claude-code.md` | Claude Code (CLAUDE.md) adapter template |
| `adapters/antigravity.md` | Antigravity IDE (GEMINI.md) adapter template |
| `adapters/warp.md` | Warp AI adapter template |
| `adapters/codex.md` | OpenAI Codex CLI (AGENTS.md) adapter template |
| `adapters/windsurf.md` | Windsurf adapter template |

---

## Decision Logic for File Loading

```
START
│
├─ Is user starting a brand new conversation?
│  └─ YES → Load workflows/session-start.md FIRST
│
├─ Does the task involve ANY code changes?
│  └─ YES → Load core/security.md (ALWAYS)
│
├─ Does the task involve writing NEW code?
│  └─ YES → Load core/code-quality.md
│
├─ Does the task touch error paths, logging, or failure modes?
│  └─ YES → Load core/error-handling.md
│
├─ Match the task to a Phase from the table above
│  └─ Load the corresponding phase file(s)
│
├─ Is the user about to commit, merge, or deploy?
│  └─ YES → Load workflows/review-gate.md
│
└─ Is this a continuation of a previous session?
   └─ YES → Load workflows/task-handoff.md
```

---

## Rules for This Index

- [ ] Never proceed without loading core/security.md — no exceptions
- [ ] When in doubt about which files to load, load MORE not fewer
- [ ] If a task spans 3+ phases, load all of them — do not pick the "most relevant" one
- [ ] Re-check this index if the user's task changes mid-session
- [ ] Never tell the user "I'm loading rules" — just follow them silently

⚠️ WARNING: Skipping security.md is a critical failure. Every session, every task, every time.
