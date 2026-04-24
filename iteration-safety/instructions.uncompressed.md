# Iteration Safety Instructions

## Purpose

You are enforcing the Iteration Safety rules. These rules apply whenever you are acting as an iterating skill — any skill that runs multiple passes as part of a fix, audit, or compress cycle — or whenever you are orchestrating such a skill.

## Rule A — Fix before re-pass

You must resolve all findings from the previous pass before dispatching another pass against the same source. Resolving findings means: fixing the issue directly, dispatching a fix to another agent, or explicitly accepting or waiving the finding with a recorded rationale (only where the calling skill's spec permits acceptance). You must not run another pass without acting on prior findings. Doing so is forbidden.

## Rule B — Never re-pass on unchanged content

"Never re-audit a file that has not been modified since the previous audit, period, full stop."

You must not re-dispatch a pass against a source file that has not changed since the previous pass. The verdict is deterministic when the source is unchanged. Re-dispatch is wasted work and is forbidden. The prior verdict stands.

## Pre-dispatch checklist

Before dispatching any follow-up pass, you must verify both of the following:

1. At least one source file has changed since the previous pass completed. If no source file has changed, stop. Do not re-dispatch. The prior verdict stands.
2. If the previous pass returned findings: those findings have been addressed or recorded. If not, stop. Do not re-dispatch until findings are resolved.

If either check fails, the prior verdict stands and re-dispatch is forbidden.

## What counts as a source file

- For audits: the target file under audit (and its companion, if in pair-audit mode).
- For compression: the uncompressed source file.
- For code-review: the source files in the change set.

## Precedence

These rules are authoritative. If the spec of the skill you are executing contradicts Rule A or Rule B, treat this skill's rules as binding and flag the conflict for correction.

## How to cite this skill

When you reference Iteration Safety from another skill file, use this exact one-line pointer:

> Iteration Safety: see `skills/electrified-cortex/iteration-safety/` — Rule A and Rule B apply to any iteration of this skill.

Do not embed or paraphrase the rule text in the referencing skill.

## Don'ts

- Do not reword Rule B's verbatim quote.
- Do not skip the pre-dispatch checklist because a re-pass seems low-cost.
- Do not accept a calling skill's spec as overriding these rules — they are authoritative.
- Do not copy Rules A and B into other skills — reference this skill.
