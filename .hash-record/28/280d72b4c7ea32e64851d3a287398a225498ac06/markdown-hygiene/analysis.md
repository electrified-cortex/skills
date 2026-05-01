---
file_path: gh-cli/SKILL.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 36: directory path `gh-cli-prs-comments/` appears in prose list without backticks
  Note: Lines 36–39 list PR sub-skill directory paths (gh-cli-prs-comments/, gh-cli-prs-create/, gh-cli-prs-merge/, gh-cli-prs-review/) as plain text; each is a file-system path that would conventionally be wrapped in backticks.

- SA014 [SUGGEST] line 44: `never` directive unemphasized in instruction document
  Note: "Never improvise commands" is a strong directive but the word "Never" carries no bold or other emphasis; readers skimming may miss the prohibition.

- SA032 [WARN] document-level: "sub-skill" and "domain skill" used for the same concept
  Note: The document consistently uses "sub-skill" (lines 6, 16, 17, etc.) but line 44 switches to "domain skill" ("use only what domain skill documents"); both appear to refer to the same delegated skill unit.

- SA035 [WARN] line 43: action stated before gate condition
  Note: "Verify `gh auth status` before executing if setup skill wasn't loaded" places the action before the condition; the condition-first form ("If setup skill wasn't loaded, verify `gh auth status` before executing") is clearer.

- SA037 [WARN] line 17: list mixes command items and observation items
  Note: In the "How It Works" numbered list, items 1–3 and 5 are instructions directed at the agent, but item 4 ("Sub-skill executes commands, reports results") is a description of what the sub-skill does, not an instruction; the mixed register may cause confusion about which items require agent action.

- SA038 [FAIL] document-level: contradictory statements about running `gh` commands
  Note: Line 6 states the skill "Doesn't run `gh` commands itself," but the Rules section (line 43) instructs the agent to "Verify `gh auth status`" — which is itself a `gh` command; the intended meaning (verify before delegating) is not stated explicitly, leaving the two directives in apparent contradiction.
