---
file_path: messaging/uncompressed.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA003 [WARN] line 137: "NOT" appears 6 times in document (signal collapse).
  Note: All six Don'ts entries use "Do NOT"; repeated ALL CAPS in a concentrated block risks normalising the emphasis rather than reinforcing it.

- SA007 [WARN] line 11: Two-item list (post/drain) may read naturally as "X and Y".
  Note: The immediately preceding sentence "Two tools handle all mechanics" frames these as a pair; a single sentence introducing both tools could be equally clear without a list.

- SA009 [WARN] line 119: List item 3 in Processing Messages spans two sentences.
  Note: The second sentence ("A single bad message must not halt inbox processing.") is a constraint rationale rather than a step action; it could stand as a follow-on paragraph outside the list.

- SA014 [SUGGEST] line 50: Unemphasized "do not" in directive sentence ("Do not write inbox files directly.").
  Note: Inline prohibition uses lowercase "do not"; the corresponding Don'ts entry uses "Do NOT", creating inconsistent emphasis between the two appearances of the same rule.

- SA014 [SUGGEST] line 65: Unemphasized "do not" in directive sentence ("Do not post to your own inbox.").
  Note: Same pattern — inline form is softer than the Don'ts counterpart.

- SA014 [SUGGEST] line 107: Unemphasized "always" in directive sentence ("Drain always does a full sweep").
  Note: The qualifier carries a behavioral guarantee with operational consequence but is not marked as mandatory.

- SA014 [SUGGEST] line 110: Unemphasized "do not" in directive sentence ("Do not drain another agent's inbox.").
  Note: Inline form is softer than the Don'ts counterpart.

- SA014 [SUGGEST] line 120: Unemphasized "must not" in directive sentence ("A single bad message must not halt inbox processing.").
  Note: Core safety constraint embedded as a list continuation line with no emphasis; easily missed relative to its importance.

- SA032 [WARN] line 8: Same concept referred to by two names ("inbox folders" vs "inbox").
  Note: Opening paragraph uses "inbox folders" in natural prose; every subsequent section and the Concepts definition use "inbox" as the canonical term.
