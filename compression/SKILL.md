---
name: compression
description: Compress .md files via subagent dispatch. Supports in-place, source→target, and untracked fallback modes.
---

# Compression

Without reading `instructions.txt` yourself, use a Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory).
Input: `<file-path> [--tier <lite|full|ultra>] [--source <src> --target <dst>]`" (default: ultra)

Modes:
`--source X --target Y` → read X, compress to Y. No git check. Primary workflow for skill dev.
Default → in-place if tracked+clean; `.compressed` alongside if untracked/dirty.

Tiers: `ultra/rules.txt` — telegraphic, abbreviations, arrows; `full/rules.txt` — drop articles, fragments OK; `lite/rules.txt` — drop filler, keep grammar

`.md` targets: post-compression markdown-hygiene pass. Fixes lint issues; remaining issues reported as warnings. Output states hygiene result — caller needs no separate pass.

## Iteration Safety

Repeated compress→audit→recompress on unchanged source = deterministic verdict + wasted work.

Rule A: audit returns NEEDS_REVISION/FAIL → fix in source (`uncompressed.md` / `instructions.uncompressed.md`) before recompressing. Unchanged source → identical artifact → same verdict. Don't recompress.

Rule B: "Never re-audit a file that has not been modified since the previous audit, period, full stop." No source change since prior pass → compressed output identical → verdict deterministic. Re-dispatch forbidden; prior verdict stands.

Gate: before any follow-up compress→audit cycle, confirm at least one authoritative source file has changed.

Related: `skill-writing` (skills workflow), `spec-auditing` (post-compression verification)
