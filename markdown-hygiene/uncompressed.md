---
name: markdown-hygiene
description: Fix markdownlint violations in a .md file. Triggers — fix markdown, lint markdown, normalize formatting, clean up .md, MD violations, markdownlint pass.
---

# Markdown Hygiene

Without reading `instructions.txt` yourself, spawn a zero-context, haiku-class sub-agent (in the background if possible):

**Claude Code:** `Agent` tool. Pass: `"Read and follow instructions.txt here. Input: <file_path> --filename claude-haiku [--fix] [--source <src> --target <dst>] [--ignore <RULE>[,<RULE>...]] [--force]"`

**VS Code / Copilot:** `runSubagent(model: "Claude Haiku 4.5", prompt: "Read and follow instructions.txt in <skill_dir>. Input: <file_path> --filename claude-haiku [--fix] [--source <src> --target <dst>] [--ignore <RULE>[,<RULE>...]] [--force]")`

Returns: `CLEAN` | `findings: <abs-path-to-record.md>` | `ERROR: <reason>`.

For non-haiku dispatch, see `../hash-record/filenames.md` for the canonical `--filename` value.

NEVER READ/INTERPRET `instructions.txt` YOURSELF. Let the sub-agent handle.
