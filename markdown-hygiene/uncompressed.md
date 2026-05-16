---
name: markdown-hygiene
description: Full markdown hygiene pass on a .md file — lint fixes, MD rule scan, semantic advisory analysis. Triggers — lint markdown, fix markdown, MD violations, markdownlint pass, hygiene check.
---

# Markdown Hygiene

## Input

`<markdown_file_path>` — absolute path to the `.md` file to process.
`--ignore <RULE>[,<RULE>...]` (optional) — MD rule codes to suppress (lint only).

## 1 — Result check (report)

Run inline `result` check for `report`. See `result/SKILL.md`.

- `MISS: <abs-path>` — bind `<report_path>`. Continue.
- Otherwise: stop, return result to caller.

## 2 — Analysis

Follow `analysis/SKILL.md` with `<markdown_file_path>`.

- `ERROR: <reason>` — stop, surface reason.
- Otherwise: bind `<analysis_result>`.

Extract `<hash_A>` from `<analysis_path>`: it is the path segment immediately after `.hash-record/<shard>/` (the full 40-char SHA1).

If `<analysis_result>` is `pass: <analysis_path>` or `findings: <analysis_path>`, review the advisories in `<analysis_path>` and decide:

- Advisories are acceptable as-is → write `result: accepted` to `<analysis_path>` frontmatter. Bind `<analysis_result>` as `accepted`.
- You addressed them (edited the target file or appended `Skipped: <reason>` notes) → write `result: fixed` to `<analysis_path>` frontmatter. Bind `<analysis_result>` as `fixed`.
- Deferring to the caller — leave `<analysis_result>` as-is and proceed.

## 3 — Lint

Follow `lint/SKILL.md` with `<markdown_file_path> [--ignore <RULE>[,<RULE>...]]`.

- `ERROR: <reason>` — stop, surface reason.
- Otherwise: bind `<lint_result>`.

## 4 — Rekey

Run inline. No agent dispatch. See `hash-record/hash-record-rekey/SKILL.md`.

```bash
bash hash-record/hash-record-rekey/rekey.sh <markdown_file_path> markdown-hygiene analysis.md <hash_A>
# Windows:
pwsh hash-record/hash-record-rekey/rekey.ps1 <markdown_file_path> markdown-hygiene analysis.md <hash_A>
```

- `REKEYED:` or `CURRENT:` — ok.
- `NOT_FOUND:` — no analysis record.
- `AMBIGUOUS:` or `ERROR:` — warn (non-fatal).

## 5 — Aggregate

Derive aggregate from `<lint_result>` and `<analysis_result>`:

- `<lint_result>` starts with `findings:` → aggregate `fail`.
- `<lint_result>` is `clean`, `<analysis_result>` is `accepted` or `fixed` → aggregate `pass`.
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

Return: `clean` → `CLEAN`; `pass` → `PASS: <report_path>`.
