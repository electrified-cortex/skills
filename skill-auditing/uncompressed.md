---
name: skill-auditing
description: Audit a skill for quality, classification, cost, and compliance with the skill-writing spec. Triggers — audit this skill, check skill quality, review skill compliance, validate skill structure, skill needs review.
---

# Skill Auditing

Apply the `../markdown-hygiene` skill with `--fix` to every `.md` file in the target skill folder — in parallel where the runtime supports it. Hygiene is always run with fix — clean before audit, every time. Findings live in their own `.hash-record/<file-hash>/markdown-hygiene/claude-haiku.md` records and stay separate from the audit body.

Then without reading `instructions.txt` yourself, spawn a zero-context, haiku-class sub-agent (in the background if possible):

**Claude Code:** `Agent` tool. Pass: `"Read and follow instructions.txt here. Input: skill_path=<path> --filename claude-haiku [--fix] [--uncompressed]"`

**VS Code / Copilot:** `runSubagent(model: "Claude Haiku 4.5", prompt: "Read and follow instructions.txt in <skill_dir>. Input: skill_path=<path> --filename claude-haiku [--fix] [--uncompressed]")`

Returns: `PATH: <abs-path-to-record.md>` on success, `ERROR: <reason>` on pre-write failure.

Non-haiku callers: see `../hash-record/filenames.md` for the canonical `--filename` value.

NEVER READ OR INTERPRET `instructions.txt` YOURSELF. Let the sub-agent do the work.
