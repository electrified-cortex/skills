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
- `--fix` (optional): single-pass fix mode against authoritative source files.
  Never modifies `spec.md`, `README.md`, `SKILL.md`, `instructions.txt`.
- `--uncompressed` (optional): audit uncompressed source files
  (`uncompressed.md`, `instructions.uncompressed.md`) instead of compiled
  runtime.
Returns: verdict (PASS / NEEDS_REVISION / FAIL) and issues. Checklist
covers 3 phases: Spec Gate (5 checks), Skill Smoke (5 checks), Spec
Compliance (10 checks).

## Iteration Safety

Two rules prevent wasted-work loops where the same file is audited repeatedly with no
intervening content change.

**Rule A — Fix before re-audit.** If an audit produces findings (verdict is NEEDS_REVISION or
FAIL), the agent must resolve those findings — by fixing directly or dispatching the fix —
before running another audit against the same skill. Running another audit without acting on
prior findings is forbidden.

**Rule B — Never re-audit unchanged content.** "Never re-audit a file that has not been
modified since the previous audit, period, full stop." If the source file's content is
unchanged, the verdict is deterministic and a re-audit is wasted work.

The caller must verify, before dispatching a follow-up audit, that at least one authoritative
source file (`uncompressed.md` or `instructions.uncompressed.md`) has changed since the
previous audit completed. If no file has changed, the prior verdict stands and re-dispatch
is forbidden.

## Output

Output follows the `audit-reporting` skill at `../audit-reporting/SKILL.md`. Apply its path shape (including target-kind), frontmatter requirements, and .gitignore check before writing any report. Targets are `skills/**` → target-kind is `skill`. Caller must set `result_file` to the audit-reporting path computed for the target (using audit-reporting's path shape including target-kind).

Related: `skill-writing`, `spec-auditing`, `compression`
