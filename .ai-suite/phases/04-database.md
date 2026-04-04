# 04-DATABASE.md
# PURPOSE: Schema design, migrations, indexing, data integrity, and database security rules
# LOAD WHEN: Designing database schemas, writing migrations, optimizing queries, or changing data models

---

## Schema Design Rules

### Table/Collection Design
- [ ] Every table has a primary key — never create a table without one
- [ ] Use UUID or ULID for primary keys in distributed systems — auto-increment leaks count
- [ ] Use auto-increment integers for primary keys in single-DB systems — simpler, faster
- [ ] Every table has `created_at` (timestamp, not null, default now) — audit trail
- [ ] Every table has `updated_at` (timestamp, not null, auto-update) — change tracking
- [ ] Consider `deleted_at` for soft deletes — prefer soft delete for user-facing data
- [ ] Table names are plural, snake_case — `users`, `order_items`, `access_logs`
- [ ] Column names are singular, snake_case — `user_id`, `email`, `is_active`
- [ ] Boolean columns start with `is_` or `has_` — `is_active`, `has_verified_email`

### Column Rules
- [ ] All columns have explicit NOT NULL unless null has business meaning — null is a source of bugs
- [ ] Use appropriate data types — don't store numbers as strings
- [ ] Use ENUM/check constraints for bounded values — `status IN ('active', 'inactive', 'suspended')`
- [ ] Use TEXT over VARCHAR unless max length is a business rule — premature optimization
- [ ] Store monetary values as integers (cents) — avoid floating-point precision issues
- [ ] Store dates in UTC — convert to local time in the application layer
- [ ] Use JSONB sparingly — only for truly unstructured data, not to avoid schema design

### Relationships
- [ ] Define foreign keys explicitly — enforce referential integrity at the DB level
- [ ] Choose ON DELETE behavior for every FK — CASCADE, SET NULL, or RESTRICT
- [ ] Index all foreign key columns — joins without indexes cause full table scans
- [ ] Use junction tables for many-to-many — never comma-separated IDs in a column
- [ ] Avoid circular foreign key dependencies — redesign the schema

⚠️ WARNING: Never store comma-separated values in a single column. This breaks normalization and makes queries impossible to optimize.

---

## Migration Rules

### Writing Migrations
- [ ] Every schema change goes through a migration — never modify schema manually
- [ ] Migrations are forward-only in production — never edit an applied migration
- [ ] Each migration does ONE thing — don't combine table creation with data backfill
- [ ] Migration files are numbered sequentially — `001_create_users.sql`, `002_add_email_index.sql`
- [ ] Test migrations on a copy of production data — catch data-specific issues
- [ ] Include a rollback/down migration — ability to undo if something goes wrong

### Safe Migration Practices
- [ ] Adding a column: add as nullable first, backfill, then add NOT NULL — avoids locking
- [ ] Renaming a column: add new, copy data, drop old — never rename directly in production
- [ ] Dropping a column: remove all code references first, then drop — prevents runtime errors
- [ ] Adding an index: use CREATE INDEX CONCURRENTLY — avoids table locks
- [ ] Changing column type: add new column, migrate data, drop old — prevents data loss
- [ ] Large data migrations: process in batches — avoid long-running transactions

⚠️ WARNING: Never run ALTER TABLE on a large production table without CONCURRENTLY or equivalent. Long locks cause downtime.

---

## Indexing Rules

### When to Add an Index
- [ ] All columns used in WHERE clauses frequently — enable the query planner
- [ ] All columns used in JOIN conditions — foreign keys are already listed above
- [ ] All columns used in ORDER BY — prevents sort operations
- [ ] Columns used in unique constraints — enforced by the DB usually
- [ ] Composite indexes for multi-column queries — column order matches query filter order

### When NOT to Add an Index
- [ ] Tables with fewer than 1000 rows — overhead exceeds benefit
- [ ] Columns with very low cardinality (e.g., boolean) — index doesn't help
- [ ] Tables with heavy write loads and rare reads — indexes slow writes
- [ ] Already covered by an existing composite index — redundant

### Index Rules
- [ ] Name indexes explicitly — `idx_users_email`, `idx_orders_user_id_created_at`
- [ ] Monitor index usage — drop unused indexes quarterly
- [ ] Limit to ≤5 indexes per table — unless workload analysis justifies more
- [ ] Use partial indexes for filtered queries — `WHERE is_active = true`
- [ ] Use covering indexes for frequent queries — include all selected columns

✅ DEFAULT: When unsure about indexing, add the index. An unused index has a small write penalty; a missing index has a large read penalty.

---

## Query Rules

- [ ] Never use SELECT * — list specific columns needed
- [ ] Use LIMIT on all user-facing queries — prevent unbounded result sets
- [ ] Use EXPLAIN/EXPLAIN ANALYZE before deploying new queries — verify the query plan
- [ ] Avoid N+1 queries — use JOINs or batch loading
- [ ] Use transactions for multi-step operations — ensure atomicity
- [ ] Set statement timeouts on all connections — prevent runaway queries
- [ ] Use connection pooling — don't open a new connection per request
- [ ] Parameterize all queries — NEVER concatenate user input into SQL strings

⚠️ WARNING: String concatenation in SQL queries is the #1 cause of SQL injection. Use parameterized queries ALWAYS.

---

## Data Integrity Rules

- [ ] Use database constraints over application-level checks — constraints are always enforced
- [ ] Use CHECK constraints for business rules — `CHECK (price >= 0)`, `CHECK (quantity > 0)`
- [ ] Use UNIQUE constraints for natural keys — email, username, etc.
- [ ] Use transactions for related operations — all-or-nothing consistency
- [ ] Validate data at both application AND database level — defense in depth
- [ ] Implement optimistic locking for concurrent updates — version column or updated_at check
- [ ] Regular backup validation — test restoring from backup monthly

---

## Backup and Recovery

- [ ] Automated daily backups — minimum for any production database
- [ ] Point-in-time recovery enabled — WAL archiving for PostgreSQL or equivalent
- [ ] Backups stored in a different region — protect against regional failures
- [ ] Backup restoration tested monthly — untested backups are not backups
- [ ] Recovery Time Objective (RTO) documented — how fast can you restore?
- [ ] Recovery Point Objective (RPO) documented — how much data can you lose?

---

## 🛑 STOP: Database Gate

Before applying any schema change:

1. [ ] Has the migration been tested on a copy of production data?
2. [ ] Is there a rollback migration?
3. [ ] Are all new columns nullable or have defaults?
4. [ ] Are foreign keys and indexes defined?
5. [ ] Has the query plan been verified with EXPLAIN?
6. [ ] Is the migration safe for zero-downtime deployment?

---

## Security Checkpoint

- [ ] All queries use parameterized statements — no string concatenation
- [ ] Database credentials in environment variables — not in code or config files
- [ ] Database accessible only from application servers — not from public internet
- [ ] Separate read-only credentials for reporting — least privilege
- [ ] PII columns identified and documented — encryption or masking plan exists
- [ ] Audit logging enabled for sensitive tables — who changed what and when
- [ ] Connection strings use SSL/TLS — no unencrypted database connections
