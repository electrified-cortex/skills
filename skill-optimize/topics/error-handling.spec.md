# Error Handling

## Purpose


Assess whether the skill explicitly addresses what happens when things go
wrong — missing inputs, malformed data, unexpected states, external tool
failures, or inputs that fall outside the skill's intended scope.

## Parameters

- <skill-path> — path to the skill directory being analyzed (inherited from optimizer invocation)
- <skill-source-files> — all source files from the skill directory (inherited from Step 1)

## Output

Finding in standard format (### CATEGORY — HIGH | MEDIUM | LOW with **Reasoning:** and **Recommendation:**), or CLEAN if no issues apply.

## Why this matters

Skills that are silent on error paths force the model to improvise.
The model will produce a plausible-looking result based on whatever
partial information it has. This is often worse than a clean failure:
a confident wrong answer is harder to catch than an explicit error.

Well-handled errors make skills predictable at the boundary — callers
know what to expect when preconditions aren't met, and they can design
around it.

## Types of errors skills should address

**Missing inputs** — A required file, parameter, or context variable is
absent. The skill should specify: detect it early, emit an explicit error,
stop. Don't attempt to infer a missing required input.

**Malformed inputs** — A file exists but is in an unexpected format; a
parameter has an unexpected type or range; a dependency is present but
in a broken state. The skill should specify the minimum validity checks
to run before proceeding.

**External tool failures** — A tool call returns an error, a file
operation fails, a hash can't be computed. The skill should specify what
to do: retry once? Surface the error and stop? Fall back to a different
approach?

**Scope violations** — The input is technically valid but falls outside
the skill's intended domain (e.g., a skill that optimizes markdown files
receiving a binary). The skill should reject gracefully rather than
attempting to process out-of-scope input.

**Partial success** — Some inputs succeed, others fail. The skill should
specify whether to: emit partial results, fail the entire invocation, or
report a mixed outcome with per-input status.

## Fail-fast principle

Errors should be surfaced at the earliest possible point — before the
model has consumed tokens on the bad input. A skill that checks
preconditions at entry (files exist, inputs are valid, scope is correct)
and emits `ERROR: <reason>` before any analysis is far cheaper than one
that proceeds and fails halfway through.

Pattern: precondition block at entry → explicit `ERROR:` output →
stop. No analysis after the error block.

**Error messages should be actionable.** `ERROR: missing required file`
is less useful than `ERROR: missing required file SKILL.md — expected
at skills/my-skill/SKILL.md. Create it or pass --input-path to specify
a different location.` The second version tells the caller what went
wrong and what to do. Skills that produce diagnostic-only errors are
following the floor; skills that produce recovery-suggesting errors are
exceeding it.

## Silent failures are HIGH severity

A skill with no error handling is not "clean" — it is silently broken
when inputs are invalid. The model fills the gap with improvisation. This
should always be flagged as at minimum MEDIUM severity, and HIGH if the
skill processes user-provided or external inputs where malformed inputs
are probable.

## Error output format

The skill should specify how errors are surfaced. Consistent with R6 in
the main spec: emit `ERROR: <reason>` as the final stdout line. The same
exit protocol applies regardless of whether the skill succeeded or failed.
Callers check the prefix (`PATH:` vs `ERROR:`) to determine outcome.

Skills that mix error messages into the normal output body (or emit them
silently as part of a larger response) make caller error-handling
unreliable.

## Defensive vs. trusting design

A skill that trusts its caller to always provide valid inputs is brittle.
A skill that checks everything is verbose. The balance:

- **Check explicitly** what is hard to recover from (missing required
  files, out-of-scope inputs).
- **Assume** what callers can reasonably be expected to provide (a path
  is a string, a model name is non-empty).
- **Document** the preconditions so callers know what they're responsible
  for.

A skill that documents its preconditions but trusts callers to meet them
is the right design — explicit about the contract, not paranoid at runtime.

## Finding criteria

Produce a finding when:

- **HIGH**: The skill processes external or user-provided inputs with no
  error handling — silent failure on malformed inputs.
- **HIGH**: The skill has no exit path for missing required inputs.
- **MEDIUM**: Error paths exist but are inconsistently handled — some
  tool failures are addressed, others are not.
- **MEDIUM**: Error output format doesn't follow the `ERROR: <reason>`
  convention, making caller error-detection unreliable.
- **LOW**: Preconditions are not documented, forcing callers to discover
  them through failure.

Do not produce a finding when the skill explicitly documents that it
operates in a controlled, trusted context where the caller guarantees
valid inputs — and that guarantee is plausible given the skill's purpose.
