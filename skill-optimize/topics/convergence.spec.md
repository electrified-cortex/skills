# Convergence

How do you know a skill has been optimized enough? How do you drive it
toward that state reliably?

## What convergence means

A skill converges when further optimization passes stop producing new
findings. Not when no findings exist — a skill can be healthy with minor
findings — but when additional passes by the same or higher-tier model
stop adding findings that weren't already surfaced.

Convergence is a gradient that flattens, not a hard stop.

## Multi-pass escalation

Start with a cheap, fast model (Haiku). Take its findings. Run again with
a mid-tier model. If new findings appear, the skill hasn't converged at
Haiku level. Escalate to Sonnet, then Opus if needed. When a higher-tier
pass returns only findings already found by the lower-tier pass, you've
reached the convergence point for this skill.

This matters because:

- Some findings require genuine judgment to detect (Sonnet-class)
- Some are pattern-match detectable (Haiku-class)
- Escalating prematurely is waste; escalating too late misses findings

The convergence signal: two consecutive passes with no net new findings.
The escalation ceiling is Opus — if it finds nothing new after Sonnet,
the skill has converged.

## Adversarial review as a convergence mechanism

An adversarial reviewer challenges the skill's findings, looking for:

- False positives (findings that aren't real issues)
- Missing findings (things the optimizer didn't catch)
- Incorrect recommendations (changes that would break the skill)

The IACDM methodology is built on this loop: initial output → adversarial
challenge → refinement → re-challenge until no new issues emerge. Applied
to skill optimization: after the initial optimization pass, a separate
adversarial agent receives the findings report and attacks it — looking for
errors in the recommendations, missing categories, or findings that would
introduce regressions. The original optimizer then responds to the critique.

The loop terminates when the adversarial agent finds nothing new to
challenge. This is the convergence criterion for the adversarial variant.

Relevant to R12 in the main spec (the multi-pass convergence requirement
that mandates skill-optimize itself be run until findings stabilize): multi-pass
convergence is already required. The adversarial variant is an enhancement
where the "next pass" is an adversarial agent, not just a higher-tier re-run.

## Automated convergence (APO / DSPy direction)

Automated Prompt Optimization (DSPy, OPRO, PromptBreeder) treats skill
instructions as learnable parameters. The optimization loop:

1. Run the skill on a benchmark set of inputs
2. Score outputs against a rubric
3. Perturb the instructions (or use a meta-optimizer to rewrite them)
4. Re-run, re-score
5. Accept the perturbation if it improves the score
6. Repeat until the score plateaus

This is a higher-order form of convergence: the loop itself is automated
rather than human- or model-directed. For this to work, the skill must
produce evaluatable output (see determinism.spec.md and model-selection.spec.md
on evaluatability). If the output is unstructured or judgment-heavy, the
scoring step is hard to automate.

This connects to the skill-optimize dogfood vision: skill-optimize itself
should eventually be runnable in a feedback loop against a known set of
skills with known findings, to verify its own recommendations are stable.

## Convergence failure modes

- **Oscillation**: two recommendations that cancel each other out across
  passes. Fix: add a finding deduplication step; flag when a recommendation
  would revert a previous change.
- **Premature convergence**: the optimizer stopped escalating too early.
  The skill looks converged at Haiku level but Sonnet would find more.
  Fix: always run one tier above the expected convergence point.
- **False convergence**: no new findings, but the skill is simply too vague
  for findings to be producible. Fix: check that DETERMINISM and WORDING
  produce findings before declaring convergence.
- **Budget exhaustion**: the loop hits token or cost limits before reaching
  convergence. This is not failure — accept the findings produced so far,
  note that convergence was not reached, and treat it as a partial run.
  Do not discard partial findings.

## Calibration via known-good references

A convergence check can be gated against a known-good skill (a "gold
standard" reference). If the optimizer is given a skill that is known to
have zero findings, it should produce zero findings. If it does not, the
optimizer is producing false positives. Likewise for a skill known to have
specific findings.

This is a form of evaluation: treat the optimizer as a classifier and
assess its precision/recall against a labeled benchmark.

## Human-in-the-loop convergence checkpoints

For high-stakes or foundational skills, convergence should include a
human review checkpoint after automated passes. The human review focuses
on: are the recommendations safe? Are any high-severity findings
actually load-bearing behavior that should not change?

Automated convergence removes false positives at scale; human review
ensures no recommendation introduces a regression that the automated loop
could not detect.
