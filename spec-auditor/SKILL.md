---
name: spec-auditor
description: Audit spec/companion pairs. Dispatch AGENT.md — don't audit inline.
---

# Spec Auditing

Dispatch `./AGENT.md` with `<target-path> [--spec <spec-path>] [--fix]`.
The agent handles resolution, gating, and multi-pass fix cycles.

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

Rationale: `AGENT.spec.md`
