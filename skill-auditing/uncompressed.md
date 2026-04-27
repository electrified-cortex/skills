---
name: skill-auditing
version: 1.0
description: Audit a skill for quality, classification, cost, and compliance with the skill-writing spec. Triggers — audit this skill, check skill quality, review skill compliance, validate skill structure, skill needs review.
---

# Skill Auditing

Without reading `instructions.uncompressed.md` yourself, use a Dispatch agent (zero context, haiku-class): "Read and follow `instructions.uncompressed.md` (in this directory).
Input: `skill_path=<path> [--fix] [--uncompressed]`"

- `skill_path` (required): Absolute path to SKILL.md
- `spec_path` (optional): Companion spec if not co-located
- `--fix` (optional): single-pass fix mode against authoritative source files. Never modifies `spec.md`, `README.md`, `SKILL.md`, `instructions.txt`.
- `--uncompressed` (optional): audit uncompressed source files instead of compiled runtime.

Returns: `PATH: <abs-path-to-record.md>` on success, `ERROR: <reason>` on pre-write failure.

## Iteration Safety

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.
