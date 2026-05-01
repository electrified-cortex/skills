---
file_path: gh-cli/instructions.uncompressed.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 20–27: Skill folder paths in "Sub-skill" table column lack backticks.
  Note: Paths like `gh-cli-actions/`, `gh-cli-api/`, etc. appear as unquoted plain text in the table cells; the Related section wraps the same names in backticks, making the treatment inconsistent.

- SA010 [WARN] line 31: Directory path `gh-cli-prs/` appears unquoted in prose.
  Note: "The prs domain has its own sub-skills under gh-cli-prs/:" uses the path inline without backticks.

- SA010 [WARN] line 33–36: Sub-skill paths in bullet list lack backticks.
  Note: `gh-cli-prs-comments/`, `gh-cli-prs-create/`, `gh-cli-prs-merge/`, `gh-cli-prs-review/` are unquoted path literals in the bullet items.

- SA014 [SUGGEST] line 40: "Always" is unemphasized in an instruction document.
  Note: The directive opens with "Always" but the word carries no bold or other emphasis.

- SA014 [SUGGEST] line 41: "Never" is unemphasized in an instruction document.
  Note: The prohibition opens with "Never" but the word carries no bold or other emphasis.

- SA028 [WARN] line 14 and line 42: Phrase "If the task spans multiple domains" appears verbatim twice.
  Note: Step 5 under How It Works and item 3 under Rules both open with the identical six-word phrase before giving slightly different instructions for the same scenario.

- SA032 [WARN] (document-level): "domain sub-skill" and "domain skill" may refer to the same concept.
  Note: Step 3 uses "domain sub-skill" while Rules item 2 uses "domain skill"; if these denote the same artifact, a single consistent term would reduce ambiguity.

- SA035 [WARN] line 40: Action stated before gate condition.
  Note: "Always verify `gh auth status` before executing commands if the setup skill was not already loaded" puts the action before its qualifying condition; leading with the condition ("If the setup skill was not already loaded, always verify…") would be clearer.

- SA037 [WARN] line 13: Observation item mixed with command items in numbered list.
  Note: Step 4 ("The sub-skill executes the commands and reports the results") describes what the sub-skill does rather than issuing a directive, while steps 1, 2, 3, and 5 are all imperative commands; no distinguishing signal separates the two kinds.
