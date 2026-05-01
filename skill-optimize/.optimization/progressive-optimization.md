# PROGRESSIVE OPTIMIZATION — 2026-04-30

**Severity:** LOW (deferred)

**Finding:** Tier ranking in `progressive-optimization.spec.md` (draft) doesn't
perfectly match the Topic Index ordering in `uncompressed.md` (e.g., CACHING
is 2nd in index but Tier 3 in spec). The spec tier ranking is labeled "draft
to be validated empirically" — index is the authoritative execution order.
The tracking log doesn't record which topic spec version was used per
analysis run; if a topic spec changes between runs, the skip logic won't
trigger re-analysis.

**Action taken:** No change. Deferred — version tracking only needed if
topic specs evolve rapidly between runs. Add `spec-hash` column to
optimize-log if that becomes a problem.
