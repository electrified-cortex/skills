# CACHING — 2026-05-01

**Severity:** LOW
**Finding:** Idempotency gap on explicit topic path — when `<topic>` is passed directly, Step 2's log-exclusion logic is bypassed and already-resolved topics can be re-analyzed and generate duplicate log rows.
**Action taken:** Added Step 2b — explicit topic guard. If `<topic>` is provided and already `clean`/`acted`/`rejected` in the log, emit `SKIP: <topic> already <status> — pass --force to re-analyze` and stop.
