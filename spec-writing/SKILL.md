---
name: spec-writing
description: Write precise, testable, auditable specification documents with explicit scope, stable terminology, and enforceable requirements.
---

Write specifications that are clear, complete, enforceable, internally consistent, and externally auditable.

## Purpose

Define intent.

A specification ("spec") is a normative document that defines rules, requirements, constraints, and expected behavior in a way that is precise, testable, and auditable.

## Scope

Use this skill when writing a specification or a derived target document governed by a source spec.

All scope must be explicitly declared.

## Definitions

- Spec: a normative document that defines rules, requirements, constraints, and expected behavior.
- Atomic: a requirement that expresses exactly one testable condition; cannot be decomposed further.
- Testable: a requirement whose satisfaction can be verified from the document text alone without external judgment.
- Normative: defines requirements, constraints, or behavior; strictly enforceable.
- Descriptive: explains context or intent; must not contradict normative content.
- Exploratory: captures ideas, tradeoffs, or open questions; may contain ambiguity.
- Informational: notes, examples, or references.
- Mandatory language: must, shall, required.
- Prohibited language: must not, shall not.
- Guidance language: should, recommended.
- Optional language: may, optional.

## Requirements

- Define behavior or constraints.
- Use enforceable language.
- Be internally consistent.
- Be structurally coherent.
- Be externally auditable.
- Avoid reliance on implied intent.
- State all required behavior explicitly.
- Make every requirement verifiable.
- Keep each requirement in one canonical location.
- Define and use terms consistently.
- Clearly distinguish required, prohibited, guidance, and optional behavior.
- Include these sections: Purpose, Scope, Definitions, Requirements, Constraints, Behavior, Defaults and Assumptions, Error Handling, Precedence Rules, Non-Goals.
- Make each requirement atomic, testable, and unambiguous.
- For a derived target document, map every normative requirement to the source spec. Mappings may be one-to-one or one-to-many. Unmapped requirements are Unauthorized Additions.

## Constraints

- Do not use vague terms.
- Do not rely on implied behavior.
- Do not hide requirements.
- Do not create contradictions.
- Do not duplicate rules.
- Do not use subjective language.
- Do not embed normative requirements in examples.
- Do not imply normative behavior in descriptive text.
- Do not introduce normative requirements in exploratory sections.
- For a derived target document, do not introduce new normative requirements, redefine terms, expand scope, change constraints or defaults, or introduce new concepts.
- If extension is allowed, define where extension is permitted and the constraints on extension. Otherwise, extension is prohibited.

## Behavior

- Classify each section as Normative, Descriptive, Exploratory, or Informational.
- Treat only Normative sections as strictly enforceable.
- If a statement affects behavior, move it to a Normative section.
- Define behavior, including edge cases.
- State defaults explicitly.
- Define failure behavior explicitly.
- Define conflict resolution explicitly.
- State explicit exclusions.
- For a derived target document, allowed transformations are: reword for clarity, reorganize structure, aggregate related requirements, add descriptive explanations.
- Preserve the meaning of all normative statements.
- Validate before accepting the spec:
  - all required sections present
  - all requirements use normative language
  - no vague wording
  - all terms defined
  - no duplicates
  - no contradictions
  - no implicit assumptions
- Accept only if:
  - all requirements are testable
  - no critical ambiguity exists
  - terminology is stable
  - no contradictions exist
  - no unauthorized scope expansion exists

## Defaults and Assumptions

- Only explicit defaults are allowed.
- Ambiguity is allowed only in non-normative sections.
- Assume every requirement will be challenged, every omission will be detected, and every ambiguity will be flagged.

## Error Handling

- If a normative statement is ambiguous, rewrite it.
- If a behavior-affecting statement appears outside a Normative section, move it to a Normative section.
- If a requirement is not atomic, testable, or enforceable, rewrite it before treating the spec as valid.

## Precedence Rules

- Correctness and enforceability take precedence over readability.
- Normative content governs behavior.
- Non-normative content must not introduce hidden requirements.
- For a derived target document, the source spec is authoritative and the target document is subordinate.
- If a normative statement can be interpreted in more than one reasonable way, it is invalid and must be rewritten.

## Non-Goals

- Do not use descriptive, exploratory, or informational content as a substitute for normative requirements.
- Do not use this skill to justify silent scope expansion.
- Do not use this skill to hide requirements in examples, notes, or descriptive prose.