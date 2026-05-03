# markdown-hygiene-analysis — Specification

## Purpose

Semantic advisory scan of a `.md` file against SA001–SA038 rules. Evaluates all SA rules and writes `analysis.md` (advisory findings). The host receives the result and aggregates it with lint output into `report.md`. Does not modify the target file.

## Scope

Applies when a semantic advisory scan is needed on a single `.md` file. Covers SA001–SA038 only. Does not cover MD rule violations (handled by `markdown-hygiene-lint`). Does not modify the target file. Independent of lint output — the host orchestrates sequencing.

## Definitions

- **Advisory**: A semantic finding from an SA rule. Unlike MD violations, advisories are observations; the host decides whether to act.
- **Executor**: The dispatched agent that runs the scan and writes `analysis.md`.
- **Host**: The caller of this sub-skill (typically the parent `markdown-hygiene` skill).
- **analysis.md**: The output record written by the executor containing advisory findings and result frontmatter.
- **accepted**: Host-set result — advisories reviewed and accepted as-is.
- **fixed**: Host-set result — advisories reviewed and addressed (file edited or skipped with reason).

## Requirements

1. The executor **must** evaluate SA001–SA038 rules against `<markdown_file_path>`. Rules in `--ignore` **must** be skipped.
2. SA032 and SA038 **must** only be flagged when clearly and unambiguously evident — LLM-detected semantic reasoning applies.
3. The executor **must** write `analysis.md` at `<analysis_path>`. If the file already exists it **must** be overwritten.
4. The executor **must** return `clean`, `pass: <analysis_path>`, or `findings: <analysis_path>` based on advisory count and severity only. It **must not** receive or evaluate lint output.
5. The executor **must not** modify `<markdown_file_path>`.
6. The executor **must not** author scripts or write any file other than `<analysis_path>`.
7. Advisory entries **must** use `Note:` (not `Fix:`) — observations only; the host decides whether to act.
8. The host **may** transition `result:` in `analysis.md` to `accepted` or `fixed` without re-dispatching the executor.
9. The executor **must not** be re-dispatched after a lint-only fix pass (analysis independence rule).

## Model Tier

Sonnet-class (`standard`). Semantic reasoning required — SA rules involve understanding intent, instruction quality, and document structure.

## Inputs

`<markdown_file_path>` (positional, required) — absolute path to the `.md` file to analyze.

`--analysis-path <analysis_path>` (required) — absolute path to write `analysis.md`. Missing → `ERROR: --analysis-path required`, stop.

`--ignore <RULE>[,<RULE>...]` (optional) — SA rule codes to suppress for this run.

## Procedure

1. **Evaluate SA001–SA038** — read `<markdown_file_path>` and apply every SA rule. Skip rules in `--ignore`. SA032 and SA038 are LLM-detected; flag only when clearly and unambiguously evident.
2. **Determine result** from advisory severity (see Result Logic).
3. If `<analysis_path>` already exists, overwrite it.
4. **Return** `clean` (no advisories), `pass: <analysis_path>` (WARN/SUGGEST advisories only), or `findings: <analysis_path>` (any FAIL-severity advisory).

## SA Rule Reference

SA001–SA038 are defined in the parent skill's `spec.md` (markdown-hygiene/spec.md). Severities: `FAIL`, `WARN`, `SUGGEST`. SA032 and SA038 require LLM-detected semantic reasoning.

## Result Logic

These result values are set by the **executor**. The host may later transition the result to `accepted` or `fixed` without re-running the executor — see Host-Driven Transitions below.

| advisory_severity | result |
| ----------------- | ------ |
| any FAIL | `findings` |
| WARN/SUGGEST only | `pass` |
| none | `clean` |

## Output Contract

All output is written to `<analysis_path>`. The host writes `report.md` — this executor only writes `analysis.md`.

### analysis.md frontmatter

```yaml
file_path: <repo-relative path>
operation_kind: markdown-hygiene-analysis
result: clean | pass | fail | accepted | fixed
```

`clean`, `pass`, `fail` — set by the executor.
`accepted`, `fixed` — set by the host (see Host-Driven Transitions).

### analysis.md body — CLEAN

```text
# Result

CLEAN
```

### analysis.md body — with advisories

```text
# Result

## Advisory

- SA014 [SUGGEST] line 22: "never" unemphasized in instruction document
  Note: consider bold or ALL CAPS to strengthen the constraint signal
- SA035 [WARN] line 47: action stated before gate condition
  Note: move "if the flag is set" to the front of the sentence
```

Each finding is exactly two lines: SA line, then indented `Note:` line (observation, not imperative).

### Return value

`clean` — no advisories.
`pass: <analysis_path>` — WARN/SUGGEST advisories present, none at FAIL severity.
`findings: <analysis_path>` — one or more FAIL-severity advisories found.
`ERROR: <reason>` — on any failure.

## Host-Driven Transitions

After the executor writes `analysis.md`, the host may update the `result:` field directly without re-running the executor:

- `accepted` — host reviewed advisories and considers them acceptable. No changes to the target file. Write `result: accepted` to `analysis.md`.
- `fixed` — host reviewed advisories AND made changes (applied a fix to the target file, or appended "Skipped: <reason>" notes to `analysis.md`). Write `result: fixed` to `analysis.md`.

Both transitions signal to the iteration loop that analysis is settled — no re-dispatch needed.

**Analysis independence rule:** The executor MUST NOT be re-dispatched after a lint-only fix pass. Lint fixes (spacing, blank lines, heading levels, etc.) cannot affect SA advisory results. After a lint-only fix pass, carry the existing `analysis.md` forward into the next aggregate step without re-running analysis.

## Constraints

- Hard prohibition: do NOT author scripts (`.ps1`, `.sh`, etc.) or write any file other than `<analysis_path>`.
- Do not write to `<markdown_file_path>`.
- Use `Note:` (not `Fix:`) for advisory entries — observations only; the host decides whether to act.
