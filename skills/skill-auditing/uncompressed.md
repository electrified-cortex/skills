---
name: skill-auditing
description: Audit a skill for quality, classification, cost, and compliance with the skill-writing spec.
---

# Skill Auditing

Without reading `instructions.txt` yourself, use a Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory).
Input: `skill_path=<path> result_file=<path> [--fix]`"

- `skill_path` (required): Absolute path to SKILL.md
- `result_file` (required): Absolute path for audit report
- `spec_path` (optional): Companion spec if not co-located
- `--fix` (optional): single-pass fix mode against authoritative source files.
  Never modifies `spec.md`, `README.md`, `SKILL.md`, `instructions.txt`.- `--uncompressed` (optional): audit uncompressed source files
  (`uncompressed.md`, `instructions.uncompressed.md`) instead of compiled
  runtime.
Returns: verdict (PASS / NEEDS_REVISION / FAIL) and issues. Checklist
covers 3 phases: Spec Gate (5 checks), Skill Smoke (5 checks), Spec
Compliance (10 checks).

Related: `skill-writing`, `spec-auditing`, `compression`
