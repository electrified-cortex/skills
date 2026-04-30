# CHAIN OF THOUGHT

Assess whether the skill requires explicit reasoning scaffolding for tasks
that must synthesize ambiguous or competing evidence before reaching a
verdict. This topic is **not** about output structure or exposing reasoning
in the final output — it is about whether the model needs a reasoning step
to reach correct conclusions.

**Signal for chain-of-thought:**

- The skill makes a judgment that depends on reasoning across multiple
  pieces of evidence (e.g., "is this finding HIGH or MEDIUM?").
- The skill asks the model to detect something that is ambiguous — a
  conclusion that requires weighing, not lookup.
- The skill produces a recommendation that should be defensible — where
  the reasoning path changes the conclusion.

**Implementation pattern:**

Instruct the model to reason before concluding: "Reason through the
evidence before producing the finding." Specify the minimum viable form:

- **Inline justification** (1 sentence): sufficient for most judgment
  tasks — e.g., `"MEDIUM — downstream impact is isolated to one caller"`
- **Structured reasoning block**: only when multiple competing signals
  must be weighed explicitly and an inline sentence is insufficient
- **Exposed scratchpad**: rarely needed; adds tokens to every invocation;
  only justified if the caller must inspect the reasoning (e.g., for
  audit or self-critique inputs)

Prefer the shortest form that produces correct verdicts. Do not default
to `<analysis>` + `<verdict>` blocks as a general pattern — reserve
structured blocks for skills where unscaffolded judgment demonstrably
produces wrong outputs.

**When NOT to use:**

- Fully deterministic tasks (file presence, format validation, line
  counting) gain nothing from reasoning elicitation — they should be
  rules, not judgments.
- Haiku-class skills on mechanical tasks: chain-of-thought adds cost
  without accuracy gain on low-complexity tasks.
- When the skill's output must be machine-parseable and any reasoning
  output would contaminate the format, omit reasoning from the output
  entirely — do not add a scratchpad unless the caller needs it.
- When the skill already has a structured review loop (self-critique,
  convergence): reasoning elicitation is redundant.

Produce a finding when: the skill makes judgment calls but provides no
reasoning elicitation, and the output quality is likely suffering for it.
Do not produce this finding for deterministic, mechanical, or already-
structured skills.
