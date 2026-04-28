---
name: skill-auditing
version: 1.0
description: Audit skill for quality, classification, cost, compliance with skill-writing spec. Triggers — audit this skill, check skill quality, review skill compliance, validate skill structure, skill needs review.
---

Dispatch agent (zero context, haiku-class): "Read and follow `instructions.txt` (in this directory). Input: `skill_path=<path> --filename claude-sonnet [--fix] [--uncompressed]`"

skill_path (required): Absolute path to SKILL.md
--filename <name> (required): exact filename string for record file + frontmatter `model:` field; lowercase-hyphenated vendor-class only (e.g. `claude-sonnet`, `claude-opus`); use VERBATIM, no inference, no sub-version. Missing → `ERROR: --filename required`, stop.
spec_path (optional): Companion spec if not co-located
--fix (optional): single-pass fix vs authoritative source files. Never modifies `spec.md`, `README.md`, `SKILL.md`, `instructions.txt`.
--uncompressed (optional): audit uncompressed source files vs compiled runtime.

Returns: `PATH: <abs-path-to-record.md>` on success, `ERROR: <reason>` on pre-write failure.

Non-sonnet dispatch: see `../hash-record/filenames.md` for canonical `--filename` value.

Don't re-audit unchanged files. See `../iteration-safety/SKILL.md`.
