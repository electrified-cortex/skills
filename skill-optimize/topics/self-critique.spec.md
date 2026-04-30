# SELF CRITIQUE

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
self-review, not a second dispatch — it adds a few tokens but improves
accuracy on judgment calls meaningfully.

**When NOT to add:**

- Fully deterministic skills: a self-critique step adds cost with no
  benefit when the output is a lookup, a format check, or a file hash.
- Skills already structured as two-pass (produce then review) — the
  check is already present.

Produce a finding when: the skill makes judgment calls without any
internal verification pass, and errors in the output would have real
downstream consequences.
