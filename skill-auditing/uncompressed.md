---
name: skill-auditing
description: Audit a skill for quality, classification, cost, and compliance with the skill-writing spec.
---

# Skill Auditing

Without reading `instructions.txt` yourself, use a Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory).
Input: `skill_path=<path> [--fix]`"

- `skill_path` (required): Absolute path to SKILL.md
- `spec_path` (optional): Companion spec if not co-located
- `--fix` (optional): single-pass fix mode against authoritative source files.
  Never modifies `spec.md`, `README.md`, `SKILL.md`, `instructions.txt`.
- `--uncompressed` (optional): audit uncompressed source files
  (`uncompressed.md`, `instructions.uncompressed.md`) instead of compiled
  runtime.
Returns: verdict (PASS / NEEDS_REVISION / FAIL) and issues. Checklist
covers 3 phases: Spec Gate (5 checks), Skill Smoke (5 checks), Spec
Compliance (10 checks).

## When to audit which artifact

**Default — audit the compressed runtime (`SKILL.md`, `instructions.txt`)
against `spec.md`.** This is the regression / smoke check: does the
shipped artifact match the spec? The compressed runtime is what actually
runs, so that is what matters.

**Build / iteration mode — pass `--uncompressed`.** Audits the source
artifacts (`uncompressed.md`, `instructions.uncompressed.md`) instead.
Apply fixes to the source. Iterate until the source passes cleanly. Only
then recompile and run a final default-mode pass on the compressed
result.

Pick the mode by intent: regression check → default. Building or revising
→ `--uncompressed` until source converges, then default for the final
pass.

## Iteration Safety

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.

## Output

Output follows the `audit-reporting` skill at `../audit-reporting/SKILL.md`. Apply its path shape (including target-kind), frontmatter requirements, and .gitignore check before writing any report. Targets are `skills/**` → target-kind is `skill`.

Related: `skill-writing`, `spec-auditing`, `compression`
