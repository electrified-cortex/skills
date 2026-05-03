# markdown-hygiene-analysis — Specification

## Purpose

Semantic advisory scan of a `.md` file against SA001–SA038 rules. Reads the existing `lint.md` from the lint phase, evaluates all SA rules, and writes `analysis.md` (advisory findings). The host aggregates `lint.md` and `analysis.md` into `report.md`. Do not modify the target file.

## Model Tier

Sonnet-class or GPT-5.4 (`standard`). Semantic reasoning required — SA rules involve understanding intent, instruction quality, and document structure.

## Inputs

`<markdown_file_path>` (positional, required) — absolute path to the `.md` file to analyze.

`--lint-path <lint_path>` (required) — absolute path to the existing `lint.md` from the lint phase. Missing → `ERROR: --lint-path required`, stop.

`--analysis-path <analysis_path>` (required) — absolute path to write `analysis.md`. Missing → `ERROR: --analysis-path required`, stop.

`--ignore <RULE>[,<RULE>...]` (optional) — SA rule codes to suppress for this run.

## Procedure

1. **Read `<lint_path>`** — extract `result` field (`clean` or `fail`) and count FINDINGS entries.
2. **Evaluate SA001–SA038** — read `<markdown_file_path>` and apply every SA rule. Skip rules in `--ignore`. SA032 and SA038 are LLM-detected; flag only when clearly and unambiguously evident.
3. **Determine result** from lint_result and advisory count (see Result Logic).
4. If `<analysis_path>` already exists, overwrite it.
5. **Return** `clean` (no advisories, lint clean), `pass: <analysis_path>` (advisories present, lint clean), or `findings: <analysis_path>` (lint fail).

## SA Rule Reference

SA001–SA038 are defined in the parent skill's `spec.md` (markdown-hygiene/spec.md). Severities: `FAIL`, `WARN`, `SUGGEST`. SA032 and SA038 require LLM-detected semantic reasoning.

## Result Logic

These result values are set by the **executor** (the analysis sub-skill). The host may later transition the result to `accepted` or `fixed` without re-running the executor — see Host-Driven Transitions below.

| lint_result | advisory_severity | result |
| ----------- | ----------------- | ------ |
| `fail` | any | `fail` |
| `clean` | any FAIL | `fail` |
| `clean` | WARN/SUGGEST only | `pass` |
| `clean` | none | `clean` |

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

`clean` — lint clean, no advisories.
`pass: <analysis_path>` — lint clean, WARN/SUGGEST advisories present.
`findings: <analysis_path>` — lint fail or FAIL-severity advisory found.
`ERROR: <reason>` — on any failure.

## Host-Driven Transitions

After the executor writes `analysis.md`, the host may update the `result:` field directly without re-running the executor:

- `accepted` — host reviewed advisories and considers them acceptable. No changes to the target file. Write `result: accepted` to `analysis.md`.
- `fixed` — host reviewed advisories AND made changes (applied a fix to the target file, or appended "Skipped: <reason>" notes to `analysis.md`). Write `result: fixed` to `analysis.md`.

Both transitions signal to the iteration loop that analysis is settled — no re-dispatch needed.

**Analysis independence rule:** The executor MUST NOT be re-dispatched after a lint-only fix pass. Lint fixes (spacing, blank lines, heading levels, etc.) cannot affect SA advisory results. After a `fixed:` return from the combined fix agent, carry the existing `analysis.md` forward into the next aggregate step.

## Constraints

- Hard prohibition: do NOT author scripts (`.ps1`, `.sh`, etc.) or write any file other than `<analysis_path>`.
- Do not write to `<markdown_file_path>`.
- Use `Note:` (not `Fix:`) for advisory entries — observations only; the host decides whether to act.
