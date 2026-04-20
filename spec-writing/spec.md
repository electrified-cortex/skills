# Spec-Writing Specification

This file defines the authoritative behavior for producing high-quality specification documents.

A specification ("spec") is a normative document that defines rules, requirements, constraints, and expected behavior in a way that is precise, testable, and auditable.

This file is the source of truth for how specs must be written.

---

## Skill Identity

**Name:** Spec Writer  
**Role:** Deterministic specification author  
**Primary Responsibility:** Produce clear, complete, enforceable, and auditable specifications  
**Disposition:** Precise, explicit, non-ambiguous in normative sections

The spec writer must prioritize correctness and enforceability over readability when in conflict.

---

## Content Modes

A document governed by this spec may contain different types of content.

Each section must be classified as one of:

- **Normative**  
  Defines requirements, constraints, or behavior. Must follow all strict rules.

- **Descriptive**  
  Explains context or intent. Must not contradict normative content.

- **Exploratory**  
  Captures ideas, tradeoffs, or open questions. May contain ambiguity.

- **Informational**  
  Notes, examples, or references.

### Rules

- Only **Normative sections** are strictly enforceable.
- Non-normative sections must not introduce hidden requirements.
- If a statement affects behavior, it must be moved to a normative section.

---

## Definition of a Specification

A valid specification must:

- define behavior or constraints
- use enforceable language
- be internally consistent
- be externally auditable
- avoid reliance on implied intent

---

## Core Principles

### 1. Explicitness Over Implication

All required behavior must be explicitly stated.

### 2. Testability

Every requirement must be verifiable.

### 3. Single Source of Truth

Each requirement must exist in one canonical location.

### 4. Terminology Stability

Terms must be defined and used consistently.

### 5. No Silent Scope Expansion

All scope must be explicitly declared.

### 6. Normative Clarity

Clearly distinguish required, prohibited, and optional behavior.

---

## Normative Language

- **must / shall / required** → mandatory  
- **must not / shall not** → prohibited  
- **should / recommended** → guidance  
- **may / optional** → discretionary  

---

## Target Document Contract

This spec defines the structure and constraints of a derived target document.

The target document must:

- conform to this spec’s structure and requirements
- include all required sections
- preserve the meaning of all normative statements

The target document must not:

- introduce new normative requirements
- redefine terms
- expand scope beyond this spec

---

## Allowed Transformations

The target document may:

- reword for clarity
- reorganize structure
- aggregate related requirements
- add descriptive explanations

The target document must not:

- introduce new requirements
- change constraints or defaults
- introduce new concepts

---

## Traceability Requirement

Every normative requirement in the target must map to this spec.

- no requirement may exist without a source
- mappings must be one-to-one or one-to-many
- unmapped requirements are Unauthorized Additions

---

## Required Sections

### Purpose

Defines intent.

### Scope

Defines boundaries.

### Definitions

Defines all key terms.

### Requirements

Atomic, testable rules.

### Constraints

Limits and prohibitions.

### Behavior

System behavior including edge cases.

### Defaults and Assumptions

Explicit defaults only.

### Error Handling

Defined failure behavior.

### Precedence Rules

Conflict resolution.

### Don'ts

Explicit exclusions.

---

## Optional but Recommended Sections

### Footguns

A spec may include a **Footguns** section listing failure modes that are easy to trigger, non-obvious to diagnose, or costly to recover from. This section is optional but strongly recommended when the spec describes behavior with sharp edges.

Each footgun entry must follow this format:

**F#: <short title>**
Description of the failure mode — what goes wrong and in what context.
Why: Why this is a footgun (non-obvious, silent, or costly).
Mitigation: The specific parameter, phrase, or constraint that prevents it.

Multiple footguns are numbered sequentially (F1, F2, ...).

Worked wrong-usage examples anywhere in the spec must be prefixed with `ANTI-PATTERN:`.

**Canonical example:** See `dispatch-strategy` skill for the established footgun catalogue pattern (F1–F5 with Mitigation: lines and one ANTI-PATTERN: worked example).

---

## Requirement Writing Rules

Each requirement must:

- be atomic (expresses exactly one testable condition; cannot be decomposed further)
- be testable (satisfaction can be verified from document text alone without external judgment)
- use normative language
- avoid ambiguity

---

## Requirement Clarity

Each normative requirement must be written using plain, explicit sentences.

- Use subject-verb-object form. Name the actor. Name the artifact acted upon. Name the trigger condition.
- Two clear sentences are preferred over one dense, nested clause.
- A reader must be able to parse any single requirement on first read without re-scanning surrounding text.

Dense or compressed phrasing in a normative requirement is a defect.

---

## Forbidden Patterns

The spec must not contain:

- vague terms
- implied behavior
- hidden requirements
- contradictions
- duplicate rules
- subjective language

---

## Normative Boundary Rule

Normative requirements must not be:

- embedded in examples
- implied in descriptive text
- introduced in exploratory sections

---

## Handling Ambiguity

If a **normative** statement is ambiguous, it must be rewritten.

Ambiguity is allowed only in non-normative sections.

---

## Extension Rules

If extension is allowed, the spec must define:

- where extension is permitted
- constraints on extension

Otherwise, extension is prohibited.

---

## Consistency Requirements

The spec must be:

- internally consistent
- structurally coherent
- free of conflicting requirements

---

## Output Quality Criteria

A spec is acceptable only if:

- all requirements are testable
- no critical ambiguity exists
- terminology is stable
- no contradictions exist
- no unauthorized scope expansion exists

---

## Self-Validation Checklist

- all required sections present
- all requirements use normative language
- no vague wording
- all terms defined
- no duplicates
- no contradictions
- no implicit assumptions

---

## Relationship to Spec Auditor

This spec is designed to be audited.

Assume:

- every requirement will be challenged
- every omission will be detected
- every ambiguity will be flagged

---

## Derivation Workflow

Before writing any artifact derived from a spec (skill, agent, or tool), the spec must pass a full audit.

Required sequence:

1. Write the spec.
2. Dispatch the spec-auditor: Haiku iterations first, Sonnet for the final pass.
3. Fix all findings.
4. Re-audit until the result is PASS.
5. Only after PASS: write the derived artifact.
6. Dispatch the appropriate artifact auditor (skill-auditor, agent-auditor, or tool-auditor) on the derived artifact as a separate pass.

Skipping the spec-auditor pass before writing a derived artifact is prohibited.

---

## Final Rule

If a normative statement can be interpreted in more than one reasonable way, it is invalid and must be rewritten.
