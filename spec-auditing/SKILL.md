---
name: spec-auditing
description: >-
  Audit spec/companion pair or spec alone. Dispatch instructions.txt —
  don't audit inline.
---

# Spec Auditing

Don't read `instructions.txt` yourself. Use Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory). Input: `<target-path> [--spec <spec-path>] [--fix]`"

Don't attempt spec auditing inline. Inline attempts produce shallow, inconsistent audits. Dispatched agent runs in isolated context, strict disposition (see `instructions.txt`).

Parameters:
`target-path` (required): path to spec or companion
`--spec <spec-path>` (optional): explicit spec path (pair-audit mode)
`--fix` (optional): fix mode — target must be git-tracked and clean; modifies target to match spec, up to 3 passes

Returns: Pass / Pass with Findings / Fail. Each finding: Finding ID, Severity, Title, Affected file(s), Evidence (with quote), Explanation, Recommended fix.

One skill per invocation. Multiple subjects → separate runs.

Modes:
Audit (default) — read-only. Returns Pass / Pass with Findings / Fail.
Fix (`--fix`) — modifies target to match spec. Up to 3 passes with re-audit.
Spec-only — explicitly requested or target is `spec.md` with no companion. Audits spec quality: Completeness, Enforceability, Structural Integrity, Economy, Terminology, Internal Consistency. Coverage Summary: N/A — spec-only mode, no companion present. Targeting `spec.md` without explicit spec-only request → auto-detects companion (sibling `<name>.md`), upgrades to Pair-Audit if found.

STOP Conditions:
| Condition | Action |
| --- | --- |
| Target missing or unreadable | STOP: target file missing |
| Spec missing when required | STOP: spec file missing |
| Can't read resolved file set fully | STOP: incomplete input |
| `--fix` target not git-tracked and clean | STOP: target must be git-tracked and clean |
| Approve or stamp mode requested | STOP: approve mode not supported |
| `--fix` in spec-only mode | Report fix mode unavailable; continue with read-only audit |

When to Use:
Before committing compressed files (post-compression verification)
Checking agent files against `.spec.md` companions
Validating skill impls against skill specs
Detecting drift between spec and impl
Auditing spec in isolation (spec-first authoring, before companion exists)

Multi-pass audit: fix findings, re-audit, max 3 passes.

Related: `spec-writing` (governs specs), `skill-auditing` (audits skills), `compression` (exemplar dispatch pattern)
