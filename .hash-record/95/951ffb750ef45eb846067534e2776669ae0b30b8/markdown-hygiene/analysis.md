---
file_path: gh-cli/gh-cli-issues/uncompressed.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 123: Shell commands in Safety Classification table cells appear without backticks (`gh issue list`, `gh issue view`, `gh issue create`, etc.).
  Note: All nine command entries in the Command column are unquoted plain text; backticking them would be consistent with how commands are rendered elsewhere in the document.

- SA013 [WARN] line 42: Heading `## Viewing Issues` introduces only a single prose sentence before a code block.
  Note: A single-sentence section could be expressed as `**Viewing Issues:**` inline rather than a standalone heading; whether the heading is worth keeping depends on navigation needs.

- SA013 [WARN] line 100: Heading `## Transferring Issues` introduces only a single prose sentence before a code block.
  Note: Same pattern as `## Viewing Issues` — one sentence plus one code block; the heading level may be heavier than the content warrants.

- SA028 [WARN] line 125: Phrase "Operator approval required before execution" (5 words) appears verbatim 7 times across table rows.
  Note: The repetition is structural but could be consolidated — e.g., a single blanket note beneath the table — leaving the Notes column for exceptions or distinctions.

- SA032 [WARN] document-level: The concept of needing permission before a destructive command is named "approval" in the table Notes column and "authorization" in the closing bold sentence.
  Note: "Operator approval required before execution" vs "explicit operator authorization in the current session" refer to the same gate; using one term throughout would reduce ambiguity.
