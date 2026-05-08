# DISPATCH — 2026-05-08

## Findings

### CACHE PROBE PLACEMENT — HIGH

**Finding:** The manifest hash computation and hash-record probe (Steps 2–3 of
`instructions.uncompressed.md`) run inside the dispatched subagent. A subagent is
spawned on every call, including cache hits.

**Reasoning:** Cache hits are the common case for a skill operating on slowly-changing
skill folders. Spawning a full subagent to return a cached value wastes dispatch
overhead on every hit. The correct architecture runs the cheap probe in the host
(uncompressed.md) before any dispatch: compute hash → probe cache → return on hit →
dispatch only on miss. The subagent should receive `manifest_hash` as a given input,
eliminating redundant hash computation inside the subagent.

**Recommendation:** In `uncompressed.md`, add pre-dispatch Steps 1–3: resolve
`repo_root`, enumerate `skill_dir` files, compute manifest hash via
`hash-record-manifest`, probe `hash-record` — return result with `cached: true` on hit.
Pass `manifest_hash` to the subagent via `<input-args>`. In
`instructions.uncompressed.md`, accept `manifest_hash` as a provided input, remove
current Steps 2–3, begin directly at Step 4 (ref walk).

**Action taken:** pending — structural redesign affecting the host/subagent interface;
requires operator judgment before applying.

---

### TIER JUSTIFICATION — MEDIUM

**Finding:** `<tier>` is set to `standard` in `uncompressed.md` with no justification
comment.

**Reasoning:** The dispatch guide requires a parenthetical reason for non-obvious tier
choices. At a glance `standard` is not self-evident: the cached path is cheap
(suggesting `fast-cheap`) while the miss path does recursive LLM file reading
(suggesting `deep`). A comment clarifies the intent.

**Recommendation:** Add inline comment after the tier value:
`` `<tier>` = `standard` -- semantic ref walk; standard for comprehension tasks ``

**Action taken:** Applied — added tier justification comment to `uncompressed.md`.
