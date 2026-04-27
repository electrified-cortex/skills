---
name: markdown-hygiene
description: Fix markdownlint violations in a .md file. Triggers — fix markdown, lint markdown, normalize formatting, clean up .md, MD violations, markdownlint pass.
---

Without reading `instructions.txt` yourself, use a Dispatch agent (zero context, haiku-class): "Read and follow `instructions.txt` (in this directory).
Input: `<file_path> [--source <src> --target <dst>] [--ignore <RULE>[,<RULE>...]] [--force]`"

Modes: `--source/--target` → source untouched; default → in-place if tracked+clean; fallback → `.fixed` alongside.

Returns: `PATH: <abs-path-to-record.md>` on success, `ERROR: <reason>` on pre-write fail. `--force` bypasses cache.

Related: `compression`, `skill-auditing`, `spec-writing`, `hash-record`
