---
name: dispatch
description: Decision tree for whether, how, and at what model tier to dispatch sub-agents.
---

# Dispatch

Read once — terms (`fast-cheap`, `standard`, `deep`, foreground/background, footguns F1–F5) are assumed known by any skill or agent that references `dispatch`. Inline skills don't need this skill. Skills that dispatch sub-agents must reference it.

Decision Tree:

Apply questions in order. Stop at first answer with outcome.

Q1: Speculative, blocked, or lower priority?
Defer — record draft task, move on. Don't dispatch or execute.

Q2: Work requires host conversation context?
Conversation context (in-memory turn history) doesn't transfer to any dispatched agent.
Empirical (2026-04-19, secret-phrase test): host wrote `purple-tractor-mountain-9183`, dispatched sub-agent asked to quote it — sub-agent saw nothing. Conversation context not inherited by any subagent type.
If work can't be stated without that history + summarizing costs more than inline → don't dispatch, inline.

Q3: Work holds exclusive resource host already owns (live session, auth channel, open lock)?
Don't dispatch — inline. See F1.

Q4: Work completable in fewer than ~3 host turns?
Don't dispatch — inline. Dispatch overhead (sys-prompt injection, context load, output round-trip) exceeds work value. See F2.

Q5: Result needed in same host turn?
Yes + blocking unacceptable → can't block. Defer or batch.
Yes + blocking acceptable → dispatch foreground.
No → dispatch background.
D3: host in long-poll loop or any responsiveness obligation → prefer background.

Q6 Summary:

| Answer | Outcome |
| --- | --- |
| Speculative or blocked | Defer |
| Requires host conversation context | Inline |
| Holds exclusive resource, no handoff | Inline |
| Completable in <~3 host turns | Inline |
| Result needed this turn, blocking unacceptable | Defer or batch |
| Result needed this turn, blocking acceptable | Dispatch foreground |
| Result can arrive later | Dispatch background |

D1: default is inline. Dispatch is exception, not rule.

Subagent Type Selection:

Project context inherited automatically by every subagent type.
Empirical (2026-04-19, enumerate-context test): `Dispatch`-type and `general-purpose`-type both reported workspace + project-scoped CLAUDE.md files + memory index in sys-prompt. Don't hand-feed project-level rules into every dispatch prompt.

Dimensions:
Tool scope: types have different permitted tools. Some restricted (e.g. audit type: no file-write). Match type to tools task needs — don't reach for broader-scoped type by default.
Sys-prompt size: heavy types cost more tokens per dispatch. Prefer lean types for simple tasks.
Default model: some types pin model. Override if pinned model heavier than task warrants (see Model Override).

Subagent type names evolve between Claude Code releases — treat known names as examples, not stable enum. Verify from current platform docs. As of 2026-04-19: `Dispatch` (scope-isolated), `general-purpose` (broader) — complete list may change.

Select narrowest type covering task's tool scope. Don't default to maximally permissive — defeats scoped dispatch.

Model Override:

`model` param on dispatch specifies model class. D2: default is host's own model.

fast-cheap: shallow/mechanical — pattern matching, formatting, extraction. Lowest cost; shallow result → re-dispatch at higher tier.
standard: moderate reasoning needed. Most common explicit override (typical from deep-tier host).
deep: critical-path or max reasoning needed. Unusual as explicit override — consider inline instead.

| Tier | Trade-off |
| --- | --- |
| fast-cheap | Lowest cost, fastest, risks shallow output |
| standard | Moderate cost, capable for most tasks |
| deep | Highest cost, maximum reasoning, rarely needed |

When NOT to Dispatch:

1. Requires host conversation context + summarizing costs more than inline.
2. Result must drive current-turn response + blocking unacceptable.
3. Holds exclusive resource, no clean handoff (sessions, open conns, continuous holds) → F1.
4. Completable inline in <3 turns — overhead exceeds value.

If inline unaffordable: (a) dispatch with fully hand-fed context prompt, or (b) defer. Don't dispatch incorrectly because inline is expensive.

Well-Formed Dispatch Prompt:

Dispatch prompt missing any component → poor/incoherent output.

Required components:
1. Goal: one sentence, exactly what dispatched agent must accomplish. No ambiguity, no implicit prior context.
2. Hand-fed context: everything dispatched agent needs that it can't inherit:
   - Prior decisions constraining task.
   - Operator preferences relevant to task.
   - File references by absolute path (dispatched agent can't infer from conversation).
   - Project-specific term definitions not in CLAUDE.md.
   - Findings from prior turns the task depends on.
3. Expected output shape: what comes back. Examples: "single verdict: PASS or FAIL", "written file at specified path", "bullet list of findings, one per line". Vague expectations → vague output.
4. Scope + length constraints: what's out of scope, what agent must NOT do, length limits.

Prompt construction checklist:
- [ ] Can stranger with no prior context read this and know exactly what to do?
- [ ] Every needed file referenced by absolute path?
- [ ] Every constraint stated?
- [ ] Output described?

If any answer no → prompt not ready. Fill gaps before dispatching.

Footgun Catalogue:

F1: Host-impersonation on shared exclusive resource
Dispatched agent tries to act as host on resource host already holds (session, auth channel, external service).
Why: host session invalidated or sub-agent errors + burns tokens — two competing owners.
Mitigation: state explicitly in prompt sub-agent mustn't initiate sessions, authenticate, or touch named shared resource. If work needs it, inline.

F2: Dispatch for trivial work
Work small enough to complete inline in few host turns.
Why: dispatch overhead exceeds work value.
Mitigation: apply Q4 — <3 host turns → inline.

F3: Tight-loop micro-dispatches
Host fires many small dispatches sequentially where one batched dispatch suffices.
Why: each dispatch has fixed overhead — sequential micro-dispatches multiply it; token churn dominates.
Mitigation: aggregate into single dispatch returning single structured result. If aggregation impossible, reconsider dispatch — sequential micro-dispatches that can't batch often belong inline.

F4: Hook-denial escape via dispatch
Host dispatches to bypass hook/permission denial that correctly applies to host.
Why: trust boundary violation — dispatched agent may perform actions host was correctly blocked from. Denial was authoritative.
Mitigation: never dispatch as denial workaround. Request permission, change approach, or escalate. Don't route around governance.

F5: Thin-prompt context assumption
Host writes sparse prompt expecting dispatched agent to reconstruct from conversation context that doesn't transfer.
Why: dispatched agent has zero visibility into prior turns. "Continue the analysis we discussed" → agent has no "we", no "analysis", no prior turns.
Mitigation: every prompt must satisfy well-formed requirements. Hand-feed all context agent can't inherit. Write prompt as if agent is stranger reading cold — it is.

ANTI-PATTERN:
Host midway through research, operator narrowed code audit scope, partial findings in prior turns. Host dispatches: "Continue the code audit and produce the final findings report."
What goes wrong: dispatched agent has no context — no operator instructions, no narrowed scope, no partial findings. Result: refuses (no goal), produces unscoped audit, or invents findings.
Correct: (a) inline where host has context, or (b) dispatch with fully hand-fed prompt including operator scope instructions, partial findings, remaining work. (a) usually cheaper.

Error Handling:

No clear decision tree outcome → inline. File draft task or feedback. Don't guess.
Footgun fires → wrong dispatch decision, not transient noise. Revise before retry. Don't retry same dispatch unchanged.
Incoherent/off-topic output → likely F5. Check prompt for missing hand-fed context. Fix prompt, re-dispatch.
Inline unaffordable → (a) dispatch with fully hand-fed context, or (b) defer. Don't dispatch incorrectly because inline is expensive.

Precedence:

Consuming skill (`skill-writing`) defines domain-specific dispatch pattern → governs over this skill's general guidance. This skill: primitives; consumers shape for context.
Empirical claims in this skill conflict with agent expectation about inherited context → empirical governs.
Correctness > throughput. Decision tree says inline but host overloaded → not permission to dispatch incorrectly. Defer or reduce scope.

Related Skills:
`skill-writing` — how to structure a skill that dispatches (routing card, inline vs dispatch decision).
Agent files: `dispatch/agents/` — ready-to-install Dispatch agent definitions for Claude Code CLI and VS Code.
