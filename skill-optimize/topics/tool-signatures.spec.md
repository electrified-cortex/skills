# TOOL SIGNATURES

Assess the quality of tool, function, and sub-skill names and descriptions
used or referenced by the skill. For agents selecting tools at runtime,
description clarity is a distinct lever from instruction clarity —
poor tool descriptions cause "wrong tool" errors that better wording
cannot fix. (Patil et al., 2024 — empirical tool-calling research)

**Signal for improvement:**

- Tool or sub-skill names are generic or ambiguous (e.g., "process",
  "handle", "run") rather than semantically precise about what they do.
- Parameter documentation is absent or terse — the model cannot infer
  what value to pass without guessing.
- Multiple tools have similar descriptions; the model cannot distinguish
  when to use each one.
- A skill dispatches to sub-skills but the sub-skill SKILL.md descriptions
  are vague — a routing agent scanning the index cannot determine which
  sub-skill applies.

Produce a finding when description quality is likely causing or will
cause selection errors. Do not produce a finding when names and
descriptions are precise and semantically distinct.
