---
file_path: messaging/implementation.md
operation_kind: markdown-hygiene-analysis
result: pass
---
# Result

## Advisory

- SA014 [SUGGEST] line 112: `do not re-enumerate or retry` — unemphasized "do not" in directive sentence of an instruction document.
  Note: The phrase reads as a behavioral rule for implementers; emphasis would signal its mandatory character more clearly.

- SA014 [SUGGEST] line 135: `never place the inbox on a different volume` — unemphasized "never" inside a callout that carries a hard constraint.
  Note: Sits in a blockquote already, which provides some visual weight, but the word itself is plain.

- SA014 [SUGGEST] line 200: `(never direct write)` — unemphasized "never" inside a checklist item.
  Note: Parenthetical placement reduces visibility for what is described elsewhere as a required technique.

- SA014 [SUGGEST] line 205: `(never deleted)` — unemphasized "never" inside a checklist item.
  Note: Same pattern as line 200; the constraint is stated parenthetically without emphasis.

- SA026 [WARN] lines 39, 62, 78, 100, 137, 157, 177, 194: `---` thematic breaks used as visual section dividers between sections that already carry `##` headings.
  Note: Each section boundary is already established by the heading that follows; the horizontal rules add visual separation but are redundant with the heading structure and may confuse renderers that interpret `---` as an alternative heading syntax in certain contexts.

- SA030 [WARN] line 36: blockquote `> Do NOT use Copy-Item + Remove-Item ...` — used as a warning callout, not a quotation.
  Note: The blockquote signals emphasis/caution rather than attributed speech; a bold label or admonition-style prefix would be more semantically accurate.

- SA030 [WARN] line 133: blockquote `> POSIX mv between paths on the same filesystem is atomic ...` — used as a technical callout, not a quotation.
  Note: Same pattern; the content is an original statement, not quoted material.

- SA035 [WARN] line 60: `Truncate to 6 characters if a shorter nonce is preferred.` — action stated before gate condition.
  Note: Reordering to "If a shorter nonce is preferred, truncate to 6 characters." places the condition first, matching the document's otherwise consistent if-then ordering.
