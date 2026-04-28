---
name: compression
description: Compress .md and text files via subagent dispatch. Triggers — compress this file, reduce tokens, shrink instructions, caveman compress, ultra/full/lite compress.
---

If source is `.md`: apply `../markdown-hygiene` skill with `--fix` before compressing. Hygiene findings land in their own `.hash-record/` records, separate from compression output.

Spawn a zero-context, haiku-class sub-agent in the background:

**Claude Code:** `Agent` tool. Pass: `"Read and follow instructions.txt here. Input: <file-path> [--tier <lite|full|ultra>] [--source <src> --target <dst>] [--hygiene-verdict <path>]"`

**VS Code / Copilot:** `runSubagent(model: "Claude Haiku 4.5", prompt: "Read and follow instructions.txt in <skill_dir>. Input: <file-path> [--tier <lite|full|ultra>] [--source <src> --target <dst>] [--hygiene-verdict <path>]")`

Don't read `instructions.txt` yourself.

file-path (required): file to compress
--tier (optional): lite | full | ultra; default ultra
--source X --target Y (optional): source→target mode; no git check; X untouched
--hygiene-verdict (optional): path to Phase 0 verdict file from host

Returns: `<before>→<after> bytes | <N>% reduction | <tier> | <mode>` + hygiene lines if `.md`

Don't re-audit unchanged files.
See `../iteration-safety/SKILL.md`.
