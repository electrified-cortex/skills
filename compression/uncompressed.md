---
name: compression
description: Compress .md and text files via subagent dispatch. Triggers — compress this file, reduce tokens, shrink instructions, caveman compress, ultra/full/lite compress.
---

# Compression

Without reading `instructions.txt` yourself, spawn a zero-context Dispatch sub-agent (sonnet-class — the Dispatch agent default; do NOT pass a haiku override):

`prompt`: `Read and follow instructions.txt here. Input: <file-path> [--tier <lite|full|ultra>] [--source <src> --target <dst>]`

**Claude Code:** `Agent` tool. `subagent_type: "Dispatch"`, `prompt: "<prompt>"`. Run in background if possible.

**VS Code / Copilot:** `runSubagent(agentName: "Dispatch", prompt: "<prompt>")`. Synchronous.

Parameters:

- `file-path` (required): file to compress.
- `--tier` (optional): `lite` | `full` | `ultra`; default `ultra`.
- `--source <src> --target <dst>` (optional): source-to-target mode; no git check; source untouched.

Returns: `<before>→<after> bytes | <N>% reduction | <tier> | <mode>`

NEVER READ OR INTERPRET `instructions.txt` YOURSELF. Let the sub-agent handle.
