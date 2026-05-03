---
name: markdown-hygiene
description: Full markdown hygiene pass on a .md file — lint fixes, MD rule scan, semantic advisory analysis. Triggers — lint markdown, fix markdown, MD violations, markdownlint pass, hygiene check.
---

# Markdown Hygiene

If attempting to lint multiple files, read `parallel-strategy.md` to help optimize; otherwise continue.

## Input

`<markdown_file_path>` — absolute path to the `.md` file to process.
`--ignore <RULE>[,<RULE>...]` (optional) — MD rule codes to suppress (lint only).

## Step 1 — Result check (report)

Run inline `markdown-hygiene-result` check for `report`. See `markdown-hygiene-result/SKILL.md`.

- `MISS: <abs-path>` — bind `<report_path>`. Continue.
- Otherwise: stop here, return result to caller.

## Step 2 — Analysis

Follow `markdown-hygiene-analysis/SKILL.md` with `<markdown_file_path>`.

- `ERROR: <reason>` — stop, surface reason.
- Otherwise: bind `<analysis_result>`.

## Step 3 — Lint

Follow `markdown-hygiene-lint/SKILL.md` with `<markdown_file_path> [--ignore <RULE>[,<RULE>...]]`.

- `ERROR: <reason>` — stop, surface reason.
- Otherwise: bind `<lint_result>`.

## Step 4 — Aggregate

Derive aggregate from `<lint_result>` and `<analysis_result>`:

- `<lint_result>` starts with `findings:` → aggregate `fail`.
- `<lint_result>` is `clean`, `<analysis_result>` starts with `pass:` → aggregate `pass`.
- Both `clean` → aggregate `clean`.

Write `report.md` at `<report_path>`:

Frontmatter: `operation_kind: markdown-hygiene`, `result: <aggregate>`, `file_path: <repo-relative-path>`. No absolute paths.

Body:

```md
# Result

lint: `<lint_result>`
analysis: `<analysis_result>`
```

Where `<lint_result>` and `<analysis_result>` are the bare return values (`clean`, `findings: lint.md`, `pass: analysis.md`) using repo-relative paths only.

## Step 5 — Prune

Run `hash-record-prune` with `repo_root=<repo_root> --target <repo-relative-path>` where `<repo-relative-path>` is `<markdown_file_path>` stripped of the repo root prefix.

This removes orphaned hash directories for the target file accumulated across iterations.

Return based on last `report.md` result: `clean` → `CLEAN`; `pass` → `pass: <report_path>`.
