# Agent Writing — SKILL.md Spec

> Child spec derived from `../spec-writing/SKILL.spec.md`.
> This file defines how to produce a skill-writing `SKILL.md` whose target domain is agent files such as `.agent.md`, `AGENT.md`, and `CLAUDE.md`.

## Purpose

This file defines the authoritative behavior for producing agent-writing instructions that yield concise, accurate, executable agent files.

The parent spec defines how specifications must be written. This child spec specializes that contract for agent files, where context cost is high and the runtime artifact must be as lean as possible without losing control semantics.

The central design rule is two-plane separation:

- the companion spec is the rich source language
- the target agent file is the executable byte-code

## Scope

This spec governs a derived target `SKILL.md` whose job is to tell an authoring agent how to write agent files.

The target domain includes agent-facing instruction files such as `.agent.md`, `AGENT.md`, `CLAUDE.md`, and similar runtime-loaded control documents.

This spec inherits the parent requirements from `../spec-writing/SKILL.spec.md` and adds agent-specific constraints about what belongs in the runtime agent file versus the companion spec.

## Definitions

- **Agent spec**: the verbose companion document that defines an agent-writing contract in full.
- **Target skill file**: the derived `SKILL.md` that teaches authors how to write agent files.
- **Runtime agent file**: the final agent instruction file loaded directly into an agent session.
- **Control content**: identity, role, goals, boundaries, permissions, tools, communication rules, escalation rules, and other instructions that directly affect agent behavior.
- **Non-control content**: reasoning, incident history, audit reports, prior bug narratives, design debate, examples beyond the minimum needed, and explanatory material that does not directly change runtime behavior.
- **Byte-code principle**: the runtime agent file is the compiled operational form of the richer spec and should contain only executable control content.
- **Authority boundary**: an instruction that defines who may do what, under what conditions, and with what escalation path.

## Requirements

The agent-writing spec must:

- conform to the parent spec
- define the runtime agent file as a control artifact, not a notebook
- explicitly separate control content from non-control content
- identify which material belongs only in the companion spec
- identify which instructions must survive unchanged into the runtime agent file

The target `SKILL.md` must instruct authors that the runtime agent file must:

- be self-contained for runtime use
- be concise by default
- be accurate and behaviorally complete
- contain only control content needed by the running agent
- preserve exact tool names, command names, file names, flags, labels, branch names, model IDs, roles, and permission boundaries when exactness matters
- preserve logic and modality words, including not, never, only, unless, must, may, required, and optional
- preserve ordered procedures, retry limits, escalation conditions, and shutdown or safety sequences
- include identity, role, scope, key operating rules, and escalation behavior when those are required for correct execution

The agent-writing spec may include:

- rationale for why the runtime file must be lean
- incident reports
- failure analyses
- audit findings
- edge-case walkthroughs
- protocol notes that push the author toward a more efficient runtime file
- examples showing what belongs in the spec rather than the agent file

These additions are permitted in the spec only when they help the author produce a safer, more accurate, and more efficient runtime agent file.

## Constraints

The runtime agent file must not include:

- long-form rationale
- audit logs
- historical incident narrative
- bug reports
- speculative design notes
- duplicated reminders that do not add operational control
- prose that exists only to persuade a human reader

The runtime agent file must not:

- rely on the companion spec being loaded during normal execution
- hide authority boundaries in descriptive text
- hide permission rules in examples
- compress away actors, permissions, sequences, or safety conditions
- trade safety or authority clarity for token savings

The agent-writing spec must not use efficiency as an excuse to omit runtime-critical control instructions.

## Behavior

The companion spec should behave like a full source-language contract for the agent.

The runtime agent file should behave like compiled byte-code for control.

Compilation from spec to runtime agent file must follow these rules:

- retain all control content needed for correct behavior
- strip non-control content
- flatten explanation into explicit operating rules
- compress wording only when role, authority, and behavior remain unchanged
- prefer direct agent-facing phrasing over narrative explanation
- keep examples only when removing them would make a control rule ambiguous
- preserve exact shutdown, safety, approval, permission, and escalation sequences

The runtime agent file should prefer:

- concise identity and role statements
- direct rules
- explicit tool-use boundaries
- explicit stop conditions
- stable terminology
- minimal repetition

If a shorter instruction weakens authority, safety, or escalation clarity, the shorter instruction must not be used.

## Defaults and Assumptions

- Runtime agent files are read frequently.
- Companion specs are read less frequently than runtime agent files.
- Token efficiency matters strongly for runtime agent files.
- Companion specs may contain large amounts of reasoning and evidence.
- Runtime agent files are expected to behave as operational control surfaces, not explanatory references.
- Human reviewers, auditors, and repair agents may consult the companion spec when the runtime file needs correction.

## Error Handling

If content in the runtime agent file does not directly control behavior, move it to the companion spec.

If content in the companion spec is required to safely operate the agent, promote it into the runtime agent file.

If shortening an instruction weakens permissions, safety, sequencing, or escalation clarity, expand the instruction until the ambiguity is removed.

If a control rule could reasonably be interpreted in more than one way, rewrite it before treating the runtime file as valid.

If a runtime agent file cannot be both extremely lean and operationally complete, operational completeness wins.

## Precedence Rules

- The parent spec governs general specification quality.
- This child spec governs agent-specific target behavior.
- Safety and authority boundaries win over brevity.
- Correctness wins over stylistic density.
- Self-containment wins over aggressive compression.
- Explicit permissions and prohibitions win over implied intent.
- The companion spec holds rationale; the runtime agent file holds executable control.

## Non-Goals

The runtime agent file is not:

- a tutorial
- a postmortem
- an audit report
- a design debate
- a historical archive
- a human-first explanation document

This spec does not require the runtime agent file to preserve every explanation from the companion spec.

This spec does require the runtime agent file to preserve every control instruction that matters at runtime.
