---
name: skill-auditing
description: Audit skill for quality, classification, cost, compliance with skill-writing spec. Triggers — audit this skill, check skill quality, review skill compliance, validate skill structure, skill needs review.
---

Using the `../markdown-hygiene` skill, collect all the markdown issues for all the files in the target skill folder. The hygiene records land in `.hash-record/` keyed by each file's content hash; the auditor reads those cached records directly — it does NOT dispatch markdown-hygiene.

Then spawn a zero-context, haiku-class sub-agent in the background:

**Claude Code:** `Agent` tool. Pass: `"Read and follow instructions.txt here. Input: skill_path=<path> --filename claude-haiku [--fix] [--uncompressed]"`

**VS Code / Copilot:** `runSubagent(model: "Claude Haiku 4.5", prompt: "Read and follow instructions.txt in <skill_dir>. Input: skill_path=<path> --filename claude-haiku [--fix] [--uncompressed]")`

Don't read `instructions.txt` yourself.

Returns: `PATH: <abs-path-to-record.md>` on success, `ERROR: <reason>` on pre-write failure.

Non-haiku callers: see `../hash-record/filenames.md` for the canonical `--filename` value.

Don't re-audit unchanged files (cache HIT — see `../iteration-safety/SKILL.md`).
