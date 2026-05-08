# COMPRESSABILITY — 2026-05-08

## Findings

### Tier Vocabulary Prose to Table — MEDIUM

**Finding:** Tier vocabulary (fast-cheap → Haiku, standard → Sonnet) was three prose lines. Harder to scan than a structured table.

**Action taken:** Converted to 2-row Markdown table in instructions.txt (`Tier | Model Class | Use For`).

### Procedure Step 1 Adversarial Framing — MEDIUM

**Finding:** "assume author made at least one mistake. Job is to find it, not approve work." restates the same concept twice in informal prose.

**Action taken:** Compressed to "assume ≥1 bug exists; find it, don't rubber-stamp."

### Rules Wording — LOW (multiple)

- "even when fix is one line" exception phrasing removed (redundant scoping)
- "working-tree state, or repo history beyond what `change_set` and `context_pointer` give" → `working-tree, or history beyond `change_set`/`context_pointer``
- "Don't invent severities" consolidated into parenthetical
