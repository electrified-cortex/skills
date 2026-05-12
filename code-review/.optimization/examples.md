# EXAMPLES — 2026-05-08

## Findings

### Input Form Ambiguity + Unenumerated Focus Values — HIGH

**Finding:** Three change_set forms (inline diff, file list, git ref) with no examples. Focus values accepted as CSV but never enumerated. Single-adversary output vs tiered output difference opaque.

**Action taken:** Added `## Examples` section to SKILL.md and uncompressed.md with:

- Three change_set form examples (inline diff, file list, git ref)
- Enumerated focus values: `security`, `correctness`, `concurrency`, `performance`, `architecture`, `testing`
