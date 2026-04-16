---
name: skill-auditing
description: Audit a skill for quality, classification, cost, and compliance with the skill-writing spec.
---

# Skill Auditing

Dispatch via Dispatch agent (zero context): "Read and follow
`instructions.txt` (in this directory). Input: `skill_path=<path> result_file=<path>`"

- `skill_path` (required): Absolute path to SKILL.md
- `result_file` (required): Absolute path for audit report
- `spec_path` (optional): Companion spec if not co-located

Returns: verdict (PASS / NEEDS_REVISION / FAIL), 9-point checklist, issues.

Related: `skill-writing`, `spec-auditing`, `compression`
