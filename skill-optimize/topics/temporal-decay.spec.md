# Temporal Decay

## Purpose


Assess whether the skill contains content that will become stale over
time — version numbers, model names, external endpoints, date-referenced
decisions, or assumptions about the environment that may change.

## Parameters

- <skill-path> — path to the skill directory being analyzed (inherited from optimizer invocation)
- <skill-source-files> — all source files from the skill directory (inherited from Step 1)

## Output

Finding in standard format (### CATEGORY — HIGH | MEDIUM | LOW with **Reasoning:** and **Recommendation:**), or CLEAN if no issues apply.

## Why skills rot

A skill written today encodes the world as it is today. External services
change. Model names are deprecated. File paths move. APIs version. Platform
conventions evolve. A skill that doesn't acknowledge its temporal
dependencies will silently produce wrong results when the world changes
and the skill hasn't.

The dangerous case is not the obvious one (a hardcoded URL that stops
working) but the subtle one: a skill that references "the current best
practice" when best practice has shifted, or assumes a specific model
behavior that has changed in a new model version.

## Types of temporal dependencies

**Version-pinned references** — Explicit version numbers for tools,
models, libraries, or APIs embedded in the skill. Each is an expiry date.
Examples: `claude-sonnet-4-6`, `Node.js 22`, `pnpm 9.x`, a specific API
endpoint path.

**Model behavior assumptions** — Instructions that rely on a specific
model's tendencies ("this model will always output JSON if asked"). Model
behavior changes across versions. Instructions that depend on version-
specific quirks are temporally fragile.

**Environmental assumptions** — Assumptions about directory structure,
tool availability, environment variables, or platform behavior. These
are implicit version dependencies on the environment: if the environment
changes, the skill breaks the same way it would if a pinned dependency
had a breaking update.

**Transitive decay** — A skill may not hardcode a dependency directly
but rely on behavior of something that does. If the skill instructs
"use the JSON output from X" and X changes its JSON schema, the skill
is affected without itself changing. Transitive dependencies are harder
to track but equally fragile. When identifying decay risks, consider
not just what the skill hardcodes but what it depends on.

**"Current" references** — Instructions that reference "the current
directory," "the active task," or "the latest version" without specifying
how to resolve them. Ambiguous at authoring time; wrong at some future
execution.

**Decision rationale tied to a point in time** — "We use approach X
because approach Y doesn't support Z" — if Y later adds Z support, the
rationale is stale and the decision may need revisiting.

## Decay mitigation patterns

**Explicit version locking** — State the version and the review trigger:
"Verified against claude-sonnet-4-6. Re-verify when model version changes."
This is not a fix but a contract: the reader knows what to check.

**Indirection over hardcoding** — Reference a config or environment
variable instead of embedding the version directly. The skill remains
stable; the pointed-to value changes.

**Expiry markers** — A comment or frontmatter field noting when this
skill should be reviewed: `review-by: 2027-01` or `review-when: model
version changes`. Not all skills need this — only those with known
expiry triggers. Note that a review-when marker with no enforcement
mechanism is just a comment: the skill will continue running past its
review date unless the team has a process to surface and act on these
markers.

**Test-based decay detection** — If the skill has an eval or test
harness, model drift and environment changes will surface as test
failures before they surface as production failures. This is the ideal
decay detector. Without a test harness, decay signals include: the skill
producing different results on previously stable inputs; downstream users
reporting unexpected behavior; manual re-runs revealing changed output.
All three are late signals — tests catch decay earliest.

## Review cadence signal

A skill that references external dependencies with no review cadence is
a time bomb. Suggested trigger: any skill that hardcodes a specific model,
service endpoint, or API version should have a `review-when` condition
noted in its frontmatter or spec.

## Finding criteria

Produce a finding when:
- **HIGH**: The skill hardcodes a model name or API endpoint without a
  review-when condition and the dependency is likely to change.
- **HIGH**: The skill relies on a specific model behavior that is known
  to vary across versions, with no fallback.
- **MEDIUM**: Version-pinned references exist but are not flagged for
  review.
- **MEDIUM**: Decision rationale embedded in instructions references
  conditions that may have changed.
- **LOW**: Environmental assumptions are implicit and undocumented.

Do not produce a finding when version references are intentionally locked
(e.g., a skill that specifically targets one model version for a controlled
evaluation) and that locking is documented as intentional.
