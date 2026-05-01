---
file_path: gh-cli/gh-cli-pr/uncompressed.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 59: `CODEOWNERS` used as a filename in plain prose without backticks.
  Note: `CODEOWNERS` is a recognized config filename; backtick formatting would mark it clearly as a file reference rather than an ordinary word.

- SA010 [WARN] line 63: `CODEOWNERS` used again in plain prose without backticks.
  Note: Second occurrence of the same unformatted filename in the Scope Boundaries section.

- SA013 [WARN] line 65: `## Related Skills` heading introduces a single line of content (comma-separated skill identifiers).
  Note: A heading that gates only one line of content could instead use an inline label like `**Related Skills:**` to avoid a standalone section for minimal content.

- SA028 [WARN] lines 59, 63: The phrase "This skill covers `gh pr`" appears verbatim in both the Notes bullet (line 59) and the Scope Boundaries paragraph (line 63).
  Note: The two sections restate the same scope constraint with nearly identical language; the overlap suggests one of the sections may be redundant.

- SA031 [WARN] document-level: `## Sub-skills` uses lowercase `s` in the second element while all sibling headings follow Title Case (`When to Use`, `Common Inspection Commands`, `Scope Boundaries`, `Related Skills`, `Safety Classification`).
  Note: `Sub-Skills` would align with the Title Case pattern used by every other level-2 heading.

- SA032 [WARN] lines 59, 63: The scope of this skill is described as covering "`gh pr` commands" on line 59 and "`gh pr` subcommands" on line 63.
  Note: Using `commands` and `subcommands` interchangeably for the same concept may create confusion about whether there is a meaningful distinction intended.

- SA037 [WARN] lines 57–59: The Notes list mixes directive items (`Use --repo owner/name when…`) with observational/descriptive items (`gh pr checks --watch is the correct way…` and `This skill covers… is out of scope`).
  Note: Readers may not immediately distinguish which items require agent action versus which are informational context.
