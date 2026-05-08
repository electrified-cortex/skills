---
file_path: messaging/drain.spec.md
operation_kind: markdown-hygiene-analysis
result: fixed
---
# Result

## Advisory

- SA009 [WARN] line 29: Behavior item 5 contains two sentences.
  Note: "If a file cannot be read after claiming..." and "Continue to next file." are consecutive imperative sentences in one list item.
  Skipped: Two-sentence format aids procedural clarity; "Continue to next file." acts as a direct step continuation.

- SA018 [WARN] line 59: Passive voice in directive — "Claimed files... are treated as unarchived messages".
  Note: Spec directive used passive construction "are treated as"; rewrote as active MUST directive.
  Fixed: Rewritten to "MUST treat `.json.claimed` files left over from a crashed prior run as unarchived messages".

- SA037 [WARN] line 56: Constraints list mixed MUST/MUST NOT command items with one plain observation item.
  Note: First three bullets led with MUST/MUST NOT; last bullet was a plain descriptive statement without directive form.
  Fixed: Last bullet rewritten to lead with MUST, consistent with sibling items.
