---
file_path: gh-cli/gh-cli-pr/gh-cli-pr-inline-comment/uncompressed.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 105: `PATCH` (HTTP method name) appears in plain prose without backticks.
  Note: "PATCH to update the body:" uses the HTTP method as a keyword-style term; consistent backtick wrapping would signal it as a technical literal rather than a prose word, matching how `GET`, `POST`, etc. are typically rendered in API docs.

- SA014 [SUGGEST] line 33: "Always" is unemphasized in a directive sentence.
  Note: "Always use the PR's latest commit:" states an absolute rule; the word "Always" carries no emphasis despite the instruction-document context.

- SA014 [SUGGEST] line 43: Second "must" is unemphasized in a directive sentence.
  Note: "it must be visible in the diff" — the first "must" in the same sentence is bolded (**must**) but this second occurrence is plain text; inconsistent emphasis on the same directive word within one sentence.

- SA014 [SUGGEST] line 69: "do not" is unemphasized in a directive sentence.
  Note: "do not repost" carries a prohibition with no bold or other emphasis.

- SA014 [SUGGEST] line 86: "Always" is unemphasized in a directive sentence.
  Note: "Always use `line` (absolute file line number)" states an absolute rule without emphasis on "Always".

- SA014 [SUGGEST] line 101: "must" appears twice unemphasized in a directive sentence.
  Note: "Both `start_line` and `line` must be in the diff; `side` and `start_side` must match." — both occurrences of "must" are plain text.

- SA016 [WARN] line 59: Heading exceeds ~60 characters.
  Note: "Step 3: Check for Existing Comments at the Target Line (Deduplication)" is approximately 72 characters; a shorter form could improve scannability without losing meaning.

- SA027 [WARN]: "Inline" and "Comment/Comments" appear in five consecutive sibling headings (lines 71, 90, 103, 115, 122).
  Note: "Post the Inline Comment", "Multi-Line Inline Comment", "Editing an Inline Comment", "Deleting an Inline Comment", and "Listing Existing Inline Comments" all share the same root words; a parent section heading grouping these operations could reduce repeated noise in the heading list.

- SA032 [WARN]: "inline comment", "inline review comment", and "inline code review comment" are used interchangeably for the same concept throughout the document.
  Note: The frontmatter description says "inline code review comments"; the document body primarily uses "inline review comment" and "inline comment". Settling on one canonical term would reduce ambiguity.
