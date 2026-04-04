# 12-MAINTENANCE.md
# PURPOSE: Tech debt tracking, deprecation strategy, upgrade planning, and code health rules
# LOAD WHEN: Refactoring, upgrading dependencies, addressing tech debt, or planning maintenance sprints

---

## Tech Debt Tracking

### Tech Debt Types
| Type | Severity | Example | Action |
|---|---|---|---|
| Intentional — Documented | Low | Shortcut taken with clear plan to fix | Track in backlog with deadline |
| Intentional — Undocumented | Medium | Shortcut taken without a plan | Document immediately, add to backlog |
| Unintentional — Knowledge Gap | Medium | Anti-pattern from inexperience | Fix during code review |
| Unintentional — Bit Rot | High | Working code that degraded over time | Schedule remediation sprint |
| Environmental — Dependency | High | Outdated library with known CVEs | Fix immediately if security-related |

### Rules
- [ ] Every tech debt item has a tracking ticket — in the issue tracker, not just a TODO
- [ ] Every TODO in code links to a ticket — `TODO(#123): description`
- [ ] Tech debt is reviewed monthly — decide: fix, defer, or accept
- [ ] 20% of sprint capacity for tech debt — sustainable pace, not debt accumulation
- [ ] New tech debt requires justification — document why the shortcut was taken
- [ ] Security-related debt is P0 — fix immediately, no deferral

### Tech Debt Tracking Format
```markdown
## TD-[number]: [Brief Description]
- **Type**: [Intentional/Unintentional] — [Documented/Knowledge Gap/Bit Rot/Dependency]
- **Severity**: [Low/Medium/High/Critical]
- **Affected Area**: [modules/files impacted]
- **Impact**: [what happens if not addressed]
- **Estimated Effort**: [S/M/L/XL]
- **Deadline**: [date or "next maintenance sprint"]
- **Created**: [date]
- **Owner**: [who will fix it]
```

⚠️ WARNING: Tech debt without a tracking ticket is invisible debt. If it's not tracked, it won't be fixed.

---

## Dependency Management

### Regular Update Schedule
| Dependency Type | Update Frequency | Action |
|---|---|---|
| Security patches | Immediately | Apply within 24 hours of advisory |
| Bug fixes (patch) | Weekly | Bundle into weekly update PR |
| Minor versions | Monthly | Test and apply during maintenance |
| Major versions | Quarterly | Evaluate, plan migration, test |
| Framework upgrades | Bi-annually | Major planning, migration guide |

### Rules
- [ ] Run `npm audit` / `pip audit` weekly — catch vulnerabilities early
- [ ] Pin exact versions for direct dependencies — reproducible builds
- [ ] Lock files always committed — `package-lock.json`, `Pipfile.lock`
- [ ] Test suite passes after every dependency update — no blind updates
- [ ] Read changelogs before major updates — know what changed and what might break
- [ ] One PR per major dependency update — isolate risk
- [ ] Have a rollback plan for every update — known-good version to revert to
- [ ] Remove unused dependencies quarterly — `depcheck` or equivalent

### Dependency Evaluation Criteria (Before Adding)
- [ ] Is this dependency actively maintained? — last commit within 6 months
- [ ] Does it have a security policy? — responsible disclosure process
- [ ] What is its download count? — community adoption indicator
- [ ] Can we vendor/inline the 5 lines we need? — avoid dependency for trivial code
- [ ] What is its transitive dependency count? — more deps = more risk
- [ ] Is there a simpler alternative? — minimal dependencies

---

## Deprecation Strategy

### Deprecation Process
1. [ ] Mark as deprecated in code — `@deprecated` annotation/tag with replacement
2. [ ] Log a warning when deprecated code is used — visibility
3. [ ] Document the migration path — how to move to the replacement
4. [ ] Notify all consumers/users — announcement, changelog
5. [ ] Set a removal deadline — minimum 2 major versions or 6 months
6. [ ] Remove after deadline — don't let deprecated code live forever

### Deprecation Warning Format
```javascript
/**
 * @deprecated Since v2.0. Use `newFunction()` instead. Will be removed in v3.0.
 */
function oldFunction() {
  console.warn('DEPRECATION: oldFunction() is deprecated. Use newFunction() instead. Removal planned for v3.0.');
  return newFunction();
}
```

### Rules
- [ ] Never remove public API without deprecation period — breaking change without warning
- [ ] Deprecated code still works — it's deprecated, not broken
- [ ] Migration guide exists before deprecation — users can migrate immediately
- [ ] Removal is scheduled and communicated — not a surprise

---

## Code Health Metrics

### Track These Regularly
| Metric | Target | Action |
|---|---|---|
| Test coverage | > 80% | Add tests for uncovered code |
| Build time | < 5 minutes | Investigate and optimize if slower |
| Test suite runtime | < 10 minutes | Parallelize or optimize slow tests |
| Lint warnings | 0 | Fix all warnings in maintenance sprint |
| TODO count | Decreasing trend | Resolve or remove stale TODOs |
| Dependency count | Stable or decreasing | Audit and remove unused |
| Dependency age | < 6 months behind latest | Update in maintenance sprint |
| Dead code | 0 | Remove detected dead code |

### Code Review Health
- [ ] PRs merged within 48 hours — long-lived PRs cause conflicts
- [ ] PR size < 400 lines changed — smaller PRs get better reviews
- [ ] Review turnaround < 24 hours — responsive review culture
- [ ] Review comments result in changes — reviews are not rubber stamps

---

## Upgrade Planning

### Before a Major Upgrade
- [ ] Read the full changelog and migration guide — know the scope
- [ ] Identify all breaking changes — enumerate each one
- [ ] Create a migration plan with steps — ordered, testable steps
- [ ] Set up a parallel environment for testing — don't upgrade in place
- [ ] Run the full test suite after upgrade — verify nothing broke
- [ ] Benchmark performance after upgrade — verify no regressions
- [ ] Plan rollback if upgrade fails — keep the old version ready

### Common Upgrade Pitfalls
- [ ] Upgrading multiple major dependencies simultaneously — upgrade one at a time
- [ ] Not reading the migration guide — breaking changes are documented
- [ ] Not testing edge cases after upgrade — happy path works, edge cases break
- [ ] Upgrading without a rollback plan — stuck if it fails

---

## Regular Maintenance Tasks

### Weekly
- [ ] Run dependency security audit — `npm audit`, `pip audit`
- [ ] Review and merge dependency bot PRs — Dependabot, Renovate
- [ ] Check and respond to error monitoring alerts — Sentry, etc.
- [ ] Review log volume and patterns — anomaly detection

### Monthly
- [ ] Review tech debt backlog — prioritize items for next sprint
- [ ] Review and close stale issues/PRs — keep the tracker clean
- [ ] Update development documentation — reflect recent changes
- [ ] Review access controls and permissions — remove stale access

### Quarterly
- [ ] Major dependency updates — test and apply
- [ ] Remove unused dependencies — `depcheck` or equivalent
- [ ] Review and update ADRs — are past decisions still valid?
- [ ] Performance benchmark — compare to historical baseline
- [ ] Security review — review OWASP checklist against current code

---

## 🛑 STOP: Maintenance Gate

Before completing a maintenance sprint:

1. [ ] Are all tech debt items tracked with tickets?
2. [ ] Are dependencies updated and audit passing?
3. [ ] Have deprecated APIs been migrated or scheduled for removal?
4. [ ] Is the test suite passing with good coverage?
5. [ ] Has the documentation been updated?

---

## Security Checkpoint

- [ ] No dependencies with known critical vulnerabilities — `npm audit` clean
- [ ] Deprecated dependencies have migration plans — no end-of-life libraries
- [ ] Access controls reviewed — stale permissions removed
- [ ] Secrets rotated on schedule — no expired or stale secrets
- [ ] Security patches applied within SLA — critical within 24 hours
