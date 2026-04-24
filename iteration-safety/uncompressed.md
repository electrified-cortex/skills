# Iteration Safety

This skill is a shared rules module. It defines two binding rules that govern any skill which iterates over audit, review, hygiene, or compression passes. It exists as a single place of truth so every iterating skill can reference these rules instead of duplicating and potentially drifting them.

## Why this skill exists

On 2026-04-24, an agent ran nine consecutive audits against the same file with no content change between runs. Each pass was wasted work. The rules below exist to prevent that class of failure from recurring across the skill tree.

## Scope

These rules apply to any skill that dispatches a verdict-producing pass and may iterate based on the verdict. This includes skill-auditing, spec-auditing, tool-auditing, markdown-hygiene, compression, code-review, and any future skill that follows a fix/audit/compress cycle.

These rules do not apply to non-iterating read-only skills, single-pass transforms, or skills that do not produce verdicts.

## Definitions

An **iterating skill** is a skill the caller runs repeatedly as part of a fix, audit, or compress cycle. A **pass** is a single invocation of that skill. **Findings** are verdict artifacts that indicate more work is needed — for example, NEEDS_REVISION, FAIL, WARN, PARTIAL, or Pass with Findings. The exact label depends on each calling skill's vocabulary; this skill keeps the definition abstract. The **source file** is the file or files whose content the iterating skill evaluates: for audits, the target under audit; for compression, the uncompressed source; for code-review, the source files in the change set.

## Rule A — Fix before re-pass

If a pass produces findings, the caller must resolve those findings before running another pass against the same source. Resolution means fixing directly, dispatching the fix, or explicitly accepting or waiving the findings with a recorded rationale where the calling skill permits it. Running another pass without acting on prior findings is forbidden.

## Rule B — Never re-pass on unchanged content

"Never re-audit a file that has not been modified since the previous audit, period, full stop."

If the source file's content is unchanged since the prior pass, the verdict is deterministic and a re-pass is wasted work. Re-dispatch is forbidden.

Rule B's opening sentence is an operator-verbatim quote. It must be preserved exactly in any artifact that restates this rule. Rewording is forbidden.

## Caller obligations

Before dispatching any follow-up pass, the caller must verify two things:

1. At least one source file has changed since the previous pass completed. This satisfies Rule B.
2. For passes that returned findings: those findings have been addressed or recorded. This satisfies Rule A.

If either check fails, the prior verdict stands and re-dispatch is forbidden.

## Precedence

These rules are authoritative. If a calling skill's spec contradicts Rule A or Rule B, the calling skill must be revised to align with this skill — not the other way around.

## Integration — how sibling skills reference this skill

Iterating skills should not embed the full text of Rules A and B in their own spec, uncompressed, or SKILL.md. Instead they include a one-line pointer. This keeps the rules DRY, makes future updates cheap, and prevents drift between sibling skills.

The canonical reference form is:

> Iteration Safety: see `skills/electrified-cortex/iteration-safety/` — Rule A and Rule B apply to any iteration of this skill.

## How to cite this skill

When calling or referencing this skill from another skill file, use the one-line pointer above verbatim. Do not embed or paraphrase the rule text.

## Don'ts

- Do not reword Rule B's verbatim quote.
- Do not copy Rules A and B into other skills' specs — reference this skill instead.
- Do not add verdict vocabulary here that is not shared by every iterating skill — keep the definition of findings abstract and let each calling skill name its own verdict labels.
- Do not turn this into a procedural audit skill — it is a shared rules module, not an audit runner.
