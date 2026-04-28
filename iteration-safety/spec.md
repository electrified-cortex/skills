# Iteration Safety

## Purpose

Prevent wasted-work loops when an agent iterates audit, review, hygiene, or compression passes. A single place of truth so every iterating skill can reference these rules instead of duplicating them.

## Scope

Any skill that dispatches a verdict-producing pass and may iterate based on the verdict. Applies to skill-auditing, spec-auditing, tool-auditing, markdown-hygiene, compression, code-review, and any future iterating skill.

Out of scope: non-iterating read-only skills; single-pass transforms; skills that do not produce verdicts.

## Definitions

- **Iterating skill** — a skill the caller runs repeatedly as part of a fix/audit/compress cycle.
- **Pass** — a single invocation of the iterating skill.
- **Findings** — verdict artifacts that indicate more work is needed (e.g. NEEDS_REVISION, FAIL, WARN, PARTIAL, Pass with Findings — the exact label depends on the calling skill's vocabulary).
- **Source file** — the file(s) whose content the iterating skill evaluates. For audits: the target under audit. For compression: the uncompressed source. For code-review: the source files in the change set.

## Requirements

**Rule A — Fix before re-pass.** If a pass produces findings, the caller MUST resolve those findings — by fixing directly, dispatching the fix, or explicitly accepting/waiving (with recorded rationale, where the calling skill permits it) — before running another pass against the same source. Running another pass without acting on prior findings is forbidden.

**Rule B — Never re-pass on unchanged content.** "Never re-audit a file that has not been modified since the previous audit, period, full stop." If the source file's content is unchanged since the prior pass, the verdict is deterministic and a re-pass is wasted work. Re-dispatch is forbidden.

Rule B's opening sentence is an operator-verbatim quote. It must be preserved exactly in any artifact that restates this rule. Rewording is forbidden.

## Caller obligations

Before dispatching a follow-up pass, the caller MUST verify:

1. At least one source file has changed since the previous pass completed (satisfies Rule B).
2. For passes that returned findings: those findings have been addressed or recorded (satisfies Rule A).

If either check fails, the prior verdict stands and re-dispatch is forbidden.

## Integration

Iterating skills SHOULD NOT embed the full text of Rules A and B in their own spec / uncompressed / SKILL.md. Instead they include this two-line pointer block in spec.md, uncompressed.md, and SKILL.md only. Do NOT include the block in instructions.uncompressed.md or instructions.txt — by the time instructions are loaded, the re-dispatch decision has already been made and the gate is too late.

Caller block (adjust the relative path for the caller's folder depth):

```markdown
## Iteration Safety

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.
```

No restated Rule B verbatim quote in callers — the quote lives in this skill only, so rewording drift cannot occur.

## Root cause this skill exists for

2026-04-24: an agent ran nine consecutive audits against the same file with no content change between runs. The rules below exist to prevent that class of failure from recurring across the skill tree.

## Constraints

### Don'ts

- Do not reword Rule B's verbatim quote.
- Do not copy Rules A and B into other skills' specs — reference this skill instead.
- Do not add verdict vocabulary here that is not shared by every iterating skill — keep the definition of "findings" abstract and let each calling skill name its own verdict labels.
- Do not turn this into a procedural audit skill — it is a shared rules module, not an audit runner.

### Precedence

If a calling skill's spec contradicts Rule A or Rule B, the calling skill must be revised. These rules are authoritative.
