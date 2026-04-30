# Composition

Assess how a skill is structured and whether it should be decomposed,
grouped, or re-shaped to reduce what any single invocation must load.
Composition is about the architecture of the skill (or skill suite) as a
whole — not the execution pattern of a single invocation.

**Signal for partitioning:**

- A single skill contains multiple distinct sub-procedures (e.g., create,
  list, update, delete) that are independently invoked. An agent calling
  only one operation must still load the full skill. This is a decomposition
  opportunity: split into targeted sub-skills, group them under a router.
- A skill has grown large enough that its instruction file exceeds ~300
  lines. Agents reading it load significant context for each invocation
  regardless of which path they take.

**Signal for routing structure:**

- A skill family with multiple operations is structured as a single flat
  skill rather than a router + sub-skills. A routing skill (no execution
  logic, just a navigation table) is a valid and often preferable structure:
  it lets the model load only the sub-skill it needs. Routing is not a
  dispatch — it is a navigation hub. Sub-skills under a router can be
  inline, dispatch, or further routers.
- An agent must scan through extensive sub-skill descriptions to find what
  it needs. A routing layer with a concise index reduces this cost.

**Signal for grouping:**

- Related standalone skills that are always used together should be grouped
  under a parent router, improving discoverability. Caution: "always used
  together" is a strong criterion. Forced grouping where the coupling is
  incidental rather than natural creates navigation overhead without benefit
  — the agent must traverse a hierarchy to reach the skill it already knew
  it needed.
- A skill that is always invoked as a chain (A → B → C) may benefit from
  a composite wrapper that orchestrates the chain once rather than requiring
  callers to know the sequence.

Produce a finding when the current structure imposes unnecessary context
cost on routine invocations or hides structure that would make the skill
family more navigable. Do not produce a finding when the skill's current
scope is appropriate for its single, well-defined purpose.

**Context efficiency (evidence):**

Context efficiency can be expressed as E = I₀/C, where I₀ = tokens
directly relevant to the current task and C = total tokens consumed.
In a monolithic skill, E approaches 0 as C grows unboundedly while I₀
(the content relevant to the specific sub-procedure being invoked)
stays constant. In a granularized skill, C is bounded per invocation
and I₀ remains a large fraction of it. Additionally, model retrieval
performance degrades for content positioned in the middle of long inputs
("lost in the middle," Liu et al., 2023) — a skill that forces the
model to scan mid-context to find its relevant section imposes this cost
on every invocation. Observed degradation begins beyond ~50k tokens of
accumulated context. (IACDM, Moreira 2026, Section 6)