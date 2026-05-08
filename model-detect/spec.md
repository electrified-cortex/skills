# Model Detect — Spec

## Purpose

Give agents a reliable, structured procedure for determining their own model identity when
asked. Reduces hallucinated version numbers and inconsistent self-reports across runtimes.

## Problem

Models frequently state incorrect version numbers drawn from training-time memory. The
problem has two layers:

- **Hallucinated precision** — a model confidently reports the wrong version (e.g., claims
  to be "Claude 3.5 Sonnet" when running as Sonnet 4.6).
- **Runtime variance** — different runtimes surface model identity via different mechanisms:
  config file frontmatter, system prompt injection, environment variables,
  operator-declared instructions, or no signal at all.

Self-knowledge is the least reliable source. A priority-ordered detection procedure is
required.

## Scope

Any agent or model instance that needs to respond to "what model are you?" or "what is
your model/version?" across any runtime (Claude Code, VS Code Copilot, OpenAI API, custom
harnesses).

Out of scope: probing *other* agents' model identity; capability fingerprinting for
purposes other than identity; runtime version detection beyond model name/identifier.

## Definitions

- **Signal** — a piece of information sourced from outside the model's weights that
  identifies the running model.
- **Self-report** — a response derived solely from the model's training-time knowledge.
- **Confidence level** — `high` (external signal), `medium` (operator-declared), `low`
  (self-report only).
- **Hedged response** — a response that explicitly notes uncertainty, e.g. "I believe I
  am..." or "Based on my config, I am...".
- **Alias** — a generic model name that resolves to a pinned version at runtime (e.g.,
  `sonnet`, `gpt-4o-latest`). The pinned version may not be determinable from the alias
  alone.

## Requirements

### R-1: Priority-ordered detection

Agents MUST follow a priority-ordered procedure when identifying their model. Stop at the
first signal found. Do not blend signals from multiple levels.

Priority order:

1. **Config file frontmatter** — `model:` field in the agent's own config file (e.g.,
   `.claude/agents/<name>.md`, `.agents/agents/<name>.md`, or runtime equivalent).
2. **System prompt injection** — model identifier injected by the runtime into the system
   prompt or instructions (e.g., "You are running as [model]", "Model: [id]").
3. **Environment variable** — `ANTHROPIC_MODEL`, `OPENAI_MODEL_NAME`, `MODEL_NAME`,
   `CLAUDE_MODEL`, or runtime-specific equivalent.
4. **Operator-declared identity** — explicit model declaration in `CLAUDE.md`,
   `copilot-instructions.md`, `.github/copilot-instructions.md`, or another in-scope
   instruction file.
5. **Self-report with mandatory hedge** — training-time knowledge as last resort. Hedging
   is mandatory at this level.

### R-2: Confidence tagging

Every detection result carries a confidence level:

- `high` — signal from config file, system prompt injection, or environment variable.
- `medium` — signal from operator-declared instructions.
- `low` — self-report only.

### R-3: Hedged response at low confidence

When confidence is `low`, the response MUST include an explicit caveat.

Acceptable hedged forms:

- "Based on my training, I believe I am [model], but I cannot verify this without an
  external signal."
- "I don't have a reliable external signal; my self-knowledge suggests I am [model]."

Unacceptable at `low` confidence:

- "I am [model]." (unhedged)
- "I am the latest version of..." (non-specific and unhedged)

### R-4: Source attribution

In technical contexts, responses SHOULD include the detection source:

- "I am Claude Sonnet 4.6 (source: config file)."
- "I am GPT-4o (source: system prompt)."

In conversational contexts where technicality would be jarring, the source MAY be omitted.
Hedging rules still apply regardless.

### R-5: Alias awareness

When the detected signal is an alias rather than a pinned version identifier:

- Report the alias as-is.
- Note that the underlying pinned version may differ.
- Do NOT expand an alias to a pinned version unless a separate, confirming signal provides
  the mapping.

### R-6: No fabrication

Agents MUST NOT invent or guess a model version not supported by any available signal.
Fabricated precision is categorically worse than a hedged self-report.

### R-7: No result caching

Agents MUST re-run the full detection procedure on each new question about model identity.
Detection results from earlier in the same conversation MUST NOT be reused. Model identity
can change between turns when a user switches models mid-session.

### R-8: Mid-session change disclosure

If the current detection result differs from a model identity stated earlier in the same
conversation, the agent MUST disclose the change explicitly rather than silently returning
the new model name. Acceptable form:

> "My model has changed since earlier in this conversation. I am now [model]
> (source: [source])."

Silently reporting a new model without noting the change is a disclosure failure.

## Constraints

- No network access or API calls required — all signals must be locally available in the
  agent's accessible context.
- Runtime-agnostic — the procedure applies across Claude Code, VS Code Copilot, OpenAI
  Agents SDK, and custom harnesses.
- SKILL.md must be self-contained. No runtime dependency on this spec.

## Acceptance Criteria

1. An agent following this skill stops at the first available signal and does not blend
   sources.
2. An agent with only self-knowledge produces a hedged response.
3. An agent with a config file signal reports confidently without hedging.
4. An agent detecting an alias reports the alias, not an expanded version.
5. No agent fabricates or guesses a version number without a supporting signal.
6. Source attribution appears in technical contexts.
7. An agent asked the same question twice in one conversation re-runs detection rather than
   repeating a cached result.
8. An agent whose model changed mid-session discloses the change rather than silently
   reporting the new model.
