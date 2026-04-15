---
name: markdown-hygiene
description: Fix all markdownlint violations in a .md file. Zero errors gate. Dispatch skill.
---

# Markdown Hygiene

Dispatch via Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory). Input: `file_path=<path> result_file=<path>`"

- `file_path` (required): Absolute path to .md file
- `result_file` (required): Absolute path for report

Returns: CLEAN (0 errors), FIXED (errors→0), or PARTIAL (unfixable remain).

Run after compression, before stamping, before committing .md files.

Related: `compression` (run hygiene after compressing), `skill-auditing` (includes hygiene check), `spec-writing`
