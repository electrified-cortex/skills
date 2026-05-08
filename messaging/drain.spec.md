# drain — Tool Specification

## Purpose

Collect all unclaimed messages from an agent's inbox. Claims each file exclusively,
reads it, archives it, and outputs the content to stdout. Returns all pending messages
in a single invocation.

## Parameters

| Flag | Required | Description |
|---|---|---|
| `--inbox` | Yes | Agent name whose inbox to drain (kebab-case) |
| `--workspace` | No | Workspace root path. Defaults to `$PWD`. |
| `--help` | No | Print usage and exit zero. |

## Behavior

1. Resolve inbox path: `<workspace>/.inbox/<inbox>/`.
2. If inbox directory does not exist, exit zero (nothing to drain).
3. Enumerate all `*.json` files directly inside the inbox (not in subdirectories).
   Sort ascending by filename (lexicographic).
4. For each file:
   a. Attempt atomic rename from `<name>.json` to `<name>.json.claimed`.
   b. If rename fails (file gone or already claimed), skip silently.
   c. If rename succeeds, read the full file content.
   d. Move claimed file to `<workspace>/.inbox/<inbox>/archive/<name>.json`.
   e. Collect the JSON object into a result list.
5. If a file cannot be read after claiming, write error to stderr and move to archive
   regardless. Continue to next file.
6. Output a JSON array of all collected message objects to stdout.
7. Exit zero when sweep is complete.

## Output

A JSON array of message objects, one per message, in ascending timestamp order:

```json
[
  {"from":"sender","to":"recipient","sent":"2026-05-08T14:30:22Z","subject":"Hello","body":"Body text here."}
]
```

An empty inbox outputs `[]`.

## Exit Codes

| Code | Meaning |
|---|---|
| 0 | Sweep complete (including empty inbox or partial skips) |
| 1 | Missing required argument |
| 2 | Tool-level failure (inbox inaccessible, archive dir not creatable) |

## Constraints

- MUST drain own inbox only — but this is a caller convention, not enforced by the tool.
- MUST NOT delete files — archive is the only terminal state.
- MUST NOT halt on a single bad file — log to stderr, archive, continue.
- Claimed files (`.json.claimed`) left over from a crashed prior run are treated as
  unarchived messages: drain picks them up by listing `*.json.claimed` after the `*.json`
  pass and archives them without re-outputting.
