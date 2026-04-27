# Model identifiers

Canonical `--model-id` values for skills that record per-model results in `.hash-record/`. Vendor + class only — sub-version is intentionally omitted so cache stays valid across minor model bumps.

| Model class | `--model-id` value |
| --- | --- |
| Claude Haiku | `claude-haiku` |
| Claude Sonnet | `claude-sonnet` |
| Claude Opus | `claude-opus` |
| GPT codex | `gpt-codex` |

Pass the value verbatim. The executor uses it as the record filename and the frontmatter `model:` field — no inference, no appending date/year/timestamp/sub-version.

If a major-version bump materially changes a skill's behavior (rare for mechanical skills like markdown-hygiene), invalidate the affected records by deleting them — the next run regenerates with the new behavior under the same model-id key.
