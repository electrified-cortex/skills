---
name: compression
description: Compress .md and text files via subagent dispatch. Triggers — compress this file, reduce tokens, shrink instructions, caveman compress, ultra/full/lite compress.
---

# Compression

Without reading `instructions.txt` yourself, spawn a zero-context, sonnet-class sub-agent (in the background if possible):

**Claude Code:** `Agent` tool. Pass: `"Read and follow instructions.txt here. Input: <file-path> [--tier <lite|full|ultra>] [--source <src> --target <dst>]"`

**VS Code / Copilot:** `runSubagent(model: "Claude Sonnet 4.6", prompt: "Read and follow instructions.txt in <skill_dir>. Input: <file-path> [--tier <lite|full|ultra>] [--source <src> --target <dst>]")`

Parameters:
- `file-path` (required): target file.
- `--tier` (optional): `lite` | `full` | `ultra`; default `ultra`.
- `--source <src> --target <dst>` (optional): source-to-target mode; no git check; source untouched.

Returns: `<before>→<after> bytes | <N>% reduction | <tier> | <mode>`

NEVER READ OR INTERPRET `instructions.txt` YOURSELF. Let the sub-agent handle.
