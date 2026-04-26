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
covers 3 phases: Spec Gate (5 checks), Skill Smoke (8 checks), Spec
Compliance (19 checks + 1 informational eval check).

## Which model class to dispatch

The latest haiku-class model is sufficient for most audits.

## When to audit which artifact

| Intent | Mode |
| --- | --- |
| Regression / smoke check | default (compiled runtime) |
| Building or revising | `--uncompressed` until source converges, then default for final pass |

## False positive guards

These patterns are CORRECT, never findings:

- Iteration-safety 2-line pointer in spec / uncompressed / SKILL.md
  (the caller blurb) — required by R-FM-9.
- Verbatim Rule B quote inside the iteration-safety skill itself —
  that is its canonical home.
- Trigger phrases in the frontmatter description — required by
  R-FM-10.
- Description ending with a tier-label suffix is a SEPARATE finding
  (A-FM-6) — flag the suffix, but not the description itself.
- (A-XR-1) Subject-matter mentions of `uncompressed.md` / `spec.md`
  file types within skill-auditing's own artifacts are NOT violations —
  this skill audits these files as targets and must name them. Only
  path-based cross-pointers to ANOTHER skill's files are violations.

If a pattern matches one of the above, do not raise it as a finding.
Saying nothing is correct.

## Iteration Safety

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.

After Phase 3: read `eval.txt` for the eval-presence check (informational; does not affect verdict).

## Output

Output follows the `audit-reporting` skill at `../audit-reporting/SKILL.md`. Apply its path shape (including target-kind), frontmatter requirements, and .gitignore check before writing any report. Targets are `skills/**` → target-kind is `skill`.

Related: `skill-writing`, `spec-auditing`, `compression`
