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

Tiered model pattern: Haiku for iteration, Sonnet for
final sign-off. Run Haiku until PASS, then one Sonnet
pass to confirm. Only Sonnet PASS = production-ready.

Related: `skill-writing`, `spec-auditing`, `compression`
