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
`<lint_path>` — absolute path to the existing `lint.md` from the lint phase (read-only reference).
`--ignore <RULE>[,<RULE>...]` (optional) — SA rule codes to suppress.

## Dispatch

Variables:

`<instructions>` = `instructions.txt` (this folder; NEVER READ THIS FILE)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `<markdown_file_path> --lint-path <lint_path> --analysis-path <analysis_path> [--ignore <RULE>[,<RULE>...]]`
`<tier>` = `standard`
`<description>` = `Analysis: <markdown_file_path>`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`

Follow `dispatch` skill. See `../dispatch/SKILL.md`.

Should return: `clean` | `pass: <analysis_path>` | `findings: <analysis_path>` | `ERROR: <reason>`

## Result

If `ERROR:` stop here and return the result to the caller.
Otherwise rerun the result check for `analysis`.
If that result is a `MISS: <abs-path>` then something is wrong and report it as: `ERROR: Expected analysis report at <abs-path>. None found.`
Otherwise return the result to the caller.
