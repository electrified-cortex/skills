---
name: audit-reporting
description: >-
  Convention for where and how audit skills write report files.
  Inline — apply directly. No dispatch.
---

# Audit Reporting

Standard output convention for any agent writing audit report files.

## Output Path

Resolve root using this fallback chain:

1. Walk up from the target file until a directory containing `.git/` is found → **repo-root**
2. No `.git/` found → **implicit-root**: immediate parent of target file

Write all report files to:

```path
{root}/.audit-reports/{target-kind}/YYYYMMDD/HHmm/
```

This is the **audit-dir**: computed once at run start; all files in one run share it. `target-kind` is a classifier supplied by the caller. `YYYYMMDD`/`HHmm` = UTC at run start.

Create audit-dir (including intermediate dirs) before writing any file.

## Filename

Collect all `(stem, ext)` pairs across all targets before naming any file.

- No collision → `{stem}{ext}.audit.md` (e.g. `spec.md.audit.md`)
- Collision (same stem+ext in different dirs) → `{parent-dir}-{stem}{ext}.audit.md` (e.g. `code-review-spec.md.audit.md`)

## Frontmatter

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
`auditor` — canonical `name` frontmatter of the audit skill.
`model` — runtime model string. Never omit; use `"unknown"` if unavailable.
`verdict` — exactly one of the four values above.

## .gitignore Check

When root is repo-root: verify `.audit-reports/` is in `{repo-root}/.gitignore` before writing. If missing, add it. The top-level `.audit-reports/` entry covers all subdirectories including target-kind subfolders — do not add subpath entries.
When root is implicit-root (no git): skip this check.

## Constraints

- Never write outside `.audit-reports/`.
- Never overwrite or modify a prior run's files.
- Use UTC only — not local wall-clock time.
