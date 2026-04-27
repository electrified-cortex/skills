---
name: audit-reporting
description: >-
  Convention for where and how audit skills write report files.
  Inline — apply directly. No dispatch.
---

# Audit Reporting

Output convention for agents writing audit report files. Apply for `skill-auditing`, `spec-auditing`, `tool-auditing`, or any audit skill.

Output Path:
Resolve `repo-root`: walk up from target file until dir containing `.git/` found. If not found, stop — report failure, write nothing.

Write all report files to:

```
{repo-root}/.audit-reports/YYYYMMDD/HHmm/
```

`YYYYMMDD` and `HHmm` must be UTC at audit run start. All files in one run share one `audit-dir`.

If dir already exists (same-minute re-run), append `-2`, `-3`, etc. to `HHmm` (e.g. `0718-2/`).

Create `audit-dir` (including intermediate dirs) before writing any file.

Filename:
Collect all `(stem, ext)` pairs across targets before naming any file.

No collision → `{stem}{ext}.audit.md` (e.g. `spec.md.audit.md`)
Collision (same stem+ext in different dirs) → `{parent-dir}-{stem}{ext}.audit.md` (e.g. `code-review-spec.md.audit.md`)

Frontmatter:
Every report file must open with this YAML block (no content before it):

```yaml
---
target: <path relative to repo-root>
auditor: <audit skill name>
model: <model identifier string, or "unknown">
timestamp: <ISO 8601 UTC, e.g. 2026-04-22T07:18:00Z>
verdict: <PASS | PASS_WITH_FINDINGS | NEEDS_REVISION | FAIL>
---
```

`target` — relative to repo-root, not absolute, not relative to audit-dir.
`auditor` — canonical `name` frontmatter of audit skill.
`model` — runtime model string. Never omit; use `"unknown"` if unavailable.
`verdict` — exactly one of four values above.

Batch Run (2+ targets):
Also write `audit.md` in same `audit-dir`:

```
{audit-dir}/audit.md
```

`audit.md` contains: target paths, verdicts, relative paths to individual reports. No prose — overview only.

.gitignore Check:
Before writing any file, verify `.audit-reports/` is in `{repo-root}/.gitignore`. If missing, add it.

Constraints:
Never write outside `.audit-reports/`.
Never overwrite or modify a prior run's files.
Use UTC only — not local wall-clock time.
`audit.md` in batch runs always written — can't be suppressed.

Related:
`skill-auditing`, `spec-auditing`, `tool-auditing`
