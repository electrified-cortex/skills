# TEMPORAL-DECAY — 2026-05-01

## Findings

### Finding 1 — HIGH

**Signal:** All check codes (P1-SC-1 through P3-CC-4, A-XR-1, etc.) are hardcoded in `instructions.uncompressed.md`. The executor does not read the spec at audit time to derive which checks apply — it runs a fixed list. The spec has a `## Version: 1.2` field and the cache embeds `v2`, but the version bump is advisory (SHOULD), not enforced.

**Reasoning:** The "check invention prohibition" (only evaluate explicitly named checks) is correct safety hygiene — but it makes spec evolution silently invisible to the executor. If the spec adds a new check, the executor omits it with no signal. The version bump only invalidates the cache; it does not force executor logic to update. The gap between spec version and executor check set can grow unbounded across spec iterations with zero runtime indication.

**Recommendation:** Add a version-pin assertion at the top of the executor procedure: read `## Version` from `spec.md`, compare to a hardcoded constant (`BUILT_AGAINST_VERSION = "1.2"`). If they diverge, emit `ERROR: executor built against spec v<X>, current spec is v<Y> — recompile instructions before running`. Upgrade version-bump coordination from SHOULD to MUST in the spec.

**Action taken:** No change yet.
