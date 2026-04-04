# 09-CICD.md
# PURPOSE: Pipeline design, environment promotion, rollback strategy, and deployment rules
# LOAD WHEN: Setting up CI/CD pipelines, configuring deployments, or managing release processes

---

## Pipeline Design

### Minimum CI Pipeline (Every PR)
```
1. Checkout → 2. Install → 3. Lint → 4. Type Check → 5. Unit Test → 6. Build → 7. Integration Test → 8. Security Scan
```

### Full CD Pipeline (Merge to Main)
```
1. CI Pipeline (all steps above)
2. Build production artifacts
3. Deploy to staging
4. Run smoke tests on staging
5. Manual approval gate (for production)
6. Deploy to production
7. Run smoke tests on production
8. Monitor for 15 minutes
9. Auto-rollback if error rate > threshold
```

### Rules
- [ ] Every PR triggers the CI pipeline — no unvalidated code merges
- [ ] Pipeline fails fast — lint and type check before expensive tests
- [ ] Pipeline runs in under 15 minutes — optimize if slower
- [ ] Artifacts are built once, deployed everywhere — same binary for staging and prod
- [ ] No manual steps in the pipeline (except approval gates) — fully automated
- [ ] Pipeline configuration is version controlled — in the repo, not in UI only

---

## CI Pipeline Steps

### Step 1: Install Dependencies
- [ ] Use lock file for deterministic installs — `npm ci` not `npm install`
- [ ] Cache dependencies between runs — speed up pipeline
- [ ] Fail if lock file is out of sync with manifest — prevents drift

### Step 2: Linting
- [ ] Zero warnings allowed — warnings become errors in CI
- [ ] Lint all changed files — not just staged files
- [ ] Include formatting check — code style is enforced, not suggested

### Step 3: Type Checking
- [ ] Strict mode enabled — `noImplicitAny`, `strictNullChecks`
- [ ] Zero type errors — no `@ts-ignore` without linked issue
- [ ] Check declaration files — verify type exports

### Step 4: Unit Tests
- [ ] Run all unit tests — not just changed files
- [ ] Generate coverage report — upload as artifact
- [ ] Fail if coverage drops below threshold — enforced, not advisory
- [ ] Fail if any test fails — zero tolerance

### Step 5: Build
- [ ] Production build mode — same optimization as production
- [ ] Build output is an artifact — preserved for deployment
- [ ] Fail on any build warning — treat warnings as errors in CI
- [ ] Verify build output size — alert if bundle grows significantly

### Step 6: Integration Tests
- [ ] Run against real (test) dependencies — database, cache, external services
- [ ] Use containers for test dependencies — docker-compose or testcontainers
- [ ] Clean up test data after run — don't pollute test environment
- [ ] Timeout: max 10 minutes — prevent hanging tests

### Step 7: Security Scanning
- [ ] Dependency audit — `npm audit`, `pip audit`
- [ ] Static analysis security scan — Semgrep, SonarQube, or equivalent
- [ ] Secret scanning — detect accidentally committed secrets
- [ ] Fail on critical/high vulnerabilities — block merge until fixed

---

## Environment Promotion

### Environment Hierarchy
```
Development → Staging → Production
```

| Environment | Purpose | Data | Access |
|---|---|---|---|
| Development | Local development | Fake/seed data | Developers only |
| Staging | Pre-production testing | Anonymized production data | Team + QA |
| Production | Live users | Real data | Restricted |

### Rules
- [ ] Same build artifact deployed to all environments — only config differs
- [ ] Environment-specific config via environment variables — not build flags
- [ ] Staging mirrors production infrastructure — same services, versions, topology
- [ ] Never deploy to production without staging first — no shortcuts
- [ ] Database migrations run automatically on deploy — not manually
- [ ] Feature flags control feature rollout — not deployment timing

⚠️ WARNING: Deploying code that was only tested in development directly to production is a deployment failure. Always go through staging.

---

## Rollback Strategy

### Automatic Rollback Triggers
- [ ] Error rate exceeds 5% (configurable) — compared to pre-deployment baseline
- [ ] Latency P99 exceeds 2x baseline — significant performance degradation
- [ ] Health check failures — service is not responding correctly
- [ ] Critical alert fires — predefined critical conditions

### Rollback Rules
- [ ] Every deployment can be rolled back in under 5 minutes — verified, not assumed
- [ ] Rollback is a single command or automated — no manual multi-step process
- [ ] Database migrations are forward-compatible — old code works with new schema
- [ ] Rollback is tested regularly — don't discover it's broken during an incident
- [ ] Post-rollback: root cause analysis required — document what went wrong

### Blue-Green / Canary Strategy
- [ ] Use canary deployments for high-risk changes — route 5-10% of traffic first
- [ ] Monitor canary for minimum 15 minutes — before promoting to full traffic
- [ ] Use blue-green for zero-downtime deployments — switch traffic, keep old version warm
- [ ] Keep the previous version running for 30 minutes — quick rollback if needed

✅ DEFAULT: Use rolling deployments for most services. Use canary deployments for critical path changes.

---

## Branch and Merge Strategy

- [ ] Main branch is always deployable — never broken
- [ ] Feature branches are short-lived — merge within 1-3 days
- [ ] PRs require at least one review — no self-merging to main
- [ ] PRs must pass CI before merge — enforced by branch protection
- [ ] Squash merge for clean history — one commit per feature/fix
- [ ] Delete branches after merge — keep the repo clean
- [ ] Release tags follow semver — `v1.2.3` for releases

---

## Deployment Checklist

Before every production deployment:

- [ ] All CI checks pass (lint, type check, tests, security scan)
- [ ] Staging deployment tested and approved
- [ ] Database migrations tested on staging
- [ ] Rollback plan documented and tested
- [ ] Monitoring dashboards reviewed — baseline metrics noted
- [ ] On-call engineer identified — someone responsible during deployment
- [ ] No deploy on Fridays (or before holidays) unless P0 — incidents on weekends are expensive

---

## 🛑 STOP: CI/CD Gate

1. [ ] Is the CI pipeline running on every PR?
2. [ ] Does the pipeline fail on lint, type, test, security, or build errors?
3. [ ] Are artifacts built once and promoted across environments?
4. [ ] Is there a staging environment that mirrors production?
5. [ ] Can every deployment be rolled back in under 5 minutes?

---

## Security Checkpoint

- [ ] Secrets are not stored in pipeline configuration — use secret management
- [ ] Pipeline runs with minimum required permissions — least privilege
- [ ] Dependency vulnerabilities scanned on every build — critical/high block merge
- [ ] Build artifacts are signed or checksummed — verify integrity
- [ ] Deployment credentials are rotated regularly — not static long-lived tokens
- [ ] Audit trail exists for all deployments — who deployed what, when
