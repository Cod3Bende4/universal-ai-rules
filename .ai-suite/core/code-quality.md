# CODE-QUALITY.md
# PURPOSE: Coding standards, naming conventions, function design, and refactoring triggers
# LOAD WHEN: Writing new code, refactoring existing code, or reviewing code quality

---

## Naming Conventions

### General Rules (Language-Agnostic)
- [ ] Names describe WHAT the thing is, not HOW it works — `userAge` not `intVal`
- [ ] Boolean variables start with is/has/can/should — `isActive`, `hasPermission`
- [ ] Functions start with a verb — `getUser`, `calculateTotal`, `validateInput`
- [ ] Constants are UPPER_SNAKE_CASE — `MAX_RETRIES`, `DEFAULT_TIMEOUT`
- [ ] Avoid abbreviations unless universally understood — `id`, `url`, `api` are OK; `usr`, `mgr` are not
- [ ] Collection names are plural — `users`, `orderItems`, `activeConnections`
- [ ] Single-item names are singular — `user`, `orderItem`, `connection`
- [ ] No single-letter variables except in loops (i, j, k) or lambdas (x, v) — prevents confusion
- [ ] Avoid generic names — no `data`, `info`, `temp`, `result`, `stuff` without qualifier
- [ ] Include units in numeric names — `timeoutMs`, `maxSizeBytes`, `retryDelaySeconds`

### Language-Specific Conventions
- [ ] JavaScript/TypeScript: camelCase for vars/functions, PascalCase for classes/components
- [ ] Python: snake_case for vars/functions, PascalCase for classes
- [ ] Go: camelCase for unexported, PascalCase for exported, no underscores
- [ ] CSS: kebab-case for classes — `user-profile`, `nav-item-active`
- [ ] SQL: snake_case for columns/tables — `user_id`, `created_at`
- [ ] Files: kebab-case for most files, PascalCase for component files

⚠️ WARNING: Never use names that differ only by case — `user` vs `User` in the same scope is a bug waiting to happen.

---

## Function Design Rules

- [ ] Single responsibility — each function does exactly one thing
- [ ] Max 20 lines per function — if longer, extract a helper function
- [ ] Max 4 parameters — if more, use an options/config object
- [ ] No boolean parameters that change function behavior — split into two functions instead
- [ ] Pure functions preferred — no side effects when possible
- [ ] Return early for guard clauses — avoid deep nesting
- [ ] Max 3 levels of nesting — refactor deeper nesting into separate functions
- [ ] Functions should return one type — no `string | null | undefined | false`
- [ ] Avoid mutating input parameters — return new values instead
- [ ] Default parameter values over null checks — use language-level defaults

### Function Size Red Flags
| Lines | Action |
|---|---|
| 1-20 | ✅ Good — leave as is |
| 21-40 | ⚠️ Consider splitting |
| 41-60 | 🛑 Must split — extract helpers |
| 61+ | 🛑 Critical — refactor immediately |

---

## Comment Rules

### ALWAYS Comment
- [ ] WHY something is done a non-obvious way — "// Skip validation here because X"
- [ ] Business logic explanations — "// Discount applies only to orders over $50"
- [ ] Workarounds and hacks — "// TODO(#123): Remove after API v3 migration"
- [ ] Complex algorithms — brief description of the approach
- [ ] Public API functions — JSDoc/docstring with params, returns, throws
- [ ] Regular expressions — explain what the pattern matches

### NEVER Comment
- [ ] What the code literally does — `i++ // increment i` is useless
- [ ] Obvious type information — `const name: string = "foo" // string name`
- [ ] Commented-out code — delete it, git has history
- [ ] Change logs in code — use git commits for history

### Docstring/JSDoc Format
```
/**
 * Brief description of what this function does.
 *
 * @param {Type} paramName - Description of the parameter
 * @returns {Type} Description of what is returned
 * @throws {ErrorType} When this error condition occurs
 *
 * @example
 * const result = functionName(input);
 */
```

⚠️ WARNING: Never leave TODO comments without an issue tracker reference — `TODO(#issue)` is required.

---

## File Organization Rules

### Import Order (enforce via linter)
1. Language built-in modules
2. Third-party libraries
3. Internal/project modules
4. Relative imports from parent directories
5. Relative imports from the same directory
6. Type imports (TypeScript)
7. CSS/style imports

- [ ] Blank line between each import group — visual separation
- [ ] Alphabetical within each group — deterministic ordering
- [ ] No unused imports — remove immediately

### File Structure
- [ ] One module/class/component per file — single responsibility for files too
- [ ] File names match the primary export — `UserService.ts` exports `UserService`
- [ ] Max 300 lines per file — split into modules if longer
- [ ] Group related files in directories — not flat file structures with 50+ files
- [ ] Index files only re-export — no logic in index/barrel files
- [ ] Test files adjacent to source files OR in a parallel test/ directory — be consistent

### Module Boundaries
- [ ] Modules expose a public API through index files — hide internal implementation
- [ ] No circular dependencies between modules — restructure if detected
- [ ] Shared utilities go in a `shared/` or `common/` directory — not duplicated
- [ ] Feature-based organization over type-based — `features/auth/` not `controllers/authController.ts`

---

## Refactoring Triggers

When you encounter ANY of these code smells, flag them to the user:

### Must Refactor Immediately
- [ ] Duplicated code blocks (3+ lines repeated) — extract to shared function
- [ ] Function over 40 lines — split into smaller functions
- [ ] More than 4 function parameters — use options object
- [ ] Nested callbacks deeper than 3 levels — use async/await or extract
- [ ] Magic numbers or strings — extract to named constants
- [ ] God class/module (does everything) — split by responsibility
- [ ] Dead code (unreachable branches) — delete it

### Flag for Future Refactoring
- [ ] Long parameter lists (3-4 params) — consider options object
- [ ] Feature envy (function uses another module's data excessively) — move it
- [ ] Shotgun surgery (one change requires edits in 5+ files) — restructure boundaries
- [ ] Primitive obsession (using strings/numbers where a type/class fits) — create domain types
- [ ] Excessive comments explaining complex logic — simplify the logic instead
- [ ] Inconsistent naming patterns — standardize across the module

---

## Type System Rules (TypeScript/Typed Languages)

- [ ] Prefer explicit types over `any` — `any` disables type safety entirely
- [ ] Use strict mode always — `"strict": true` in tsconfig.json
- [ ] Define interfaces for all API request/response shapes — documents the contract
- [ ] Use unions over enums when possible — more idiomatic in TypeScript
- [ ] Avoid type assertions (`as Type`) — use type guards instead
- [ ] Make illegal states unrepresentable — use the type system to prevent bugs

⚠️ WARNING: Using `any` type is equivalent to disabling the type system. Every use of `any` must have a comment explaining why it's necessary.

---

## 🛑 STOP: Quality Gate

Before submitting any code, verify:

1. [ ] Do all names follow the naming conventions above?
2. [ ] Are all functions under 20 lines with ≤4 parameters?
3. [ ] Is nesting depth ≤3 levels everywhere?
4. [ ] Are there zero instances of commented-out code?
5. [ ] Are imports organized in the correct order?
6. [ ] Are there no magic numbers or strings — all extracted to constants?
7. [ ] Are all TODOs linked to issue tracker references?
8. [ ] Does every public function have a docstring/JSDoc?
9. [ ] Are there no circular dependencies?
10. [ ] Have all refactoring triggers been addressed or flagged?

✅ DEFAULT: When unsure about code organization, prefer MORE files with LESS code each over fewer large files.
