# spec-writing

Guide for writing precise, testable spec documents. Use this as a reference
when authoring a new spec or revising one that has drifted from its skill.

## When to Use

- Writing a `.spec.md` companion for a new or existing skill
- Revising a spec that has drifted from its skill
- Learning the normative language and requirement conventions used in this repo

## What a Spec Is For

The spec is the long-form record of intent. Where `SKILL.md` is compressed
and operational, `.spec.md` preserves:

- The rationale behind each design decision
- Edge cases and explicit exclusions
- Credits and references
- Requirements in testable, normative language

Specs are never compressed. They are the safety net — everything stripped from
a compressed skill lives in the spec.

## Key Conventions

**Normative language.** Use `MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, and
`MAY` (RFC 2119) consistently. Ambiguous language fails audit.

**Requirement atomicity.** Each requirement covers exactly one behavior.
Compound sentences with "and" usually indicate two requirements that should
be split.

**Testability.** Every `MUST`/`MUST NOT` statement should have an observable
pass/fail criterion. If you cannot describe how to test it, rewrite it.

**No compression.** Specs are written in full natural language prose. Do not
apply ultra or full compression tiers to spec files.

## Structure

A well-formed spec typically includes:

1. Purpose and scope
2. Definitions (if the skill introduces domain terms)
3. Requirements (normative, atomic, testable)
4. Exclusions (explicit non-requirements)
5. Design decisions and rationale
6. Credits and references

## Related Skills

- [`skill-writing`](../skill-writing/) — guide for the `SKILL.md` this spec accompanies
- [`spec-auditing`](../spec-auditing/) — audits the spec against its skill
- [`skill-auditing`](../skill-auditing/) — audits the skill against this spec

## Standards

This skill follows the [Agent Skills](https://agentskills.io) open standard.

## License

MIT — see [LICENSE](../LICENSE) in the repository root.
