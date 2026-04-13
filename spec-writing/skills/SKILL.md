---
name: skills
description: Write skill files that are concise, accurate, self-contained, and operationally complete. Compile from companion spec to runtime executable form.
---

Write skill files as executable byte-code. Companion spec = source language; SKILL.md = compiled program.

Purpose: produce runtime skill files (`SKILL.md`) containing only instructions needed to execute correctly.

Scope: use when writing or rewriting a SKILL.md from a companion spec.

Definitions:
Skill spec: verbose companion defining full skill contract, including rationale and displaced detail.
Target skill file: derived SKILL.md loaded by agent at runtime.
Program content: instructions directly changing how agent executes skill.
Non-program content: rationale, history, audit notes, bug reports, long examples, design debate, publication notes, other material not controlling runtime behavior.
Executable compression: transforming skill spec into smaller operational file without changing meaning.
Byte-code principle: target skill file is compiled operational form of companion spec — only instructions agent needs at execution time.
Self-contained: target skill file contains all instructions to apply skill without requiring companion spec during normal runtime.
Parent spec: ../spec-writing/SKILL.spec.md — general contract for writing specifications.

What goes where:

Skill file (program content):
Purpose, scope, definitions.
Requirements, constraints.
Procedures, ordered steps, thresholds.
Defaults, error handling, stop conditions.
Precedence rules, conflict resolution.
Explicit exclusions (do-not constraints).

Companion spec only (non-program content):
Design rationale.
Audit reports, bug histories.
Extended examples, anti-pattern catalogs.
Edge-case walkthroughs.
Compression guidance, protocol notes.
Change history, credits, publication notes.

Additions permitted in companion spec only when producing more accurate or efficient target skill file.

Defaults:
Target skill file assumed read by agent, not human auditor.
Token efficiency matters for target more than companion spec.
Target expected to be loaded frequently.
Companion spec available for review, audit, repair, evolution.

Requirements:
When authoring companion spec: conform to parent spec; define target as runtime artifact; clearly separate program and non-program content.
Self-contained. Skill file mustn't require companion spec at runtime.
Concise. Every line must earn its place.
Accurate. Preserve all load-bearing meaning from spec.
Semantically complete. Every runtime-relevant instruction must be present.
Preserve exact technical strings: paths, commands, flags, config keys, identifiers, versions, thresholds, branch names, quoted literals.
Preserve logic/modality words: not, never, only, unless, must, may, required, optional.
Preserve actors and permission boundaries.
Preserve ordered steps, counts, thresholds.
Include minimal frontmatter required by target runtime or standard.

Constraints:
No design rationale.
No audit logs, audit reports, or bug histories.
No publication notes, change history, credits.
No tutorials, design essays, changelogs, or bug trackers.
No publication artifacts intended for human-first consumption.
No long-form examples unless removing them makes rule ambiguous.
No broad conceptual explanation not affecting execution.
No multiple explanations of same rule.
No filler, marketing prose, narrative framing.
No dependency on reader also loading spec during ordinary execution.
Never trade correctness for brevity.
Never remove detail necessary for unambiguous execution.
Don't use byte-code principle to justify omitting runtime-critical instructions.

Behavior — compiling spec → skill file:
1. Extract all program content from spec.
2. Strip non-program content.
3. Flatten explanation into direct operational rules.
4. Compress wording when meaning preserved.
5. Use dense agent-facing phrasing over explanatory prose.
6. Keep examples only when removing them makes operational rule ambiguous.
7. Keep structure only when it improves execution reliability.

Prefer: short sections or labeled lines, direct imperatives, stable terminology, minimal repetition, explicit stop conditions.
Fewer tokens without loss of meaning → prefer shorter form. Shortening introduces ambiguity → keep longer form.

Error handling:
Content doesn't affect runtime behavior → move to spec.
Spec content required for correct execution → promote into skill file.
Compression changes meaning → expand until meaning restored.
Instruction depends on implied context → rewrite as explicit instruction.
File cannot be both concise and self-contained → self-containment wins.

Precedence:
Parent spec governs general specification quality and clarity.
Child skill-writing spec governs skill-specific target behavior.
Correctness wins over brevity.
Self-containment wins over aggressive compression.
Exact technical meaning wins over stylistic density.
Runtime instructions win over explanation.
Companion spec holds rationale; skill file holds executable program.
