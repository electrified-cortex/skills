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
- `--fix` (optional): Enable single-pass fix mode. The auditor modifies the
  authoritative source files `uncompressed.md` and `instructions.uncompressed.md`
  (siblings of `skill_path`) to align with the spec. Runs only on a NEEDS_REVISION
  verdict; refused on any candidate with pending git changes (untracked, unstaged,
  staged, or merge-conflicted) or any path that escapes the skill directory. The
  companion `spec.md`, the `README.md`, and the compiled runtime files
  (`SKILL.md`, `instructions.txt`) are never modified — the caller recompresses
  via the `compression` skill and re-runs the auditor for verification.

Returns: verdict (PASS / NEEDS_REVISION / FAIL) and issues. Checklist
covers 3 phases: Spec Gate (5 checks), Skill Smoke (5 checks), Spec
Compliance (10 checks).

Tiered model strategy: dispatch an inexpensive/fast model for iterate
passes, default model for final sign-off. Warn: some models struggle with
inline editing and may not be suitable for large files in fix mode.

Related: `skill-writing`, `spec-auditing`, `compression`
