# EXAMPLES — 2026-05-01

## Findings

### SYNTHESIS OUTPUT FORMAT — MEDIUM

**Severity:** MEDIUM
**Finding:** Step 8 listed four required synthesis output fields in prose with no template. When swarm is invoked by a downstream agent (e.g., code-review), field ordering and naming variance is likely without an anchoring template.
**Recommendation:** Add a minimal labeled-field template block to Step 8 showing exact field names and structure.
**Action taken:** Added synthesis output template block to uncompressed.md Step 8 and condensed template reference into SKILL.md S8.

### CONFIDENCE RATING CALIBRATION — MEDIUM

**Severity:** MEDIUM
**Finding:** Confidence rating rules included "any personality returns no findings" as a Low trigger, but no example disambiguated this from Medium. The boundary was non-obvious: a run where one personality legitimately finds nothing (e.g., Performance Reviewer on a documentation artifact) would incorrectly be rated Low without a calibration example.
**Recommendation:** Add concrete calibration examples (High/Medium/Low) showing boundary cases, especially the "no findings" → Low trigger and what would raise it.
**Action taken:** Added calibration examples block to uncompressed.md D6. Clarified Low definition in SKILL.md Confidence Rating section to include "If Low, state what would raise it."

### TRIGGER EVALUATION EXAMPLES — LOW

**Severity:** LOW
**Finding:** Step 2 trigger evaluation ("evaluate trigger conditions against packet traits") has no example of a trigger string matched against a representative packet. Risk of under/over-inclusion.
**Recommendation:** Add one inline example (e.g., trigger "auth, user input" against a packet with Goal "add login endpoint") to Step 2 in uncompressed.md.
**Action taken:** Deferred — sonnet-class minimum caller tier is sufficient to apply the string-matching heuristic; adding an example at this position would consume tokens with marginal gain relative to the MEDIUM fixes already applied.
