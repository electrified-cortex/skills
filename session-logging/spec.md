# session-logging

Companion spec for `SKILL.md`. Normative requirements for session log creation.

## Purpose

Define mandatory structure, naming, and content rules for all session log entries
written under `logs/session/` and `logs/telegram/`.

## Scope

Applies whenever an agent writes any log entry or summary during a workspace session.
Applies to both session logs and Telegram recordings. Does NOT cover log archival,
rotation, or deletion.

## Definitions

- **Session directory** — timestamped leaf folder under a log root; one per session.
- **Entry** — numbered `.md` file inside a session directory recording a discrete event.
- **Summary** — `summary.md` file capturing session-level outcomes.
- **Single exchange** — one request plus one response; shortest possible session.

## Requirements

### Directory Layout

1. Session logs MUST reside under `logs/session/YYYYMM/DD/HHmmss/`.
2. Telegram recordings MUST reside under `logs/telegram/YYYYMM/DD/HHmmss/`.
3. Each session MUST have its own unique timestamped directory.
4. `YYYYMM` MUST be a six-digit year-month (e.g., `202604`).
5. `DD` MUST be a zero-padded two-digit day.
6. `HHmmss` MUST be a zero-padded six-digit 24-hour timestamp.

### Entry Naming

7. Entries MUST be named with a two-digit sequential prefix: `01-`, `02-`, etc.
8. Prefix MUST start at `01` and increment by one with no gaps.
9. Entry filenames MUST be lowercase kebab-case with `.md` extension.
10. `summary.md` MUST NOT carry a numeric prefix.

### Summary Requirement

11. `summary.md` MUST be created for any session longer than a single exchange.
12. `summary.md` MUST contain: what was accomplished, key decisions made, follow-up tasks created.
13. `summary.md` MUST be the final file written before session close.

### What to Log

14. Agents MUST log: significant incoming messages, every decision with reasoning,
    discoveries (unexpected state, missing files, errors), and outcomes (tasks created,
    changes made, commands run).
15. Entries MUST be written as events happen — not batched at session end.

### Timing

16. First entry MUST be created at session start before any substantive work begins.
17. Agents SHALL NOT defer all logging to the end of a session.

## Parameters

- `log_root` — path to workspace log root; defaults to `logs/` in repo root.
- `session_dir` — timestamped session directory path; auto-derived from start time.
- `entry_content` — markdown body of the event being recorded.
- `entry_label` — short kebab-case descriptor for the entry filename.

## Output

- One `.md` file per event, named `NN-<label>.md`, written into `session_dir`.
- `summary.md` written into `session_dir` at session end (multi-exchange sessions).
- All output files conform to markdown-hygiene requirements.

## Constraints

1. Agents MUST NOT place log files outside the designated `logs/session/` or
   `logs/telegram/` subtrees.
2. Agents MUST NOT use a flat (non-timestamped) directory structure.
3. Agents MUST NOT omit the summary for multi-exchange sessions.
4. Entries MUST NOT be renumbered or deleted after creation.
5. This spec does NOT govern log archival, purging, or rotation — those are out of scope.
