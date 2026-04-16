---
name: markdown-hygiene
description: Fix all markdownlint violations in a .md file. Zero errors gate. Dispatch skill.
---

# Markdown Hygiene

Dispatch (Dispatch agent, zero context): "Read and follow `instructions.txt` (in this directory). Input: `file_path=<path> result_file=<path>`"

`file_path` (required): absolute path to .md file; `result_file` (required): absolute path for report; `--source X --target Y` (optional): read X, fix, write Y, no git check.

Modes: `--source/--target` → source untouched; default → in-place if tracked+clean; fallback → `.fixed` alongside.

Returns: CLEAN (0 errors), FIXED (errors→0), or PARTIAL (unfixable remain).

Run after compression, before stamping, before committing .md files.

Related: `compression`, `skill-auditing`, `spec-writing`
