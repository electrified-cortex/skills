# OUTPUT FORMAT

## Purpose

Assess whether the skill specifies its output format explicitly enough to
produce consistent, parseable results across invocations. Implicit format
descriptions cause variance — different structure, different keys, different
ordering — that breaks downstream consumers.

**Signal for output format:**

- The skill describes its expected output in prose without a schema,
  template, or concrete example.
- Different invocations of the same skill produce structurally different
  outputs (different keys, different nesting, different markdown structure).
- The skill's output is consumed by another tool, agent, or parser that
  requires predictable structure.
- The output format is described in the spec but not enforced in the
  instructions file — the model must infer structure at runtime.

**Implementation pattern:**

Provide the minimum schema that anchors behavior. Options in ascending
cost:

1. **Labeled fields** — `TOPIC: <slug>\nFINDINGS: <N>` — lowest cost,
   good for structured but non-nested output
2. **Markdown template** — a concrete example block the model fills in
3. **Named sections** — `## Findings\n...\n## Recommendation\n...`
4. **JSON schema** — only when a downstream parser requires it

Choose the simplest form that prevents variance. A two-line labeled-field
format is almost always sufficient for agent-to-agent communication. Full
JSON schema is rarely warranted for skills — prefer it only when the output
is consumed by code, not by another model.

**When schema is not needed:**

- The output is free-form prose consumed by a human or a general-purpose
  model that does not need to parse it programmatically.
- The skill is exploratory / advisory and the consumer explicitly handles
  variable structure.
- A single one-sentence answer is the full output — no structure needed.

**Variance indicators (produce a finding):**

- The instructions say "return your findings" with no format specification
- The output has fields described in prose: "include the topic name, the
  number of findings, and a summary" — without a template
- The spec defines a format but the instructions file does not reproduce it
- Prior invocations have produced different keys or structures

**Produce a finding when:** the skill has structured output consumed by
a downstream agent or tool, and no explicit format is specified in the
instructions file.

**Do not produce a finding when:** the output is explicitly specified in
the instructions with a template or field schema, OR the output is
genuinely unstructured and consumed by a context that handles variance.

## Parameters

- <skill-path> — path to the skill directory being analyzed (inherited from optimizer invocation)
- <skill-source-files> — all source files from the skill directory (inherited from Step 1)

## Output

Finding in standard format (### CATEGORY — HIGH | MEDIUM | LOW with **Reasoning:** and **Recommendation:**), or CLEAN if no issues apply.
