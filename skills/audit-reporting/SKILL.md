---
name: audit-reporting
description: >-
  Convention for where and how audit skills write report files.
  Inline — apply directly. No dispatch.
---

# Audit Reporting

Output convention for agents writing audit report files. Apply when producing output from `skill-auditing`, `spec-auditing`, `tool-auditing`, or any audit skill.

Output Path:

Root fallback chain:

1. Walk up from target file until dir containing `.git/` found → repo-root
2. No `.git/` → implicit-root: immediate parent of target (single), or deepest common ancestor of all targets (batch)

Write all report files to:

```path
{root}/.audit-reports/YYYYMMDD/HHmm/
```

`YYYYMMDD`/`HHmm` = UTC at run start. All files in one run share one `audit-dir`.

Create `audit-dir` (including intermediate dirs) before writing.

Filename:

Collect all `(stem, ext)` pairs across targets before naming.

No collision → `{stem}{ext}.audit.md` (e.g. `spec.md.audit.md`)
Collision (same stem+ext in different dirs) → `{parent-dir}-{stem}{ext}.audit.md` (e.g. `code-review-spec.md.audit.md`)

Frontmatter:

Every report opens with this YAML block (no content before it):

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

```path
{audit-dir}/audit.md
```

`audit.md` contains: target paths, verdicts, relative paths to individual reports. No full prose — overview only.

.gitignore Check:

root = repo-root: verify `.audit-reports/` in `{repo-root}/.gitignore` before writing. If missing, add it.
root = implicit-root (no git): skip.

Constraints:

Never write outside `.audit-reports/`.
Never overwrite or modify prior run's files.
Use UTC only — not local wall-clock time.
`audit.md` in batch runs always written — can't be suppressed.

Related:

`skill-auditing`, `spec-auditing`, `tool-auditing`
