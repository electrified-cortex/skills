---
name: compression
description: Compress .md files via subagent dispatch. Supports in-place, source→target, and untracked fallback modes.
---

Phase 0 (`.md` source): host runs `markdown-hygiene --filename claude-haiku [--fix]` on source; pass verdict as `--hygiene-verdict <path>`.

Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory). Input: `<file-path> [--tier <lite|full|ultra>] [--source <src> --target <dst>] [--hygiene-verdict <path>]`" (default tier: ultra)

file-path (required): file to compress
--tier (optional): lite | full | ultra; default ultra
--source X --target Y (optional): source→target mode; no git check; X untouched
--hygiene-verdict (optional): path to Phase 0 verdict file from host

Returns: `<before>→<after> bytes | <N>% reduction | <tier> | <mode>` + hygiene lines if `.md`

Don't re-audit unchanged files.
See `../iteration-safety/SKILL.md`.
