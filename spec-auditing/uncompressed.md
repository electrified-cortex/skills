# Spec Auditing

Without reading `instructions.txt` yourself, use a Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory).
Input: `<target-path> [--spec <spec-path>] [--fix]`"

**Do NOT attempt spec auditing inline.** Inline attempts produce shallow,
inconsistent audits. The dispatched agent runs in isolated context with its
own strict disposition (defined in `instructions.txt`).

## Parameters

- `target-path` (string, required): path to spec file or companion file to audit
- `--spec <spec-path>` (string, optional): explicit path to spec file (pair-audit mode)
- `--fix` (flag, optional): enable fix mode — target must be git-tracked and clean; modifies target to match spec, up to 3 passes

**Returns:** Pass / Pass with Findings / Fail. Each finding includes: Finding ID, Severity, Title, Affected file(s), Evidence (with quote), Explanation, Recommended fix.

One skill per invocation. Chain multiple subjects as separate runs.

## Modes

- **Audit** (default) — read-only. Returns Pass / Pass with Findings / Fail.
- **Fix** (`--fix`) — modifies target to match spec. Up to 3 passes with re-audit.
- **Spec-only** — used when explicitly requested for isolated spec review, or when target is `spec.md` and no companion is present.
  Audits spec quality alone: Completeness, Enforceability, Structural Integrity,
  Economy, Terminology, Internal Consistency. Coverage Summary set to:
  N/A — spec-only mode, no companion present. When targeting `spec.md` without
  explicit spec-only request, auto-detects companion (sibling `<name>.md`) and
  upgrades to Pair-Audit if found.

## When to Use

- Before committing compressed files (post-compression verification)
- Checking agent files against their `.spec.md` companions
- Validating skill implementations against skill specs
- Detecting drift between spec and implementation
- Auditing a spec in isolation (spec-first authoring workflow, before companion exists)

Multi-pass audit: fix findings, re-audit, max 3 passes.

## Errors / Stop Gates

- **Missing target** — STOP: target file missing or unreadable
- **Spec file missing** — STOP when `--spec` provided and unresolvable
- **Incomplete input** — STOP: all resolved files must be fully read before judging
- **`--fix` on untracked/dirty target** — STOP: target must be git-tracked and clean before fix mode runs
- **Approve/stamp request** — STOP: approve mode not supported by this skill

## Output

When producing file output: follow the `audit-reporting` skill at `../audit-reporting/SKILL.md`. Apply its path shape (target-kind derived dynamically from the actual target-path using audit-reporting's derivation rules), frontmatter (mapping spec-auditing verdicts to audit-reporting vocabulary: `Pass → PASS`, `Pass with Findings → PASS_WITH_FINDINGS`, `Fail → FAIL`), and .gitignore check. Target-kind is computed from the actual target-path, not assumed to always be `spec`.

Related: `spec-writing` (governs specs), `skill-auditing` (audits skills),
`compression` (exemplar dispatch pattern)
