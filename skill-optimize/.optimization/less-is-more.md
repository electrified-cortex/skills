# LESS IS MORE — 2026-04-29

**Severity:** LOW (deferred)

**Finding:** The fallback assessor heuristics table in `uncompressed.md` is
detailed enough to be partial spec content inside an instruction file. It is
load-bearing for the "qualifier dispatch unavailable" fallback path. Fix
deferred until the dispatch pattern matures and the fallback becomes a true
edge case.

**Action taken:** No change. Finding logged for a future pass when the
qualifier dispatch path is proven stable.
