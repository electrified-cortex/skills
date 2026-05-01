---
file_path: skill-auditing/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA003 [WARN] document-level: ALL CAPS verdict/severity identifiers FAIL, PASS, HIGH, and NEEDS_REVISION each appear 5+ times throughout the document.
  Note: Repeated ALL CAPS identifiers across every section may dilute their attention-signaling function; PASS and FAIL alone appear in over a dozen distinct places outside code blocks.

- SA009 [WARN] line ~78 (Requirements): Numbered list items 10, 11, 13–21 are multi-sentence paragraphs, several spanning 5–7 sentences each.
  Note: Extended list items in a Requirements block are harder to scan and cross-reference; sub-sections or short rule blocks would improve navigability.

- SA011 [FAIL] line ~453 (Verdict Rules): `**PASS**`, `**NEEDS_REVISION**`, and `**FAIL**` apply both bold and ALL CAPS to the same label — redundant double-emphasis.
  Note: One form (bold or ALL CAPS) is sufficient for a verdict label; using both simultaneously is the SA011 anti-pattern.

- SA014 [SUGGEST] document-level: `must`, `must not`, and `never` directives in the Constraints, Auditing Constraints, and Fix Mode Behavior sections appear without bold emphasis (e.g., "must never be modified," "must only run after," "must be read-only").
  Note: Emphasis is consistent in the Requirements section but absent in several other directive sections; unemphasized normative terms may be skimmed past by an agent reading quickly.

- SA018 [WARN] line ~334 (Dispatch Skill Audit Criteria, DS-1): Directive sentence uses passive voice — "MUST be flagged HIGH" rather than "the auditor must flag ... HIGH."
  Note: Passive voice obscures the actor performing the action; active construction is more directive-clear for an instruction document.

- SA020 [WARN] line ~64 (Requirements): Numbered list items 3–21 have no sequential execution dependency; numbering is used for reference identity, not ordering.
  Note: A numbered list signals execution order; bullet items with explicit reference IDs (e.g., R-03) would more clearly indicate reference-oriented numbering.

- SA028 [WARN] document-level: Fix-mode eligibility and compiled-artifact immutability constraints are restated near-verbatim across five locations: Requirements (items 13, 15), Constraints ("Fix mode conditional," "Compiled artifacts immutable"), Defaults and Assumptions, Auditing Constraints, and Fix Mode Behavior.
  Note: Five sections with overlapping constraint text increase drift risk when one copy is updated without updating the others.

- SA032 [WARN] line ~622 (Tiered Model Strategy): "Iterate tier," "fast-cheap model class," and "Haiku-class" are used as synonyms; "Sign-off tier," "standard model class," and "Sonnet-class" are likewise interchangeable within the same section.
  Note: Three distinct name-sets for two concepts in close proximity may cause an agent to treat them as separate things.

- SA034 [WARN] line ~637 (Tiered Model Strategy): "other model families should map to their own inexpensive/default tiers" uses the vague qualifier "should" without stating an exception condition.
  Note: No condition is given for when this mapping guidance does not apply; a model-agnostic directive would be stronger with a concrete failure mode stated.

- SA035 [WARN] line ~44 (Version): "Bump this when the audit semantics, output schema, or check codes change in a way that invalidates prior records" states the action (Bump) before the gate condition (when … change).
  Note: Gate-first form is preferred: "When audit semantics, output schema, or check codes change in a way that invalidates prior records, bump the version."
