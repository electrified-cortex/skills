# status — Tool Specification

## Purpose

Lightweight, read-only inbox probe. Counts unclaimed message files and reports the
pending count. Intended as a Monitor callback — fires on signal change and tells the
agent how many messages are waiting. Does not claim, read, or modify any file.

## Parameters

| Flag | Required | Description |
| --- | --- | --- |
| `--inbox` | Yes | Agent name whose inbox to check (kebab-case) |
| `--workspace` | No | Workspace root path. Defaults to `$PWD`. |
| `--help` | No | Print usage and exit zero. |

## Behavior

1. Resolve inbox path: `<workspace>/.inbox/<inbox>/`.
2. If inbox directory does not exist, count is zero.
3. Count all `*.json` files directly inside the inbox (not in subdirectories, not
   `*.json.claimed`).
4. Get current UTC time in ISO 8601 format.
5. Output exactly one line to stdout:

   ```text
   [<utc-timestamp>]: <N> messages waiting
   ```

6. Exit zero.

## Output

```text
[2026-05-08T14:30:22Z]: 5 messages waiting
[2026-05-08T14:30:22Z]: 0 messages waiting
```

Output is written even when N is zero.

## Exit Codes

| Code | Meaning |
| --- | --- |
| 0 | Normal completion |
| 1 | Missing required argument |
| 2 | Tool-level failure (filesystem inaccessible) |

## Constraints

- MUST NOT claim, read, move, or modify any file.
- MUST NOT count `.json.claimed` files or files in subdirectories.
- MUST output exactly one line — no extra newlines, no headers.
