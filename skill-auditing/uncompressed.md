---
name: skill-auditing
version: 1.0
description: Audit a skill for quality, classification, cost, and compliance with the skill-writing spec. Triggers — audit this skill, check skill quality, review skill compliance, validate skill structure, skill needs review.
---

# Skill Auditing

Spawn a zero-context, haiku-class sub-agent in the background:

**Claude Code:** `Agent` tool. Pass: `"Read and follow instructions.uncompressed.md here. Input: skill_path=<path> --filename claude-haiku [--fix] [--uncompressed]"`

**VS Code / Copilot:** `runSubagent(model: "Claude Haiku 4.5", prompt: "Read and follow instructions.uncompressed.md in <skill_dir>. Input: skill_path=<path> --filename claude-haiku [--fix] [--uncompressed]")`

Don't read `instructions.uncompressed.md` yourself.

Returns: `PATH: <abs-path-to-record.md>` on success, `ERROR: <reason>` on pre-write failure.

Non-haiku callers: see `../hash-record/filenames.md` for the canonical `--filename` value.

Don't re-audit unchanged files (cache HIT — see `../iteration-safety/SKILL.md`).
