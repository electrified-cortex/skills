# CACHING — 2026-05-03

**Severity:** MEDIUM
**Finding:** The manifest hash for the spec-auditing cache key covers only input file contents (target spec + companion). The `--kind` flag (meta vs domain) is not included. Auditing the same unchanged files first with `--kind meta`, then `--kind domain`, would return a stale cache hit — the cached meta-mode result would be returned for the domain-mode request. These two modes produce different results for Unauthorized Additions (§9), so the stale hit is a wrong verdict.

Evidence: `instructions.uncompressed.md §Gate HC`: manifest hash computed from file contents only. `spec.md §Manifest Hash`: "Compute from all input files (target spec and companion, if present)" — no parameter hashing.

**Action taken:** pending — requires spec and instructions update to include effective audit kind in manifest hash or use distinct operation_kind per mode (e.g. `spec-auditing/v1/meta` vs `spec-auditing/v1/domain`). Operator judgment required on preferred approach.
