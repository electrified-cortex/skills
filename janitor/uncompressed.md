---
name: janitor
description: >-
  prune accumulated artifacts, session-log hygiene, audit-report sweep,
  handoff cleanup, dry-run delete preview, operator-invoked maintenance
---

# Janitor

Dispatch (zero context): 'Read and follow `instructions.txt` (in this directory). Input: `[mode=dry-run|commit] [target_root=<path>] [keep_session_logs=N] [keep_telegram_logs=N] [audit_reports_age_days=N] [keep_handoffs=N] [pattern=<scope-pattern>]`'

`mode` (optional): `dry-run` (default) or `commit` — preview vs. execute deletions
`target_root` (optional): absolute path to prune root; defaults to workspace root
`keep_session_logs` (optional): number of session logs to retain; default `5`
`keep_telegram_logs` (optional): number of Telegram logs to retain; default `5`
`audit_reports_age_days` (optional): age threshold for pruning audit reports; default `14`
`keep_handoffs` (optional): number of handoff files to retain; default `3`
`pattern` (optional): scope filter; defaults to all patterns

Returns: structured YAML report — overall status, pruned entries (pattern/candidates/deleted), preserved entries (pattern/paths/reason).
