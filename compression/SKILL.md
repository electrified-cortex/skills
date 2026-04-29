---
name: compression
description: Compress .md and text files via subagent dispatch. Triggers — compress this file, reduce tokens, shrink instructions, caveman compress, ultra/full/lite compress.
---

⚠ Never compress spec files (*.spec.md — token cost acceptable; meaning loss is not).

## Input

`<file-path>` — path to target file

Parameters:

- `<file-path>` (required): file to compress.
- `--tier` (optional): `none` | `lite` | `full` | `ultra`; default `ultra`.
- `--source <src> --target <dst>` (optional): source-to-target mode; no git check; source untouched.
- In-place mode: target must be git-tracked and clean before modification.
- Preserves: code blocks, URLs, technical terms, logic words (not/must/only), actors, normative language (Preserve List). No exceptions at any tier.
- When target is SKILL.md and source H1 matches frontmatter `name:`, H1 is stripped from target (A-FM-3 compliance).

## Dispatch

Don't read `instructions.txt` yourself — spawn zero-context, standard-tier sub-agent:

Claude Code: `Agent` tool. Pass: "Read and follow `instructions.txt` here. Input: `<file-path> [--tier <none|lite|full|ultra>] [--source <src> --target <dst>]`"

VS Code / Copilot: `runSubagent(model: "Claude Sonnet 4.6", prompt: "Read and follow `instructions.txt` in this directory. Input: `<file-path> [--tier <none|lite|full|ultra>] [--source <src> --target <dst>]`")`

Returns: `<before>-><after> bytes | <N>% reduction | <tier> | <mode> | hygiene: clean|fixed N|N warning(s)`
