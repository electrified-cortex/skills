---
file_path: gh-cli/gh-cli-actions/SKILL.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 53: `stdin` in plain prose without backtick
  Note: The phrase "pipe from stdin or use env var" uses `stdin` as an unformatted token; stream names are code literals by convention.

- SA010 [WARN] line 64: `stdin` in plain prose without backtick
  Note: "or stdin prompts interactively" repeats the same unformatted use in a second prose sentence.

- SA014 [SUGGEST] line 53: "never" in directive sentence is unemphasized
  Note: The constraint "never pass as CLI arg" carries no visual weight; in an instruction document it risks being skimmed.

- SA014 [SUGGEST] line 64: "Always" at start of directive sentence is unemphasized
  Note: "Always pipe or use `--body` in automated contexts" opens with a strong imperative that is not visually distinguished from surrounding prose.

- SA038 [FAIL]: Contradictory instructions regarding secret value delivery
  Note: Line 53 states "never pass as CLI arg" for secret values, yet line 57 shows `gh secret set MY_SECRET --body "value"` (the value is a CLI argument), and line 64 explicitly endorses this with "Always pipe or use `--body`"; the absolute prohibition and the endorsed pattern are in direct conflict.
