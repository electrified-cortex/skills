# EXAMPLES

## Purpose

Assess whether the skill could benefit from including one or more
concrete input/output examples. Few-shot examples are one of the most
reliable levers for improving model behavior on format-sensitive or
judgment-sensitive tasks. (Brown et al., 2020 — GPT-3 in-context learning)

**When examples improve accuracy:**

- The skill requires a non-obvious output format that is hard to describe
  precisely in prose. A single example makes the format unambiguous.
- The skill makes a judgment call (e.g., HIGH / MEDIUM / LOW severity)
  where the boundary between categories is not self-evident. An example
  showing a HIGH finding and a MEDIUM finding calibrates the model's
  judgment better than a definition.
- The skill produces structured content (a findings table, a scored
  report, a checklist) that has subtle formatting requirements. An
  example is more instructive than a template description.

**Cost of examples:**

Examples consume context tokens. They should be short and targeted — the
minimum needed to anchor behavior. Two well-chosen examples usually
outperform one long one. Examples embedded mid-instruction also carry
the "lost in the middle" attention risk — place them near the beginning
(to anchor early) or immediately before the task instruction that uses
them.

**When NOT to use examples:**

- The task is fully deterministic and the output format is already
  unambiguous without examples.
- Adding an example would commit the model to a style that is too narrow
  for the range of valid inputs.

Produce a finding when: the skill's output format or judgment calibration
would be materially improved by 1-3 targeted examples and none are present.
Do not produce speculative findings — only when the gap is evident from
the current instructions.

## Parameters

- <skill-path> — path to the skill directory being analyzed (inherited from optimizer invocation)
- <skill-source-files> — all source files from the skill directory (inherited from Step 1)

## Output

Finding in standard format (### CATEGORY — HIGH | MEDIUM | LOW with **Reasoning:** and **Recommendation:**), or CLEAN if no issues apply.
