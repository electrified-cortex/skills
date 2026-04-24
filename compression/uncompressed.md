---
name: compression
description: Compress .md files via subagent dispatch. Supports in-place, source→target, and untracked fallback modes.
---

# Compression

Without reading `instructions.txt` yourself, use a Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory).
Input: `<file-path> [--tier <lite|full|ultra>] [--source <src> --target <dst>]`" (default: ultra)

Modes:

- `--source X --target Y` → read X, compress to Y. No git check. Primary workflow for skill development.
- Default → in-place if tracked+clean; creates `.compressed` alongside if untracked/dirty.

Tiers: `ultra/rules.txt` — telegraphic, abbreviations, arrows; `full/rules.txt` — drop articles, fragments OK; `lite/rules.txt` — drop filler, keep grammar

For `.md` targets: after compression, runs a markdown-hygiene pass on the result. Fixes lint issues in-place; remaining unfixable issues reported as warnings, never rejected. Output always states hygiene outcome so callers know no further pass is needed.

## Iteration Safety

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.

Related: `skill-writing` (skills workflow), `spec-auditing` (post-compression verification)
