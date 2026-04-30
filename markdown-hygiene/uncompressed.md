---
name: markdown-hygiene
description: Full markdown hygiene pass on a .md file — lint fixes, MD rule scan, semantic advisory analysis. Triggers — lint markdown, fix markdown, MD violations, markdownlint pass, hygiene check.
---

# Markdown Hygiene

## Input

`<markdown_file_path>` — absolute path to the `.md` file to process.
`--ignore <RULE>[,<RULE>...]` (optional) — MD or SA rule codes to suppress across all phases.

## Step 1 — Result check (report)

Run inline result check for `report`. See `markdown-hygiene-result/SKILL.md`.

- `CLEAN` — stop, already clean.
- `pass: <abs-path>` — stop, surface path to user.
- `findings: <abs-path>` — stop, surface path to user.
- `MISS: <abs-path>` — bind `<report_path>`. Derive siblings:
  - `<lint_path>` = dirname(`<report_path>`) + `/lint.md`
  - `<analysis_path>` = dirname(`<report_path>`) + `/analysis.md`
  - Continue. Do NOT use these paths yet — lint will modify the file and the hash will change.

## Step 2 — Preparation

If a markdown linter is available, run auto-fix on `<markdown_file_path>`. Re-run the result check for `report`. On 2nd MISS, continue.

## Step 3 — Result check (lint)

Run inline result check for `lint`. See `markdown-hygiene-result/SKILL.md`.

- `clean: <lint_path>` or `findings: <lint_path>` — bind `<lint_path>`, skip to Step 5.
- `MISS` — run Phase 1 (Step 4).

## Step 4 — Phase 1: Lint

Dispatch `markdown-hygiene-lint`. See `markdown-hygiene-lint/SKILL.md`.

Input: `<markdown_file_path> --lint-path <lint_path> [--ignore <RULE>[,<RULE>...]]`

- `clean` or `findings: <lint_path>` — continue to Step 5.
- `ERROR: <reason>` — stop, surface reason.

## Step 5 — Result check (analysis)

Run inline result check for `analysis`. See `markdown-hygiene-result/SKILL.md`.

- `clean: <analysis_path>`, `pass: <analysis_path>`, or `findings: <analysis_path>` — bind `<analysis_path>`, skip to Step 7.
- `MISS` — run Phase 2 (Step 6).

## Step 6 — Phase 2: Analysis

Dispatch `markdown-hygiene-analysis`. See `markdown-hygiene-analysis/SKILL.md`.

Input: `<markdown_file_path> --lint-path <lint_path> --analysis-path <analysis_path> [--ignore <RULE>[,<RULE>...]]`

Analysis executor writes `analysis.md`. It does NOT write `report.md`.

- `clean`, `pass: <analysis_path>`, or `findings: <analysis_path>` — continue to Step 7.
- `ERROR: <reason>` — stop, surface reason.

## Step 7 — Host aggregate

Read `lint.md` and `analysis.md` results. Derive aggregate:

- Either is `fail` → aggregate `fail`.
- Lint `clean`, analysis `pass` → aggregate `pass`.
- Both `clean` → aggregate `clean`.

Write `report.md` at `<report_path>`: frontmatter `operation_kind: markdown-hygiene`, aggregate result, refs to `lint.md` and `analysis.md`.

## Step 8 — Iteration check

Read `report.md` result.

- `clean` — stop.
- `pass` — stop. Surface `<analysis_path>` to the user.
- `fail` — dispatch fix pass targeting findings, then restart from Step 2. If this is the 3rd fail iteration, stop and return `findings: <report_path>` instead.
