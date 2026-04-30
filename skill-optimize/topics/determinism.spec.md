# Determinism

## Purpose


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

**Debuggability benefit:** Deterministic tools are unit-testable, loggable,
and auditable in a way LLM steps are not. A wrong LLM step looks like a
different answer; a wrong deterministic tool produces a traceable, reproducible
error. This compounds over time: a tool that's wrong can be fixed once and
the fix holds; an LLM step that's wrong may behave differently on every run.

**Hybrid pattern:** A useful middle path is LLM for intent detection, tool
for execution. The LLM identifies *what* needs to happen (judgment, ambiguity
resolution), the tool applies it precisely (execution, transformation). This
preserves LLM value where it's needed and removes it where it's not.

Produce a finding only when a realistic, concrete tool replacement exists.
Do not suggest vague "use a script instead" findings without specifying
what the script would do.

Be conservative about tool use as it can create unforeseen complexity that
an LLM can do on its own. A rough signal: if the deterministic step recurs
across many invocations or is meaningfully expensive in latency or tokens,
a tool is worth it. If it's a one-off in a single skill, the LLM handling
it inline is usually fine. Creating a tool for every execution is an anti-pattern.

## Parameters

- <skill-path> — path to the skill directory being analyzed (inherited from optimizer invocation)
- <skill-source-files> — all source files from the skill directory (inherited from Step 1)

## Output

Finding in standard format (### CATEGORY — HIGH | MEDIUM | LOW with **Reasoning:** and **Recommendation:**), or CLEAN if no issues apply.
