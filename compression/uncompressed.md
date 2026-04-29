---
name: compression
description: Compress .md and text files via subagent dispatch. Triggers — compress this file, reduce tokens, shrink instructions, caveman compress, ultra/full/lite compress.
---

# Compression

## Input

`<file-path>` — the path to the target file

Parameters:

- `<file-path>` (required): file to compress.
- `--tier` (optional): `lite` | `full` | `ultra`; default `ultra`.
- `--source <src> --target <dst>` (optional): source-to-target mode; no git check; source untouched.

## Dispatch

Variables:

`<instructions>` = `instructions.txt` (this folder; NEVER READ THIS FILE)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `<file-path> [--tier <lite|full|ultra>] [--source <src> --target <dst>]`
`<tier>` = `standard`
`<description>` = `Compressing: <file-path>`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`

Follow `dispatch` skill. See `../dispatch/SKILL.md`.
Returns: `<before>-><after> bytes | <N>% reduction | <tier> | <mode>`
