# Markdown Hygiene

## Inputs

`<markdown_file_path>` (required) — absolute path to the `.md` file.
`--report-path <report_path>` (required) — absolute path to write the report. Missing -> `ERROR: --report-path required`, stop. Existing file at `<report_path>` is overwritten.
`--ignore <RULE>[,<RULE>...]` (optional) — rules to skip.

## Procedure

**Hard prohibition:** do NOT author scripts (`.ps1`, `.sh`, `.py`, etc.), helper files, or any file other than `<report_path>`. The target file is read-only. Use Read/Bash/Grep only for inspection.

1. **Run verify**, whichever your runtime has:
   - Bash: `bash <skill-dir>/verify.sh <markdown_file_path> [--ignore <RULE>[,<RULE>...]]`
   - PS7: `pwsh <skill-dir>/verify.ps1 <markdown_file_path> [-Ignore <RULE>[,<RULE>...]]`

   Verify lists every rule it determined and the result. Take its output and include it in the report findings. You (LLM) are responsible for everything verify did not determine — covered in step 2.
2. **Scan** `<markdown_file_path>` for the remaining rules. Read the file (Read tool) and apply rule-knowledge from step 3. Cross-check each finding against the actual line; drop any you cannot point at on a verified line. Skip rules in `--ignore`. Cover every rule in step 3, including all four table rules (MD055/MD056/MD058/MD060).
3. **Reference rule list** (use to compose `Fix:` imperatives for rules verify did not determine):

   - MD001 — heading levels increment by one (H1 to H3 violates).
   - MD003 — heading style consistent (atx `#` vs setext `===`/`---`).
   - MD004 — list markers consistent (`-`, `*`, `+`).
   - MD022 — headings need blank before AND after (except start/end).
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
   - MD055 — table pipe style consistent across rows.
   - MD056 — all rows in a table same number of cells.
   - MD058 — tables need blanks before AND after.
   - MD060 — table cell separators need a space on each side of the dash run.
4. **Write report** at `<report_path>` (overwrite if present):
   - `mkdir -p $(dirname <report_path>)` first.
   - Frontmatter (open `---`, close `---`):
     - `file_path: <repo-relative path>` — repo-relative, NOT absolute. Compute via `git ls-files --full-name <markdown_file_path>` or strip `<repo_root>/` from the absolute path.
     - `operation_kind: markdown-hygiene`
     - `result: pass` (no violations) or `result: findings` (violations)
   - Body:
     - No violations: `# Result\n\nCLEAN`.
     - Violations: `# Result\n\nFINDINGS\n\n- <list>`. Each entry is two lines:
       - `MD0XX line N: <description>`
       - Indented `Fix: <imperative instruction>` — complete, standalone, byte-precise.
5. **Return** the literal string `done`. On any failure, return `ERROR: <reason>`.

## Report Format

Record body always opens with `# Result` H1.

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
- MD058 line 23: table missing blank line before
  Fix: insert blank line before line 23
- MD056 line 31: table row 3 has 4 cells, table has 3 columns
  Fix: split or remove the extra cell on line 31; ensure all rows have 3 cells
```

Each entry is two lines: the finding line (`MD0XX line N: <description>`), then an indented `Fix:` line.

### Fix line philosophy

The `Fix:` line is a complete, standalone imperative applied verbatim by a downstream agent with no markdown-rule knowledge. Two tests: would a human applying only the `Fix:` line (without the finding line, without the rule code) produce a correct result? Would two different agents produce identical edits?

Bad: `Fix: fix the table` — ambiguous.
Bad: `Fix: enforce MD058` — assumes rule knowledge.
Good: `Fix: insert blank line before line 23` — explicit, byte-precise.
Good: `Fix: split the cell on line 31 into two cells; ensure all rows have exactly 3 cells` — explicit, no rule knowledge needed.

### Table fix examples

Tables (MD055/MD056/MD058/MD060) are high-frequency violators agents often miscorrect.

```text
- MD058 line 23: table missing blank line before
  Fix: insert blank line before line 23

- MD058 line 28: table missing blank line after
  Fix: insert blank line after line 27 (between the last table row and the next non-blank line)

- MD056 line 31: table row 3 has 4 cells, header declares 3 columns
  Fix: examine line 31; either remove the trailing extra cell to make it 3 cells, or, if the cell is intentional, add a 4th column to the header on line 28 and the separator on line 29

- MD055 line 30: table separator uses ":---:" (centered) but header on line 28 is left-aligned
  Fix: change line 30 separator to `| --- | --- | --- |` to match left-aligned header style; OR change the header's alignment style consistently

- MD060 line 29: table separator uses `|---|---|---|` (no spaces)
  Fix: replace line 29 with `| --- | --- | --- |` — exactly one space on each side of every dash run
```

Every table `Fix:` line names the exact column count, the exact separator format, or the exact line numbers. Generic instructions will fail the apply test.
