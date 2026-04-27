---
name: markdown-hygiene
description: Fix markdownlint violations in a .md file. Triggers — fix markdown, lint markdown, normalize formatting, clean up .md, MD violations, markdownlint pass.
---

# Markdown Hygiene

Without reading `instructions.txt` yourself, use a Dispatch agent (zero context, haiku-class): "Read and follow `instructions.txt` (in this directory).
Input: `<file_path> [--fix] [--source <src> --target <dst>] [--ignore <RULE>[,<RULE>...]] [--force]`"

Default (no `--fix`): detect violations only, write one record, return PATH. File not modified — no git-state check needed.
`--fix`: detect then apply fixes. Requires tracked+clean target (or `--source/--target`). Two records if violations found: one at the original hash (FINDINGS), one at the post-fix hash (FIXED or PARTIAL).
`--source/--target` → source untouched; implies `--fix`. No git-state check.

Returns: `PATH: <abs-path-to-record.md>` on success, `ERROR: <reason>` on pre-write failure. `--force` bypasses cache.

Record frontmatter uses `model: <model-id>` (not `actor`).

Related: `compression`, `skill-auditing`, `spec-writing`, `hash-record`
