---
file_path: gh-cli/gh-cli-pr/gh-cli-pr-comments/SKILL.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 41: `PATCH` HTTP method referenced in prose without backticks
  Note: "PATCH:" appears at the end of the sentence "Use REST API — find comment ID, PATCH:" naming an HTTP verb that acts as a command reference; surrounding flags like `--edit` and `--delete` are wrapped in backticks but this term is not.

- SA013 [WARN] line 8: `## Adding` heading introduces only a single sentence before a code block
  Note: The sole prose under this heading is the fragment "Add comment to PR:" — a single sentence. An inline label pattern (`**Adding:**`) could replace the heading; the code block does provide context but the heading level may be heavier than needed for one sentence.

- SA014 [SUGGEST] line 36: "never" unemphasized in an instruction document
  Note: "never for exhaustive comment checks" uses a strong directive keyword without bold or other emphasis; instruction documents typically emphasize such terms to aid scanning.
