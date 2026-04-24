---
name: compression
description: Compress .md files via subagent dispatch. Supports in-place, source→target, and untracked fallback modes.
---

Without reading `instructions.txt` yourself, use a Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory).
Input: `<file-path> [--tier <lite|full|ultra>] [--source <src> --target <dst>]`" (default: ultra)

Modes:
`--source X --target Y` → read X, compress to Y. No git check. Primary workflow for skill dev.
Default → in-place if tracked+clean; `.compressed` alongside if untracked/dirty.

Tiers: `ultra/rules.txt` — telegraphic, abbreviations, arrows; `full/rules.txt` — drop articles, fragments OK; `lite/rules.txt` — drop filler, keep grammar

`.md` targets: post-compression markdown-hygiene pass. Fixes lint issues; remaining issues reported as warnings. Output states hygiene result — caller needs no separate pass.

## Iteration Safety

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.

Related: `skill-writing` (skills workflow), `spec-auditing` (post-compression verification)
