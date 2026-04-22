# audit-reporting — Spec

## Purpose

Define a consistent, self-locating audit report output convention for agents running audit skills. Reports must be producible without caller input, never checked in, and identifiable by file name alone.

## Scope

Applies to any agent producing audit output via `skill-auditing`, `spec-auditing`, `tool-auditing`, or any future audit skill in this repo.

Not in scope: general log output, session logs, terminal output, non-audit report files.

## Definitions

- **repo-root**: resolved root for locating `.audit-reports/`. Preferred: directory containing `.git/`. Fallback: see R1-fallback.
- **implicit-root**: fallback root when no `.git/` is found. For a single target: immediate parent directory of the target file. For a batch run: deepest common ancestor directory of all target files.
- **audit-dir**: `{root}/.audit-reports/YYYYMMDD/HHmm/` — the output directory for one audit run. `YYYYMMDD` and `HHmm` are UTC date and time at run start. All files in one run share one audit-dir.
- **audit run**: a single invocation of an audit skill, covering one or more target files.
- **target**: file being audited.
- **target-stem**: filename without extension (e.g. `spec` from `spec.md`).
- **target-ext**: file extension including leading dot (e.g. `.md`).
- **parent-dir**: immediate parent directory name of the target file.
- **report file**: a `*.audit.md` file written during an audit run.
- **overview file**: `audit.md` written when a run covers two or more targets.
- **batch run**: an audit run covering two or more targets.
- **verdict**: outcome of an audit run. One of: `PASS`, `PASS_WITH_FINDINGS`, `NEEDS_REVISION`, `FAIL`.

## Requirements

### Output Path

R1. Agent must resolve root by walking up from the target file until a directory containing `.git/` is found.
R1-fallback. If no `.git/` is found: use implicit-root. Single target → immediate parent of target file. Batch run → deepest common ancestor of all target files.
R2. All report files must be written inside audit-dir, where `root` is repo-root (R1) or implicit-root (R1-fallback).
R3. `YYYYMMDD` and `HHmm` must reflect UTC time at the start of the audit run. All files in one run share the same audit-dir.

### Report Filename

R5. Single-target run with no collision: report file must be named `{target-stem}{target-ext}.audit.md`.
R6. Batch run where two or more targets share the same `target-stem` + `target-ext`: every colliding report file must be named `{parent-dir}-{target-stem}{target-ext}.audit.md`.
R7. Non-colliding files in a batch run may use either naming form; `{parent-dir}-` prefix is permitted but not required.

### Frontmatter

R8. Every report file must begin with a valid YAML frontmatter block containing exactly these keys:

```yaml
---
target: <path relative to repo-root>
auditor: <audit skill name>
model: <model identifier string>
timestamp: <ISO 8601 UTC datetime>
verdict: <PASS | PASS_WITH_FINDINGS | NEEDS_REVISION | FAIL>
---
```

R9. `target` must be a path relative to repo-root (not absolute, not relative to audit-dir).
R10. `auditor` must be the canonical `name` of the audit skill that produced the report.
R11. `model` must be the model identifier string as reported by the runtime. If unavailable, the value must be `"unknown"` — not omitted.
R12. `timestamp` must be ISO 8601 UTC (e.g. `2026-04-22T07:18:00Z`).
R13. `verdict` must be one of the four defined verdict values. No other values are permitted.

### Overview File

R14. Every batch run must produce an `audit.md` overview file in the same audit-dir.
R15. `audit.md` must list: each target path, its verdict, and the relative path to its report file.
R16. `audit.md` must not repeat per-file detail already present in individual report files.

### .gitignore

R17. When root is repo-root: `.audit-reports/` must be listed in the `.gitignore` at repo-root. Agent must verify this entry exists before writing any report; if missing, agent must add it.
R18. When root is implicit-root (no git repo found): `.gitignore` check is skipped.

## Constraints

C1. Report files must not be written outside `.audit-reports/`.
C2. Agents must not modify existing report files. Each audit run produces new files in a new audit-dir.
C3. `model` frontmatter key must not be omitted. Use `"unknown"` when unavailable.
C4. Overview `audit.md` must not include full audit prose — summaries and verdict table only.
C5. Absolute paths must not appear in `target` frontmatter values.

## Behavior

B1. Agent computes audit-dir at run start. All files in one run share one audit-dir.
B2. Agent resolves root by walking up from the target file until `.git/` is found (repo-root). If not found, uses implicit-root (R1-fallback).
B3. Agent collects all `(target-stem, target-ext)` pairs before naming any file. Collision check runs on the full set.
B4. Agent creates audit-dir (including any intermediate directories) before writing any report file.

## Defaults and Assumptions

- `model`: defaults to `"unknown"` if runtime does not expose it.
- Batch run: overview file is always written; cannot be suppressed.

## Error Handling

E1. audit-dir cannot be created (permissions, disk full): agent must stop and report. No partial output.

## Precedence Rules

P1. This spec governs output path and metadata. Individual audit skills govern audit content and verdict logic.
P2. Where an individual audit skill's output format conflicts with this spec's frontmatter requirements, this spec takes precedence on frontmatter; the audit skill governs content below the frontmatter block.

## Don'ts

- Must not write reports to any location other than `.audit-reports/`.
- Must not use local wall-clock time — `YYYYMMDD/HHmm` must be UTC.
- Must not omit `model` key even when value is unknown.
- Must not reuse or overwrite a prior run's audit-dir.
- Must not include full audit detail in `audit.md` — overview only.
