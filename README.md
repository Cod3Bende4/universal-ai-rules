# 🛡️ Universal AI Rules & Skills Suite

**A modular, production-grade rule system that makes any AI code assistant write secure, reliable, maintainable software — regardless of the model's capability level.**

Works with: **Cursor** · **Claude Code** · **Antigravity IDE** · **Warp AI** · **OpenAI Codex CLI** · **Windsurf** · and any AI editor that supports project-level instructions.

---

## Why This Exists

AI coding assistants are powerful but inconsistent. They forget to validate inputs, hardcode secrets, skip error handling, write untestable code, and silently ship vulnerabilities — especially when using smaller or less capable models.

This suite solves that by giving the AI a **structured, checklist-based rule system** that covers the entire software development lifecycle. Instead of hoping the model "knows" best practices, we tell it exactly what to check, when to stop, and what never to do.

### The Core Problem

| Without Rules | With This Suite |
|---|---|
| AI hardcodes a database password | ✅ Security gate blocks it — must use env vars |
| AI skips input validation | ✅ Checklist requires validation at every boundary |
| AI writes 200-line functions | ✅ Quality rules enforce max 20 lines |
| AI leaves Supabase RLS disabled | ✅ **Hardened RLS checklist** ensures data isolation |
| Context lost between sessions | ✅ Task handoff captures exact state and next steps |
| AI ships code without review | ✅ **45-question review gate** runs before every delivery |
| Different rules in different editors | ✅ One canonical source, thin adapters per editor |

---

## Quick Start

### Option A: Interactive Setup Script (Recommended)

```bash
# Clone this repo
git clone https://github.com/your-org/ai-rules-suite.git
cd ai-rules-suite

# Run the setup wizard — it asks which IDE(s) you use and places files automatically
./setup.sh
```

The script will:
1. Ask where your project is
2. Ask which AI editor(s) you use (supports multi-select)
3. Copy `.ai-suite/` into your project
4. Place the correct adapter file(s) in the right location
5. Show you the next steps

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🛡️  Universal AI Rules & Skills Suite — Setup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Which AI code editor(s) do you use?
  1) Cursor
  2) Claude Code (Anthropic)
  3) Antigravity IDE (Google)
  4) Warp AI
  5) OpenAI Codex CLI
  6) Windsurf (Codeium)
  7) All of the above

Your choice(s) [e.g. 1 3 5]: 2

✔ .ai-suite/ installed
✔ Created CLAUDE.md

  ✅ Setup Complete!
```

### Option B: Manual Setup (Under 5 Minutes)

If you prefer to do it manually:

**Step 1** — Copy the `.ai-suite/` directory into your project:
```bash
cp -r .ai-suite /path/to/your/project/.ai-suite
```

**Step 2** — Copy the ready-to-use adapter file for your editor:

| Editor | Command to Run (from your project root) |
|---|---|
| **Cursor** (single file) | `cp .ai-suite/ready/cursorrules .cursorrules` |
| **Cursor** (granular) | `mkdir -p .cursor/rules && cp .ai-suite/ready/cursor-rules/*.mdc .cursor/rules/` |
| **Claude Code** | `cp .ai-suite/ready/CLAUDE.md CLAUDE.md` |
| **Antigravity IDE** | `cp .ai-suite/ready/GEMINI.md GEMINI.md` |
| **Warp AI** | `mkdir -p .warp && cp .ai-suite/ready/warp-rules.md .warp/rules.md` |
| **Codex CLI** | `cp .ai-suite/ready/AGENTS.md AGENTS.md` |
| **Windsurf** | `cp .ai-suite/ready/windsurfrules .windsurfrules` |

**Step 3** — Commit:
```bash
git add .ai-suite/ CLAUDE.md  # (or whichever adapter you chose)
git commit -m "chore: add AI rules suite"
```

The AI will automatically read `MASTER.md` and load the right rules based on your task.

---

## How It Works

### Context-Aware Loading

The AI doesn't load all 4,000+ lines at once. `MASTER.md` acts as a routing table:

```
User says "build me a login API"
    ↓
MASTER.md routes to:
    ├── core/security.md       (always loaded)
    ├── phases/05-api-design.md
    ├── phases/07-backend.md
    └── core/error-handling.md
    ↓
AI loads ~600 lines of relevant rules (not 4,389)
```

This keeps context window usage efficient while ensuring the right rules are always active.

### Checklist-First Design

Every rule is a binary checkbox the AI can self-verify:

```markdown
- [ ] Use parameterized queries for ALL database operations — prevents SQL injection
- [ ] Never hardcode secrets in source code — use environment variables
- [ ] Every function has ≤4 parameters — if more, use an options object
```

No vague principles like "write clean code." Every rule is **falsifiable** — the AI can check "did I do this? yes or no" mechanically.

### Mandatory Gates

The AI must pass through verification gates before delivering code:

```
🛑 Security Gate    → 10 binary questions (blocking — must pass)
🛑 Vibe Security Audit →  5 binary questions (blocking — owner-only data)
🛑 Quality Gate     → 10 binary questions
🛑 Testing Gate     → 10 binary questions
🛑 Performance Gate →  5 binary questions
🛑 Documentation Gate → 5 binary questions
```

If any gate item fails, the AI must flag it to the user — **never silently skip**.

---

## Architecture

```
project-root/                    What the setup script creates in YOUR project:
│
├── .ai-suite/                   ← The brain (copied by setup.sh)
│   ├── MASTER.md                  Routing table: maps tasks → files to load
│   ├── core/
│   │   ├── security.md            OWASP Top 10, secrets, input validation
│   │   ├── code-quality.md        Naming, functions, file org, refactoring
│   │   └── error-handling.md      Error taxonomy, logging, retries, UX
│   ├── phases/
│   │   ├── 01-project-init.md     Scaffolding, env setup, git, first PR
│   │   ├── 02-requirements.md     Scope, user stories, acceptance criteria
│   │   ├── 03-system-design.md    ADRs, scalability, component boundaries
│   │   ├── 04-database.md         Schema, migrations, indexing, integrity
│   │   ├── 05-api-design.md       REST conventions, contracts, versioning
│   │   ├── 06-frontend.md         Components, state, a11y, responsive
│   │   ├── 07-backend.md          Services, DI, config, middleware
│   │   ├── 08-testing.md          Test pyramid, coverage, flaky policy
│   │   ├── 09-cicd.md             Pipelines, promotion, rollback
│   │   ├── 10-observability.md    Structured logging, metrics, alerting
│   │   ├── 11-performance.md      Profiling, caching, load testing
│   │   ├── 12-maintenance.md      Tech debt, deps, deprecation
│   │   └── 13-documentation.md    README, API docs, runbooks, ADRs
│   ├── workflows/
│   │   ├── session-start.md       AI boot sequence for every session
│   │   ├── task-handoff.md        Context preservation between sessions
│   │   └── review-gate.md         40-question pre-delivery self-review
│   └── ready/                     Pre-built adapter files (used by setup.sh)
│       ├── cursorrules            → copied to .cursorrules
│       ├── cursor-rules/*.mdc     → copied to .cursor/rules/*.mdc
│       ├── CLAUDE.md              → copied to CLAUDE.md
│       ├── GEMINI.md              → copied to GEMINI.md
│       ├── AGENTS.md              → copied to AGENTS.md
│       ├── warp-rules.md          → copied to .warp/rules.md
│       └── windsurfrules          → copied to .windsurfrules
│
├── .cursorrules                 ← Created if you chose Cursor
├── CLAUDE.md                    ← Created if you chose Claude Code
├── GEMINI.md                    ← Created if you chose Antigravity
├── .warp/rules.md               ← Created if you chose Warp AI
├── AGENTS.md                    ← Created if you chose Codex CLI
└── .windsurfrules               ← Created if you chose Windsurf
```

### Design Principles

| Principle | How It's Implemented |
|---|---|
| **No file > 400 lines** | Largest file is 277 lines — context window space is expensive |
| **Checklist-first** | `[ ]` format everywhere — binary, falsifiable, machine-checkable |
| **Security is non-negotiable** | `security.md` loaded in every session; Security Checkpoint in every phase |
| **Non-capable model guarantee** | Explicit NEVER/ALWAYS lists, safe defaults, STOP gates |
| **Cross-editor compatible** | One canonical source (`.ai-suite/`), thin adapters per editor |
| **Full SDLC coverage** | 13 phases from project init to documentation — no gaps |

---

## File Reference

### Core (loaded frequently)

| File | Lines | What It Covers |
|---|---|---|
| [`security.md`](.ai-suite/core/security.md) | 143 | OWASP Top 10 checklist, secrets management, input validation, secure defaults, 10-question security gate |
| [`code-quality.md`](.ai-suite/core/code-quality.md) | 172 | Naming conventions (language-agnostic + specific), function design rules, comment rules, file organization, refactoring triggers, type system rules |
| [`error-handling.md`](.ai-suite/core/error-handling.md) | 201 | Error taxonomy (recoverable vs fatal), per-layer handling (UI/API/service/DB), logging rules (what to log, what never to log), retry/backoff strategy, graceful degradation, user-facing error templates |

### Phases (loaded based on task)

| File | Lines | Key Content |
|---|---|---|
| [`01-project-init.md`](.ai-suite/phases/01-project-init.md) | 158 | Directory structure template, .gitignore, README skeleton, .env.example, dependency rules, git strategy, commit format, pre-commit hooks, first-PR checklist |
| [`02-requirements.md`](.ai-suite/phases/02-requirements.md) | 146 | Scope definition, user story template (As a / I want to / So that), acceptance criteria (Given/When/Then), priority framework (P0-P4), requirements validation |
| [`03-system-design.md`](.ai-suite/phases/03-system-design.md) | 168 | ADR template, scalability questions (traffic, data, availability), component boundary decision rules, data flow mapping format, over-engineering red flags, design pattern usage matrix |
| [`04-database.md`](.ai-suite/phases/04-database.md) | 147 | Schema design rules, column naming, relationship rules, safe migration practices, indexing strategy, query rules, data integrity, backup and recovery |
| [`05-api-design.md`](.ai-suite/phases/05-api-design.md) | 252 | REST naming conventions, request/response contract template, HTTP status code mapping, pagination (cursor & offset), filtering/sorting/search, API versioning strategy, OpenAPI spec requirement |
| [`06-frontend.md`](.ai-suite/phases/06-frontend.md) | 176 | Component design rules, state management decision tree, accessibility (a11y) rules, responsive breakpoints, Core Web Vitals targets, form handling rules |
| [`07-backend.md`](.ai-suite/phases/07-backend.md) | 184 | Service layer architecture, controller/service/repository separation, DI patterns, config management, middleware ordering, background job rules, health check endpoints |
| [`08-testing.md`](.ai-suite/phases/08-testing.md) | 218 | Testing pyramid ratios, what must have unit/integration tests, Given_When_Then naming, AAA pattern, coverage thresholds by layer, zero-tolerance flaky test policy, security testing checklist, mock rules |
| [`09-cicd.md`](.ai-suite/phases/09-cicd.md) | 173 | CI pipeline steps (8 stages), CD pipeline (9 stages), environment promotion rules, automatic rollback triggers, canary/blue-green deployment, branch strategy, deployment checklist |
| [`10-observability.md`](.ai-suite/phases/10-observability.md) | 171 | Structured logging format (JSON), log levels guide, what to / never to log, four golden signals, application & business metrics, alert priority levels, alert anti-patterns, distributed tracing |
| [`11-performance.md`](.ai-suite/phases/11-performance.md) | 183 | Performance targets table, profiling rules, caching decision matrix, cache anti-patterns, database query optimization, connection pooling, API performance, load test types |
| [`12-maintenance.md`](.ai-suite/phases/12-maintenance.md) | 185 | Tech debt taxonomy & tracking format, dependency update schedule, deprecation process, code health metrics, upgrade planning, weekly/monthly/quarterly maintenance tasks |
| [`13-documentation.md`](.ai-suite/phases/13-documentation.md) | 277 | README required sections, API docs rules, runbook template, ADR requirements, changelog format (Keep a Changelog), inline docstring format, onboarding guide sections |

### Workflows

| File | Lines | What It Does |
|---|---|---|
| [`session-start.md`](.ai-suite/workflows/session-start.md) | 141 | 5-step boot sequence (read state → assess project → load rules → confirm scope → surface status), greeting template, keyword-based file loading decision tree |
| [`task-handoff.md`](.ai-suite/workflows/task-handoff.md) | 175 | Session-end handoff template (completed/in-progress/not-started/decisions/files changed/blockers), session-start restoration steps, multi-task switching, long-running feature tracking |
| [`review-gate.md`](.ai-suite/workflows/review-gate.md) | 219 | 40-question pre-delivery review: Security (10), Quality (10), Testing (10), Performance (5), Documentation (5) — with specific fix instructions per item, escalation rules |

---

## Where Files Go (Per Editor)

The setup script handles all of this automatically. This table shows what gets placed where, so you understand the structure:

| Editor | Adapter File Placed At | Source File | How It's Read |
|---|---|---|---|
| **Cursor** (simple) | `<project>/.cursorrules` | `.ai-suite/ready/cursorrules` | Auto-read by Cursor on every session |
| **Cursor** (granular) | `<project>/.cursor/rules/*.mdc` | `.ai-suite/ready/cursor-rules/*.mdc` | Auto-read; supports `alwaysApply` and `globs` |
| **Claude Code** | `<project>/CLAUDE.md` | `.ai-suite/ready/CLAUDE.md` | Auto-read by Claude Code on every session |
| **Antigravity** | `<project>/GEMINI.md` | `.ai-suite/ready/GEMINI.md` | Auto-read by Antigravity IDE |
| **Warp AI** | `<project>/.warp/rules.md` | `.ai-suite/ready/warp-rules.md` | Auto-read by Warp terminal AI |
| **Codex CLI** | `<project>/AGENTS.md` | `.ai-suite/ready/AGENTS.md` | Auto-read by OpenAI Codex CLI |
| **Windsurf** | `<project>/.windsurfrules` | `.ai-suite/ready/windsurfrules` | Auto-read by Windsurf |

> **Note:** The adapter file is a thin entry point that tells the AI to load rules from `.ai-suite/`. The actual rules live in `.ai-suite/` — never duplicated across editors.

### Cursor-Specific Notes

- **Single file** (`.cursorrules`): All rules in one file, simple setup
- **Granular** (`.cursor/rules/*.mdc`): Four separate files with independent `alwaysApply` and `globs` settings:
  - `security.mdc` — `alwaysApply: true` (always active)
  - `code-quality.mdc` — `alwaysApply: true` (always active)
  - `session-start.mdc` — `alwaysApply: true` (boots rule loading)
  - `review-gate.mdc` — `alwaysApply: false` (activated on review context)

### Claude Code-Specific Notes

- `CLAUDE.md` is read automatically at session start — no extra config
- Optionally create `CLAUDE.local.md` for developer-specific overrides (add to `.gitignore`)
- Use `@file` references in conversation to point Claude to specific `.ai-suite/` files

### Antigravity-Specific Notes

- `GEMINI.md` is read automatically — no extra config
- Optionally create skill files in `.gemini/skills/` for specialized behaviors (see `.ai-suite/adapters/antigravity.md` for templates)
- Supports both Gemini and Claude models — rules are model-agnostic

### Multi-Editor Projects

You can install adapters for multiple editors in the same project. They all point to the same `.ai-suite/` canon:

```bash
# Example: team uses Cursor, Claude Code, and Windsurf
./setup.sh  # Select options 1, 2, and 6

# Result:
# .cursorrules      → points to .ai-suite/
# CLAUDE.md          → points to .ai-suite/
# .windsurfrules     → points to .ai-suite/
# .ai-suite/         → single source of truth for all editors
```

---

## Customizing for Your Project

### Add project-specific rules

Add a `## Project-Specific Configuration` section at the bottom of your adapter file (CLAUDE.md, GEMINI.md, etc.):

```markdown
## Project-Specific Configuration
- This project uses Next.js 14 with App Router
- Use Supabase for database and authentication
- Use Tailwind CSS for styling
- All API routes go in src/app/api/
- Use Zod for runtime validation
```

### Add a new rule file

1. Create the file in `.ai-suite/` following the 3-line header format:
   ```markdown
   # FILE NAME
   # PURPOSE: one sentence
   # LOAD WHEN: one sentence trigger
   ```
2. Use `[ ]` checkbox format for all rules
3. Include a `🛑 STOP GATE` and `Security Checkpoint`
4. Add the file to `MASTER.md` (task mapping table + file reference)
5. Update your adapter file

### Modify existing rules

Edit files in `.ai-suite/` directly — they're the canonical source. Keep every file under 400 lines. If a file is growing too large, split it.

---

## FAQ

<details>
<summary><b>Does this slow down the AI?</b></summary>

No. The routing system in `MASTER.md` ensures the AI loads only 2-4 files (200-600 lines) per task, not the entire suite. This is comparable to what most project rule files already consume.
</details>

<details>
<summary><b>Does this work with any AI model?</b></summary>

Yes. The rules are written for the lowest common denominator — they use binary checklists, explicit NEVER/ALWAYS instructions, and safe defaults. A capable model benefits from the systematic structure; a less capable model benefits from the explicit guardrails.
</details>

<details>
<summary><b>Can I use multiple editors on the same project?</b></summary>

Yes. The `.ai-suite/` directory is the single source of truth. Each editor's adapter file is a thin pointer to the same canonical rules. You can have `CLAUDE.md`, `GEMINI.md`, and `.cursorrules` all in the same repo.
</details>

<details>
<summary><b>What if a rule doesn't apply to my project?</b></summary>

Delete it or comment it out in the relevant `.ai-suite/` file. The rules are opinionated defaults — override or remove what doesn't fit. But think twice before removing security rules.
</details>

<details>
<summary><b>How do I keep the rules up to date?</b></summary>

Treat rules like code — they live in git, go through PR review, and evolve with your project. Schedule a quarterly review to audit and update rules based on lessons learned.
</details>

---

## Stats

| Metric | Value |
|---|---|
| Total rule files | 26 |
| Total lines of rules | 4,691 |
| Ready-to-use adapter files | 8 (incl. 4 `.mdc` for Cursor) |
| Largest file | 277 lines (13-documentation.md) |
| SDLC phases covered | 13 |
| Review gate questions | 45 |
| Supported editors | 6 |
| Security checkpoints | 16 (harden with Vibe-Security) |

---

## License

MIT — use freely, modify as needed, contribute back if you improve it.

---

<p align="center">
  <i>Built to make AI assistants write code like a senior engineer with a security background — even when they're not one.</i>
</p>