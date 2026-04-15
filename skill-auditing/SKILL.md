---
name: skill-auditing
description: Audit a skill for quality, classification, cost, and compliance with the skill-writing spec.
---

# Skill Auditing

Dispatch an isolated agent (Dispatch agent, zero context): "Read and follow
`instructions.txt` (in this directory). Input: `skill_path=<path> result_file=<path>`"

Parameters:
- `skill_path` (string, required): Absolute path to SKILL.md to audit
- `result_file` (string, required): Absolute path to write audit report
- `spec_path` (string, optional): Path to companion spec if not co-located

Returns: Audit report with verdict (PASS / NEEDS_REVISION / FAIL), 8-point
checklist, issues, and recommendation.

Related: `skill-writing` (rules enforced), `spec-auditing` (spec quality),
`compression` (exemplar dispatch pattern)
