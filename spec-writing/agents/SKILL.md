---
name: agents
description: Write agent files that are concise, accurate, self-contained, and operationally complete. Compile from companion spec to runtime control surface.
---

Write agent files as executable control surfaces. Companion spec = source language; agent file = compiled byte-code.

Purpose: produce runtime agent files (`.agent.md`, `AGENT.md`, `CLAUDE.md`) containing only instructions needed to operate correctly.

Scope: use when writing or rewriting an agent file from a companion spec.

Definitions:
Agent spec: verbose companion defining full agent contract.
Runtime agent file: instruction file loaded directly into agent session.
Control content: identity, role, goals, boundaries, permissions, tools, communication rules, escalation rules, other instructions affecting agent behavior.
Non-control content: reasoning, incident history, audit reports, bug narratives, design debate, excessive examples, explanatory material not changing runtime behavior.
Byte-code principle: runtime file is compiled operational form of richer spec — only executable control content.
Authority boundary: instruction defining who may do what, under what conditions, with what escalation path.

What goes where:

Agent file (control content):
Identity, role, scope.
Operating rules, boundaries.
Tool permissions, restrictions.
Procedures, ordered steps, retry limits.
Escalation conditions, shutdown sequences, safety gates.
Authority boundaries: who does what, under what conditions.
Stop conditions, error handling.

Companion spec only (non-control content):
Design rationale.
Incident history, audit findings.
Bug reports, failure analyses.
Extended examples, edge-case walkthroughs.
Protocol notes explaining why rules exist.

Requirements:
Self-contained. Agent file must not require companion spec at runtime.
Concise. Every line must earn its place.
Accurate. Preserve all load-bearing meaning from spec.
Behaviorally complete. Every control instruction that matters at runtime must be present.
Preserve exact technical strings: tool names, commands, flags, file paths, config keys, branch names, model IDs, roles, permission boundaries.
Preserve logic/modality words: not, never, only, unless, must, may, required, optional.
Preserve ordered procedures, retry limits, escalation conditions, shutdown sequences.
Preserve authority boundaries unchanged.

Constraints:
No long-form rationale.
No audit logs, bug reports, historical incident narrative.
No speculative design notes.
No duplicated reminders adding no operational control.
No prose existing only to persuade human reader.
Never hide authority boundaries in descriptive text.
Never hide permission rules in examples.
Never compress away actors, permissions, sequences, or safety conditions.
Never trade safety or authority clarity for token savings.
Never use efficiency as excuse to omit runtime-critical control instructions.

Behavior — compiling spec → agent file:
1. Extract all control content from spec.
2. Strip non-control content.
3. Flatten explanation into explicit operating rules.
4. Compress wording only when role, authority, and behavior remain unchanged.
5. Use direct agent-facing phrasing over narrative explanation.
6. Keep examples only when removing them makes control rule ambiguous.
7. Preserve exact shutdown, safety, approval, permission, and escalation sequences.

Prefer: concise identity statements, direct rules, explicit tool-use boundaries, explicit stop conditions, stable terminology, minimal repetition.

Error handling:
Content doesn't directly control behavior → move to companion spec.
Spec content required for safe operation → promote into agent file.
Shortening weakens permissions, safety, sequencing, or escalation clarity → expand until unambiguous.
Control rule has multiple reasonable interpretations → rewrite before accepting.
File cannot be both lean and operationally complete → operational completeness wins.

Precedence:
Parent spec governs general specification quality.
Child agent-writing spec governs agent-specific target behavior.
Safety and authority boundaries win over brevity.
Correctness wins over stylistic density.
Self-containment wins over aggressive compression.
Explicit permissions/prohibitions win over implied intent.
Companion spec holds rationale; runtime agent file holds executable control.

Defaults:
Runtime agent files read frequently; token efficiency matters strongly.
Companion specs read less frequently, may contain large reasoning.
Runtime agent files are operational control surfaces, not explanatory references.
Human reviewers, auditors, repair agents may consult companion spec when runtime file needs correction.

Non-goals: runtime agent file is not a tutorial, postmortem, audit report, design debate, historical archive, or human-first explanation document.
Does not require preserving every explanation from companion spec.
Does require preserving every control instruction that matters at runtime.
