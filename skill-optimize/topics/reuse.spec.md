# REUSE

## Purpose


Assess whether the skill contains procedure blocks that could be extracted,
shared, or replaced with existing reusable components. A good skill library,
like a good code library, finds ways to reuse functions — not rewrite them.

**The skill-as-program lens:**

Many skills are programs. When read as code, it becomes apparent whether
their steps are novel to this skill's purpose or generic enough to belong
in a shared primitive. Dispatch itself is the canonical example: a spawning
procedure once duplicated across every skill was extracted into one reusable
`dispatch` skill. That extraction saved tokens, removed drift, and turned a
pattern into a force multiplier.

**Signal for sub-skill extraction:**

- A multi-step block inside this skill also appears (or is likely to appear)
  in other skills. Repeated procedure = extraction candidate. Rough signal:
  if the same block appears in 2+ existing skills or is expected to appear
  in skills on the immediate roadmap, extraction is likely worth it.
- The block is self-contained: it has a clear input, a clear output, and no
  dependency on the surrounding skill's state. It could be called independently.
- The block is long enough that duplicating it adds meaningful overhead to
  every consumer skill. A 2-line conditional is not worth extracting; the
  sub-skill overhead would exceed any token savings.

**Versioning friction:** Extracted sub-skills become shared dependencies.
  A breaking change to a sub-skill requires auditing all dependent skills.
  Only extract when the sub-skill is stable or when the value of sharing
  outweighs the coordination cost of versioning it.

**Signal for tool conversion:**

- A skill step is fully deterministic — given the same input, it always
  produces the same output, with no judgment required.
- The step is scriptable (PowerShell, Bash, or a structured API call).
- Running it as a tool (not an LLM call) would be faster, cheaper, and more
  reliable than asking the model to execute it step by step.
- Examples: file hashing, manifest building, line counting, JSON validation.

**Signal for dispatch adoption:**

- The skill spawns a sub-agent but does not use the `dispatch` skill. This
  is a duplication of spawning mechanics that dispatch already owns. Recommend
  adopting dispatch as the spawning primitive.

Produce a finding when a reuse or extraction opportunity is clear and the
benefit outweighs the overhead of introducing a new dependency. Do not
produce speculative findings — only when the repeated or extractable block
is evident in the current skill's instructions.

**Dependency minimization:** Alongside reuse, assess whether the skill's
existing dependencies are necessary. A skill that depends on five sub-skills
where two would do the job has unnecessary coupling. Circular dependencies
(Skill A depends on B, which depends on A) are always a finding. A dependency
that can be eliminated without replacing it — because the dependent step
can be inlined cheaply — is a LESS IS MORE candidate, not just a reuse one.

## Parameters

- <skill-path> — path to the skill directory being analyzed (inherited from optimizer invocation)
- <skill-source-files> — all source files from the skill directory (inherited from Step 1)

## Output

Finding in standard format (### CATEGORY — HIGH | MEDIUM | LOW with **Reasoning:** and **Recommendation:**), or CLEAN if no issues apply.
