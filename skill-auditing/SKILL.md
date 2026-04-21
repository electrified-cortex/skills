---
name: skill-auditing
description: Audit a skill for quality, classification, cost, and compliance with the skill-writing spec.
---

Dispatch (Dispatch agent, zero context): "Read and follow `instructions.txt` (in this directory). Input: `skill_path=<path> result_file=<path> [--fix]`"

`skill_path` (required): path to SKILL.md
`result_file` (required): path for audit report
`spec_path` (optional): companion spec if not co-located
`--fix` (optional): single-pass repair of `uncompressed.md` and `instructions.uncompressed.md` (sibling sources only). Runs only on NEEDS_REVISION; refuses files with pending git changes; refuses paths outside the skill directory. Never modifies `spec.md`, `README.md`, `SKILL.md`, or `instructions.txt`. Caller recompresses + re-audits.

Returns: verdict (PASS / NEEDS_REVISION / FAIL) + issues.
Checklist covers 3 phases: Spec Gate (5 checks), Skill Smoke (5 checks), Spec Compliance (10 checks).

Tiered model strategy: dispatch inexpensive/fast model for iterate passes, default model for final sign-off.

Related: `skill-writing`, `spec-auditing`, `compression`
