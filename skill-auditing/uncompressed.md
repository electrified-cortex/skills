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

Returns: verdict (PASS / NEEDS_REVISION / FAIL) and issues. Checklist
covers 3 phases: Spec Gate (5 checks), Skill Smoke (5 checks), Spec
Compliance (10 checks).

Tiered model strategy: dispatch an inexpensive/fast model for iterate
passes, default model for final sign-off.

Related: `skill-writing`, `spec-auditing`, `compression`
