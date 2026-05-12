# Markdown Hygiene — Lint Executor

## Constraints

Hard prohibition: do NOT author scripts, helper files, or any file other than `<lint_path>`. Use Read/Bash/Grep tools only for inspection.

## Procedure

1. **Run local lint tool** — `lint.sh` / `lint.ps1` co-located in this folder. Fixes MD009, MD012, MD047 in-place. Always runs — no availability check.
   - Bash: `bash <skill-dir>/lint.sh <markdown_file_path>`
   - PS7: `pwsh <skill-dir>/lint.ps1 <markdown_file_path>`

2. **Run installed linter** — if the runtime already has a markdown linter available, run its auto-fix pass on `<markdown_file_path>`. Do not install one if absent. Ignore MD041 warnings if the target is a `SKILL.md`. Best-effort.

3. **Run result check (`lint` filename)** — the file was modified; get the updated hash location.
   - Bash: `bash <skill-dir>/../markdown-hygiene-result/result.sh <markdown_file_path> lint`
   - PS7: `pwsh <skill-dir>/../markdown-hygiene-result/result.ps1 <markdown_file_path> lint`
   - `MISS: <abs-path>` → rebind `<lint_path>` = `<abs-path>`, continue.
   - Anything else → return that output verbatim, stop.

4. **Run verify** — `verify.sh` / `verify.ps1` co-located in this folder. Covers MD010, MD041 (MD009, MD012, MD047 already fixed by lint tool).
   - Bash: `bash <skill-dir>/verify.sh <markdown_file_path> [--ignore <RULE>[,<RULE>...]]`
   - PS7: `pwsh <skill-dir>/verify.ps1 <markdown_file_path> [-Ignore <RULE>[,<RULE>...]]`
   Include its output in findings. Do not re-check covered rules unless verify was skipped or errored.

5. **Scan** `<markdown_file_path>` for remaining MD rules. Apply rule-knowledge from the reference below. Cross-check every suspected finding against the actual line — drop any not pointable to a verified line. Hallucinated findings are worse than missed findings. Skip rules in `--ignore`.

   **Adaptive MD041 suppression:** if the first non-blank line is `---` (YAML frontmatter), drop MD041 regardless of `--ignore`.

6. **Write `<lint_path>`** (overwrite if present):
   - `mkdir -p $(dirname <lint_path>)` first.
   - Frontmatter (`---` open/close):
     - `file_path: <repo-relative path>` — via `git ls-files --full-name <markdown_file_path>` or strip `<repo_root>/`.
     - `operation_kind: markdown-hygiene-lint`
     - `result: clean` (no violations) or `result: fail` (violations present).
   - Body — no violations: `# Result\n\nCLEAN`.
   - Body — violations: `# Result\n\nFINDINGS\n\n- <list>`. Each entry two lines:
     - `MD0XX line N: <description>`
     - Indented `Fix: <imperative>` — complete, standalone, byte-precise.

7. **Return** `clean` or `findings: <lint_path>`. On failure: `ERROR: <reason>`.

## MD Rule Reference

- MD001 — heading levels increment by one.
- MD003 — heading style consistent (atx `#` vs setext).
- MD004 — list markers consistent (`-`, `*`, `+`).
- MD010 — hard tabs in non-code content (covered by verify).
- MD022 — headings need blank line before AND after (except file start/end).
- MD023 — headings must not have leading whitespace.
- MD024 — duplicate heading text among siblings.
- MD025 — only one H1 per file.
- MD026 — headings must not end with `.`, `!`, `?`, `:`, `,`, `;`.
- MD029 — ordered list prefixes consistent.
- MD031 — fenced code blocks need blanks before AND after.
- MD032 — lists need blanks before AND after.
- MD033 — no inline HTML outside fenced blocks.
- MD034 — bare URLs (not in angle brackets, backticks, or links).
- MD040 — fenced code blocks need a language identifier.
- MD041 — first non-blank line must be H1 (suppressed for frontmatter; covered by verify).
- MD047 — file must end with exactly one newline. Fixed by lint tool — verify it ran; don't re-scan.
- MD055 — table pipe style consistent across rows.
- MD056 — all rows in a table have the same number of cells.
- MD058 — tables need blanks before AND after.
- MD060 — table cell separators need space on each side of dash run (`| --- |` not `|---|`).
- MD060-PAD — table cell alignment padding: data row cells must not contain extra spaces for visual column alignment (e.g. `| error   |` must be `| error |`). Each cell must have exactly one space between each pipe and its content. LLMs produce this habitually when generating tables. Scan every data row; strip padding to single-space on each side.
- MONO-ESCAPE — backslash-backtick (`` \` ``) inside inline code spans — breaks Markdown rendering (HIGH, not FAIL). Fix: use double-backtick fence (`` `` text with `backtick` `` ``) instead of single-backtick with backslash-escape.

## Output Format

CLEAN:

```text
# Result

CLEAN
```

FINDINGS:

```text
# Result

FINDINGS

- MD022 line 7: blank line missing before heading "Configuration"
  Fix: insert blank line before line 7
- MD047: file lacks trailing newline
  Fix: append a single newline at end of file
```
