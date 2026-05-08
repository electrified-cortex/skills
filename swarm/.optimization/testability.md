# TESTABILITY — 2026-05-08

## Findings

### DISPATCH-* MODEL SELECTION UNDEFINED — HIGH

**Severity:** HIGH
**Finding:** Step 2 said "select first available from suggested_models" but for `dispatch-*` backends, no probe runs (Step 3 explicitly excludes them). The word "available" was never defined for non-probed backends. An implementor could read this as (a) assume available and take first, (b) skip because no probe confirmed it, or (c) let E3 catch the dispatch failure — three distinct observable behaviors.
**Action taken:** Added clarifying sentence after the selection instruction in Step 2 (both files): "For `dispatch-*` backends, no model-class probe is run — treat all listed entries as available and select the first." Selection is now fully deterministic.

### 5-CAP SPECIFICITY TIE-BREAK MISSING — MEDIUM

**Severity:** MEDIUM
**Finding:** 5-cap priority step said "personalities with most-specific trigger match (narrower/more-specific trigger = higher priority)" but gave no scoring function. With two equally-specific triggers, the selection is non-deterministic. An implementor cannot write a reproducible test.
**Action taken:** Replaced vague "narrower/more-specific" description with a countable specificity rule: specificity score = count of distinct comma-delimited terms in the `trigger` field; `"always"` = 0. Tie-break: alphabetical personality name. Applied to both files.

### D6 "ALL PERSONALITIES AGREE" UNDER-SPECIFIED — MEDIUM

**Severity:** MEDIUM
**Finding:** D6 said "Raised to High when all personalities agree and all findings cite evidence." "Agree" was never defined — does it mean no contradictions, or overlapping findings, or both? A test with non-overlapping-but-non-contradictory finding sets had no defined outcome.
**Action taken:** Replaced "all personalities agree" with two explicit conditions: "(1) disagree set is empty AND (2) every dispatched personality returned at least one finding." This removes semantic overlap-checking entirely — agreement = no contradictions + all contributed. Applied to both files.
