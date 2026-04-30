# Verification Strategy

## Purpose


Assess whether the skill defines *what counts as correct* — not just
whether the model reviewed its own output (self-critique.spec.md), but
the actual evidentiary standard the skill applies when producing and
validating its conclusions.

## Parameters

- <skill-path> — path to the skill directory being analyzed (inherited from optimizer invocation)
- <skill-source-files> — all source files from the skill directory (inherited from Step 1)

## Output

Finding in standard format (### CATEGORY — HIGH | MEDIUM | LOW with **Reasoning:** and **Recommendation:**), or CLEAN if no issues apply.

## Self-critique vs. verification strategy

Self-critique is a within-turn review: the model produces an output and
then asks itself whether it holds. It catches careless mistakes but
shares the same blind spots as the original generation.

Verification strategy is the design decision about *what* the skill
treats as ground truth, *how* it checks claims against that ground
truth, and *what level of confidence* it attaches to outputs at different
evidence levels. It is a property of the skill's design, not an added
review step.

A skill with strong verification strategy knows: what it can state with
authority, what it can state with confidence, and what it should flag as
unverified.

## What must be verified vs. what can be assumed

Not every claim in a skill's output can or should be verified. The skill
should distinguish:

- **Must verify** — claims that carry risk if wrong; factual assertions
  about specific artifacts; verdicts that trigger downstream action.
- **Can assume** — well-known conventions, stable platform behavior,
  facts the skill's inputs confirm directly.
- **Explicitly unverified** — claims based on inference or pattern-
  matching that the skill cannot confirm from available sources. These
  should be labeled.

## Primary source preference

For skills that make claims about files, code, configurations, or data,
the verification standard should specify: does the skill read the actual
source, or does it rely on summaries, indices, or cached state?

Primary source = the actual file, the actual diff, the actual API
response. Secondary source = a summary, an index entry, a previously
cached result.

For findings that will be acted upon, primary source is strongly
preferred. A skill that issues a finding based on a filename pattern
without reading the file is applying a weaker evidentiary standard than
one that reads the file and confirms the pattern.

## Cross-check requirements

For high-stakes conclusions, the skill should specify whether independent
corroboration is required:

- **Single-source verdict** — one piece of evidence is sufficient to
  conclude.
- **Corroborated verdict** — two independent sources must agree.
- **Adversarial cross-check** — an independent pass must fail to
  contradict the finding before it is finalized (see convergence.spec.md
  on adversarial review).

## Testable acceptance criteria

The skill's output should have acceptance criteria that can be checked
without re-running the skill. "The output is a valid findings report"
is not testable. "The output is a markdown document containing a

## Findings section with at least one entry per category, each entry

containing a severity label (HIGH/MEDIUM/LOW) and a sentence of
rationale" is testable.

Acceptance criteria serve two purposes: they anchor the model's behavior
during generation, and they enable external validation of the output
without relying on the model's self-assessment.

## Source-of-truth hierarchy

When multiple sources of information are available (inline skill
instructions, external spec file, operator message, task document),
the skill should declare which source wins when they conflict. Without
this, the model resolves conflicts with its own priority logic, which
may not match the skill designer's intent.

## Finding criteria

Produce a finding when:

- **HIGH**: The skill produces verdicts without specifying what evidence
  standard those verdicts are based on — the evidentiary basis is
  implicit or absent.
- **HIGH**: Claims about specific artifacts are made without confirming
  from the primary source (the actual file/diff/response).
- **MEDIUM**: The skill has no declared source-of-truth hierarchy —
  conflicts between instruction sources are resolved by model
  improvisation.
- **MEDIUM**: Output has no testable acceptance criteria — correctness
  can only be evaluated by re-running the skill.
- **LOW**: The skill issues corroborated-verdict-level conclusions
  (security findings, compliance verdicts) on single-source evidence.
