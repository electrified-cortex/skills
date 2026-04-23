---
name: session-logging
description: Standards for creating session log entries in logs/session/ and logs/telegram/. Use when writing any log entry or summary during a cortex.lan session.
---

# Session Logging

Log every interaction, decision, discovery, and outcome. If it's not written down, it didn't happen.

## Directory Layout

- Session logs: `logs/session/YYYYMM/DD/HHmmss/`
- Telegram recordings: `logs/telegram/YYYYMM/DD/HHmmss/`

Each session gets its own timestamped directory.

## Entry Naming

Number entries sequentially with two-digit prefix so they sort correctly:

```text
01-session-start.md
02-message-received.md
03-decision.md
...
summary.md
```

## Summary Requirement

`summary.md` required for any session longer than a single exchange. Capture:

- What was accomplished
- Key decisions made
- Follow-up tasks created

## Log as You Go

For long sessions, log as events happen. Don't wait until the end — waiting risks losing detail.

## What to Log

- Significant incoming messages and requests
- Every decision and the reasoning behind it
- Discoveries: unexpected state, missing files, errors
- Outcomes: tasks created, changes made, commands run
