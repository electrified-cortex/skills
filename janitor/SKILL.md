---
name: janitor
description: >-
  prune accumulated artifacts, session-log hygiene, audit-report sweep,
  handoff cleanup, dry-run delete preview, operator-invoked maintenance
---

Dispatch (zero context): Read and follow `instructions.txt` (in this directory). Input: `[mode=dry-run|commit] [target_root=<path>] [keep_session_logs=N] [keep_telegram_logs=N] [audit_reports_age_days=N] [keep_handoffs=N] [pattern=<scope-pattern>]`

`mode`: `dry-run` (default) or `commit` — preview vs. execute deletions
`target_root`: prune root; defaults to workspace root
`keep_session_logs`: session logs to retain; default `5`
`keep_telegram_logs`: Telegram logs to retain; default `5`
`audit_reports_age_days`: age threshold for audit reports; default `14`
`keep_handoffs`: handoff files to retain; default `3`
`pattern`: scope filter; all if omitted

Returns: YAML report — overall status, pruned (pattern/candidates/deleted), preserved (pattern/paths/reason).

Related: `iteration-safety`, `audit-reporting`, `session-logging`
