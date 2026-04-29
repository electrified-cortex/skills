# Spec-Writing Specification

This file defines the authoritative behavior for producing high-quality specification documents.

A specification ("spec") is a normative document that defines rules, requirements, constraints, and expected behavior in a way that is precise, testable, and auditable.

This file is the source of truth for how specs must be written.

---

## Purpose

**Name:** Spec Writer
**Role:** Deterministic specification author
**Primary Responsibility:** Produce clear, complete, enforceable,
and auditable specifications
**Disposition:** Precise, explicit, non-ambiguous in normative sections

The spec writer must prioritize correctness and enforceability over
readability when in conflict.

---

## Scope

This skill applies when:

- writing a new specification document (spec.md)
- updating an existing specification document
- writing a derived specification document governed by an existing spec

This skill does not apply to:

- non-specification documents (design notes, ADRs, READMEs)
- auditing specifications (see `spec-auditing`)
- retroactive application to existing artifacts without a re-audit

All scope must be explicitly declared. The canonical scope-expansion rule
is `Requirements > No Silent Scope Expansion`.

This spec governs all specification documents, including itself.

> **Note:** Self-application means the Required Sections list is binding on this file itself; section removal or renaming requires a spec amendment.

---

## Definitions

**Spec:** A normative document defining rules, requirements,
constraints, and expected behavior.

**Target spec:** The specification document being authored or updated
under this spec.

**Derived spec:** A target spec written under the authority of an
existing governing spec.

**Governing spec:** The authoritative spec that constrains a derived
spec.

**Source requirement:** The requirement or rule in the governing spec
that authorizes a corresponding requirement in a derived spec.

**Unauthorized Addition:** A requirement, behavior, or constraint in a
derived spec that has no supporting source requirement in the governing
spec.

**Atomic:** A requirement expressing exactly one testable condition;
cannot be decomposed further.

**Testable:** Satisfaction is verifiable from document text alone
without external judgment.

**Normative:** Defines requirements, constraints, or behavior;
strictly enforceable.

**Descriptive:** Explains context or intent; must not contradict
normative content.

**Exploratory:** Captures ideas, tradeoffs, or open questions;
may contain ambiguity.

**Informational:** Notes, examples, or references.

**Mandatory language:** must, shall, required.

**Prohibited language:** must not, shall not.

**Guidance language:** should, recommended.

**Optional language:** may, optional.

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
- Section classification must be explicit in a `Section Classification`
  table inside `Content Modes`. Each top-level section must appear exactly
  once with exactly one mode.

### Section Classification

| Section | Mode |
| --- | --- |
| Purpose | Normative |
| Scope | Normative |
| Definitions | Normative |
| Content Modes | Normative |
| Definition of a Specification | Normative |
| Requirements | Normative |
| Normative Language | Normative |
| Target Spec Contract | Normative |
| Allowed Transformations | Normative |
| Traceability Requirement | Normative |
| Behavior | Normative |
| Defaults and Assumptions | Normative |
| Required Sections | Normative |
| Optional but Recommended Sections | Normative |
| Requirement Writing Rules | Normative |
| Requirement Clarity | Normative |
| Constraints | Normative |
| Error Handling | Normative |
| Extension Rules | Normative |
| Consistency Requirements | Normative |
| Output Quality Criteria | Normative |
| Self-Validation Checklist | Informational |
| Relationship to Spec Auditor | Descriptive |
| Derivation Workflow | Normative |
| Precedence Rules | Normative |
| Don'ts | Normative |

---

## Definition of a Specification

A valid specification must:

- define behavior or constraints
- use enforceable language
- be internally consistent
- be externally auditable
- avoid reliance on implied intent

---

## Requirements

### 1. Explicitness Over Implication

When writing any spec governed by this spec, the spec author must state all required behavior explicitly; no behavior may be left to implication.

### 2. Testability

When writing any spec governed by this spec, the spec author must write each requirement so it is verifiable against the spec's target from document text alone, without external judgment.

### 3. Single Source of Truth

When writing any spec governed by this spec, the spec author must place each requirement in exactly one canonical location; duplication of normative content is prohibited.

### 4. Terminology Stability

When writing any spec governed by this spec, the spec author must define every key term in the Definitions section and use each term consistently throughout the document.

### 5. No Silent Scope Expansion

When writing any spec governed by this spec, the spec author must declare all scope explicitly in the Scope section; silent scope expansion is prohibited.

### 6. Normative Clarity

When writing any spec governed by this spec, the spec author must clearly distinguish required, prohibited, and optional behavior using the normative language defined in this spec.

### 7. No Absolute Filesystem Paths in Artifact Bodies

When writing any spec governed by this spec, the spec author must not include
absolute filesystem paths in any artifact body. This prohibition covers Windows
drive-letter prefixes (`<letter>:/...` or `<letter>:\\...`) and Unix
root-anchored paths under `/Users/`, `/home/`, `/d/`, `/c/`, or any similar
root. Repo-relative paths must be used instead, computed via
`git ls-files --full-name <file>` or by stripping `<repo-root>/` from an
absolute path. Frontmatter, body prose, code samples, and embedded examples
are all in scope.

- **Right**: `file_path: skill-auditing/instructions.uncompressed.md`
- **Wrong**: `file_path: <abs-prefix>/.agents/skills/electrified-cortex/skill-auditing/instructions.uncompressed.md`

Stdout return values that emit absolute paths (e.g. `PATH: <abs>`) are exempt
— those are runtime addresses, not artifact body content.

---

## Normative Language

- **must / shall / required** → mandatory  
- **must not / shall not** → prohibited  
- **should / recommended** → guidance  
- **may / optional** → discretionary  

---

## Target Spec Contract

This spec defines the structure and constraints of a target spec.
When the target spec is a derived spec, the derived-spec rules below apply.

The target spec must:

- conform to this spec’s structure and requirements
- include all required sections
- preserve the meaning of all normative statements
- keep definitions, scope, constraints, and defaults semantically stable

The target spec must not:

- introduce new requirements
- redefine terms
- expand scope beyond this spec
- change constraints or defaults
- introduce new behavior or terminology without explicit support in the governing spec

---

## Allowed Transformations

A derived spec may:

- reword for clarity
- reorganize structure
- aggregate related requirements
- add descriptive explanations

These transformations are allowed only when they preserve the Target Spec
Contract above.

---

## Traceability Requirement

Every normative requirement in a derived spec must map to a source
requirement in its governing spec.

- no requirement may exist without a source
- mappings must be one-to-one or one-to-many
- unmapped requirements are Unauthorized Additions

---

## Behavior

This section is where a governed spec places behavior-specific rules,
including edge cases. Section-mode placement rules are defined in
`Content Modes`.

Derived-spec transformation rules are defined in `Target Spec Contract` and
`Allowed Transformations`.

---

## Defaults and Assumptions

Only explicit defaults are permitted. Ambiguity is allowed only in
non-normative sections.

Assume every requirement will be challenged, every omission will be
detected, and every ambiguity will be flagged during audit.

---

## Required Sections

Every spec governed by this spec must contain all of the following
top-level sections:

- **Purpose** — defines intent
- **Scope** — defines boundaries
- **Definitions** — defines all key terms
- **Content Modes** — explicit section classification
- **Requirements** — atomic, testable rules
- **Constraints** — limits and prohibitions
- **Behavior** — system behavior including edge cases
- **Defaults and Assumptions** — explicit defaults only
- **Error Handling** — defined failure behavior
- **Precedence Rules** — conflict resolution
- **Don'ts** — explicit exclusions

---

## Optional but Recommended Sections

### Footguns

A spec may include a **Footguns** section listing failure modes that are easy to trigger, non-obvious to diagnose, or costly to recover from. This section is optional but strongly recommended when the spec describes behavior with sharp edges.

Each footgun entry must follow this format:

**F#: {short title}**
Description of the failure mode — what goes wrong and in what context.
Why: Why this is a footgun (non-obvious, silent, or costly).
Mitigation: The specific parameter, phrase, or constraint that prevents it.

Multiple footguns are numbered sequentially (F1, F2, ...).

**Canonical example:** See `dispatch` skill for the established footgun catalogue pattern (F1–F5 with Mitigation: lines and one ANTI-PATTERN: worked example).

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

- Use subject-verb-object form or an equivalent explicit actor-action-object structure.
- Name the actor, the artifact acted upon, and the trigger condition when they apply.
- Split a requirement if it contains more than one independent obligation or a nested exception chain that obscures the main rule.

A normative requirement is defective if the actor, required action, or trigger condition cannot be identified from the text.

---

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

Worked wrong-usage examples anywhere in the spec must be prefixed with `ANTI-PATTERN:`.

Artifact bodies (frontmatter, prose, code samples, embedded examples) must not
contain absolute filesystem paths. Use repo-relative paths only. Stdout return
values that emit absolute paths at runtime are exempt.

---

## Error Handling

If a **normative** statement is ambiguous, it must be rewritten.

Ambiguity is allowed only in non-normative sections.

A spec containing unresolvable defects must not be used as the basis
for derived artifacts until defects are resolved and the spec passes
a full audit.

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
- no unauthorized scope expansion exists relative to the declared Scope
  section, and for a derived spec relative to the governing spec

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

Audit assumptions are defined in `Defaults and Assumptions`.

---

## Derivation Workflow

Before writing any artifact derived from a spec (skill, agent, or tool), the spec must pass a full audit.

Required sequence:

1. Write the spec.
2. Dispatch `markdown-hygiene` on the spec to ensure zero lint errors.
3. Dispatch the spec-auditor: fast-cheap iterations first, standard for the final pass.
4. Fix all findings.
5. Re-audit until the result is PASS.
6. Only after PASS: write the derived artifact.
7. Dispatch the appropriate artifact auditor (skill-auditor, agent-auditor, or tool-auditor) on the derived artifact as a separate pass.

Skipping the spec-auditor pass before writing a derived artifact is prohibited.

---

## Precedence Rules

Correctness and enforceability take precedence over readability.

If a normative statement can be interpreted in more than one
reasonable way, it is invalid and must be rewritten.

Normative content governs behavior. Non-normative content must not
override normative content.

---

## Don'ts

- Do not write specs for non-specification documents.
- Do not embed normative requirements in examples, descriptive text,
  or exploratory sections.
- Do not apply this spec retroactively to existing artifacts without
  a re-audit.
- Do not treat paraphrase as acceptable unless semantically
  equivalent by rigorous test.
- Do not embed absolute filesystem paths in any artifact body; use
  repo-relative paths (see Requirement 7).

