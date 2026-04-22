# Dispatch — Supplemental

Background, evidence, and nuance for the `dispatch` skill. Agents read this on demand when the runtime card is insufficient. Not loaded by default.

## Empirical: Context Inheritance

**Conversation context does NOT inherit.**

Empirical (2026-04-19, secret-phrase): host wrote `purple-tractor-mountain-9183` in conversation, then dispatched a sub-agent and asked it to quote the token. Sub-agent reported nothing visible. Confirmed across all subagent types tested.

Implication: any prompt that says "continue what we were doing" or "use the findings from earlier" delivers zero context to the dispatched agent. Hand-feed every relevant prior turn.

**Project context IS inherited.**

Empirical (2026-04-19, enumerate-context): dispatched both a `Dispatch`-type and a `general-purpose`-type sub-agent and asked each to list `CLAUDE.md` and memory files visible in its system prompt. Both reported workspace and project-scoped `CLAUDE.md` files plus the project memory index.

Implication: don't waste tokens repeating project conventions in every prompt. The agent already has them.

Both claims may drift between Claude Code releases. Re-verify if behavior seems off.

## Subagent Type Dimensions

Types differ on three axes:

- **Tool scope** — which tools the agent may call. Some types deliberately restrict (e.g. audit-style types with no file-write).
- **System prompt size** — heavier types cost more tokens per dispatch. Prefer lean for simple tasks.
- **Default model** — some types pin a model. Override if the pin is heavier than the task warrants.

Type names as of 2026-04-19: `Dispatch` (scope-isolated), `general-purpose` (broader). The complete list and properties evolve; treat known names as examples, not a stable enumeration.

## Anti-Pattern Walkthrough

ANTI-PATTERN: Host is midway through a research conversation. Operator has narrowed the scope of a code audit across several turns. Host has accumulated partial findings. Host dispatches: "Continue the code audit and produce the final findings report."

What goes wrong: dispatched agent has no conversation context. It does not know the operator's narrowing instructions, the partial findings, or what "continue" means. It will refuse (no goal), produce an unscoped audit (ignoring narrowing), or invent findings.

Correct decision:

- (a) Inline where the host already has the context. Usually cheaper.
- (b) Dispatch with a fully hand-fed prompt that includes the operator's scope instructions (quoted), the partial findings (written out), and the specific remaining work.

## Error Handling

| Symptom | Likely cause | Action |
| --- | --- | --- |
| Decision tree gives no clear outcome | Ambiguous case | Inline. File draft task or feedback. Don't guess. |
| Footgun fires (e.g. F1 error) | Wrong dispatch decision | Revise decision before retry. Don't retry unchanged. |
| Output incoherent or off-topic | F5 (missing hand-fed context) | Inspect prompt for gaps. Fix, then re-dispatch. |
| Inline cost unaffordable | Context too large or work too slow | (a) dispatch with full hand-fed prompt accepting overhead, or (b) defer. |

## Precedence

- Consuming skill defines a domain-specific dispatch pattern → that pattern governs over this skill's general guidance for that domain. This skill provides primitives; consumers shape them.
- Empirical claims here conflict with an agent's expectation about inherited context → empirical governs.
- Correctness > throughput. Decision tree says inline but host is overloaded → not permission to dispatch incorrectly. Defer or reduce scope.
