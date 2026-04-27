# Janitor — Dispatch Instructions

## Inputs

| Input | Type | Required | Default |
| --- | --- | --- | --- |
| `mode` | string | no | `dry-run` |
| `target_root` | string | no | workspace root (dir containing `.agents/`) |
| `keep_session_logs` | integer | no | `5` |
| `keep_telegram_logs` | integer | no | `5` |
| `audit_reports_age_days` | integer | no | `14` |
| `keep_handoffs` | integer | no | `3` |
| `pattern` | string | no | _(all patterns processed)_ |

Valid `pattern` values: `logs/session`, `logs/telegram`, `audit-reports`, `handoffs`.

## Scope

Whitelist of directories the janitor may touch. Nothing outside this list is ever accessed or deleted.

| Pattern | Path shape |
| --- | --- |
| Session logs | `<target_root>/logs/session/YYYYMM/DD/HHmmss/` |
| Telegram logs | `<target_root>/logs/telegram/YYYYMM/DD/HHmmss/` |
| Audit reports | `<target_root>/.audit-reports/<target-kind>/YYYYMMDD/HHmm/` |
| Handoff files | `<target_root>/memory/handoff*.md` |

**Never touched:** `.git/`, source code, specs, skill files, `tasks/` directories, `memory/feedback_*`, `memory/project_*`, `memory/reference_*`, or any path not listed above.

## Pruning Rules

### Session logs (`logs/session/YYYYMM/DD/HHmmss/`)

1. Enumerate all leaf directories matching the `YYYYMM/DD/HHmmss` shape under `logs/session/`.
2. Sort by the date-time encoded in the path, descending (newest first).
3. Keep the first `keep_session_logs` directories.
4. For each remaining (older) directory: run `git log --oneline -- <path>`. If at least one commit references the path, it is a candidate for deletion. If zero commits reference it, preserve it (not yet committed — skip).
5. Candidates are reported in `pruned[].candidates`. In commit mode, delete each candidate directory tree sequentially.

### Telegram logs (`logs/telegram/YYYYMM/DD/HHmmss/`)

Same algorithm as session logs. Uses `keep_telegram_logs` as the keep count.

### Audit reports (`.audit-reports/<target-kind>/YYYYMMDD/HHmm/`)

1. Enumerate all leaf directories matching the `YYYYMMDD/HHmm` shape under `.audit-reports/<any-target-kind>/`.
2. Compute age in days from the `YYYYMMDD/HHmm` path components to current date/time.
3. Directories older than `audit_reports_age_days` are candidates.
4. No git-history check required.
5. Candidates are reported and deleted (in commit mode) regardless of git status.

### Handoff files (`memory/handoff*.md`)

1. Enumerate all files matching `handoff*.md` under `memory/`.
2. Sort by file mtime descending (newest first).
3. Keep the first `keep_handoffs` files.
4. For each remaining (older) file: run `git log --oneline -- <path>`. If at least one commit references the file, it is a candidate for deletion. If zero commits reference it, preserve it.
5. Candidates are reported in `pruned[].candidates`. In commit mode, delete each candidate file sequentially.

## Safety Constraints

1. Never delete any file or directory outside the Scope whitelist. Walk only the listed directories.
2. Never run automatically. This skill is operator-invoked only; no scheduling, no startup hook, no cron.
3. Default mode is `dry-run`. Commit mode requires explicit `mode: commit` input.
4. In commit mode, deletes are sequential. On the first delete failure, stop immediately; report what was successfully deleted before the failure and set `overall: error`.
5. The skill must not create, modify, or commit any file. It is read-only on everything except the scope targets it prunes.
6. No mutating git commands: no `git rm`, no `git commit`, no `git add`. Use `git log --oneline -- <path>` (read-only) to check history. Filesystem deletes only.

## Behavior

1. Resolve `target_root`. If not provided, default to the directory containing `.agents/`. If the resolved directory does not contain `.agents/`, emit `overall: error` and halt.
2. Determine which patterns to process: all four if `pattern` is omitted; only the matching pattern if `pattern` is set.
3. For each pattern in scope, compute candidates per the per-pattern rules above.
4. **Dry-run mode:** build the report. Set `deleted: []` for all pruned entries. Set `overall: dry-run`. Do not perform any deletes.
5. **Commit mode:** for each candidate across all patterns, delete sequentially (filesystem delete). On any failure: stop, set `overall: error`, include the failed path in the report.
6. On success in commit mode, set `overall: committed`.
7. Return the structured report.

## Output Format

```yaml
overall: dry-run | committed | error
pruned:
  - pattern: <one of: logs/session, logs/telegram, audit-reports, handoffs>
    candidates:
      - <path>         # matched age + pattern criterion
    deleted:
      - <path>         # actually removed (empty list in dry-run)
preserved:
  - pattern: <same pattern values>
    paths:
      - <path>         # kept, not a candidate
    reason: >-
      "newest N kept"          # within the keep count
      | "younger than threshold" # audit-reports: age < audit_reports_age_days
      | "matched protected list" # not in git history (session/telegram/handoffs)
```

In dry-run: `deleted` is always `[]`; `overall` is `dry-run`.
In commit with no errors: `deleted` lists all removed paths; `overall` is `committed`.
In commit with failure: `overall` is `error`; `deleted` lists paths removed before the failure.
