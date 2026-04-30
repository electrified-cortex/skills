# Dispatch

## Purpose


Assess whether the skill's execution pattern (dispatch vs inline) is the
right choice for its purpose. Full rationale for the dispatch primitive is
in `dispatch/dispatch-pattern.md`; the summary below covers the key signals.

**Signal for dispatch (scope isolation needed):**

- The skill performs a long, multi-step procedure that would pollute the
  host agent's context with intermediate state.
- The skill's work is context-independent — it needs no shared state with
  the calling agent.
- The skill's instructions contain a complete executor procedure that would
  consume significant tokens in the host agent.
- The procedure involves multiple LLM calls, file reads, or build steps
  whose intermediate state should not persist in the host's context window.

Scope isolation via dispatch has compounding long-term value: every token
not loaded into the host context is permanently avoided — and the host's
context stays cleaner for longer, reducing context pollution that would
otherwise force earlier compaction or degraded reasoning at context limits.

**Signal for inline (host agent context needed):**

- The skill uses or modifies shared state in the calling agent's session
  (e.g., operator communication context, active task tracking, live memory).
- The skill is a brief procedure (a few steps) where dispatch overhead
  would dominate the work and extra tool calls would just mean more cost.
- The skill writes a file-based artifact that the host agent immediately
  references in the same turn.
- The skill is meant to teach the host agent a behavior pattern — the
  instructions are the behavior, not a program to delegate.

Produce a finding only when the current pattern is a poor fit. A skill
using dispatch correctly (or inline correctly) requires no finding.

**Tool call vs. text substitution (call-cost efficiency):**

Within a skill's instructions, individual tool calls carry overhead:
latency (a round-trip to the tool executor), cost (tokens consumed by
the function call schema, the response, and any parse step), and
fragility (tool errors, schema drift, availability). If the same result
can be achieved with 2-3 lines of inline instruction that the model
can follow without invoking a tool, the inline form is usually cheaper,
faster, and more reliable.

Signal for replacement:

- The tool call retrieves or computes something the model can derive
  directly from context already present in the input.
- The tool call does a single lookup that could be expressed as a
  conditional rule ("if the file ends in .spec.md, treat it as...").
- The tool call is called once per run and returns a value that could
  be hard-coded or parameterized in the instructions.

Signal to keep the tool call:

- The tool interacts with external state (filesystem, network, clock)
  that the model cannot derive from context.
- The tool call is reused across many skills — its overhead is
  amortized and centralizing logic in the tool prevents drift.
- The text equivalent would require enough prose that the model might
  misapply it — the tool call enforces the behavior more reliably.

Produce a finding when a tool call is present whose behavior could be
replaced by a small inline instruction with no loss of reliability or
correctness, and where the replacement would reduce latency or cost.

## Parameters

- <skill-path> — path to the skill directory being analyzed (inherited from optimizer invocation)
- <skill-source-files> — all source files from the skill directory (inherited from Step 1)

## Output

Finding in standard format (### CATEGORY — HIGH | MEDIUM | LOW with **Reasoning:** and **Recommendation:**), or CLEAN if no issues apply.
