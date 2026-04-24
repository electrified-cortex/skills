---
name: iteration-safety
description: Shared rules module preventing wasted-work loops in iterating skills. Rule A and Rule B are authoritative for all audit/review/hygiene/compression cycles.
---

# Iteration Safety

Shared rules module. Defines two binding rules for any skill that iterates verdict-producing passes. Sibling skills reference this skill; they don't embed the rule text.

## Why it exists

2026-04-24: agent ran nine consecutive audits against same file, no content change between runs. Rules A and B prevent that class of failure across the skill tree.

## Scope

Applies to: skill-auditing, spec-auditing, tool-auditing, markdown-hygiene, compression, code-review, any future iterating skill.
Out of scope: non-iterating read-only skills, single-pass transforms, skills that don't produce verdicts.

## Definitions

Iterating skill: runs repeatedly as part of fix/audit/compress cycle.
Pass: single invocation of iterating skill.
Findings: verdict artifacts indicating more work needed (NEEDS_REVISION, FAIL, WARN, PARTIAL, Pass with Findings — exact label per calling skill).
Source file: file(s) the skill evaluates. Audits → target under audit. Compression → uncompressed source. Code-review → change set files.

## Rule A — Fix before re-pass

If pass produces findings, caller must resolve them before running another pass against same source. Resolve = fix directly, dispatch fix, or explicitly accept/waive with recorded rationale (where calling skill permits). Re-passing without acting on findings is forbidden.

## Rule B — Never re-pass on unchanged content

"Never re-audit a file that has not been modified since the previous audit, period, full stop."

Source unchanged → verdict deterministic → re-pass is wasted work → re-dispatch forbidden.

## Caller obligations — pre-dispatch checklist

Before any follow-up pass, verify both:

1. At least one source file changed since previous pass. Fails → prior verdict stands, re-dispatch forbidden.
2. Prior findings addressed or recorded. Fails → prior verdict stands, re-dispatch forbidden.

## Precedence

These rules are authoritative. Calling skill's spec contradicts Rule A or Rule B → calling skill must be revised.

## How to cite this skill

> Iteration Safety: see `skills/electrified-cortex/iteration-safety/` — Rule A and Rule B apply to any iteration of this skill.

Use this one-line pointer in sibling skill files. Don't embed or paraphrase rule text.

## Don'ts

- Don't reword Rule B's verbatim quote.
- Don't copy Rules A and B into other skills' specs — reference this skill.
- Don't add verdict vocabulary not shared by every iterating skill — keep findings abstract.
- Don't use this as a procedural audit runner — it's a shared rules module only.
