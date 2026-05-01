---
file_path: markdown-hygiene/markdown-hygiene-analysis/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA012 [WARN] line 1: title heading immediately followed by "## Purpose" with no content between
  Note: a short subtitle or lead sentence under the H1 would provide document-level context before the first section

- SA012 [WARN] line 41: "## Output Contract" immediately followed by "### analysis.md frontmatter" with no content between
  Note: a brief description of the output contract before the first subsection would add structural context

- SA014 [SUGGEST] line 5: "never" unemphasized in "The target file is never modified."
  Note: bolding or ALL CAPS on "never" would strengthen the constraint signal in an instruction document

- SA014 [SUGGEST] line 85: "never" unemphasized in "never `Fix:` (imperative)"
  Note: this is a key behavioral directive; emphasis on "never" would help readers catch the restriction

- SA018 [WARN] line 5: passive voice on directive sentence — "The target file is never modified."
  Note: active phrasing such as "Agents must not modify the target file." would make the constraint more direct

- SA029 [WARN] line 25: positional reference — "(see Result Logic below)"
  Note: a section name reference without the directional qualifier would be more stable if sections are reordered

- SA037 [WARN] line 83: Constraints list mixes command-style items ("do NOT author scripts", "Advisory entries use `Note:`") with an observation item ("Target file is read-only.")
  Note: rephrasing all items as imperatives or separating behavioral directives from state descriptions would make the list uniform
