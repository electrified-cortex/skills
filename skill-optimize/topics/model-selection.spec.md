# Model Selection

Assess the appropriate model tier for this skill's executor and whether
instruction quality is the limiting factor that prevents lower-tier execution.

**Model tier signals:**

- **Haiku-class** (fast, cheap): pure rule-following, pattern matching,
  structured lookups, checklists with explicit decision trees, file presence
  checks, format validation. No judgment required — if the instructions are
  precise enough, any model can follow them.
  Cross-provider equivalents: GPT-5.4 mini (~1/3 the cost of GPT-5.4),
  Gemini Flash (fast, light, similar cost profile). These are interchangeable
  at this tier when the task is fully specified and deterministic.
- **Sonnet-class** (standard): multi-step judgment, semantic evaluation,
  weighing tradeoffs, reasoning across context, creative assessment.
  Most skills that require comparing things or deciding "is this good enough"
  land here.
- **Opus-class** (rare): complex multi-perspective reasoning, deep
  architectural analysis, tasks requiring the model to hold many competing
  constraints simultaneously. Reserve for genuinely hard problems — most
  things that feel like Opus are actually Sonnet with better instructions.
  This is not a license to downgrade everything; some tasks genuinely need
  Opus-class reasoning. Use evidence — test with the cheaper tier first.

**The instruction-quality lever:**

The key insight is that model tier and instruction quality are
substitutes on a cost-reliability curve. A skill that needs Sonnet to
"make sense of" vague instructions can often run on Haiku after the
instructions are made explicit — decision trees instead of prose
conditionals, tables instead of ambiguous descriptions, explicit error
branches instead of implied handling. The extra tokens from better
instructions still cost far less than upgrading the model tier.

Conversely, if a skill requires Opus only because its instructions are
underspecified and the model must fill in gaps with judgment, that is a
finding: the barrier is instruction quality, not genuine cognitive demand.

**Evaluatability sub-check:**

Can this skill's output be measured and compared across runs? If the
output is a structured artifact (a report, a verdict, a hash record),
it can be evaluated empirically — A/B tested across model tiers to
confirm quality holds. If the output is unstructured or highly
context-dependent, model selection must rely on qualitative assessment.

Produce a finding when:

- The current model tier is higher than the cognitive demand justifies
  AND instruction quality is the real barrier (not genuine complexity).
  Recommendation: tighten instructions to enable a cheaper tier.
- The skill is currently underpowered for its task — instructions
  demand judgment but the skill is specified for Haiku.
  Recommendation: upgrade tier or document why current tier is sufficient.
- The skill's output is evaluatable but no eval exists, meaning model
  tier selection is unverified.
  Recommendation: add an eval to confirm the recommended tier holds.

**Cost-tier switch point (evidence):**

Once a task is well-specified and bounded — inputs are explicit,
decisions are defined, edge cases are documented — a faster, cheaper
model performs equivalently to a larger one. The key question is whether
the principal difficulty is *reasoning* (incomplete, ambiguous context
requiring judgment) or *execution* (following a fully specified procedure).
After design decisions are externalized and persisted, execution phases
can almost always drop to a lower tier. If a skill was designed at
Opus-level but its instructions are now fully explicit, it may be
over-tiered. (IACDM, Moreira 2026, Section 8.3, model property 5)

Do not produce a finding when the current model tier is appropriate and
the instructions are as explicit as the task allows.
