---
name: skill-auditing
version: 1.0
description: Audit a skill for quality, classification, cost, and compliance with the skill-writing spec. Triggers — audit this skill, check skill quality, review skill compliance, validate skill structure, skill needs review.
---

Without reading `instructions.txt` yourself, use a Dispatch agent (zero context, haiku-class): "Read and follow `instructions.txt` (in this directory).
Input: `skill_path=<path> --filename claude-sonnet [--fix] [--uncompressed]`"

`skill_path` (required): path to SKILL.md
`--filename <name>` (required): exact filename string for record file and frontmatter `model:` field; lowercase-hyphenated vendor-class only (e.g. `claude-sonnet`, `claude-opus`); use VERBATIM, no inference, no sub-version. Missing -> `ERROR: --filename required`, stop.
`spec_path` (optional): companion spec if not co-located
`--fix` (optional): single-pass fix mode on source files. Never modifies `spec.md`, `README.md`, `SKILL.md`, `instructions.txt`.
`--uncompressed` (optional): audit uncompressed source files instead of compiled runtime.

Returns: `PATH: <abs-path-to-record.md>` on success, `ERROR: <reason>` on pre-write failure.

For non-sonnet dispatch, see `../hash-record/filenames.md` for canonical `--filename` value.

Iteration Safety:
Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.

Related: `skill-writing`, `spec-auditing`, `compression`
