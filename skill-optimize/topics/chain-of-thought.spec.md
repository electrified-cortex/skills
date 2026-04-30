# CHAIN OF THOUGHT

Assess whether the skill requires multi-step reasoning and whether it
elicits that reasoning explicitly. For tasks requiring inference, comparison,
or weighing competing evidence, instructing the model to reason step by
step before producing a final answer improves accuracy measurably. (Wei
et al., 2022 — Chain-of-Thought Prompting Elicits Reasoning in LLMs;
~5-20% accuracy improvement on reasoning tasks)

**Signal for chain-of-thought:**

- The skill makes a judgment that depends on reasoning across multiple
  pieces of evidence (e.g., "is this finding HIGH or MEDIUM?").
- The skill asks the model to detect something that is ambiguous — a
  conclusion that requires weighing, not lookup.
- The skill produces a recommendation that should be defensible — where
  the reasoning path matters as much as the conclusion.

**Implementation pattern:**

Explicitly instruct: "Reason through the evidence before producing the
finding" or structure the output to include a reasoning block before
the verdict. An `<analysis>` section before a `<verdict>` section is a
well-established pattern. The model produces better verdicts when it
has "committed" reasoning in writing before reaching the conclusion.

**When NOT to use:**

- Fully deterministic tasks (file presence, format validation, line
  counting) gain nothing from reasoning elicitation — they should be
  rules, not judgments.
- Haiku-class skills on mechanical tasks: chain-of-thought adds cost
  without accuracy gain on low-complexity tasks.
- If the skill's output must be machine-parseable and reasoning output
  would contaminate the format, use a scratchpad block with a delimiter
  that downstream parsers skip.

Produce a finding when: the skill makes judgment calls but provides no
reasoning elicitation, and the output quality is likely suffering for
it. Do not produce this finding for deterministic or mechanical skills.