# audit-reporting — Spec

## Purpose

Define a consistent, self-locating audit report output convention. Reports must be producible without caller input, never checked in, and identifiable by file name alone.

## Scope

Applies to any agent writing audit report files.

Not in scope: general log output, session logs, terminal output, non-audit report files, target classification logic (that is the caller skill's responsibility).

## Definitions

- **repo-root**: directory containing `.git/`. Preferred root for output path resolution.
- **implicit-root**: fallback root when no `.git/` is found. For a single target: immediate parent directory of the target file.
- **audit-dir**: `{root}/.audit-reports/{target-kind}/YYYYMMDD/HHmm/` — the output directory for one audit run. `YYYYMMDD` and `HHmm` are UTC date and time at run start. All files in one run share one audit-dir.
- **target-kind**: a classifier supplied by the caller. Not derived by this skill.
- **audit run**: a single invocation of an audit skill, covering one or more target files.
- **target**: file being audited.
- **target-stem**: filename without extension (e.g. `spec` from `spec.md`).
- **target-ext**: file extension including leading dot (e.g. `.md`).
- **parent-dir**: immediate parent directory name of the target file.
- **report file**: a `*.audit.md` file written during an audit run.
- **verdict**: outcome of an audit run. One of: `PASS`, `PASS_WITH_FINDINGS`, `NEEDS_REVISION`, `FAIL`.

## Requirements

### Output Path

R1. Agent must resolve root by walking up from the target file until a directory containing `.git/` is found.
R1-fallback. If no `.git/` is found: use implicit-root — immediate parent of the target file.
R2. All report files must be written inside audit-dir, where `root` is repo-root (R1) or implicit-root (R1-fallback).
R3. `YYYYMMDD` and `HHmm` must reflect UTC time at the start of the audit run. All files in one run share the same audit-dir.

### Report Filename

R4. Single target or no collision: report file must be named `{target-stem}{target-ext}.audit.md`.
R5. Where two or more targets share the same `target-stem` + `target-ext`: every colliding report file must be named `{parent-dir}-{target-stem}{target-ext}.audit.md`.
R6. Non-colliding files in a multi-target run may use either naming form; `{parent-dir}-` prefix is permitted but not required.

### Frontmatter

R7. Every report file must begin with a valid YAML frontmatter block containing exactly these keys:

```yaml
---
target: <path relative to repo-root>
auditor: <audit skill name>
model: <model identifier string>
timestamp: <ISO 8601 UTC datetime>
verdict: <PASS | PASS_WITH_FINDINGS | NEEDS_REVISION | FAIL>
---
```

R8. `target` must be a path relative to repo-root (not absolute, not relative to audit-dir).
R9. `auditor` must be the canonical `name` of the audit skill that produced the report.
R10. `model` must be the model identifier string as reported by the runtime. If unavailable, the value must be `"unknown"` — not omitted.
R11. `timestamp` must be ISO 8601 UTC (e.g. `2026-04-22T07:18:00Z`).
R12. `verdict` must be one of the four defined verdict values. No other values are permitted.

### .gitignore

R13. When root is repo-root: `.audit-reports/` must be listed in the `.gitignore` at repo-root (the top-level entry covers all subdirectories including target-kind subfolders — do not add subpath entries). Agent must verify this entry exists before writing any report; if missing, agent must add it.
R14. When root is implicit-root (no git repo found): `.gitignore` check is skipped.

## Constraints

C1. Report files must not be written outside `.audit-reports/`.
C2. Agents must not modify existing report files. Each audit run produces new files in a new audit-dir.
C3. `model` frontmatter key must not be omitted. Use `"unknown"` when unavailable.
C4. Absolute paths must not appear in `target` frontmatter values.

## Behavior

B1. Agent computes audit-dir at run start. All files in one run share one audit-dir.
B2. Agent resolves root by walking up from the target file until `.git/` is found (repo-root). If not found, uses implicit-root (R1-fallback).
B3. Agent collects all `(target-stem, target-ext)` pairs before naming any file. Collision check runs on the full set.
B4. Agent creates audit-dir (including any intermediate directories) before writing any report file.

## Defaults and Assumptions

- `model`: defaults to `"unknown"` if runtime does not expose it.
- `target-kind`: must be provided by the caller. This skill does not derive it.

## Error Handling

E1. audit-dir cannot be created (permissions, disk full): agent must stop and report. No partial output.

## Precedence Rules

P1. This spec governs output path and metadata format only.
P2. Where an individual audit skill's output format conflicts with this spec's frontmatter requirements, this spec takes precedence on frontmatter; the audit skill governs content below the frontmatter block.

## Don'ts

- Must not write reports to any location other than `.audit-reports/`.
- Must not use local wall-clock time — `YYYYMMDD/HHmm` must be UTC.
- Must not omit `model` key even when value is unknown.
- Must not reuse or overwrite a prior run's audit-dir.
- Must not derive `target-kind` — that is the caller skill's responsibility.
