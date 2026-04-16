---
name: markdown-hygiene
description: Fix all markdownlint violations in a .md file. Zero errors gate. Dispatch skill.
---

# Markdown Hygiene

Dispatch via Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory). Input: `file_path=<path> result_file=<path> [--source <src> --target <dst>]`"

- `file_path` (required): Absolute path to .md file
- `result_file` (required): Absolute path for report
- `--source X --target Y` (optional): Read X, fix, write to Y. No git check.

Modes: `--source/--target` → source untouched; default → in-place if tracked+clean; fallback → `.fixed` alongside.

Returns: CLEAN (0 errors), FIXED (errors→0), or PARTIAL (unfixable remain).

Run after compression, before stamping, before committing .md files.

Related: `compression` (run hygiene after compressing), `skill-auditing` (includes hygiene check), `spec-writing`
