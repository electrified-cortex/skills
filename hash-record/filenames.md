# Filename categories

Canonical `--filename` values for skills that record results in `.hash-record/`. Callers control the filename; executors use it verbatim as the record filename. Vendor + class only — sub-version is intentionally omitted so cache stays valid across minor model bumps.

| Category | Filename |
| --- | --- |
| Claude Haiku | `claude-haiku` |
| Claude Sonnet | `claude-sonnet` |
| Claude Opus | `claude-opus` |
| GPT codex | `gpt-codex` |

Pass the value verbatim. No inference, no appending date/year/timestamp/sub-version.

If a major-version bump materially changes a skill's behavior (rare for mechanical skills like markdown-hygiene), invalidate the affected records by deleting them — the next run regenerates with the new behavior under the same filename key.
