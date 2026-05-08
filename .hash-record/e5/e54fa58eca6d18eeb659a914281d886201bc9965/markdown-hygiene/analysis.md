---
file_path: messaging/post.spec.md
operation_kind: markdown-hygiene-analysis
result: fixed
---

# Result

## Advisory

- SA009 [WARN] line 34: Behavior step 8 contains two sentences in a single list item.
  Note: The item opens with the write directive and closes with a tolerance policy ("Signal write failure is tolerated — exit zero regardless.") that is a separate instruction.

- SA018 [WARN] line 35: Passive voice on directive — "Signal write failure is tolerated — exit zero regardless."
  Note: The passive construction obscures the acting subject; an active phrasing would state the behavior as an explicit policy or action.

- SA018 [WARN] line 39: Passive voice on directive — "Errors written to stderr."
  Note: The sentence omits the acting subject; active phrasing would be "Write errors to stderr."

- SA032 [WARN]: Timestamp value described by two distinct names within the document.
  Note: Step 3 (line 23) labels the format "`YYYYMMDDTHHmmssZ`" while the JSON example (line 30) labels the same field value `<ISO 8601 UTC>` — two different identifiers for the same concept.

- SA038 [FAIL]: Contradictory exit-code handling for signal write failure.
  Note: Behavior step 8 (line 35) declares "Signal write failure is tolerated — exit zero regardless," but the Exit Codes table (line 47) defines code 2 as "Write failure (inbox not writable, filesystem error)" with no exclusion for signal write failures — the table scope can be read to include signal failures, directly contradicting the explicit exit-0 directive.
