---
name: skill-auditing
description: Audit a skill for quality, classification, cost, and compliance with the skill-writing spec.
---

Dispatch (Dispatch agent, zero context): "Read and follow `instructions.txt` (in this directory). Input: `skill_path=<path> result_file=<path>`"

`skill_path` (required): path to SKILL.md
`result_file` (required): path for audit report
`spec_path` (optional): companion spec if not co-located

Returns: verdict (PASS / NEEDS_REVISION / FAIL),
9-point checklist, issues.

Tiered model strategy: dispatch inexpensive/fast model for iterate passes, default model for final sign-off.

Related: `skill-writing`, `spec-auditing`, `compression`
