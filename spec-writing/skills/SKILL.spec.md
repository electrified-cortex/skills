# Skill Writing — SKILL.md Spec

> Child spec derived from `../SKILL.spec.md`.
> This file defines how to produce a skill-writing `SKILL.md` whose target is the concise, executable form of the broader skill-design contract.

## Purpose

This file defines the authoritative behavior for producing skill files that are accurate, concise, and operationally complete.

The parent spec defines how specifications must be written. This child spec specializes that contract for skills that produce or govern `SKILL.md` files.

The central design rule is two-plane separation:

- the spec is the human-readable source language
- the target `SKILL.md` is the executable byte-code

The spec may be expansive. The target skill file must be concise.

## Scope

This spec governs a derived target file named `SKILL.md` for skill authoring and skill execution guidance.

This spec applies when the target file is intended to be loaded directly into agent context as an operational skill.

This spec inherits the parent requirements from `../spec-writing/SKILL.spec.md` and adds skill-specific constraints on what belongs in the target skill file versus the companion spec.

## Definitions

- **Parent spec**: `../spec-writing/SKILL.spec.md`, the general contract for writing specifications.
- **Skill spec**: the verbose companion document that defines the skill in full, including rationale and displaced detail.
- **Target skill file**: the derived `SKILL.md` loaded by an agent at runtime.
- **Program content**: instructions that directly change how the agent should execute the skill.
- **Non-program content**: rationale, history, audit notes, bug reports, long examples, design debate, publication notes, and other material that does not directly control runtime behavior.
- **Executable compression**: transforming the skill spec into a smaller operational file without changing meaning.
- **Byte-code principle**: the target skill file is the compiled operational form of the companion spec and should contain only the instructions the agent needs at execution time.
- **Self-contained**: a target skill file contains all instructions required to apply the skill without requiring the companion spec during normal runtime use.

## Requirements

The skill spec must:

- conform to the parent spec
- define the target skill file as a runtime artifact, not as a design notebook
- clearly separate program content from non-program content
- explicitly state which information belongs only in the spec
- explicitly state what the target skill file must preserve verbatim

The target `SKILL.md` must:

- be self-contained for runtime use
- be accurate and semantically complete
- be concise by default
- contain only program content needed to execute the skill
- preserve all load-bearing meaning from the spec
- preserve exact technical strings when exactness matters, including paths, commands, flags, config keys, identifiers, versions, thresholds, branch names, and quoted literals
- preserve logic and modality words, including not, never, only, unless, must, may, required, and optional
- preserve actors and permission boundaries
- preserve ordered steps, counts, and thresholds
- include minimal frontmatter required by the target runtime or standard

The skill spec may include:

- reasoning
- design rationale
- bug reports
- audit reports
- examples
- anti-pattern catalogs
- edge cases
- compression guidance
- notes that push the author toward a more efficient target protocol

These additions are permitted in the spec only when they help the author produce a more accurate and more efficient target `SKILL.md`.

## Constraints

The target `SKILL.md` must not include:

- design rationale
- audit logs
- bug histories
- publication notes
- long-form examples
- change history
- credits
- broad conceptual explanation that does not affect execution
- repeated explanation already displaced to the spec

The target `SKILL.md` must not:

- depend on the reader also loading the spec during ordinary execution
- contain filler, marketing prose, or narrative framing that does not change behavior
- include multiple explanations of the same rule
- trade correctness for brevity
- remove detail that is necessary for unambiguous execution

The skill spec must not use the byte-code principle to justify omission of runtime-critical instructions from the target file.

## Behavior

The skill spec should behave like a high-level source file.

The target `SKILL.md` should behave like compiled byte-code for agent execution.

Compilation from spec to target must follow these rules:

- keep all runtime-relevant instructions
- strip non-program content
- flatten explanation into direct operational rules where possible
- compress wording when meaning is preserved
- prefer dense agent-facing phrasing over explanatory prose
- keep examples only when removing the example would make the operational rule ambiguous
- keep structure only when structure improves execution reliability

The target `SKILL.md` should prefer:

- short sections or labeled lines
- direct imperatives
- stable terminology
- minimal repetition
- explicit stop conditions when ambiguity would otherwise be introduced

When a rule can be expressed in fewer tokens without loss of meaning, the shorter form should be preferred.

When shortening would introduce ambiguity, the longer form must be kept.

## Defaults and Assumptions

- The spec may be large.
- The target skill file is expected to be loaded frequently.
- The companion spec is expected to be read less frequently than the target skill file.
- Token efficiency matters for the target skill file more than for the companion spec.
- The target skill file is assumed to be read by an agent, not by a human auditor.
- The companion spec is assumed to be available for review, audit, repair, and evolution.

## Error Handling

If content in the target `SKILL.md` does not directly affect runtime behavior, it must be moved to the spec.

If content in the spec is required for correct runtime execution, it must be promoted into the target `SKILL.md`.

If compression or shortening changes meaning, the target `SKILL.md` must be expanded until the meaning is restored.

If a target instruction depends on implied context, the implication must be rewritten as an explicit instruction.

If a target skill file cannot be both concise and self-contained, self-containment wins.

## Precedence Rules

- The parent spec governs general specification quality and clarity.
- This child spec governs skill-specific target behavior.
- Correctness wins over brevity.
- Self-containment wins over aggressive compression.
- Exact technical meaning wins over stylistic density.
- Runtime instructions win over explanation.
- The spec holds rationale; the target `SKILL.md` holds the executable program.

## Non-Goals

The target `SKILL.md` is not:

- a tutorial
- a design essay
- a changelog
- an audit report
- a bug tracker
- a publication artifact for humans first

This spec does not require the target `SKILL.md` to preserve all human-readable context from the companion spec.

This spec does require the target `SKILL.md` to preserve all runtime-relevant behavior.
