---
name: skill-auditing
description: Audit a skill for quality, classification, cost, and compliance with the skill-writing spec. Triggers — audit this skill, check skill quality, review skill compliance, validate skill structure, skill needs review.
---

# Skill Auditing

## Input

`<skill_path>` — absolute path to the target skill's `SKILL.md`
`<flags>` — optional, any combination of `--fix` `--uncompressed`

- `--fix`: single-pass fix on `uncompressed.md` and `instructions.uncompressed.md` when the audit verdict is `NEEDS_REVISION`. Refuses if the skill dir has pending git changes.
- `--uncompressed`: audit the source files (`uncompressed.md`, `instructions.uncompressed.md`) instead of the compiled artifacts (`SKILL.md`, `instructions.txt`).

## Inspect

Variables:

`<instructions>` = `instructions.txt` (this folder; NEVER READ THIS FILE)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `skill_path=<skill_path> [--fix] [--uncompressed]`
`<tier>` = `fast-cheap`
`<description>` = `Auditing skill: <skill_path>`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`

Follow `dispatch` skill. See `../dispatch/SKILL.md`.
Returns: `PATH: <abs-path-to-record.md>` | `ERROR: <reason>`
