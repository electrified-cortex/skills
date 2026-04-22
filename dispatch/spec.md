# dispatch spec

## Purpose

This skill helps a calling agent decide whether to dispatch a sub-agent for a given task, and if so, how to dispatch it. The decision is currently tribal knowledge: agents repeatedly fork sub-agents that bootstrap fresh, lose context, redundantly load project files, and sometimes interfere with shared resources the host already owns. This skill replaces tribal knowledge with an explicit decision tree, documented dimensions, and a footgun list.

The skill answers: foreground or background? Which subagent type? Which model? Should this even be a dispatch, or done inline? What context does the dispatched agent inherit, and what must be hand-fed via the prompt?

## Scope

This skill applies to any calling agent that has access to a sub-agent dispatch primitive (in Claude Code: the `Agent` tool with a `subagent_type` parameter). It covers the choice of dispatching, the parameters of the dispatch, and the boundary between "do it inline" and "delegate to a sub-agent."

This skill does NOT cover:

- The internals of how Claude Code transports a dispatch (request/response shape, hook ordering).
- How to design a custom subagent type or write its agent file.
- How to author a skill, write a spec, or run an audit. Those are separate skills (`skill-writing`, `spec-writing`, `skill-auditing`).
- Communication between dispatched agents and external systems (Telegram, MCP servers, databases). Those interactions are governed by their respective skills.

This skill IS consumed by: `skill-writing` (the canonical "spec-inline, body-dispatched" workflow depends on dispatch decisions), `task-management` and its sub-skills (claim/audit work is often dispatched), and any role-specific agent file that describes when to use sub-agents.

## Definitions

**Calling agent** (or **host**): the agent currently executing that is considering whether to dispatch. The host owns the conversation with the operator (or driving system), holds in-memory state, and pays the inline-token cost for any work it does not delegate.

**Dispatched agent** (or **sub-agent**): the agent spawned by the calling agent via the dispatch primitive. The dispatched agent runs as a child process of the host, completes its task, and returns a single result to the host.

**Subagent type**: the named class of sub-agent the host requests. The platform offers a small set of named types (for example, in Claude Code as of 2026-04, the type `Dispatch` is intended for scope-isolated work and the type `general-purpose` is intended for broader work). Specific type names are platform-defined and may change between releases; this skill treats type names only as illustrative examples and never as a stable enumeration. The conceptual term "subagent type" (with a space) refers to this category in prose; the literal token `subagent_type` (with an underscore) refers only to the parameter name in the dispatch tool's schema.

**Foreground dispatch**: the host blocks until the dispatched agent returns. The host cannot continue its own work, respond to its driver, or service other concerns until the result arrives.

**Background dispatch**: the host fires the dispatch and immediately continues its own work. The host receives a notification when the dispatched agent completes. In Claude Code this is the `run_in_background: true` parameter on the `Agent` tool.

**Project context**: the disk-resident files Claude Code automatically loads for any session running in the project — primarily the `CLAUDE.md` hierarchy walked from the working directory upward, and any project-configured memory index.

**Conversation context**: the in-memory turn history the calling agent has accumulated since its session began — operator messages, tool results, and the host's own prior outputs.

**Inherited context**: context that arrives in the dispatched agent's system prompt automatically, without the host writing anything into the dispatch prompt.

**Hand-fed context**: context the host explicitly composes into the dispatch prompt because it would not otherwise reach the dispatched agent.

**fast-cheap**: the cost-optimized model tier for shallow, mechanical work (Haiku-class on Anthropic; map to your platform's inexpensive tier). Use for smoke passes, iterate-phase audits, and zero-context dispatch tasks.

**standard**: the capable default tier for work requiring moderate reasoning (Sonnet-class on Anthropic; map to your platform's standard tier). The most common explicit override when dispatching from a `deep`-tier host.

**deep**: the highest-reasoning tier for critical-path or complex work (Opus-class on Anthropic; map to your platform's most capable tier). Upgrade to this tier is unusual; consider inline instead.

**Model override**: the `model` parameter on the dispatch, allowing the host to specify a model class (for example `fast-cheap`, `standard`, `deep`) that may differ from the host's own model. Used to trade depth for cost or speed.

**Tool scope**: the set of tools the dispatched subagent type is allowed to call. Distinct subagent types have different tool scopes; some types are deliberately restricted.

**Footgun**: a documented failure mode where an obviously sensible-looking dispatch produces a damaging or wasteful result.

## Requirements

R1. The skill must present a decision tree that a calling agent can apply in order, asking a small number of explicit questions, and arriving at one of these outcomes for each candidate piece of work:

- **Do not dispatch** — perform the work inline.
- **Dispatch foreground** — block on the result.
- **Dispatch background** — continue host work, await notification.
- **Defer** — neither dispatch nor execute now; record the work as a draft to be addressed later.

R2. The skill must explicitly state, as a load-bearing fact, that **conversation context is not inherited by any dispatched subagent type**. The dispatched agent has zero visibility into the host's prior turns. The skill must present this claim in the canonical empirical form defined in B3 — for example: "Empirical (2026-04-19, secret-phrase test: host wrote a unique token in conversation, dispatched a sub-agent and asked it to quote the token; sub-agent reported no conversation context visible). Conversation context is not inherited." This is the single most common assumption that calling agents get wrong, and the decision tree depends on this fact being correctly understood.

R3. The skill must explicitly state that **project context (CLAUDE.md hierarchy and project-configured memory index) IS inherited automatically by every subagent type**. The skill must present this claim in the canonical empirical form defined in B3 — for example: "Empirical (2026-04-19, enumerate-context test: dispatched both a `Dispatch`-type and a `general-purpose`-type sub-agent, asked each to list the CLAUDE.md and memory files visible in its system prompt; both reported the workspace and project-scoped CLAUDE.md files plus the project memory index). Project context is inherited." This explains why dispatched agents already have a baseline awareness of project conventions without the host writing anything.

R4. The skill must enumerate the dimensions on which subagent types differ. At minimum:

- Tool scope (which tools the dispatched agent may call).
- System prompt size (how much default instruction the dispatched agent carries).
- Default model (if any subagent type pins a default model).

R5. The skill must explain when to specify a model override and which trade-offs the override makes. At minimum the skill must cover the three named tiers defined in Definitions:

- **fast-cheap** — for shallow mechanical work (pattern matching, formatting, simple extraction). Lowest cost; risks shallow output on tasks requiring reasoning depth.
- **standard** — for work requiring moderate reasoning. Most common explicit override when dispatching from a `deep`-tier host.
- **deep** — when the dispatched task requires maximum reasoning depth, or when errors are expensive to retry. Unusual as an explicit override; consider inline.

R6. The skill must enumerate at least the following footguns. For each, the skill must state (a) the footgun name and (b) the mitigation (per B4). The rationale for why each is a footgun belongs in this spec, not in the runtime skill.

- F1. **Host-impersonation on a shared exclusive resource.** Dispatched agent acts as host on a resource the host already holds open. Rationale (spec only): host session may be invalidated; two competing owners burn tokens. **Mitigation**: state in dispatch prompt that the dispatched agent must NOT initiate sessions, authenticate, or interact with the named shared resource; if the work needs that resource, perform inline.
- F2. **Dispatch-for-trivial-work.** Dispatched agent given work completable inline in a few host turns. Rationale (spec only): dispatch overhead exceeds work value. **Mitigation**: apply Q4 — fewer than ~3 host turns → inline.
- F3. **Tight-loop micro-dispatches.** Host fires many small dispatches sequentially where one batched dispatch suffices. Rationale (spec only): aggregate token churn dominates. **Mitigation**: aggregate into a single dispatch returning a single structured result; if impossible, reconsider dispatch entirely.
- F4. **Hook-denial escape via dispatch.** Host dispatches to bypass a hook or permission denial. Rationale (spec only): trust boundary violation. **Mitigation**: never dispatch as denial workaround; treat denial as authoritative; request permission, change approach, or escalate.
- F5. **Thin-prompt context assumption.** Host writes sparse prompt expecting dispatched agent to reconstruct from conversation context that does not inherit (per R2). Rationale (spec only): dispatched agent has zero visibility into prior turns. **Mitigation**: every dispatch prompt must satisfy well-formed requirements in R8; hand-feed all context the agent cannot inherit.

R7. The skill must include a section titled "When NOT to dispatch" that lists the classes of work where inline execution is correct, even if the work is large or slow. At minimum:

- Work that requires the host's conversation context and would cost more to summarize than to do inline.
- Work whose result must be acted on within the same host turn (the dispatched agent's notification arrives later — by definition not in the same turn for background; for foreground the host blocks, which may itself be unacceptable).
- Work that holds an exclusive resource for which there is no clean handoff (see F1).

R8. The skill must define the minimum content of a well-formed dispatch prompt. A well-formed prompt includes:

- The goal the dispatched agent is to accomplish, stated as a single sentence.
- The relevant context the dispatched agent needs but cannot inherit (for example: prior decisions, operator preferences, references to files by absolute path, definitions of project-specific terms).
- The expected output shape (for example: a verdict, a file written, a list of findings, a single line of text).
- Any constraints on length or scope.

R9. The skill must define the boundary between this skill and adjacent skills. The skill must reference, but not reproduce:

- `skill-writing` for how to structure a skill that dispatches (routing card, inline vs dispatch decision). `skill-writing` decides *whether* a skill dispatches and *how to shape it*; `dispatch` covers the mechanics a calling agent applies at runtime.
- Agent files (`dispatch/agents/`) as ready-to-install Dispatch agent definitions; these are companion artifacts, not normative skill content.
- Any project-internal agent files only as examples, never as authoritative content for this skill.

R10. The skill must use role-agnostic language. The terms "Curator," "Worker," "Overseer," or any other project-internal role name must not appear in the normative text of the skill. The terms "host," "dispatched agent," and "calling agent" are the canonical labels.

R11. The skill must include at least one explicit anti-pattern example. The example must show: (a) a concrete dispatch decision a calling agent might plausibly make, (b) the specific outcome that makes it wrong (token waste, broken assumption, footgun fired, incorrect result), and (c) the correct decision the calling agent should have made instead. The example must be prefixed with the `ANTI-PATTERN:` marker defined in B5. The example may be drawn from any plausible scenario; it does not need to map to a real incident.

R12. The skill must hedge any empirical claim about subagent context inheritance with a date stamp and a reference to the test method. Subagent behavior may evolve in future Claude Code releases; readers must be able to identify when a claim is anchored.

## Constraints

C1. The skill body must not exceed approximately 4000 bytes after compression. Specs may be longer; the compressed skill must remain skim-friendly under load.

C2. The skill must not enumerate the current Claude Code subagent_type list as if it were stable. Where the skill names types, it must do so as examples and signal that the list evolves.

C3. The skill must not embed Curator-specific, Worker-specific, or any other project-internal procedural detail in the normative text. Examples drawn from a project may appear in descriptive sections only, and must be flagged as examples.

C4. The skill must not recommend a single subagent type as a universal default. The whole point of the decision tree is the trade-off; any default would defeat the skill.

C5. The skill must not duplicate content from `skill-writing`, `task-management`, or `spec-writing`. Where overlap exists, this skill carries the dispatch primitive; the consuming skill carries its own logic and references this one.

C6. The skill must not create a friction point that defeats its purpose. If the decision tree is so elaborate that an agent under load skips it, the skill has failed. Optimization target: an agent can apply the decision tree in under three reading seconds.

C7. The skill must not present empirical context-inheritance claims as theoretical or speculative. Where a claim is empirically established, it must be stated as fact with a date stamp. Where a claim is unverified, it must be labeled as such.

C8. The skill must not require external lookup to be useful. All decision-tree branches must be answerable from the skill body alone.

## Behavior

B1. **Top-of-skill decision tree first.** The skill body must place the decision tree at or near the top, before any extended explanation. An agent skimming the skill must reach the decision tree without scrolling past background material.

B2. **Layered detail.** The skill must use a layered structure: decision tree first, then dimensions and footguns, then the well-formed-prompt template, then the cross-reference section. An agent that needs only the decision tree must be able to stop reading after the first layer.

B3. **Empirical claims explicitly anchored.** Each empirical claim about subagent behavior must be presented in the form: "Empirical (DATE, METHOD): CLAIM." This makes drift detectable.

B4. **Footguns paired with mitigations.** Each documented footgun must be followed by the specific dispatch parameter or prompt construction that prevents it. A footgun without a mitigation is incomplete. The runtime skill states the footgun name and mitigation only — no "why" prose (rationale lives in this spec).

B5. **Anti-pattern callouts use a distinct visual marker.** The skill must prefix every anti-pattern paragraph or block with the literal token `ANTI-PATTERN:` (uppercase, followed by a colon and space) so that a skimming agent can identify "do not do this" content at a glance. Mitigations (per B4) use the literal token `Mitigation:` (title case, followed by a colon and space) inline with the footgun text. Both markers are part of the skill's normative content; the implementer must not substitute alternative phrasings.

B6. **Cross-references one-way.** This skill references and is referenced; it does not embed content from skills it references, and consuming skills must not embed content from this one. The boundary section makes this explicit.

## Defaults and Assumptions

D1. Default for "is this work worth dispatching at all" is **no, do it inline** — unless the decision tree returns a positive answer. Dispatch is the exception, inline is the default.

D2. Default model for a dispatch where the host has not specified one is the host's own model. This is a Claude Code platform default, not a skill default; the skill notes this for the avoidance of doubt.

D3. Default for "foreground vs background" when the host is in a long-poll loop or has any responsiveness obligation is **background**. The host's responsiveness to its driver outweighs the latency of the result.

D4. Default for empirical claims that this skill cannot itself verify is to label them as "unverified" rather than presenting them as fact.

## Error Handling

E1. If a calling agent finds the decision tree returns no clear outcome for its work, the skill must direct the agent to default to inline and to file a draft task or feedback note describing the gap. The skill must not direct the agent to "guess."

E2. If a footgun fires (for example, a dispatched agent attempts to act as the host on a shared resource and produces an error), the host must treat the error as evidence of a wrong dispatch decision, not as transient noise. The skill must direct the host to revise the decision before retrying.

E3. If the host receives a dispatched agent's output that is incoherent or off-topic, the most likely cause is conversation-context absence. The skill must direct the host to inspect the dispatch prompt for missing context before re-dispatching.

E4. If the host cannot afford the inline cost of an inline-default decision, the skill must direct the host to either dispatch with a fully hand-fed context prompt (and accept the prompt-construction cost) or to defer the work.

## Precedence Rules

P1. **Correctness over throughput.** When the decision tree's "correct" outcome is "inline" but the host is overloaded, the skill must not be read as permission to dispatch incorrectly. The host should defer or reduce scope, not dispatch wrongly.

P2. **Empirical fact over expectation.** Where this skill's stated empirical behavior conflicts with an agent's expectation (for example, the agent assumed conversation context inherits), the empirical claim governs.

P3. **This skill subordinate to consuming skills' specific procedures.** Where `skill-writing` or `task-management` describes a specific dispatch pattern for its domain, that procedure governs over this skill's general guidance for that domain. This skill provides the primitives; consumers shape them.

P4. **Role-agnostic language over project-specific clarity.** Where a project-specific term would make the skill clearer to a host inside that project, this skill must still use the role-agnostic term. Project-specific clarity is gained by the project's own agent file referencing this skill, not by this skill bending to the project.

## Don'ts

DN1. Do not enumerate every Claude Code subagent_type with a stability guarantee. Examples are fine; comprehensive lists rot.

DN2. Do not include a tutorial. The skill is a reference, not a walkthrough.

DN3. Do not include implementation detail of how Claude Code transports a dispatch.

DN4. Do not include role-specific language ("Curator," "Worker," "Overseer," etc.).

DN5. Do not embed memory references, MEMORY.md citations, or any host-private artifacts in the normative text. Descriptive text may mention them as examples, flagged as such.

DN6. Do not introduce a default subagent type, default model, or default foreground/background mode beyond the platform defaults already documented in D1-D3.

DN7. Do not duplicate content from `skill-writing`, `task-management`, `spec-writing`, or any other adjacent skill. Reference and stop.

DN8. Do not create a "quick reference" block separate from the decision tree. The decision tree IS the quick reference.

DN9. Do not include claims about subagent behavior without an empirical anchor (date and method) or an explicit "unverified" label.

DN10. Do not extend the skill scope to cover non-dispatch delegation patterns (writing tasks for other agents to claim, posting to a shared queue, etc.). Those are task-management territory.
