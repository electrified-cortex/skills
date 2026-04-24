---
name: skill-auditing
description: Audit a skill for quality, classification, cost, and compliance with the skill-writing spec.
---

Don't read `instructions.txt` yourself. Dispatch (zero context): "Read and follow `instructions.txt` (in this directory). Input: `skill_path=<path> result_file=<path> [--fix]`"

`skill_path` (required): absolute path to SKILL.md
`result_file` (required): absolute path for audit report
`spec_path` (optional): companion spec if not co-located
`--fix` (optional): single-pass fix mode against authoritative source files. Never modifies `spec.md`, `README.md`, `SKILL.md`, `instructions.txt`.
`--uncompressed` (optional): audit uncompressed source files (`uncompressed.md`, `instructions.uncompressed.md`) instead of compiled runtime.

Returns: verdict (PASS / NEEDS_REVISION / FAIL) + issues. Checklist: Spec Gate (5), Skill Smoke (5), Spec Compliance (10).

## Iteration Safety

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.

## Output

Output follows the `audit-reporting` skill at `../audit-reporting/SKILL.md`. Apply its path shape (including target-kind), frontmatter requirements, and .gitignore check before writing any report. Targets are `skills/**` → target-kind is `skill`. Caller must set `result_file` to the audit-reporting path computed for the target (using audit-reporting's path shape including target-kind).

Related: `skill-writing`, `spec-auditing`, `compression`
