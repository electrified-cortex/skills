---
name: markdown-hygiene-analysis
description: Semantic advisory scan of a .md file against SA001-SA038 rules. Triggers — analysis phase, SA rules, semantic advisory, style advisories.
---

# Markdown Hygiene — Analysis

## Cached Result check (analysis)

Run inline result check for `analysis`. See `../markdown-hygiene-result/SKILL.md`.

- `MISS: <abs-path>` — bind `<analysis_path>`. Jump to Dispatch.
- Otherwise: stop here, return result to caller.

## Inputs

`<markdown_file_path>` — absolute path to the `.md` file to analyze.

## Dispatch

Variables:

`<instructions>` = `instructions.txt` (this folder; NEVER READ THIS FILE)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `<markdown_file_path> --analysis-path <analysis_path>`
`<tier>` = `standard` = needs higher reasoning to interpret SA rules and apply them to the content.
`<description>` = `Markdown Hygiene Analysis: <markdown_file_path>`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`
Optional (if available): `<model-override>` = `GPT-5.4` fallback to no override if this fails.

Follow `dispatch` skill. See `../../dispatch/SKILL.md`.

Should return: `clean` | `pass: <analysis_path>` | `ERROR: <reason>`

## Result

If `ERROR:` stop here and return the result to the caller.
Otherwise rerun the result check for `analysis`.
If that result is a `MISS: <abs-path>` then something is wrong and report it as: `ERROR: Expected analysis report at <abs-path>. None found.`
Otherwise return the result to the caller.

If `clean`, return the result to the caller and stop here.

Otherwise consider reading the analysis report and decide with the caller (agent/operator) whether to apply any fixes or log skipped advisories with reasons in the final report.

To fix, `dispatch` a sub-agent with this report as input instructing it to fix all the issues.
Then follow this skill again, keep track of the number of revision rounds.

If not planning to fix or it has been 3 iterations, stop here and surface the report.
