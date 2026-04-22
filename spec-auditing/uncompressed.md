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

**Returns:** Pass / Pass with Findings / Fail. Each finding includes: Finding ID, Severity, Title, Affected file(s), Evidence (with quote), Explanation, Recommended fix.

Dispatch tier: read-only audit may use an inexpensive iterate tier.
If `--fix` is requested, dispatch to an edit-capable default tier up front; haiku-class models may struggle with inline edits.

## Modes

- **Audit** (default) — read-only. Returns Pass / Pass with Findings / Fail.
- **Fix** (`--fix`) — modifies target to match spec. Up to 3 passes with re-audit.
- **Spec-only** — used when explicitly requested for isolated spec review, or when target is `spec.md` and no companion is present.
  Audits spec quality alone: Completeness, Enforceability, Structural Integrity,
  Economy, Terminology, Internal Consistency. Coverage Summary set to:
  N/A — spec-only mode, no companion present. If spec-only is not explicitly
  requested, targeting `spec.md` auto-upgrades to Pair-Audit when a companion is
  found via auto-detect fallback chain: `companion:` frontmatter → sibling
  `<name>.md` for named companion specs. Folder-level `spec.md` has no extra
  universal fallback and otherwise remains spec-only.

### Companion Auto-Detect

When target ends in `spec.md`, `--spec` is not provided, and spec-only was not
explicitly requested, the auditor checks for a companion in this order:
`companion:` frontmatter field → sibling `<name>.md` for a named
companion spec. Folder-level `spec.md` has no additional universal fallback.
If the frontmatter companion
path is invalid, report that and continue the remaining chain. Reports which
file was found, or reports none and uses spec-only mode.

## STOP Conditions

| Condition | Action |
| --- | --- |
| Target file missing or unreadable | STOP: target file missing |
| Spec file missing when required | STOP: spec file missing |
| Unable to read the resolved file set fully | STOP: incomplete input |
| `--fix` target is not git-tracked and clean | STOP: target must be git-tracked and clean |
| Approve or stamp mode requested | STOP: approve mode not supported |
| `--fix` in spec-only mode | Report fix mode unavailable; continue with read-only audit |

## When to Use

- Before committing compressed files (post-compression verification)
- Checking agent files against their `.spec.md` companions
- Validating skill implementations against skill specs
- Detecting drift between spec and implementation
- Auditing a spec in isolation (spec-first authoring workflow, before companion exists)

Multi-pass audit: fix findings, re-audit, max 3 passes.

Related: `spec-writing` (governs specs), `skill-auditing` (audits skills),
`compression` (exemplar dispatch pattern)
