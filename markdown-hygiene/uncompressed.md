---
name: markdown-hygiene
description: Fix markdownlint violations in a .md file. Triggers — fix markdown, lint markdown, normalize formatting, clean up .md, MD violations, markdownlint pass.
---

# Markdown Hygiene

Without reading `instructions.txt` yourself, use a Dispatch agent (zero context, haiku-class): "Read and follow `instructions.txt` (in this directory).
Input: `<file_path> --model-id <id> [--fix] [--source <src> --target <dst>] [--ignore <RULE>[,<RULE>...]] [--force]`"

Returns: `CLEAN` | `findings: <abs-path-to-record.md>` | `ERROR: <reason>`.

## Model-id reference

Pass the exact string verbatim via `--model-id` based on which model class the dispatch will run on. The executor consumes the value without inference.

| Model class | `--model-id` value |
| --- | --- |
| Claude Haiku 4.5 | `claude-haiku-4-5` |
| Claude Sonnet 4.6 | `claude-sonnet-4-6` |
| Claude Opus 4.7 | `claude-opus-4-7` |
| GPT 5.3 codex | `gpt-5-3-codex` |
