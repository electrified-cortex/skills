# Analysis

FINDINGS

## MD060 — Table Column Style (7 violations)

markdownlint reports 7 MD060/table-column-style violations in `tool-auditing/result.spec.md`.

### Affected tables

**`## Parameters` table (line 11)**
- Extra space to the left of a pipe — compact style mismatch.

**`## Output contract` table (lines 60-64)**
- Pipes do not align with header row — aligned style mismatch.
- Affects rows describing PASS, PASS_WITH_FINDINGS, FAIL, MISS, and ERROR conditions.

### Impact

Visual inconsistency only; no semantic issues. The table data and output contract are correct
and complete. MD060 violations do not affect meaning or parseability for most renderers.

### Fix

Reformat both tables so pipe characters align. Use a Markdown table formatter to normalize
spacing across all columns.
