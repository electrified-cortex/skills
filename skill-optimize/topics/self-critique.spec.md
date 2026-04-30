# SELF CRITIQUE

## Purpose


Assess whether the skill includes a verification or self-critique step
for its own outputs. For judgment-heavy skills, instructing the model to
review its own finding before finalizing significantly reduces errors.
(Shinn et al. 2023 — Reflexion; Madaan et al. 2023 — Self-Refine)

**Signal for self-critique:**

- The skill produces a verdict, classification, or judgment that carries
  risk if wrong (e.g., a security finding, a severity rating, a
  recommendation to make a change).
- The skill makes a comparison or weighs evidence across multiple sources.
- The skill is invoked in a pipeline where a downstream agent trusts its
  output without independent verification.

**Implementation pattern:**

After producing an initial finding, instruct the model to verify it:
"Review: does this finding hold under the available evidence? Is the
severity calibrated correctly? If not, revise." This is a within-turn
self-review, not a second dispatch (no extra LLM call, no context isolation
— the review happens in the same turn). For short findings, this adds a
small token overhead. For complex findings (detailed security reviews,
multi-criteria assessments), the review pass can be significant — weigh
the cost against the error rate of the skill.

**False confidence:** Self-critique does not catch systematic errors. If
the model has a consistent bias or blind spot, a within-turn review will
confirm the original error — both the generation and the critique share
the same context and the same model. Self-critique catches careless
mistakes, not structural flaws. For structural review, use a separate
adversarial pass (see convergence.spec.md).

**Asymmetric evidence:** Ensure the critique step has access to the same
evidence as the generation step. If the model is asked to review a finding
but not shown the source data that produced it, the critique is hollow —
it can only check internal consistency, not factual grounding.

**When NOT to add:**

- Fully deterministic skills: a self-critique step adds cost with no
  benefit when the output is a lookup, a format check, or a file hash.
- Skills already structured as two-pass (produce then review) — the
  check is already present.

Produce a finding when: the skill makes judgment calls without any
internal verification pass, and errors in the output would have real
downstream consequences.

## Parameters

- <skill-path> — path to the skill directory being analyzed (inherited from optimizer invocation)
- <skill-source-files> — all source files from the skill directory (inherited from Step 1)

## Output

Finding in standard format (### CATEGORY — HIGH | MEDIUM | LOW with **Reasoning:** and **Recommendation:**), or CLEAN if no issues apply.
