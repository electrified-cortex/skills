---
name: dispatch-strategy
description: Decision tree for whether to dispatch a sub-agent, foreground vs background, subagent type and model selection, prompt construction, and documented footguns with mitigations.
---

# Dispatch Strategy

Dispatched agents bootstrap from scratch: no conversation history, no host context beyond what platform injects and host writes into prompt. Wrong dispatch = token waste or trust-boundary violation.

## Decision Tree

**Q1: Is work worth doing now?**
Speculative, blocked, or lower priority → Defer: record draft task, move on. Don't dispatch or execute.

**Q2: Does work require host's conversation context?**
Conversation context doesn't transfer to any dispatched agent.
Empirical (2026-04-19, secret-phrase test): host wrote unique token (`purple-tractor-mountain-9183`) in conversation, dispatched sub-agent asked to quote it; sub-agent reported no conversation context visible. Context isn't inherited by any dispatched subagent type.
If work can't be stated without that history, and summarizing costs more tokens than doing it inline → don't dispatch — perform inline.

**Q3: Does work hold exclusive resource host already owns?**
Live session, authenticated channel, open file lock — no clean handoff → don't dispatch — perform inline. See F1.

**Q4: Is work large enough to justify dispatch overhead?**
Every dispatch carries fixed overhead: system prompt injection, project context loading, output round-trip. Host can complete in fewer than ~3 turns → don't dispatch — perform inline. See F2.

**Q5: Does result need to be acted on same host turn?**

- Yes + must keep responding to driver: can't block. Defer or batch.
- Yes + blocking acceptable: dispatch foreground — host blocks until result arrives.
- No (result can arrive later): dispatch background — host continues, notified on completion.

Default (D3): in long-poll loop or any responsiveness obligation, prefer background dispatch.

## Q6: Summary

| Answer | Outcome |
| --- | --- |
| Work speculative or blocked | Defer |
| Requires host conversation context | Inline |
| Holds exclusive resource, no handoff | Inline |
| Completable in fewer than ~3 host turns | Inline |
| Result needed this turn, blocking unacceptable | Defer or batch |
| Result needed this turn, blocking acceptable | Dispatch foreground |
| Result can arrive later | Dispatch background |

Default (D1): default is inline. Dispatch is exception, not rule.

## Subagent Type Selection

Project context IS inherited automatically by every subagent type.
Empirical (2026-04-19, enumerate-context test): both `Dispatch`-type and `general-purpose`-type sub-agents were asked to list CLAUDE.md and memory files visible in system prompts; both reported workspace and project-scoped CLAUDE.md files plus project memory index. Project context is inherited.
Don't hand-feed project-level rules into every dispatch prompt.

Three dimensions for type selection:

1. Tool scope: types are permitted different tools. Some are deliberately restricted (e.g., scope-isolated audit type may have no file-write tools). Match type to tools task actually needs — don't reach for broader-scoped type just because familiar.
2. System prompt size: heavy system prompt = more tokens per dispatch. Prefer leaner types for simple tasks.
3. Default model: some types pin a default model. Override if pinned model is heavier than task warrants (see Model Override).

Platform's named subagent types evolve between Claude Code releases. Treat any type name as example, not stable enumeration. Verify from current platform docs before relying on specific name. As of 2026-04-19 Claude Code offers types such as `Dispatch` (scope-isolated) and `general-purpose` (broader), but complete list and properties may change.

In practice: "Does task need file writes, external tool calls, or only read/analysis?" Match narrowest type whose tool scope covers task. Don't default to maximally permissive type.

## Model Override

`model` param on dispatch specifies model class differing from host's. Platform default (D2): host's own model when no override specified.

Downgrade to cheaper model (e.g., `haiku` from `sonnet`/`opus` host): correct for shallow, mechanical work — pattern matching, formatting, simple extraction. Trades reasoning depth for cost and speed. Weak result = re-dispatch at higher tier; calibrate before dispatching.
Downgrade one tier (e.g., `sonnet` from `opus` host): correct for moderate reasoning. Most common override; captures most cost savings with less risk of shallow output.
Same or upgrade (e.g., `opus` from `sonnet` host): correct when task requires reasoning depth equal to or exceeding host's, or when critical-path work and errors are expensive to retry. Upgrade is unusual; consider whether inline is better.

| Override direction | Trade-off |
| --- | --- |
| Downgrade to cheapest (`haiku`) | Low cost, fast, risks shallow output |
| Downgrade one tier (`sonnet`) | Moderate cost, moderate risk |
| Same or upgrade | High cost, deepest output, rarely needed |

## When NOT to Dispatch

1. Work requiring host's conversation context where summarizing costs more than doing it directly. Context doesn't inherit; hand-feeding a full summary is often the work itself.
2. Work whose result must drive host's current-turn response when blocking is unacceptable. Background delivers later; foreground blocks. Neither fits "need this now to finish composing reply."
3. Work holding exclusive resource with no clean handoff: authenticated sessions, open connections, resources host must hold continuously. Dispatching produces F1.
4. Work trivial enough to complete inline in under three turns. Dispatch overhead exceeds work value.

If host can't afford inline cost: (a) dispatch with fully hand-fed context prompt and accept prompt-construction cost, or (b) defer. Don't dispatch incorrectly because inline is expensive.

## Well-Formed Dispatch Prompt

Omitting any required component produces poor or incoherent output.

Required components:

1. Goal: one sentence stating exactly what dispatched agent is to accomplish. No ambiguity. No implicit prior context.
2. Hand-fed context: everything dispatched agent needs that it can't inherit:
   - Prior decisions constraining task
   - Operator preferences relevant to task
   - File references by absolute path (dispatched agent can't infer paths from conversation)
   - Definitions of project-specific terms not in CLAUDE.md
   - Any findings from host's prior turns the task depends on
3. Expected output shape: what should come back. Examples: "single verdict: PASS or FAIL", "written file at specified path", "bullet list of findings one per line", "single line of text". Vague expectations produce vague output.
4. Scope and length constraints: what's out of scope, what agent must NOT do, any length limits.

Checklist before dispatching:

- [ ] Can stranger with no prior context read this prompt and know exactly what to do?
- [ ] Have I referenced every needed file by absolute path?
- [ ] Have I stated every constraint task requires?
- [ ] Have I described expected output?

Any answer no → prompt isn't ready. Fill gaps before dispatching.

## Footgun Catalogue

**F1: Host-impersonation on shared exclusive resource**
Dispatched agent attempts to act as host on resource host already holds open — authenticating to session, channel, or external service host is already connected to.
Why: host's session may be invalidated, or dispatched agent errors and consumes tokens reporting it. Resource has two competing owners.
Mitigation: state explicitly in dispatch prompt that dispatched agent must NOT initiate sessions, authenticate, or interact with named shared resource. If work genuinely needs that resource, perform inline.

**F2: Dispatch for trivial work**
Dispatched agent given work small enough to complete inline in few host turns.
Why: dispatch overhead — system prompt injection, project context loading, output round-trip — exceeds work value. More tokens dispatching than task costs.
Mitigation: apply Q4. Fewer than ~3 host turns → don't dispatch.

**F3: Tight-loop micro-dispatches**
Host fires many small dispatches sequentially where one batched dispatch would suffice.
Why: each dispatch carries fixed overhead. Sequential micro-dispatches multiply overhead; aggregate token churn dominates useful work.
Mitigation: aggregate work into single dispatch prompt returning single structured result. If aggregation genuinely impossible, reconsider whether dispatch is right pattern — sequential micro-dispatches that can't be batched often indicate work should be inline.

**F4: Hook-denial escape via dispatch**
Host dispatches to bypass hook or permission denial that correctly applies to host.
Why: trust boundary violation. Dispatched agent may inadvertently perform actions host was correctly prevented from performing. Hook denial was authoritative.
Mitigation: never dispatch as workaround for denial. Treat denial as authoritative. Address directly: request permission from operator, change approach, or escalate. Don't route around governance.

**F5: Thin-prompt context assumption**
Host writes sparse dispatch prompt expecting dispatched agent to reconstruct intent from conversation context that doesn't transfer.
Why: dispatched agent has zero visibility into host's prior turns. "Continue analysis we discussed" delivers nothing — no "we", no "analysis", no prior turns.
Mitigation: every dispatch prompt must satisfy well-formed prompt requirements. Hand-feed every piece of context dispatched agent needs but can't inherit. Write as if dispatched agent is stranger reading cold — because it is.

## Anti-Pattern Example

ANTI-PATTERN: Host midway through research conversation. Operator gave several instructions narrowing scope of code audit; host produced partial findings in prior turns. Host dispatches sub-agent with: "Continue the code audit and produce the final findings report."

What goes wrong: dispatched agent has no conversation context. Doesn't know operator's instructions, narrowed scope, or partial findings. Will either refuse (no goal), produce full unscoped audit (ignoring narrowing), or invent findings to fill gap. Host receives unusable result.

Correct decision: (a) perform inline where host has conversation context, or (b) dispatch with fully hand-fed prompt including operator's scope instructions (quoted or paraphrased), partial findings to date (written out explicitly), and specific remaining work to complete. Option (a) is usually cheaper.

## Error Handling

Decision tree returns no clear outcome → default to inline. File draft task or feedback note describing ambiguous case. Don't guess.

Footgun fires (e.g., dispatched agent errors on shared resource): treat error as evidence of wrong dispatch decision, not transient noise. Revise decision before retrying. Don't retry same dispatch unchanged.

Dispatched agent output incoherent or off-topic: most likely cause is conversation-context absence (F5). Inspect dispatch prompt for missing hand-fed context. Correct prompt, then re-dispatch.

Inline cost unaffordable: (a) dispatch with fully hand-fed context prompt, accepting prompt-construction overhead, or (b) defer. Don't dispatch incorrectly because inline is expensive.

## Precedence Notes

Consuming skill (`skill-writing`, `task-management`) describing specific dispatch pattern for its domain → that procedure governs over this skill's general guidance for that domain. This skill provides primitives; consumers shape them for their context.

Where this skill's empirical claims conflict with agent's expectation about what dispatched agents inherit → empirical claim governs.

Correctness over throughput: when correct outcome is "inline" but host is overloaded, this skill isn't permission to dispatch incorrectly. Defer or reduce scope; don't dispatch wrongly.

## Related Skills

`skill-writing` — spec-inline / body-dispatched workflow depends on dispatch decisions; consult for how dispatch is used in skill creation.
`task-management` — task pipeline work (claim, audit, complete) uses dispatch; consult for domain-specific dispatch patterns for task work.
`spec-writing` — for terminology consistency when this skill's output feeds spec workflow.
