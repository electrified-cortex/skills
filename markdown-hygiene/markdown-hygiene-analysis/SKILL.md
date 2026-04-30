---
name: markdown-hygiene-analysis
description: Semantic advisory scan of a .md file against SA001-SA038 rules. Triggers — analysis phase, SA rules, semantic advisory, style advisories.
---

# Markdown Hygiene — Analysis

## Inputs

`<markdown_file_path>` — absolute path to the `.md` file to analyze.
`<lint_path>` — absolute path to the existing `lint.md` from the lint phase (read-only reference).
`<analysis_path>` — absolute path to write `analysis.md`.
`<report_path>` — absolute path to write `report.md` (index).
`--ignore <RULE>[,<RULE>...]` (optional) — SA rule codes to suppress.

## Dispatch

Variables:

`<instructions>` = `instructions.txt` (this folder; NEVER READ THIS FILE)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `<markdown_file_path> --lint-path <lint_path> --analysis-path <analysis_path> --report-path <report_path> [--ignore <RULE>[,<RULE>...]]`
`<tier>` = `standard`
`<description>` = `Analysis: <markdown_file_path>`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`

Follow `dispatch` skill. See `../dispatch/SKILL.md`.
Returns: `done` | `ERROR: <reason>`
