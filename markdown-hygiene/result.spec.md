# result.spec.md - markdown-hygiene result tool

## Purpose

Wraps `hash-record-check` for `markdown-hygiene` and translates a HIT into the cached verdict. Host calls `result` to read the on-disk record state — at cache-check time AND at post-execute validation time. Same script, same return shape, both calls.

Read-only.

## Parameters

`<markdown_file_path>` (positional, required) — absolute path to the `.md` file.

`--help` / `-h` — print usage, exit 0.

## Procedure

1. Invoke `hash-record-check` with `<markdown_file_path> markdown-hygiene report.md` (sibling tool — do NOT reimplement).
2. Branch on its stdout:
   - `MISS: <abs-path>` -> emit `MISS: <abs-path>`, exit 0.
   - `ERROR: <reason>` -> emit `ERROR: <reason>`, exit 1.
   - `HIT: <abs-path>` -> read frontmatter `result:`:
     - `pass` -> emit `CLEAN`, exit 0.
     - `findings` -> emit `findings: <abs-path>`, exit 0.
     - other -> emit `ERROR: malformed cache record at <abs-path>`, exit 1.

## Output contract

| Condition          | Output                  | Exit |
| ------------------ | ----------------------- | ---- |
| HIT pass           | `CLEAN`                 | 0    |
| HIT findings       | `findings: <abs-path>`  | 0    |
| MISS               | `MISS: <abs-path>`      | 0    |
| Error              | `ERROR: <reason>`       | 1    |

Forward-slash paths, ASCII, LF terminator.

## Constraints

- Read-only.
- Frontmatter parsing is line-based (`^result:` line, first whitespace-separated token after `:`).
- Both `result.sh` (Bash) and `result.ps1` (PowerShell 7+); byte-identical stdout.

## Dependencies

`hash-record-check` (sibling at `../hash-record/hash-record-check/`).
