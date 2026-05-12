---
name: spec-writing
description: Write precise, testable, auditable specification documents with explicit scope, stable terminology, and enforceable requirements. Triggers - write a spec, create specification, draft spec document, new spec file, spec document.
---

# spec-writing

Write specs: clear, complete, enforceable, internally consistent, externally auditable.

Purpose: define intent precisely, testably, auditably.

Scope: use when writing spec or derived target doc governed by source
spec. All scope must be explicitly declared.
Not for: non-spec docs (design notes, ADRs, READMEs), auditing (see
spec-auditing), retroactive application without re-audit.

## Definitions

Spec: normative doc defining rules, requirements, constraints, expected behavior.
Atomic: requirement expressing exactly one testable condition; can't decompose further.
Testable: satisfaction verifiable from doc text alone without external judgment.
Normative: defines requirements/constraints/behavior; strictly enforceable.
Descriptive: explains context/intent; must not contradict normative content.
Exploratory: captures ideas, tradeoffs, open questions; may contain ambiguity.
Informational: notes, examples, references.
Mandatory language: must, shall, required.
Prohibited language: must not, shall not.
Guidance language: should, recommended.
Optional language: may, optional.

## Content Modes

Every section in a spec must be classified as one of:

- **Normative**: defines requirements, constraints, or behavior. Strictly enforceable.
- **Descriptive**: explains context or intent. Must not contradict normative content.
- **Exploratory**: captures ideas, tradeoffs, or open questions. May contain ambiguity.
- **Informational**: notes, examples, or references.

Only Normative sections are strictly enforceable. Any statement that affects behavior must be placed in a Normative section.

## Requirements

Define behavior or constraints. Use enforceable language. Be internally consistent, structurally coherent, externally auditable. No reliance on implied intent. State all required behavior explicitly. Every requirement verifiable. Each requirement in one canonical location. Define and use terms consistently. Clearly distinguish required, prohibited, guidance, optional behavior.
Include required sections:

- Purpose: defines intent
- Scope: defines boundaries
- Definitions: defines all key terms
- Requirements: atomic, testable rules
- Constraints: limits and prohibitions
- Behavior: system behavior including edge cases
- Content Modes: lists the operational modes the document defines (inline, dispatch, etc.) and their distinguishing trigger/behavior
- Defaults and Assumptions: explicit defaults only
- Error Handling: defined failure behavior
- Precedence Rules: conflict resolution
- Don'ts: explicit exclusions

After listing sections, include a **Section Classification** table with columns: `Section` and `Mode`. Mode values are Normative, Descriptive, or Informational. This makes the section structure auditable at a glance.

Each requirement must be atomic (one testable condition only), testable (verifiable from document text alone), and unambiguous.

Use subject-verb-object form. Name the actor, the artifact acted upon, and the trigger condition. Two clear sentences are preferred over one dense nested clause.

Dense or compressed phrasing in any normative requirement is a defect. A reader must be able to parse any single requirement on first read without re-scanning surrounding text.
For derived targets: map every normative requirement to source spec. Mappings one-to-one or one-to-many. Unmapped = Unauthorized Additions.

## Constraints

The spec must not contain:

- vague terms
- implied behavior
- hidden requirements
- contradictions
- duplicate rules
- subjective language

Normative requirements must not be:

- embedded in examples
- implied in descriptive text
- introduced in exploratory sections

For derived targets: no new normative requirements, no term
redefinition, no scope expansion, no changed constraints/defaults,
no new concepts.
If extension is allowed, the spec must define where extension is
permitted and what constraints apply to it. Otherwise extension is
prohibited.

### Domain-Flavor Extension

This skill's spec permits **domain-flavor extension**. A derived
spec may declare itself a domain flavor (e.g., `prd-writing` for
Product Requirements Documents) and add normative sections specific
to its domain, subject to all of:

- the derived spec includes an **Inheritance** section naming this
  spec as parent and stating the domain-flavor declaration;
- the derived spec inherits, without contradiction, this spec's
  Content Modes, normative-language rules, atomicity requirements,
  and audit gate;
- additional normative requirements are atomic, testable, and use
  the normative language defined here;
- every additional section is classified in a Section
  Classification table using this spec's Content Modes;
- the derived spec does not redefine any term defined here, expand
  scope contrary to this spec, change a default or constraint
  declared here, or override any rule here;
- the derived spec references a corresponding audit skill that runs
  `spec-auditing` first, then domain-specific checks.

Additional requirements in a conforming derived spec are **Valid
Extensions**, not Unauthorized Additions. Traceability still
applies to requirements that restate or specialize a parent rule;
requirements unique to the domain need not trace to a parent rule.

Without an explicit Inheritance declaration and conformance to the
above, the derived-target rules apply unchanged: no new normative
requirements are permitted.

## Behavior

Statement affects behavior → move to Normative section (see Content Modes). Define behavior including edge cases. State defaults explicitly. Define failure behavior explicitly. Define conflict resolution explicitly. State explicit exclusions.
For derived targets, allowed transforms: reword for clarity, reorganize structure, aggregate related requirements, add descriptive explanations. Preserve meaning of all normative statements.
Validate before accepting: all required sections present, all
requirements use normative language, no vague wording, all terms
defined, no duplicates, no contradictions, no implicit assumptions.

Output Quality Gate:
Accept only if: all requirements testable, no critical ambiguity,
terminology stable, no contradictions, no unauthorized scope
expansion.

## Defaults and Assumptions

Only explicit defaults allowed. Ambiguity allowed only in non-normative sections. Assume every requirement will be challenged, every omission detected, every ambiguity flagged.

## Error Handling

A spec containing unresolvable defects is invalid; artifact derivation
is blocked until defects are fixed and the spec reaches PASS.

Ambiguous normative statement → rewrite.
Behavior-affecting statement outside Normative section → move to
Normative section.
Requirement not atomic, testable, or enforceable → rewrite before
treating the spec as valid or deriving any artifact from it.

## Precedence

Correctness and enforceability over readability. Normative content governs behavior. Non-normative content must not introduce hidden requirements. For derived targets, source spec authoritative, target subordinate. Normative statement with multiple reasonable interpretations → invalid, must rewrite.

## Derivation Workflow

Before writing any artifact derived from a spec (skill, agent, or
tool), the spec must pass a full audit.

1. Write the spec.
2. Dispatch spec-auditor: fast-cheap iterations first, standard for the final pass.
3. Fix all findings (including any formatting issues flagged).
4. Re-audit until the result is PASS.
5. Write the derived artifact (skill, agent, or tool) only after PASS.
6. Dispatch the appropriate artifact auditor (skill-auditor, agent-auditor, or tool-auditor) on the derived artifact as a separate pass.

Skipping the spec-auditor pass before writing a derived artifact is prohibited.

## Completion Gate

> **The spec is NOT done until `spec-auditing` returns PASS.**

FAIL → fix all findings → re-audit. Repeat until PASS.

Do not derive any artifact, commit, or hand off a spec until a PASS verdict
is in hand. There are no exceptions. Receiving FAIL and stopping work is a
workflow violation.

Don't use descriptive, exploratory, or informational content as substitute for normative requirements. Don't use this skill to justify silent scope expansion. Do not embed normative requirements in examples, descriptive text, or exploratory sections.

## Footgun Convention

Specs may include an optional `Footguns` section. Format:

**F#: {title}** — failure mode description.
Why: Why it's a footgun.
Mitigation: Specific fix (parameter, phrasing, constraint).

Wrong-usage examples anywhere in the spec use `ANTI-PATTERN:` prefix.
Canonical reference: `dispatch` skill (F1–F5 with Mitigation:
lines and one ANTI-PATTERN: worked example).

Related: `spec-auditing` (verify spec quality), `skill-writing` (write skills from specs), `skill-auditing` (verify skill quality), `markdown-hygiene` (zero-error lint gate)
