# Janitor Specification

## Purpose

Define a skill that prunes accumulated maintenance artifacts — old session logs, stale audit-report snapshots, superseded handoff files — that other skills create but never delete. Other lifecycle skills are intentionally delete-free; the janitor is the single exception, with conservative scope and explicit operator invocation.

## Scope

Applies to fleet-internal maintenance directories that hold point-in-time artifacts:

- `logs/session/YYYYMM/DD/HHmmss/` — session conversation logs.
- `logs/telegram/YYYYMM/DD/HHmmss/` — telegram dump archives.
- `.audit-reports/<target-kind>/YYYYMMDD/HHmm/` — audit-pass outputs (per `audit-reporting` SKILL).
- `memory/handoff*.md` — old handoff snapshots when superseded and in git history.

Does NOT touch:

- Source code, specs, skill files, or anything under `.git/`.
- `tasks/` directories (drafts, queued, active, done — those are archive-managed by the task engine).
- `memory/feedback_*`, `memory/project_*`, `memory/reference_*` — durable memory entries.
- Anything not explicitly listed in Scope above. The whitelist is the boundary.

## Definitions

- **Janitor**: this skill. Runs on operator demand only.
- **Pruneable artifact**: a file or directory matching one of the Scope patterns AND satisfying the per-pattern age threshold.
- **Age threshold**: the minimum age (in days, or count-from-newest) below which an artifact is preserved. Per-pattern.
- **Dry-run**: preview mode that reports what would be deleted without actually deleting.
- **Commit**: actual delete mode. Never the default.

## Requirements

### Inputs

| Input | Required | Description |
| --- | --- | --- |
| `mode` | no | `dry-run` (default) or `commit`. Dry-run reports what would be deleted; commit performs the deletes. |
| `target_root` | optional | Root to scan from. Default: workspace root (the directory containing `.agents/`). |
| `keep_session_logs` | optional | Number of newest session-log directories to keep. Default: 5. |
| `keep_telegram_logs` | optional | Number of newest telegram-log directories to keep. Default: 5. |
| `audit_reports_age_days` | optional | Audit-report directories older than this many days are pruneable. Default: 14. |
| `keep_handoffs` | optional | Number of newest handoff files to keep in `memory/`. Default: 3. |
| `pattern` | optional | When set, prune only artifacts matching this Scope pattern (e.g., `logs/session`, `audit-reports`, `handoffs`). When omitted, all patterns are processed. |

### Output

```yaml
overall: dry-run | committed | error
pruned:
  - pattern: <one of the Scope patterns>
    candidates: <list of paths that matched age + pattern>
    deleted: <list of paths actually deleted; empty in dry-run>
preserved:
  - pattern: <pattern>
    paths: <list of preserved paths within pattern>
    reason: <"newest N kept" | "younger than threshold" | "matched protected list">
```

In dry-run mode, `deleted` is always `[]` and `committed` is never used as the overall verdict. In commit mode, `deleted` lists the actual paths removed, and `overall` is `committed` (or `error` if any delete failed mid-run).

### Pruning Rules (per pattern)

**Session logs** (`logs/session/YYYYMM/DD/HHmmss/`):

- Sort directories by date descending.
- Keep the newest `keep_session_logs` (default 5).
- Older directories are candidates for deletion ONLY IF the directory is verified to exist in git history (run `git log --oneline -- <path>` and confirm at least one commit references it). Directories not yet in git are preserved regardless of age.

**Telegram logs** (`logs/telegram/YYYYMM/DD/HHmmss/`):

- Same algorithm as session logs. `keep_telegram_logs` default 5.

**Audit reports** (`.audit-reports/<target-kind>/YYYYMMDD/HHmm/`):

- Compute directory age from `YYYYMMDD/HHmm` parts.
- Directories older than `audit_reports_age_days` (default 14) are candidates.
- Audit reports are point-in-time snapshots; they do NOT need to be in git history to be pruned. Operator-stated: audit reports should not be committed.

**Handoff files** (`memory/handoff*.md`):

- Sort by mtime descending.
- Keep newest `keep_handoffs` (default 3).
- Older handoffs are candidates ONLY IF they are committed to git history. Uncommitted handoffs are preserved.

### Safety Constraints

1. The janitor must never delete files outside the Scope patterns. Implementation must walk only the listed directories.
2. The janitor must never run automatically. Operator invocation is the sole trigger.
3. Default mode is `dry-run`. Commit mode requires explicit `mode: commit` input.
4. In commit mode, deletes must be sequential and the run must fail-fast on the first delete error (do not continue after a failed delete; report what was deleted before the failure).
5. The skill must not create, modify, or commit any file (read-only on everything except the targets it prunes).
6. The skill must not invoke `git` commands that mutate state (no `git rm`, no `git commit`). Filesystem deletes only — git history is the source of truth, the working tree is the target.

## Behavior

When invoked:

1. Resolve `target_root` (default cwd if it contains `.agents/`; otherwise error).
2. For each pattern in scope (or only `pattern` if specified): compute candidates per the per-pattern rules.
3. In dry-run: build the report; do not delete.
4. In commit: delete each candidate sequentially. On any failure, stop and report.
5. Return the structured report.

## Don'ts

- Don't run automatically (no scheduling, no cron, no startup hook).
- Don't widen the scope beyond the Scope patterns above. Scope is normative.
- Don't delete in dry-run mode (default).
- Don't continue past a failed delete in commit mode.
- Don't touch `.git/`, source code, specs, skills, or task directories.
- Don't tombstone — actually delete. Tombstones are the anti-pattern this skill exists to avoid.
- Don't implement filesystem walking in the skill body — defer to standard tools (`find`, `Get-ChildItem`).

## Relationship to Other Skills

- **iteration-safety**: governs re-pass behavior. Janitor is excluded — janitor's idempotent in dry-run, destructive in commit. Re-running after a commit is a no-op (already pruned).
- **audit-reporting**: produces audit reports the janitor prunes. Audit-reporting must keep producing reports without concern for cleanup.
- **All other skills**: stay delete-free. Janitor is the single owner of cleanup.

## Iteration Safety

Janitor is exempt from iteration-safety: dry-run is idempotent (no state change); commit is one-shot (subsequent runs find nothing to prune). Re-pass on unchanged target is naturally a no-op in commit mode and a duplicate report in dry-run mode.
