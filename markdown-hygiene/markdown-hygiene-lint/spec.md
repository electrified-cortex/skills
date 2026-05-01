# markdown-hygiene-lint — Specification

## Purpose

Deterministic scan of a `.md` file for MD rule violations. Runs a two-step preparation pass before scanning: the co-located `lint` tool unconditionally auto-fixes known safe rules, followed by any installed markdown linter for a broader auto-fix pass. Writes `lint.md` at the host-specified path with imperative `Fix:` instructions per finding. Preparation always modifies the target file; the scan pass then reads the post-fix file.

## Model Tier

Haiku-class (`fast-cheap`). No semantic reasoning — deterministic pattern-matching only.

## Inputs

`<markdown_file_path>` (positional, required) — absolute path to the `.md` file to scan.

`--lint-path <lint_path>` (optional) — absolute path to write `lint.md`. If omitted, derived in step 3 via result check.

`--ignore <RULE>[,<RULE>...]` (optional) — comma-separated rule codes to suppress for this run.

## Procedure

1. **Run local lint tool** — `lint.sh` / `lint.ps1` co-located in this sub-skill folder. Fixes MD009, MD012, MD047 in-place. Unconditional — always runs, no availability check.
2. **Run installed linter** — if the runtime already has a markdown linter available, run its auto-fix pass on `<markdown_file_path>`. If absent, **do not** install one. If the target file is a `SKILL.md`, ignore MD041 warnings. Best-effort.
3. **Re-run result check (`lint` mode)** — the file was modified by preparation; the hash has changed. Re-probe the cache to get the updated path. Branch on stdout:
   - `HIT: ...` → return that result verbatim to the caller, stop. The content was already scanned.
   - `MISS: <abs-path>` → bind as `<lint_path>` (replaces any previously bound value). Continue.
4. **Run verify** — `verify.sh` / `verify.ps1` co-located in this sub-skill folder. Detects MD009, MD010, MD012, MD041, MD047. Include its output in findings; **do not** re-check covered rules unless verify was skipped or errored.
5. **Scan** — read `<markdown_file_path>` and apply rule-knowledge for all remaining MD rules. Cross-check every suspected finding against the actual line; drop any not pointable to a verified line. Hallucinated findings are worse than missed findings.
6. **Adaptive MD041 suppression** — if the first non-blank line of the file is `---` (YAML frontmatter), suppress MD041 regardless of `--ignore`.
7. **Write `<lint_path>`** — if present, overwrite.
8. **Return** `clean` (no violations) or `findings: <lint_path>` (violations present).

## MD Rule Reference

| Rule | Description |
| --- | --- |
| MD001 | Heading levels increment by one |
| MD003 | Heading style consistent (atx vs setext) |
| MD004 | List markers consistent (`-`, `*`, `+`) |
| MD009 | Trailing spaces (covered by verify) |
| MD010 | Hard tabs outside fenced blocks (covered by verify) |
| MD012 | Multiple consecutive blank lines (covered by verify) |
| MD022 | Headings need blank line before AND after (except file start/end) |
| MD023 | Headings must not have leading whitespace |
| MD024 | Duplicate heading text among siblings |
| MD025 | Only one H1 per file |
| MD026 | Headings must not end with `.`, `!`, `?`, `:`, `,`, `;` |
| MD029 | Ordered list prefixes consistent |
| MD031 | Fenced code blocks need blank lines before AND after |
| MD032 | Lists need blank lines before AND after |
| MD033 | No inline HTML outside fenced blocks |
| MD034 | Bare URLs (not in angle brackets, backticks, or links) |
| MD040 | Fenced code blocks need a language identifier |
| MD041 | First non-blank line must be H1 (suppressed for frontmatter; covered by verify) |
| MD047 | File must end with exactly one newline (covered by verify) |
| MD055 | Table pipe style consistent across rows |
| MD056 | All rows in a table have the same number of cells |
| MD058 | Tables need blank lines before AND after |
| MD060 | Table cell separators need space on each side of dash run |

## Verify Scripts

`verify.sh` / `verify.ps1` are co-located in this sub-skill folder. They are deterministic shell scripts — no external packages required. They cover MD009, MD010, MD012, MD041, MD047. See `verify.spec.md` for full interface and output format.

## Output Contract

### lint.md frontmatter

```yaml
file_path: <repo-relative path>
operation_kind: markdown-hygiene-lint
result: clean | fail
```

### lint.md body — CLEAN

```text
# Result

CLEAN
```

### lint.md body — FINDINGS

```text
# Result

FINDINGS

- MD022 line 7: blank line missing before heading "Configuration"
  Fix: insert blank line before line 7
- MD047: file lacks trailing newline
  Fix: append a single newline at end of file
```

Each finding is exactly two lines: rule line, then indented `Fix:` line.

### Return value

`clean` — no violations found.
`findings: <lint_path>` — one or more violations present.
`ERROR: <reason>` — on any failure.

## Constraints

- Hard prohibition: do NOT author scripts (`.ps1`, `.sh`, etc.) or write any file other than `<lint_path>`.
- This executor must not modify the target file. Preparation auto-fix is the only permitted modification.
- Haiku-class: no semantic reasoning. Drop any finding you cannot verify against a specific line.
