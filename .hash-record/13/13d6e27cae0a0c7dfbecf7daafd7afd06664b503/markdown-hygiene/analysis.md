---
file_path: gh-cli/gh-cli-actions/uncompressed.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA014 [SUGGEST] line 54: `do not` appears unemphasized in a directive sentence.
  Note: "do not assume success" carries instructional weight in a safety-relevant context; emphasis would reinforce the warning to the reader.

- SA014 [SUGGEST] line 100: `Never` appears unemphasized at the start of a directive sentence.
  Note: "Never pass secret values as command-line arguments" is a high-priority security directive; emphasis on "Never" would signal its strength relative to surrounding prose.

- SA014 [SUGGEST] line 115: `Always` appears unemphasized in a directive sentence.
  Note: "Always prefer piping from a variable or using `--body` in automated contexts" is an operational guideline; emphasis would reinforce the expectation.

- SA028 [WARN] lines 151–166: The phrase "Operator approval required before execution" (5 words) appears verbatim 10 times across the Safety Classification table rows.
  Note: The repetition is structurally consistent as a table cell value, but the column header or a footnote could carry the meaning once, allowing each cell to use a shorter token or remain implicit.
