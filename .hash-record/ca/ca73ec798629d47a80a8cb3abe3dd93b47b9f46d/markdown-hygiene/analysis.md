---
file_path: gh-cli/gh-cli-releases/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 45: `git` used as a shell command in plain prose without backticks.
  Note: The phrase "via git first" references the `git` CLI directly; the surrounding context backticks `gh release create` but leaves `git` unformatted.

- SA014 [SUGGEST] line 49: `never` appears unemphasized in a directive sentence.
  Note: "a draft release is never exposed as the `latest` release regardless of creation date" — `never` carries directive weight here and could be emphasized for clarity.

- SA018 [WARN] line 41: Passive voice on a directive sentence in a spec document.
  Note: "The draft-then-publish flow and the direct publish flow are treated as distinct patterns" — the agent of the treating is unspecified; active voice ("The skill treats...") would be more direct.

- SA028 [WARN] lines 65–68: "Operator approval required before execution" appears verbatim four times.
  Note: The phrase is repeated identically in every destructive-command row of the Safety Classification table; a table note or footnote reference would eliminate the duplication.

- SA032 [WARN] document-level: Same authorization concept referred to by two distinct names.
  Note: The Safety Classification table uses "operator approval" while the footnote below the table uses "operator authorization" — these appear to describe the same requirement.

- SA036 [WARN] line 41: Directive sentence contains three coordinating conjunctions.
  Note: The first sentence of the Behavior section chains items with "or … or … and"; splitting the enumeration into a list or shorter sentences would reduce cognitive load.
