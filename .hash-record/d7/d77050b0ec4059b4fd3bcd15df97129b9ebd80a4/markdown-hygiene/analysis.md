---
file_path: gh-cli/gh-cli-projects/SKILL.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 54: "Item-add" is a shell subcommand name used in plain prose without backticks.
  Note: "Item-add" refers to the `gh project item-add` subcommand; wrapping it in backticks would be consistent with how other commands are styled in the document.

- SA018 [WARN] line 35: "option ID required, not label text" — passive voice on a directive sentence.
  Note: The phrasing "option ID required" states a requirement in passive form; an active form such as "requires an option ID, not label text" or "use an option ID, not label text" would be more direct.
