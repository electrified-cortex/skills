# COMPRESSABILITY — 2026-05-08

## Findings

### MODEL-SELECTION ALGORITHM TRIPLICATED — MEDIUM

**Severity:** MEDIUM
**Finding:** The model selection algorithm (read `suggested_models`, caller overrides take precedence, fall back to `sonnet-class`) appeared verbatim in three locations: Personality Metadata Schema, Step 2, and Step 5. Schema and Step 2 are semantically identical — same three sentences, same logic, same fallback. Step 5 is operationally distinct (applying overrides at actual dispatch time after final swarm is set), so it justifies its own copy.
**Action taken:** Collapsed the Personality Metadata Schema model-selection paragraph to a single pointer ("Model selection at dispatch: see Step 2.") in both SKILL.md and uncompressed.md. Step 2 and Step 5 both kept.

### ROLLING-WINDOW CONCURRENCY TRIPLE-STATED — LOW

**Severity:** LOW
**Finding:** Step 5 stated the rolling-window constraint three times in one paragraph: "Maximum concurrency: rolling window of 3" + "Dispatch up to 3 personalities in parallel; as each completes, dispatch the next until all personalities have run" + "Don't dispatch more than 3 at once." Sentences 1 and 3 are restatements of sentence 2; sentence 2 is the only one that fully defines the behavior.
**Action taken:** Replaced the three-sentence block with the single defining sentence in both files. Label "Maximum concurrency" kept as inline header.

### B9 REDUNDANT CLAUSES — LOW

**Severity:** LOW
**Finding:** B9 stated "Not cached. Always re-dispatched on any re-run." — these are equivalent (not cached = always re-dispatched). Similarly, uncompressed.md Key Terms had "Exists for the current invocation only. Not persisted" — also equivalent. Two clauses stating one fact.
**Action taken:** Collapsed B9 to "Not in registry; not cached (always re-dispatched)." in SKILL.md. Collapsed Key Terms to "Exists for current invocation only; not cached; no reviewers/ file." in uncompressed.md.
