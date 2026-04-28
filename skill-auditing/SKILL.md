---
name: skill-auditing
description: Audit skill for quality, classification, cost, compliance with skill-writing spec. Triggers — audit this skill, check skill quality, review skill compliance, validate skill structure, skill needs review.
---

Apply `../markdown-hygiene` skill with `--fix` to every `.md` file in the target skill folder. Hygiene always runs with fix — clean before audit, every time. Findings land in `.hash-record/<file-hash>/markdown-hygiene/claude-haiku.md` records, separate from the audit body.

Then spawn a zero-context, haiku-class sub-agent in the background:

**Claude Code:** `Agent` tool. Pass: `"Read and follow instructions.txt here. Input: skill_path=<path> --filename claude-haiku [--fix] [--uncompressed]"`

**VS Code / Copilot:** `runSubagent(model: "Claude Haiku 4.5", prompt: "Read and follow instructions.txt in <skill_dir>. Input: skill_path=<path> --filename claude-haiku [--fix] [--uncompressed]")`

Don't read `instructions.txt` yourself.

Returns: `PATH: <abs-path-to-record.md>` on success, `ERROR: <reason>` on pre-write failure.

Non-haiku callers: see `../hash-record/filenames.md` for the canonical `--filename` value.
