# CACHING — 2026-05-08

## Findings

### Unimplemented Cache Probe — HIGH

**Finding:** spec.md defines a complete hash record (probe, write, invalidation, versioning) but SKILL.md has no cache probe step before dispatch. Running the skill twice on identical inputs triggers two full reviews.

**Action taken:** Added `## Cache Probe` section to SKILL.md and uncompressed.md with explicit probe-before-dispatch and write-after-receive steps.

### Responsibility Ambiguity — HIGH

**Finding:** spec.md defines caching but doesn't assign ownership — calling agent vs. dispatched agent. Dispatched agents in instructions.txt don't implement it.

**Action taken:** Added ownership clarification to spec.md Hash Record section: "SKILL.md owns probe + write; dispatched agents don't cache."

### Incomplete Cache Key — MEDIUM

**Finding:** spec.md cache key covered only `change_set` file contents. `tier`, `focus`, `context_pointer`, and `prior_findings` all affect output but were excluded — risking stale cache hits on same files with different parameters.

**Action taken:** Expanded cache key definition in spec.md and Cache Probe step in SKILL.md/uncompressed.md to include all input dimensions.

### Model Override Scope Unclear — LOW

**Finding:** `model` parameter shown only in single-adversary mode inputs but spec says it applies to all tiers. Not documented in main Inputs table.

**Action taken:** Added `model` to the Inputs table in SKILL.md and uncompressed.md with cache path subfolder note.
