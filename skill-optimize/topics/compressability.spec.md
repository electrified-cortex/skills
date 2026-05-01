# Compressability

## Purpose

Assess whether the skill's instructions can be made tighter and shorter
while preserving accuracy. Compressibility is brevity in service of
reliability — not compression for its own sake, but eliminating every
word that does not directly produce better output.

**The determinism-to-creativity slider:**

Instruction style should match the skill's cognitive demand:

- **Deterministic work** (scans, lookups, format checks, rule application):
  instructions should be short, explicit, and how-focused. Explaining why
  rules exist is waste. Decision trees and tables are preferred. If an
  instruction can be replaced with a lookup table, do it.
- **Probabilistic / judgment work** (assessments, recommendations,
  creative generation): instructions may benefit from why-context. The
  model needs to understand intent to handle cases the instructions
  don't enumerate. Too little context leads to literal rule-following
  that misses the point; too much leads to rambling.
- **Creative work** (document generation, story, open-ended synthesis):
  explaining what the output should feel like may matter more than
  step-by-step instructions. The why can be load-bearing.

The optimization target is: every word earns its presence based on
the actual cognitive demand of the task.

**Partitioning signal:**

If a single skill's instructions cover multiple distinct sub-procedures
that an agent must read through even for single-purpose invocations,
that's a partitioning opportunity. Splitting into sub-skills means each
invocation only loads the relevant piece — smaller context, lower cost,
easier to maintain.

Produce a finding when:

- The instructions contain significant prose that is not operative for
  the skill's cognitive demand (e.g., rationale paragraphs in a
  deterministic scan). Recommendation: compress to decision trees and
  tables.
- The skill bundles multiple independent procedures that could be separate
  sub-skills. Recommendation: partition and route.
- The skill is creative or probabilistic but instructions are bare
  step-by-step without intent context, causing the model to interpret
  literally. Recommendation: add why-context to guide judgment.

Do not produce a finding when instruction length matches the genuine
complexity and cognitive demands of the task.

## Parameters

- <skill-path> — path to the skill directory being analyzed (inherited from optimizer invocation)
- <skill-source-files> — all source files from the skill directory (inherited from Step 1)

## Output

Finding in standard format (### CATEGORY — HIGH | MEDIUM | LOW with **Reasoning:** and **Recommendation:**), or CLEAN if no issues apply.
