# CACHING — 2026-05-08

## Findings

### CACHE KEY SCOPE — HIGH

**Finding:** The manifest hash is computed from files directly in `skill_dir`
(non-recursive). The ref walk recurses into files outside `skill_dir` up to
`depth_limit`. The output (`files`, `broken_refs`) therefore depends on external files
not included in the cache key. Stale cache hits are possible with no invalidation signal.

**Reasoning:** `hash-record-manifest` hashes only `skill_dir` direct files (R-HASH-1).
The subagent walks transitive refs — `../dispatch/SKILL.md`, `../hash-record/SKILL.md`,
etc. — and includes those paths in the returned file list. If `dispatch/SKILL.md` adds a
new ref to `../new-skill/SKILL.md`, the cache returns the old list missing `new-skill`.
Publish pipelines that trust this output to copy exactly the right files to dist would
silently produce an incomplete package. Cached `broken_refs` are similarly stale: a ref
broken at scan time that gets resolved externally (file created) remains in `broken_refs`
on cache hit. The caching spec explicitly flags this pattern: "If parameters, flags, or
environment state affect the result, they must be included in the hash. Omitting them
causes stale cache hits."

**Recommendation:** Document the scope limitation in `spec.md` (Known Limitations),
`uncompressed.md` (probe step note), and `instructions.uncompressed.md` (Rules).
For a full fix: expand the cache key to include hashes of all directly referenced
external files (a shallow one-level walk before the cache probe). This adds one fast
file-read pass per call vs. guaranteed freshness on transitive dep changes — requires
operator decision on tradeoff. Alternatively, expose an optional `force` parameter that
bypasses the cache entirely.

**Action taken:** pending — documentation notes applied to `spec.md`,
`uncompressed.md`, and `instructions.uncompressed.md`; cache key redesign requires
operator judgment.
