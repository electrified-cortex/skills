# Determinism

Assess whether any LLM-dependent step in the skill could be replaced with
a deterministic tool, script, or structured algorithm.

**Signal for deterministic replacement:**

- The step is pattern-matching on well-defined formats (frontmatter,
  regex, YAML structure) where an LLM is used but a parser would suffice.
- The step counts, lists, or enumerates artifacts — pure file-system or
  git operations.
- The step applies a fixed transformation (normalize whitespace, sort
  entries, strip comments) where the rule is fully specified.
- The step checks for the presence or absence of specific strings or
  structures — grep or AST traversal would be cheaper and more reliable.

**Weak or no signal:**

- The step requires semantic understanding that cannot be expressed as
  a fixed rule (e.g., "does this prose convey intent clearly?").
- The step must handle unbounded variation in inputs that would require
  an exhaustive rule set to cover.
- The deterministic alternative would be as expensive or more complex
  than the LLM call.

Produce a finding only when a realistic, concrete tool replacement exists.
Do not suggest vague "use a script instead" findings without specifying
what the script would do.

Be conservative about tool use as it can create unforeseen complexity that
an LLM can do on its own. Creating one or two useful tools to help with
deterministic processes is probably a win. Creating a tool for every
execution is probably an anti-pattern.
