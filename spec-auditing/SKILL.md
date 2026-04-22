---
name: spec-auditing
description: >-
  Audit a spec/companion pair or a spec alone. Dispatch instructions.txt —
  don't audit inline.
---

# Spec Auditing

Without reading `instructions.txt` yourself, use a Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory).
Input: `<target-path> [--spec <spec-path>] [--fix]`"

Don't attempt spec auditing inline — inline attempts produce shallow, inconsistent audits. The dispatched agent runs in isolated context with its own strict disposition (defined in `instructions.txt`).

Parameters:
- `target-path` (string, required): path to spec file or companion file to audit
- `--spec <spec-path>` (string, optional): explicit path to spec file (pair-audit mode)
- `--fix` (flag, optional): enable fix mode — modifies target to match spec, up to 3 passes

Returns: Pass / Pass with Findings / Fail verdict with numbered findings (Severity, Evidence, Recommended fix per finding)

Tiered model strategy: dispatch inexpensive/fast model for iterate passes, default model for final sign-off. Warn: some models struggle with inline editing and may not be suitable for large files in fix mode.

Modes:
- Audit (default) — read-only, returns Pass / Pass with Findings / Fail.
- Fix (`--fix`) — modifies target to match spec, up to 3 passes with re-audit.
- Spec-only (auto-detected) — target is `spec.md` with no companion; audits spec quality alone (Completeness, Enforceability, Structural Integrity, Terminology, Internal Consistency). Auto-upgrades to pair-audit if companion found via auto-detect fallback chain: `<basename-without-spec-suffix>.md` → `uncompressed.md` → `SKILL.md` → `*.agent.md`.

When to use: pre-commit compressed file verification; agent files vs `.spec.md` companions; skill impls vs skill specs; drift detection; auditing a spec before its companion exists.

Multi-pass audit: fix findings, re-audit until PASS.

Related: `spec-writing` (governs specs), `skill-auditing` (audits skills), `compression` (exemplar dispatch pattern)
