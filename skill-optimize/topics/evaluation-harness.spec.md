# Evaluation Harness

## Purpose

Assess whether the skill has a mechanism to verify that a proposed
optimization actually improves it — and that improvements to one aspect
don't introduce regressions in another. Without an evaluation harness,
skill optimization is subjective: "this feels better" rather than "this
is measurably better."

## Parameters

- <skill-path> — path to the skill directory being analyzed (inherited from optimizer invocation)
- <skill-source-files> — all source files from the skill directory (inherited from Step 1)

## Output

Finding in standard format (### CATEGORY — HIGH | MEDIUM | LOW with **Reasoning:** and **Recommendation:**), or CLEAN if no issues apply.

## Why this matters for an optimize-skill skill

Skill-optimize is self-referential: it optimizes skills, and skills
should be optimizable. Without an evaluation harness, the optimization
loop has no exit condition based on objective improvement — it converges
on aesthetics rather than performance.

The evaluation harness is also the mechanism that makes the dogfood
vision possible: skill-optimize itself should be runnable in a feedback
loop against a known set of skills with known findings.

## Benchmark inputs

A representative set of inputs that covers the skill's common cases and
at least one edge case. The benchmark is:

- **Small enough** to run quickly (not the full production input set)
- **Representative** of the real input distribution — not cherry-picked
  success cases
- **Stable** — it should not change between optimization runs unless the
  skill's domain changes

For skill-optimize: a small set of SKILL.md files with known optimization
profiles (one overly complex skill, one already optimized skill, one with
a model-tier mismatch, one with missing error handling).

## Regression cases

Inputs where the skill's correct behavior is already known and must be
preserved. Optimization should not break what was already working.

Regression cases are distinct from benchmark inputs: they represent
the floor (must not get worse), while benchmarks measure the ceiling
(should get better).

## Golden outputs

Reference outputs that represent correct behavior. Comparison format:
- For structured output: field-level diff (did severity change? did
  a finding disappear that should still be present?)
- For prose output: rubric-based scoring (does the output hit all
  required sections? Is the reasoning grounded in the input?)
- For verdicts: classification accuracy (does the verdict match the
  expected verdict for this input?)

Golden outputs should be stored alongside the skill, versioned with it,
and reviewed when the skill's domain changes.

## Before/after comparison

The core evaluation loop: run the skill on the benchmark before the
proposed optimization, run it after, compare. The comparison should be:

- **Token cost** — did the optimized skill cost fewer tokens to run?
- **Output quality** — did the output score higher on the rubric?
- **Variance** — did the optimized skill produce more consistent output
  across runs?
- **Regression** — did any regression cases fail that previously passed?

An optimization that improves quality but increases token cost by 40%
is a tradeoff, not an unambiguous win. An optimization that reduces
tokens but introduces a regression is a net negative. The evaluation
harness makes these tradeoffs visible.

## Adversarial inputs

Inputs designed to expose edge cases, failure modes, and boundary
conditions. For skill-optimize: a SKILL.md file that is deliberately
ambiguous, a skill that mixes concerns, a skill that is optimal as-is
(to test for false positives).

Adversarial inputs are the complement to regression cases: regression
cases confirm the floor; adversarial inputs probe the ceiling.

## Finding criteria

Produce a finding when:
- **HIGH**: The skill has never been tested against a representative
  input set — optimization decisions are based solely on inspection,
  not measurement.
- **HIGH**: Optimization has been applied but there is no before/after
  comparison — it is unknown whether the optimization improved anything.
- **MEDIUM**: The skill has benchmark inputs but no regression cases —
  the floor is undefined.
- **MEDIUM**: Golden outputs exist but are stale — the skill's domain
  has changed and the golden outputs haven't been updated.
- **LOW**: Token cost and output quality are not tracked across
  optimization runs — the tradeoff between them is unknown.
