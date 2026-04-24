---
name: iteration-safety
description: Rules for iterating audit, compression, hygiene, or review passes. Reference this skill from callers; do not embed these rules elsewhere.
---

# Iteration Safety

## Rules

**Rule A — Fix before re-pass.** If a pass returns findings, resolve them before running another pass against the same source. Resolve means fix the source, dispatch the fix, or (where the calling skill permits) record an accept/waive rationale. Running another pass without resolving prior findings is forbidden.

**Rule B — Never re-pass on unchanged content.** "Never re-audit a file that has not been modified since the previous audit, period, full stop." If the source is unchanged since the prior pass, the verdict is deterministic. Re-dispatch is forbidden.

Rule B's opening sentence is verbatim and must not be reworded.

## Caller obligations

Before dispatching a follow-up pass, verify:

1. At least one source file has changed since the previous pass (satisfies Rule B).
2. If the previous pass returned findings, those findings have been resolved or recorded (satisfies Rule A).

If either check fails, do not re-dispatch.

## How to cite this skill

Calling skills reference this skill with a short blurb:

> **Iteration Safety.** Do not re-audit unchanged files. See `skills/electrified-cortex/iteration-safety/` for Rule A and Rule B, including caller obligations.

Do not restate Rule B's verbatim quote in caller skills.
