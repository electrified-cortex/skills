---
name: markdown-hygiene
description: Fix markdownlint violations in a .md file. Triggers — fix markdown, lint markdown, normalize formatting, clean up .md, MD violations, markdownlint pass.
---

Don't read `instructions.txt` yourself. Dispatch (zero context, haiku-class): "Read and follow `instructions.txt` (in this directory).
Input: `<file_path> --model-id claude-haiku-4-5 [--fix] [--source <src> --target <dst>] [--ignore <RULE>[,<RULE>...]] [--force]`"

Returns: `CLEAN` | `findings: <abs-path-to-record.md>` | `ERROR: <reason>`.

Replace `claude-haiku-4-5` if dispatching on a different model class:

| Model class | `--model-id` value |
| --- | --- |
| Claude Haiku 4.5 | `claude-haiku-4-5` |
| Claude Sonnet 4.6 | `claude-sonnet-4-6` |
| Claude Opus 4.7 | `claude-opus-4-7` |
| GPT 5.3 codex | `gpt-5-3-codex` |
