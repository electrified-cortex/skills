---
name: skill-auditing
description: Audit a skill for quality, classification, cost, and compliance with the skill-writing spec.
---

# Skill Auditing

Don't read `instructions.txt` yourself. Dispatch (zero context): "Read and follow `instructions.txt` (in this directory). Input: `skill_path=<path> result_file=<path> [--fix]`"

`skill_path` (required): absolute path to SKILL.md
`result_file` (required): absolute path for audit report
`spec_path` (optional): companion spec if not co-located
`--fix` (optional): single-pass fix mode. Auditor modifies `uncompressed.md` and `instructions.uncompressed.md` (siblings of `skill_path`) to align with spec. Runs only on NEEDS_REVISION; refused on pending git changes (untracked, unstaged, staged, merge-conflicted) or paths escaping skill dir. `spec.md`, `README.md`, compiled runtime files (`SKILL.md`, `instructions.txt`) never modified — caller recompresses via `compression` skill and re-runs auditor for verification.

Returns: verdict (PASS / NEEDS_REVISION / FAIL) + issues. Checklist: Spec Gate (5), Skill Smoke (5), Spec Compliance (10).

Related: `skill-writing`, `spec-auditing`, `compression`
