# WORDING — 2026-05-08

## Findings

### GUARD CLAUSE DISCONNECTION — HIGH

**Severity:** HIGH
**Finding:** Step 1's "Verify packet" instruction had no exit path — it said "attempt to resolve gap" but gave no instruction for when resolution fails. B1 (the actual halt condition) was ~100 lines away in the Behavior section. A model failing to resolve the gap had no in-scope stop instruction and would proceed to Step 2 and dispatch against an empty artifact.
**Action taken:** Added "If gap cannot be resolved, return error per B1 and halt." directly to the Step 1 verify instruction in SKILL.md and uncompressed.md.

### "SHOULD RETURN" WEAKENS OUTPUT CONTRACTS — HIGH

**Severity:** HIGH
**Finding:** Both Step 5 ("Should return: structured findings list") and Step 6 ("Should return: structured two-section action list") used "Should" — a preference, not a requirement. These are the primary data contracts of the pipeline. "Should" allows models to treat non-structured output as compliant, degrading the hallucination filter (C2) and file-existence filter.
**Action taken:** Replaced "Should return" with "Must return" in Step 5 and Step 6 of both SKILL.md and uncompressed.md.

### C2 EXACT PHRASE NOT PROXIMATE TO DISPATCH — MEDIUM

**Severity:** MEDIUM
**Finding:** Step 5 cross-referenced C1–C3 for the read-only constraint but the verbatim required phrase ("read-only review — analyze and report only, no file edits, no commits, no shell commands") was ~150 lines away in the Constraints section. Models relying on cross-reference retrieval from mid-document may paraphrase rather than use the exact string.
**Action taken:** Inlined the verbatim phrase directly in Step 5's dispatch item 3 in both SKILL.md and uncompressed.md. Cross-reference to C1–C3 retained parenthetically.

### B8 FULLY DEFERRED FROM DISPATCH TRIGGER — MEDIUM

**Severity:** MEDIUM
**Finding:** Step 5 said "execute the resolution order defined in B8 before dispatching" — fully deferring to B8 ~100 lines later. A model that misses B8 retrieval silently skips the diversity guarantee with no fallback in-scope. The three resolution steps are short and concrete.
**Action taken:** Inlined the three-step B8 resolution order directly in Step 5 in both SKILL.md and uncompressed.md. B8 retained in Behavior section as the governing reference.

### VALIDATION THEATER (PARTIAL) — LOW

**Severity:** LOW
**Finding:** Step 1's verify criterion "Goal must be specific enough to evaluate" is self-referential — the model evaluates its own output against a standard only it can define. Not load-bearing since the fallback is gap resolution, but creates a vacuous gate.
**Action taken:** Replaced with observable criterion: "Goal must name the artifact type and state what outcome is being evaluated (e.g., 'evaluate diff for correctness and security')." Applied to both SKILL.md and uncompressed.md.
