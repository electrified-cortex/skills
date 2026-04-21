---
name: spec-auditing
description: >-
  Audit a spec/companion pair or a spec alone. Dispatch instructions.txt —
  don't audit inline.
---

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

**Returns:** Pass / Pass with Findings / Fail verdict with numbered findings (Severity, Evidence, Recommended fix per finding)

## Modes

- **Audit** (default) — read-only. Returns Pass / Pass with Findings / Fail.
- **Fix** (`--fix`) — modifies target to match spec. Up to 3 passes with re-audit.
- **Spec-only** (auto-detected) — target is `spec.md` with no companion present.
  Audits spec quality alone: Completeness, Enforceability, Structural Integrity,
  Terminology, Internal Consistency. Coverage Summary set to: N/A — spec-only mode, no companion present. Auto-upgrades to
  Pair-Audit if a companion is found via auto-detect fallback chain:
  `<basename-without-spec-suffix>.md` → `uncompressed.md` → `SKILL.md` → `*.agent.md`.

### Companion Auto-Detect

When target ends in `spec.md` and `--spec` is not provided, the auditor checks
for a companion in this order: `<basename-without-spec-suffix>.md` (e.g.,
`skill.md` for `skill.spec.md`) → `uncompressed.md` → `SKILL.md` → `*.agent.md`.
Reports which was found (or reports none and uses spec-only mode).

## When to Use

- Before committing compressed files (post-compression verification)
- Checking agent files against their `.spec.md` companions
- Validating skill implementations against skill specs
- Detecting drift between spec and implementation
- Auditing a spec in isolation (spec-first authoring workflow, before companion exists)

Multi-pass audit: fix findings, re-audit, max 3 passes.

Related: `spec-writing` (governs specs), `skill-auditing` (audits skills),
`compression` (exemplar dispatch pattern)
