# MODEL-SELECTION — 2026-05-08

## Findings

### ARBITRATOR TIER AMBIGUITY — MEDIUM

**Severity:** MEDIUM
**Finding:** Step 6 said "sonnet-class by default," implying overridability, but no override input, precedence rule, or caller mechanism existed anywhere in the skill. The arbitrator's job is the most cognitively loaded step — cross-member deduplication, disagree-set identification, severity judgment across up to 5 finding sets. Callers running high-stakes reviews had no way to upgrade the arbitrator to opus-class.
**Action taken:** Added `arbitrator_model` optional input to Inputs table in SKILL.md, uncompressed.md, and spec.md. Updated Step 6 dispatch in SKILL.md and uncompressed.md to use `arbitrator_model` (default: `sonnet-class`). Documents `opus-class` as the upgrade path for high-stakes reviews.

### UNIFORM SONNET RATIONALE UNDOCUMENTED — LOW

**Severity:** LOW
**Finding:** All built-in personalities default to sonnet-class with no explanation. The `suggested_models` frontmatter field was explicitly designed to support tiering, yet no personality uses it to offer haiku-class as an alternative. The rationale (C2 hallucination filter requires evidence-cite self-checking that haiku-class handles unreliably) was correct but never stated.
**Action taken:** Added one-line rationale to D2 in SKILL.md, uncompressed.md, and spec.md explaining the uniform floor and the `model_overrides` escape hatch.

All other roles (host, haiku sub-task): CLEAN and correctly tiered.
