# 10-OBSERVABILITY.md
# PURPOSE: Structured logging, metrics, alerting, dashboards, and tracing rules
# LOAD WHEN: Adding logging, monitoring, alerting, or debugging production issues

---

## Structured Logging

### Log Format (JSON)
```json
{
  "timestamp": "2024-01-15T10:30:00.000Z",
  "level": "INFO",
  "service": "user-service",
  "requestId": "req-uuid-123",
  "userId": "usr-456",
  "message": "User login successful",
  "duration_ms": 45,
  "metadata": {
    "method": "POST",
    "path": "/api/v1/auth/login",
    "statusCode": 200,
    "userAgent": "Mozilla/5.0"
  }
}
```

### Rules
- [ ] Use JSON format for all logs — machine parseable, searchable
- [ ] Include timestamp (ISO 8601, UTC) in every log — enables time-based queries
- [ ] Include log level in every log — enables filtering by severity
- [ ] Include service name in every log — identifies the source in multi-service systems
- [ ] Include request ID in every log — trace a request across all log entries
- [ ] Include user ID when authenticated — audit trail
- [ ] Include duration for operations — performance tracking

### Log Levels
| Level | When to Use | Example |
|---|---|---|
| FATAL | Application cannot continue | Out of memory, config missing |
| ERROR | Operation failed, needs attention | DB query failed, payment declined |
| WARN | Unexpected but handled | Rate limit approaching, retry needed |
| INFO | Significant business event | User registered, order placed |
| DEBUG | Developer troubleshooting | Function params, query plans |
| TRACE | Deep debugging (rarely used) | Full request/response bodies |

- [ ] Production default level: INFO — only INFO, WARN, ERROR, FATAL
- [ ] Debug logging can be enabled per-request — via header or config
- [ ] Every ERROR log triggers alert evaluation — errors need attention
- [ ] Log volume monitored — alert on sudden spikes

### What to Log
- [ ] All HTTP requests (method, path, status, duration) — at INFO level
- [ ] All authentication events (login, logout, failed attempts) — at INFO level
- [ ] All authorization failures — at WARN level
- [ ] All errors with stack traces — at ERROR level (non-production only for stack traces)
- [ ] All external service calls (service, method, duration, status) — at INFO level
- [ ] All database query performance issues (>100ms) — at WARN level
- [ ] Application startup and shutdown — at INFO level
- [ ] Configuration loaded (keys only, not values) — at INFO level

### What NEVER to Log
- [ ] Passwords or password hashes — PCI/security violation
- [ ] API keys, tokens, or secrets — security violation
- [ ] Credit card numbers — PCI violation
- [ ] Social Security Numbers — PII violation
- [ ] Full request/response bodies in production — contains user data
- [ ] Health check requests — generates noise without value
- [ ] Static asset requests — generates noise without value

⚠️ WARNING: Logging PII or secrets is a compliance violation that can result in fines. When in doubt, DO NOT log it.

---

## Metrics

### Four Golden Signals (Monitor These Always)
| Signal | Metric | Target |
|---|---|---|
| Latency | Request duration (P50, P95, P99) | P99 < 500ms for APIs |
| Traffic | Requests per second | Baseline established |
| Errors | Error rate (5xx / total requests) | < 0.1% |
| Saturation | CPU usage, memory usage, DB connections | < 70% capacity |

### Application Metrics
- [ ] Request count by endpoint, method, status — traffic patterns
- [ ] Request duration histogram — latency distribution
- [ ] Error count by type — which errors are most common
- [ ] Active connections / concurrent requests — capacity monitoring
- [ ] Queue depth (if using queues) — backlog monitoring
- [ ] Cache hit/miss ratio — cache effectiveness
- [ ] Database query duration — DB performance monitoring
- [ ] External service call duration and error rate — dependency health

### Business Metrics
- [ ] User registrations per hour — growth tracking
- [ ] Active sessions — concurrent usage
- [ ] Feature usage counts — adoption tracking
- [ ] Transaction volume and value — business health

### Rules
- [ ] Use a metrics library (Prometheus, StatsD, OpenTelemetry) — not custom logging
- [ ] Metrics have labels/tags — service, endpoint, status, environment
- [ ] Avoid high-cardinality labels — don't use user_id as a metric label
- [ ] Dashboards exist for all Golden Signals — visible to the team
- [ ] Metrics retention: 30 days at full resolution, 1 year aggregated — cost management

---

## Alerting

### Alert Priority Levels
| Priority | Response Time | Examples |
|---|---|---|
| P0 — Critical | Immediate (page on-call) | Service down, data breach |
| P1 — High | Within 1 hour | Error rate > 5%, latency 3x baseline |
| P2 — Medium | Within 4 hours | Error rate > 1%, disk space > 80% |
| P3 — Low | Next business day | Warning trends, minor anomalies |

### Alert Rules
- [ ] Every alert has a clear title — what is happening
- [ ] Every alert has an actionable runbook link — how to fix it
- [ ] Every alert has a severity level — guides response urgency
- [ ] Alerts based on symptoms, not causes — "high error rate" not "CPU usage high"
- [ ] Set appropriate thresholds — avoid alert fatigue from false positives
- [ ] Alert on rate of change, not just absolute values — sudden spikes matter
- [ ] Test alerts regularly — verify they fire and reach the right people
- [ ] Review and tune alerts quarterly — remove stale alerts, adjust thresholds

### Alert Anti-Patterns
- [ ] No alerts that nobody acts on — delete or fix them
- [ ] No duplicate alerts for the same issue — consolidate
- [ ] No alerts that fire during every deployment — adjust thresholds or suppress during deploy
- [ ] No alerts without a runbook — the on-call engineer must know what to do

✅ DEFAULT: Start with fewer, well-tuned alerts. Add more as you understand your system's behavior. Alert fatigue is worse than missing a non-critical alert.

---

## Distributed Tracing

### Rules
- [ ] Propagate trace ID across all service calls — request ID from entry point to DB
- [ ] Include trace ID in all log entries — correlate logs across services
- [ ] Include trace ID in error responses — enables support team debugging
- [ ] Instrument external service calls — HTTP clients, message producers
- [ ] Instrument database queries — query timing and parameters
- [ ] Sample traces in production (1-10%) — full tracing is too expensive
- [ ] Store traces for at least 7 days — incident investigation window

---

## 🛑 STOP: Observability Gate

Before deploying any service:

1. [ ] Is structured logging implemented with request IDs?
2. [ ] Are the four Golden Signals (latency, traffic, errors, saturation) monitored?
3. [ ] Do critical alerts have runbooks?
4. [ ] Are PII and secrets excluded from all logs?
5. [ ] Is there a dashboard for this service?

---

## Security Checkpoint

- [ ] Logs do not contain secrets or PII — verified with grep/scan
- [ ] Log storage has access controls — only authorized personnel can read
- [ ] Monitoring dashboards require authentication — no public access
- [ ] Alert channels are secured — Slack channels, PagerDuty accounts
- [ ] Log retention complies with regulations — GDPR, HIPAA, SOC 2
