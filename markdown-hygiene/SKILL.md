---
name: markdown-hygiene
description: Fix markdownlint violations in a .md file. Triggers — fix markdown, lint markdown, normalize formatting, clean up .md, MD violations, markdownlint pass.
---

Don't read `instructions.txt` yourself. Dispatch (zero context, haiku-class): "Read and follow `instructions.txt` (in this directory).
Input: `<file_path> [--fix] [--source <src> --target <dst>] [--ignore <RULE>[,<RULE>...]] [--force]`"

Returns: `CLEAN` | `findings: <abs-path-to-record.md>` | `ERROR: <reason>`.
