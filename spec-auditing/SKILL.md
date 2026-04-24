---
name: spec-auditing
description: >-
  Audit a spec/companion pair or a spec alone. Dispatch instructions.txt —
  don't audit inline.
---

# Spec Auditing

Don't read `instructions.txt` yourself. Use Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory).
Input: `<target-path> [--spec <spec-path>] [--fix]`"

Don't attempt spec auditing inline. Inline attempts → shallow, inconsistent audits. Dispatched agent runs in isolated context; strict disposition defined in `instructions.txt`.

Parameters:
`target-path` (required): path to spec or companion file
`--spec <spec-path>` (optional): explicit spec path (pair-audit mode)
`--fix` (flag, optional): fix mode — target must be git-tracked and clean; modifies to match spec, up to 3 passes

Returns: Pass / Pass with Findings / Fail. Each finding: Finding ID, Severity, Title, Affected file(s), Evidence (with quote), Explanation, Recommended fix.
One skill per invocation. Chain multiple subjects as separate runs.

Modes:
Audit (default): read-only. Returns Pass / Pass with Findings / Fail.
Fix (`--fix`): modifies target to match spec. Up to 3 passes with re-audit.
Spec-only: when explicitly requested for isolated spec review, or target is `spec.md` with no companion. Audits spec quality: Completeness, Enforceability, Structural Integrity, Economy, Terminology, Internal Consistency. Coverage Summary: N/A — spec-only, no companion. When targeting `spec.md` without explicit spec-only request, auto-detects companion (sibling `<name>.md`) → Pair-Audit if found.

Iteration Safety:
Rule A — fix before re-audit: if verdict is Pass with Findings or Fail, resolve findings before running another audit against the same spec. Re-auditing without acting on prior findings is forbidden.
Rule B — never re-audit unchanged content: "Never re-audit a file that has not been modified since the previous audit, period, full stop." Unchanged spec → prior verdict stands → re-dispatch forbidden.
Caller must verify spec or companion changed before dispatching follow-up audit.

When to use:
Before committing compressed files (post-compression verification)
Checking agent files against `.spec.md` companions
Validating skill impls against skill specs
Detecting spec/impl drift
Auditing spec in isolation (spec-first workflow, before companion exists)

Multi-pass audit: fix findings, re-audit, max 3 passes.

Stops: missing target → STOP; --spec unresolvable → STOP; --fix on untracked/dirty target → STOP; approve/stamp request → STOP.

## Output

When producing file output: follow the `audit-reporting` skill at `../audit-reporting/SKILL.md`. Apply its path shape (target-kind derived dynamically from the actual target-path using audit-reporting's derivation rules), frontmatter (mapping spec-auditing verdicts to audit-reporting vocabulary: `Pass → PASS`, `Pass with Findings → PASS_WITH_FINDINGS`, `Fail → FAIL`), and .gitignore check. Target-kind is computed from the actual target-path, not assumed to always be `spec`.

Related: `spec-writing` (governs specs), `skill-auditing` (audits skills), `compression` (exemplar dispatch pattern)
