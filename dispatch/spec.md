# dispatch spec

## Purpose

Define the runtime decision an agent makes when considering whether and how to dispatch a sub-agent. Replaces tribal knowledge with an explicit decision tree, model tier table, footgun list, and well-formed-prompt template.

This skill governs four artifacts:

- `spec.md` (this file): the normative specification. Audited but never loaded at runtime.
- `uncompressed.md`: the human-readable source for the runtime card. Edited by `--fix` mode.
- `SKILL.md`: the compiled runtime card (compressed from `uncompressed.md`). Loaded by every caller.
- `supplemental.md`: optional read for nuance. Empirical evidence, anti-pattern walkthroughs, error handling, precedence rules, subagent-type dimensions. Not loaded by default; agents fetch it on demand when the runtime card is insufficient.

## Scope

Applies to any calling agent with access to a sub-agent dispatch primitive (in Claude Code: the `Agent` tool with a `subagent_type` parameter). Covers the choice to dispatch, the parameters of dispatch, and the boundary between inline execution and delegation.

Does NOT cover:

- Internals of how Claude Code transports a dispatch.
- How to design a custom subagent type or write its agent file.
- How to author a skill or write a spec (`skill-writing`, `spec-writing`).
- Inter-agent communication via Telegram, MCP, or other channels.
- Non-dispatch delegation patterns (writing tasks to a queue for other agents to claim).

This skill is a **runtime** skill, not an authoring skill. Cross-references are one-way: authoring skills (`skill-writing`) reference `dispatch`; `dispatch` does not reference them back.

## Definitions

**Calling agent** (or **host**): the agent currently executing that is considering dispatch. Owns the operator conversation, holds in-memory state, pays the inline-token cost for any work it does not delegate.

**Dispatched agent** (or **sub-agent**): the agent spawned by the host via the dispatch primitive. Runs as a child process, completes its task, returns a single result.

**Subagent type**: the named class of sub-agent the host requests. Platform-defined; names evolve between releases. The conceptual term "subagent type" (with a space) refers to this category in prose; the literal token `subagent_type` (with an underscore) is only the parameter name in the dispatch tool's schema.

**Foreground dispatch**: host blocks until dispatched agent returns.

**Background dispatch**: host fires the dispatch and continues; receives a notification on completion. In Claude Code: `run_in_background: true` on the `Agent` tool.

**Project context**: disk-resident files Claude Code loads automatically — primarily the `CLAUDE.md` hierarchy walked from cwd upward, plus project memory index.

**Conversation context**: in-memory turn history the host has accumulated since session start.

**Inherited context**: context arriving in the dispatched agent's system prompt automatically.

**Hand-fed context**: context the host explicitly composes into the dispatch prompt.

**fast-cheap**: cost-optimized model tier for shallow, mechanical, true zero-context work (Haiku-class on Anthropic).

**standard**: capable default tier for moderate reasoning (Sonnet-class on Anthropic). Most common explicit override.

**deep**: highest-reasoning tier (Opus-class on Anthropic). Rare as explicit override; consider inline.

**Model override**: the `model` parameter on the dispatch.

**Tool scope**: tools a given subagent type may call.

**Footgun**: a documented failure mode where an obviously sensible-looking dispatch produces a damaging or wasteful result.

## Requirements

### Runtime card (`SKILL.md` / `uncompressed.md`)

R1. Must present the decision tree as a single table. Conditions evaluated in order; first match wins. Outcomes limited to: Defer, Inline, Dispatch foreground, Dispatch background, Defer-or-batch.

R2. Must present the model tier table with three rows: `fast-cheap`, `standard`, `deep`. Each row: use-case + risk. Must explicitly note that `fast-cheap` pre-pass is appropriate only for true zero-context work.

R3. Must state that **project context inherits automatically** and **conversation context does not**. Empirical evidence lives in `supplemental.md`, not the runtime card.

R4. Must include a Well-Formed Prompt section listing the four required components (Goal, Hand-fed context, Output shape, Scope/length constraints) and a four-item checklist.

R5. Must enumerate footguns F1–F5 as a table with two columns only: footgun name + mitigation. No "why" prose. Rationale lives in this spec and may be expanded in `supplemental.md`.

R6. Must instruct on subagent-type selection at minimum:
- Project context inherits; don't hand-feed.
- Conversation context does not inherit; hand-feed everything else.
- Select narrowest type covering required tool scope.
- Type names evolve; treat known names as examples.

R7. Must state the inline-cost-unaffordable fallback: (a) dispatch with fully hand-fed prompt, or (b) defer.

R8. Must point to `supplemental.md` for nuance. Must NOT inline supplemental content.

R9. Must NOT contain:
- Empirical test descriptions (date, method, token examples) — those live in `supplemental.md`.
- Anti-pattern walkthroughs — `supplemental.md`.
- Error-handling tables — `supplemental.md`.
- Precedence rules prose — `supplemental.md`.
- Subagent-type dimension prose — `supplemental.md`.
- "Why it is a footgun" rationale — this spec only.
- Cross-references to authoring skills (`skill-writing`, `spec-writing`).

### Supplemental (`supplemental.md`)

R10. Must present empirical claims about context inheritance in the canonical form: "Empirical (DATE, METHOD): CLAIM." Both the conversation-context-not-inherited and project-context-inherited claims must be present with date stamps.

R11. Must include at least one explicit anti-pattern walkthrough prefixed with the literal token `ANTI-PATTERN:`. The example shows (a) a plausible dispatch decision, (b) what goes wrong, (c) the correct decision.

R12. Must provide error-handling guidance covering: ambiguous decision tree, footgun fires, incoherent output, inline cost unaffordable.

R13. Must enumerate precedence rules: consuming-skill domain pattern governs over general guidance; empirical fact governs over expectation; correctness over throughput.

R14. Must enumerate subagent-type dimensions (tool scope, system prompt size, default model) with current Claude Code examples flagged as non-stable.

### Boundary

R15. Cross-references are one-way. `dispatch` is referenced by authoring skills (`skill-writing`, `spec-writing`) and by runtime callers; `dispatch` itself references only `dispatch/agents/` (companion artifacts). The runtime card and supplemental must NOT reference authoring skills.

R16. Use role-agnostic language. Terms "Curator," "Worker," "Overseer," or any project-internal role name must not appear. Canonical labels: "host," "dispatched agent," "calling agent."

## Constraints

C1. `SKILL.md` (compiled runtime) must not exceed approximately 3000 bytes. Skim-friendly under load is the priority.

C2. `uncompressed.md` is the source the auditor edits in `--fix` mode. It must be a tight reference card, not exposition. Auditor's "too much why" / "essay not reference card" / "prose conditionals" findings apply.

C3. `supplemental.md` has no byte cap but must remain a single file. If it grows beyond ~6000 bytes, split contents into `supplemental/<topic>.md` files referenced from a `supplemental.md` index.

C4. The runtime card must not enumerate the current Claude Code subagent_type list as if stable. Names appear as examples only and must signal evolution.

C5. The runtime card must not embed project-internal procedural detail.

C6. The runtime card must not recommend a single subagent type as a universal default.

C7. The runtime card must remain answerable end-to-end without reading `supplemental.md`. Supplemental is for nuance, not load-bearing instructions.

## Behavior

B1. Decision tree appears at top of runtime card before any other section.

B2. Layered structure: decision tree → tier table → subagent type → prompt → footguns → fallback → pointer to supplemental → related artifacts.

B3. Every empirical claim in `supplemental.md` is anchored: "Empirical (DATE, METHOD): CLAIM."

B4. Footgun rows in the runtime card use the literal token `Mitigation:` is not required (the table column header replaces the inline marker). Anti-pattern blocks in `supplemental.md` use the literal token `ANTI-PATTERN:`.

B5. Cross-references one-way (per R15).

## Defaults and Assumptions

D1. Default for "is this work worth dispatching at all" is **inline**. Dispatch is the exception.

D2. Default model for a dispatch where the host has not specified one is the host's own model.

D3. Default for foreground vs background when the host is in a long-poll loop or has any responsiveness obligation is **background**.

D4. Default for empirical claims this skill cannot verify is "unverified" labeling.

## Error Handling

Operational error-handling rules (what to do when things go wrong at runtime) live in `supplemental.md`. The spec governs what content must be present there:

E1. Decision tree no clear outcome → default inline + file feedback. No "guess."

E2. Footgun fires → revise decision before retry.

E3. Output incoherent → inspect prompt for missing hand-fed context (F5).

E4. Inline cost unaffordable → (a) hand-feed and dispatch, or (b) defer.

## Precedence Rules

P1. Correctness over throughput.

P2. Empirical fact over expectation.

P3. Consuming skill's domain procedure governs over this skill's general guidance.

P4. Role-agnostic language over project-specific clarity.

(Operational text for these rules lives in `supplemental.md` per R13.)

## Don'ts

DN1. Do not enumerate every Claude Code subagent_type with a stability guarantee.

DN2. Do not include a tutorial in the runtime card.

DN3. Do not include implementation detail of how Claude Code transports a dispatch.

DN4. Do not include role-specific language.

DN5. Do not embed memory references or host-private artifacts in normative text.

DN6. Do not introduce a default subagent type, default model, or default foreground/background mode beyond D1–D3.

DN7. Do not duplicate content from authoring skills. Reference and stop. (And do not reference them from this skill — see R15.)

DN8. Do not create a "quick reference" block separate from the decision tree. The decision tree IS the quick reference.

DN9. Do not include claims about subagent behavior without an empirical anchor or "unverified" label.

DN10. Do not extend the skill scope to non-dispatch delegation patterns.

DN11. Do not move runtime instructions into `supplemental.md`. Supplemental is for nuance only; the runtime card must stand alone.

DN12. Do not move spec rationale into `supplemental.md`. Spec rationale lives in the spec.
