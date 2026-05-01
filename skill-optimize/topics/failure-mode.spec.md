# Failure Mode Design

## Purpose

Assess whether the skill explicitly catalogs the ways it can fail to
produce useful output — not just runtime errors (which are covered by
error-handling.spec.md), but the semantic failure modes where the skill
executes without error and produces plausible-looking output that is
wrong, incomplete, or not useful.

## Parameters

- <skill-path> — path to the skill directory being analyzed (inherited from optimizer invocation)
- <skill-source-files> — all source files from the skill directory (inherited from Step 1)

## Output

Finding in standard format (### CATEGORY — HIGH | MEDIUM | LOW with **Reasoning:** and **Recommendation:**), or CLEAN if no issues apply.

## Error handling vs. failure mode design

Error handling addresses *detectable* failures: missing file, tool call
error, malformed input. The skill can catch these and surface them.

Failure mode design addresses *undetectable* failures from the skill's
perspective: the skill produces output, but that output is wrong because
the preconditions for correctness weren't met, the inputs were ambiguous,
the model's confidence was too low, or the skill was invoked outside its
intended domain.

A skill with no failure mode design produces confident wrong answers.
A skill with explicit failure mode design produces cautious, labeled
outputs when conditions for certainty aren't met.

## Core failure modes to document

**Insufficient input** — The input is technically present but doesn't
contain enough signal for the skill to produce a reliable result. The
skill should specify: what is the minimum input quality required, and
what should be produced when input quality is below that threshold?

**Conflicting instructions** — The skill receives instructions from
multiple sources (system prompt, task prompt, user message) that
contradict each other. Without a priority hierarchy, the model
arbitrarily resolves the conflict. The skill should define: which
instruction source wins, and whether conflicts should be surfaced
or silently resolved.

**Missing tool access** — The skill assumes a tool is available (file
system, git, external API) but it is not. Unlike a hard error (tool
call fails), this is a silent failure when the skill simply skips
the tool-dependent step without noting the omission.

**Low-confidence judgment** — The skill must make a judgment call but
the evidence is weak or ambiguous. Instead of surfacing this uncertainty,
the model produces a confident-sounding output. The skill should specify
the confidence threshold below which the output should be labeled as
uncertain or should request additional input.

**Partial completion** — The skill processes N of M inputs successfully
and silently drops the rest. The caller receives a result but doesn't
know it's incomplete. Partial completion should be declared, not hidden.

**Stale assumptions** — The skill was written against a specific context
(model behavior, API contract, file structure) that has since changed.
The skill runs without error but its decisions are wrong because its
assumptions no longer hold. This connects to temporal-decay.spec.md.

**Out-of-domain invocation** — The skill is called on inputs outside its
intended domain. Error handling covers the detectable version (wrong file
type). Failure mode design covers the undetectable version (the inputs
are syntactically valid but semantically wrong for this skill).

## Confidence labeling

Skills that make judgment calls should label their confidence on outputs
that fall below the reliability threshold:

- `HIGH confidence` — evidence is clear and unambiguous
- `MEDIUM confidence` — evidence supports the conclusion but has gaps
- `LOW confidence` — evidence is thin; conclusion is a best guess

A skill that applies a consistent confidence label gives downstream
agents and operators the signal they need to decide whether to trust the
output or seek verification.

## Must-stop vs. best-effort modes

Some failure modes should be hard stops — the skill should not produce
output and should surface an explicit failure: "I cannot complete this
reliably given the available inputs." Others are acceptable degradation
points — produce output with a caveat.

The skill should specify for each significant failure mode: stop, degrade
with label, or attempt with warning.

## Finding criteria

Produce a finding when:
- **HIGH**: The skill makes judgment calls with no confidence labeling —
  low-confidence outputs are indistinguishable from high-confidence ones.
- **HIGH**: Partial completion is not declared — the caller cannot tell
  whether the result covers all inputs or a subset.
- **MEDIUM**: The skill documents error handling but not semantic failure
  modes — it handles detectable failures but not wrong-but-plausible ones.
- **MEDIUM**: The skill has no defined behavior for conflicting instruction
  sources — priority resolution is left to model improvisation.
- **LOW**: Must-stop vs. best-effort is not specified for the skill's
  known failure modes.
