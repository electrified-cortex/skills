---
name: spec-auditing
description: Audit spec/companion pairs. Dispatch instructions.txt — don't audit inline.
---

# Spec Auditing

Dispatch an isolated agent (Dispatch agent, zero context): "Read and follow
`instructions.txt` (in this directory). Input: `<target-path> [--spec <spec-path>] [--fix]`"

**Do NOT attempt spec auditing inline.** The agent runs in isolated context with
strict disposition (skeptical, evidence-based, non-creative). Inline attempts
produce shallow, inconsistent audits.

## Modes

- **Audit** (default) — read-only. Returns Pass / Pass with Findings / Fail.
- **Fix** (`--fix`) — modifies target to match spec. Up to 3 passes with re-audit.

## When to Use

- Before committing compressed files (post-compression verification)
- Checking agent files against their `.spec.md` companions
- Validating skill implementations against skill specs
- Detecting drift between spec and implementation

Multi-pass audit: fix findings, re-audit until PASS.

Related: `spec-writing` (governs specs), `skill-auditing` (audits skills),
`compression` (exemplar dispatch pattern)
