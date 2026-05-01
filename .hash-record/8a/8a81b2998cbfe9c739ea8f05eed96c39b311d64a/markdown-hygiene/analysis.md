---
file_path: gh-cli/gh-cli-pr/skill.index.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA003 [WARN]: "CLI" appears 6 times in the document.
  Note: Repeated ALL CAPS acronym across all section bodies may signal the term could be factored into a document-level header or preamble to reduce repetition.

- SA013 [WARN] line 7: `## gh-cli-pr-comments` introduces only a single sentence.
  Note: Each of the five sub-skill sections (lines 7, 11, 15, 19, 23) consists of a heading followed by exactly one descriptive sentence; a `**Label:**` inline pattern would achieve the same structure with less heading overhead.

- SA013 [WARN] line 11: `## gh-cli-pr-create` introduces only a single sentence.
  Note: See note on line 7.

- SA013 [WARN] line 15: `## gh-cli-pr-inline-comments` introduces only a single sentence.
  Note: See note on line 7.

- SA013 [WARN] line 19: `## gh-cli-pr-merge` introduces only a single sentence.
  Note: See note on line 7.

- SA013 [WARN] line 23: `## gh-cli-pr-review` introduces only a single sentence.
  Note: See note on line 7.

- SA032 [WARN]: "pull request" (lines 5, 9, 13, 21, 25) and "PR" (lines 5, 17, 25) refer to the same concept using two distinct names.
  Note: The document uses the full term and the abbreviation interchangeably within the same section bodies; picking one form consistently would reduce ambiguity.
