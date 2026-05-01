# MODEL SELECTION — 2026-05-01

**Severity:** MEDIUM
**Finding:** Step 3b (Assessor Decision, Sonnet-class) operates on the output of Step 3a, which short-circuits at first match and returns exactly one candidate. A Sonnet-class selection step with a singleton input performs no selection — the tie-breaking rules in 3b are moot when there is only one result. The assessor step was designed for multi-candidate input that the qualifier prompt no longer fulfills.
**Action taken:** Changed qualifier prompt (Step 3a) from short-circuit first-match with yes/maybe/no to full-list scoring with 0-100 yield scores. Step 3b now picks highest score, with tie-breaking for equal scores. Removed second qualifier call instruction (was a workaround for the short-circuit design).
