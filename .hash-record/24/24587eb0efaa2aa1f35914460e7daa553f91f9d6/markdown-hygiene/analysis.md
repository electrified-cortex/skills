---
file_path: gh-cli/skill.index.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA003 [WARN]: "CLI" appears 7 times in document
  Note: Repetition reaches signal-collapse threshold; the document title and sub-skill names already establish the CLI context implicitly.

- SA010 [WARN] line 13: `gh` appears as plain prose in "no dedicated gh subcommand"
  Note: "gh" is a CLI command name and conventionally belongs in backticks when referenced in prose.

- SA010 [WARN] line 17: `gh issue` appears as plain prose in "using the gh issue subcommand"
  Note: "gh issue" is a CLI subcommand; backtick quoting would distinguish it from surrounding text.

- SA010 [WARN] line 29: `gh release` appears as plain prose in "via gh release Full lifecycle"
  Note: "gh release" is a CLI subcommand appearing inline in prose without code formatting.

- SA013 [WARN]: All 9 level-2 sections consist of a heading introducing exactly one sentence
  Note: Each entry is a heading plus a single descriptive sentence; the heading level may be heavier than needed for what is functionally a labeled description.

- SA027 [WARN]: All sibling level-2 headings share the "gh-cli" prefix
  Note: With the document title already establishing the "gh-cli" namespace, repeating the prefix in every sibling heading is structurally redundant.

- SA032 [WARN]: The GitHub CLI tool is named three different ways across sections — "GitHub CLI" (lines 5, 25, 37), "the CLI" (line 13), and "CLI" (lines 9, 21, 33)
  Note: Three naming variants refer to the same tool; the inconsistency may cause routing ambiguity in semantic dispatch.
