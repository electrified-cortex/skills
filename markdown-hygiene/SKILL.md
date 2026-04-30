---
name: markdown-hygiene
description: Full markdown hygiene pass on a .md file — lint fixes, MD rule scan, semantic advisory analysis. Triggers — lint markdown, fix markdown, MD violations, markdownlint pass, hygiene check.
---

## Input

`<markdown_file_path>` — absolute path to the `.md` file to process.
`--ignore <RULE>[,<RULE>...]` (optional) — MD or SA rule codes to suppress across all phases.

## Step 1 — Result check (report)

Run inline result check for `report`. See `markdown-hygiene-result/SKILL.md`.

- `MISS: <abs-path>` — bind `<report_path>`. Jump to Step 2.
- Otherwise: stop here, result to caller.

## Step 2 — Preparation

If a markdown linter is available, run auto-fix on `<markdown_file_path>`. Re-run the result check for `report`.

- `MISS: <abs-path>` — rebind `<report_path>`. Continue.
- Otherwise: stop here, result to caller.

## Step 3 — Result check (lint)

Run inline result check for `lint`. See `markdown-hygiene-result/SKILL.md`.

- `clean: <lint_path>` or `findings: <lint_path>` — bind `<lint_path>`, skip to Step 5.
- `MISS: <abs-path>` — bind `<lint_path>`, run Phase 1 (Step 4).

## Step 4 — Phase 1: Lint

Dispatch `markdown-hygiene-lint`. See `markdown-hygiene-lint/SKILL.md`.

Input: `<markdown_file_path> --lint-path <lint_path> [--ignore <RULE>[,<RULE>...]]`

On return, run `result lint` again:

- `clean: <lint_path>` or `findings: <lint_path>` — bind confirmed `<lint_path>`. Continue to Step 5.
- `ERROR: <reason>` — stop, surface reason.

## Step 5 — Result check (analysis)

Run inline result check for `analysis`. See `markdown-hygiene-result/SKILL.md`.

- `clean: <analysis_path>`, `pass: <analysis_path>`, or `findings: <analysis_path>` — bind `<analysis_path>`, skip to Step 7.
- `MISS: <abs-path>` — bind `<analysis_path>`, run Phase 2 (Step 6).

## Step 6 — Phase 2: Analysis

Dispatch `markdown-hygiene-analysis`. See `markdown-hygiene-analysis/SKILL.md`.

Input: `<markdown_file_path> --lint-path <lint_path> --analysis-path <analysis_path> [--ignore <RULE>[,<RULE>...]]`

Analysis executor writes `analysis.md`. It does NOT write `report.md`.

- `clean: <analysis_path>`, `pass: <analysis_path>`, or `findings: <analysis_path>` — continue to Step 7.
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
- `pass` — stop. Surface `<analysis_path>` to caller.
- `fail` — dispatch fix pass targeting findings, then restart from Step 2. If this is the 3rd fail iteration, stop and return `findings: <report_path>` instead.

## Step 9 — Prune

Run `hash-record-prune` with `repo_root=<repo_root> --target <repo-relative-path>` where `<repo-relative-path>` is `<markdown_file_path>` stripped of the repo root prefix.

This removes orphaned hash directories for the target file accumulated across iterations.
