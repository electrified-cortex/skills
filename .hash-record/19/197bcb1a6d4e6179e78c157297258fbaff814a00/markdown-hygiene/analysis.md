---
file_path: gh-cli/gh-cli-pr/gh-cli-pr-create/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 42: `git push` used in plain prose without backticks.
  Note: The command `git push` appears as a bare word in the Constraints list; backtick formatting would mark it as a shell command consistent with other command references in the document.

- SA010 [WARN] line 48: `gh pr create` in Safety Classification table cell without backticks.
  Note: The command in the Command column appears as unformatted plain text; backticks would distinguish it as a shell command, matching how it is formatted elsewhere in the document.

- SA010 [WARN] line 49: `gh pr ready` in Safety Classification table cell without backticks.
  Note: Same as above — the command in the second table row is unformatted while it is backtick-wrapped in all other occurrences.

- SA013 [WARN] line 35: Heading "## Precedence Rules" introduces only a single sentence.
  Note: The entire section body is one sentence; an inline bold label such as `**Precedence Rules:**` would serve the same purpose without creating a heading for a single-sentence entry.

- SA018 [WARN] line 29: "The body may be provided inline or from a file." — passive voice in spec document.
  Note: Spec behavior prose tends to read more precisely in active voice; the sentence does not name who provides the body.

- SA018 [WARN] line 29: "A closing issue link is embedded in the body via the `Closes #NNN` syntax." — passive voice in spec document.
  Note: The actor (the agent) is omitted; active phrasing would align with the directive style used in the Requirements and Error Handling sections.

- SA028 [WARN] lines 48–49: Phrase "Operator approval required before execution" appears verbatim twice.
  Note: Both table rows carry identical Notes cell text; the repetition provides no distinction between the two commands and may be a copy-paste artefact.
