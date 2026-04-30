# Context Budget

Assess whether the skill is responsible with the context it consumes and
the context it passes on. Compressibility and Less Is More focus on the
instruction file itself. Context budget addresses the full picture: what
context the skill requires to run, what it passes to sub-agents, and what
it leaves behind in the host's context window.

## Why context budget is distinct from compressibility

Compressibility is about the size of the skill's *instructions*. Context
budget is about the total context load of the skill's *execution*:
instructions + inputs + intermediate state + output. A compact skill that
processes a 50,000-token document and passes all of it to three sub-agents
has a large context budget despite lean instructions.

Context budget matters because context is the primary cost driver in
agentic systems — more than model tier in most cases. A skill that
manages its context budget poorly can exhaust the host agent's window,
force premature compaction, or degrade reasoning quality long before the
skill's work is complete.

## Minimum viable context

What is the smallest context load that allows the skill to produce correct
output? This is a design question, not just an optimization question.

- **Required context** — content without which the skill cannot function.
  If the skill will produce wrong or incomplete output without this
  context, it is required.
- **Optional context** — content that improves quality or precision but
  is not blocking. The skill should degrade gracefully when optional
  context is absent rather than failing or producing errors.
- **Decorative context** — content that was once useful, is no longer
  load-bearing, and should be pruned before invocation.

A skill that loads all available context "in case it's useful" is not
well-designed. Loading context that is never referenced in the output
is a context budget antipattern.

## Context pruning

Before invoking a sub-agent or dispatching a skill, prune context to the
minimum required for that step. Passing full conversation history to a
sub-skill that needs only one file is a budget leak. Pruning patterns:

- Pass only the artifact(s) the sub-skill needs, not the full workspace
  state.
- Summarize long history into a compact handoff rather than passing it
  verbatim.
- Strip intermediate reasoning that is no longer needed once a
  conclusion has been reached.

## Stale context

Context that was accurate at step N may be wrong at step N+3. If a skill
caches a workspace state at the start and operates on it across many steps,
the cached state may diverge from reality (files changed, tasks completed,
external state updated). A skill that assumes its initial context snapshot
remains valid throughout execution has a stale-context risk. Mitigation:
re-read authoritative sources at decision points rather than relying on
held context.

## Context handoff format

When a skill passes work to a sub-agent or downstream skill, the handoff
context should be:
- **Minimal** — only what the downstream skill needs.
- **Explicit** — structured rather than narrative where possible.
- **Fresh** — re-derived from source if the original context may be stale.
- **Scoped** — the sub-agent should not receive the full parent context
  by default; it should receive a bounded task package.

## Examples and context cost

Inline examples are context. Each example costs tokens on every invocation.
If a skill includes three worked examples to anchor behavior, those tokens
are loaded regardless of whether the specific case resembles any of the
examples. For high-invocation skills, consider whether examples belong in
the skill instructions or behind a dispatch (loaded only when the
specific example type is needed).

## Finding criteria

Produce a finding when:
- **HIGH**: The skill passes the full parent context to sub-agents without
  pruning — sub-agents receive context irrelevant to their task.
- **HIGH**: Required vs. optional context is not distinguished — the skill
  fails or degrades ungracefully when any context is absent.
- **MEDIUM**: The skill loads large inputs fully when only a portion is
  needed (e.g., reads an entire file to check one section).
- **MEDIUM**: Examples are inline in a high-invocation skill where they
  consume significant budget on every run.
- **LOW**: Context snapshot is taken once at skill entry and used
  throughout without re-reads at decision points — stale-context risk.
