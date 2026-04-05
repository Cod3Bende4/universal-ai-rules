# 11-PERFORMANCE.md
# PURPOSE: Profiling, caching, query optimization, load testing, and scalability rules
# LOAD WHEN: Optimizing performance, debugging slow operations, planning for scale, or setting up caching

---

## Performance Optimization Rules

### The Golden Rule
- [ ] Measure before optimizing — never guess where the bottleneck is
- [ ] Set a performance budget — define targets before optimizing
- [ ] Optimize the 80/20 — fix the highest-impact bottleneck first
- [ ] Keep the code readable — a 5% speedup is not worth unreadable code
- [ ] Document the optimization — explain what was slow, what was changed, what improved

⚠️ WARNING: Premature optimization is the root of all evil. Profile first, optimize second, measure third.

---

## Profiling Rules

### When to Profile
- [ ] Before optimization — establish baseline measurements
- [ ] After optimization — verify improvement and no regressions
- [ ] When users report slowness — reproduce and measure
- [ ] When latency P99 exceeds target — identify the tail latency cause
- [ ] Before production launch — establish performance baseline

### What to Profile
- [ ] API endpoint response times — measure P50, P95, P99
- [ ] Database query execution times — EXPLAIN ANALYZE
- [ ] External service call latency — HTTP client timing
- [ ] Memory usage over time — detect memory leaks
- [ ] CPU usage under load — identify CPU-bound operations
- [ ] Network I/O — bandwidth and connection usage
- [ ] Garbage collection frequency and duration — GC pauses affect latency

### Performance Targets
| Metric | Target |
|---|---|
| API response (simple read) | < 100ms P95 |
| API response (complex query) | < 500ms P95 |
| API response (write operation) | < 200ms P95 |
| Database query (simple) | < 10ms P95 |
| Database query (complex join) | < 100ms P95 |
| Page load time (frontend) | < 2 seconds |
| Time to interactive | < 3 seconds |
| Memory per request | < 10MB |

✅ DEFAULT: If you don't have specific performance targets, use the table above as starting defaults.

---

## Caching Strategy

### Cache Decision Matrix
| Data Type | Cache? | TTL | Invalidation |
|---|---|---|---|
| Static content (images, CSS) | Yes — CDN | 1 year (version in URL) | Deploy new version |
| API reference data (countries, categories) | Yes — in-memory | 1 hour | TTL expiration |
| User session data | Yes — Redis/memory | Session duration | Logout/timeout |
| Frequently read, rarely changed data | Yes — Redis | 5-15 minutes | Write-through |
| Real-time data (stock prices, live feed) | No | — | — |
| User-specific dynamic data | Maybe — short TTL | 30-60 seconds | User action |
| Write-heavy data | No | — | — |

### Caching Rules
- [ ] Cache at the right layer — CDN, reverse proxy, application, or database
- [ ] Set explicit TTL on all cached data — no infinite caches
- [ ] Implement cache invalidation strategy — write-through, write-behind, or TTL
- [ ] Cache the result, not the query — cache transformed/ready-to-use data
- [ ] Use cache-aside pattern as default — check cache, miss → fetch, store, return
- [ ] Monitor cache hit ratio — target >80% hit rate or the cache is not helping
- [ ] Size the cache appropriately — too small = thrashing, too large = memory waste
- [ ] Handle cache failures gracefully — fallback to source, don't crash

### Cache Anti-Patterns
- [ ] Caching everything "just in case" — increases complexity without measurement
- [ ] No TTL — stale data accumulates forever
- [ ] Caching mutable data without invalidation — users see stale data
- [ ] Cache stampede — 1000 requests hit cache miss simultaneously; use mutex/single-flight
- [ ] Cache without monitoring — no way to know if it helps

⚠️ WARNING: There are only two hard things in computer science: cache invalidation, naming things, and off-by-one errors. Get invalidation right or don't cache.

---

## Database Performance

### Query Optimization
- [ ] Use EXPLAIN ANALYZE on every new query — verify the query plan
- [ ] Avoid N+1 queries — use JOINs or batch loading instead of loops
- [ ] Use appropriate indexes — on WHERE, JOIN, ORDER BY columns
- [ ] Limit result sets — always use LIMIT, especially for user-facing queries
- [ ] Select only needed columns — `SELECT id, name` not `SELECT *`
- [ ] Use pagination for large datasets — cursor or offset based
- [ ] Move complex aggregations to async/background — don't block requests

### Connection Management
- [ ] Use connection pooling — don't open a new connection per request
- [ ] Pool size = number of CPU cores × 2 + 1 — starting recommendation
- [ ] Set connection timeouts — idle timeout, max lifetime
- [ ] Monitor active connections — alert when approaching pool max
- [ ] Handle connection exhaustion — queue or reject gracefully

### Slow Query Identification
- [ ] Enable slow query logging — threshold: 100ms for OLTP
- [ ] Review slow queries weekly — optimize top 5 by frequency
- [ ] Alert on queries exceeding 1 second — in production
- [ ] Track query plans over time — plan changes can cause regressions

---

## API Performance

- [ ] Implement response compression (gzip/brotli) — reduces payload size 60-80%
- [ ] Use ETag/Last-Modified headers — enables conditional requests (304 Not Modified)
- [ ] Implement request coalescing — batch multiple requests into one
- [ ] Use streaming for large responses — don't buffer everything in memory
- [ ] Implement request timeouts — protect against slow clients
- [ ] Set keep-alive on connections — reduce connection overhead
- [ ] Use CDN for static and cacheable API responses — reduce origin server load

---

## Load Testing

### Rules
- [ ] Load test before production launch — establish capacity limits
- [ ] Load test after major changes — verify no performance regressions
- [ ] Test with realistic data volumes — not 10 rows in a test database
- [ ] Test at 2x expected peak traffic — ensure headroom
- [ ] Run load tests from multiple locations — if your users are geographically distributed
- [ ] Monitor ALL system components during load test — DB, cache, queue, CPU, memory

### Load Test Types
| Type | Purpose | Duration |
|---|---|---|
| Smoke Test | Verify system works under minimal load | 1-5 minutes |
| Load Test | Verify performance at expected load | 30-60 minutes |
| Stress Test | Find the breaking point | Until failure |
| Soak Test | Find memory leaks, connection issues | 2-8 hours |
| Spike Test | Verify behavior under sudden traffic bursts | 10-30 minutes |

### Load Test Targets
- [ ] Mean response time under load < 2x idle response time — acceptable degradation
- [ ] Error rate under load < 0.1% — no errors from normal load
- [ ] System recovers after overload — returns to normal after load subsides
- [ ] No memory leaks under sustained load — memory stabilizes, doesn't just grow

---

## Frontend Performance

- [ ] Bundle size < 200KB gzipped — initial load
- [ ] Code-split by route — each page loads only needed code
- [ ] Images optimized (WebP/AVIF, responsive sizes) — largest content element
- [ ] Fonts preloaded, display:swap — prevent layout shifts
- [ ] Critical CSS inlined — above the fold renders immediately
- [ ] Third-party scripts loaded async — don't block rendering
- [ ] Service worker for offline and caching — PWA capabilities

---

## Cost & Budget Limits (AI / Usage)

In modern "vibe-coded" apps, performance is directly linked to cost. Unbounded AI or API usage can lead to massive financial losses (DoS via billing).

- [ ] **Establish Budget Caps** — Configure hard billing limits in GCP/OpenAI/Stripe dashboards.
- [ ] **Usage Alerts** — Set up notifications at 50%, 75%, and 90% of your monthly budget.
- [ ] **Per-User Quotas** — Enforce a maximum number of AI generations per user per day/month.
- [ ] **IP-Based Global Limits** — Add a secondary layer of rate limiting based on IP to stop botnets even if they create multiple accounts.
- [ ] **Model Switching** — Fallback to cheaper models (e.g., GPT-4o-mini, Gemini Flash) when a user approaches their limit.
- [ ] **Automatic Service Cutoff** — If a cost-threshold is breached, gracefully disable only the expensive features, not the whole app.

⚠️ WARNING: A single leaked API key or a missing rate limit on an AI endpoint can rack up a $10,000+ bill in hours. Budget caps are your "financial circuit breaker."

---

## 🛑 STOP: Performance Gate

Before deploying performance-sensitive changes:

1. [ ] Has the change been profiled with before/after measurements?
2. [ ] Do all API endpoints meet their response target?
3. [ ] Are database queries using appropriate indexes (verified with EXPLAIN)?
4. [ ] Is caching implemented where beneficial with proper invalidation?
5. [ ] Has load testing been performed at 2x expected peak?

---

## Security Checkpoint

- [ ] Rate limiting prevents resource exhaustion — all endpoints
- [ ] **Budget caps and alerts** are configured in all 3rd-party provider dashboards
- [ ] **Usage quotas** are enforced server-side for all expensive AI/API operations
- [ ] Request body size limits prevent memory attacks — no unbounded input
- [ ] Query complexity limits prevent DoS — no arbitrarily expensive queries
- [ ] Caching respects authorization — one user's cached data is not visible to another
- [ ] CDN cache keys include authorization context — prevent cache poisoning
