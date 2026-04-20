---
name: spec-auditing
description: >-
  Audit a spec/companion pair or a spec alone. Dispatch instructions.txt —
  don't audit inline.
---

# Spec Auditing

Dispatch isolated agent (Dispatch agent, zero context): "Read and follow `instructions.txt` (in this directory). Input: `<target-path> [--spec <spec-path>] [--fix]`"

Don't attempt spec auditing inline. Agent runs in isolated context with strict disposition (skeptical, evidence-based, non-creative). Inline attempts produce shallow, inconsistent audits.

Modes:
- Audit (default) — read-only, returns Pass / Pass with Findings / Fail.
- Fix (`--fix`) — modifies target to match spec, up to 3 passes with re-audit.
- Spec-only (auto-detected) — target is `spec.md` with no companion; audits spec quality alone. Auto-upgrades to pair-audit if companion found via auto-detect.

When to use: pre-commit compressed file verification; agent files vs `.spec.md` companions; skill impls vs skill specs; drift detection; auditing a spec before its companion exists.

Multi-pass audit: fix findings, re-audit until PASS.

Related: `spec-writing` (governs specs), `skill-auditing` (audits skills), `compression` (exemplar dispatch pattern)
