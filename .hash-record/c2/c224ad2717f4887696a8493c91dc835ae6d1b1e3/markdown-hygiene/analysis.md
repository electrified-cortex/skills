---
file_path: gh-cli/gh-cli-releases/uncompressed.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA018 [WARN] line 40: Passive voice in directive sentence.
  Note: "Ensure the tag exists and is pushed before running this command" uses passive construction ("is pushed") inside a directive clause; an active phrasing such as "Ensure the tag exists and has been pushed" or "Ensure you have pushed the tag" would be more direct.

- SA028 [WARN] lines 110-113: Phrase "Operator approval required before execution" appears verbatim four times.
  Note: The identical five-word note is repeated in every destructive-command row of the safety table; a footer note or a single column header could convey the same information without the repetition.

- SA031 [WARN] line 51: Heading "## Pre-releases" uses sentence case while all sibling headings use Title Case.
  Note: Every other ## heading capitalises all major words (e.g., "Listing Releases", "Uploading Assets", "Scope Boundaries"); "Pre-releases" only capitalises the first word, making it inconsistent with the surrounding set.

- SA032 [WARN] document-level: Same concept referred to as "operator approval" (table, lines 110-113) and "operator authorization" (prose, line 115).
  Note: The table notes use "Operator approval required before execution" while the closing paragraph uses "explicit operator authorization"; treating these as synonyms may cause ambiguity about whether they represent the same gate or different thresholds.
