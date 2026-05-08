# WORDING — 2026-05-08

## Findings

### Duplicate `model` Parameter — HIGH

**Finding:** `model` parameter appeared twice on consecutive lines in instructions.txt (exact duplicate, lines 22-23). Clear bug — created contradictory or ambiguous parameter contract.

**Action taken:** Removed duplicate line. Also removed "single-adversary only" restriction since spec says model applies to all tiers.

### Passive Voice in Rules — MEDIUM

**Finding:** "Caller disputes about prior findings won't be passed to you. Form own judgment." — passive construction, slightly ambiguous.

**Action taken:** "Form own judgment on prior findings; ignore caller disputes."

### Severity Vocabulary Redundancy — MEDIUM

**Finding:** "Use ONLY severity vocabulary above. Don't invent severities." — second sentence restates the first.

**Action taken:** "Use ONLY severity vocabulary above (no invention)."

### Procedure Step 4 Passive Voice — LOW

**Finding:** "Contradictions go in output so calling agent can preserve them." — indirect causal clause.

**Action taken:** "Contradictions go in output for caller to preserve."

### Procedure Step 2 "Touched By" — LOW

**Finding:** "Read every file touched by change set" — informal phrasing.

**Action taken:** "Read every affected file."
