# markdown-hygiene-result — Specification

## Purpose

Wraps `hash-record-check` for `markdown-hygiene` and translates a HIT into the cached verdict for a named sub-document. The host dispatches this sub-skill to probe the cache before running any executor phase — and again after execution to read back the result. Read-only.

## Parameters

`<markdown_file_path>` (positional, required) — absolute path to the `.md` file.

`<filename>` (positional, required) — sub-document to probe, e.g. `report`, `lint`, `analysis`. The script appends `.md` to form the record filename passed to `hash-record-check`.

`--help` / `-h` — print usage, exit 0.

## Procedure

1. Invoke `hash-record-check` with `<markdown_file_path> markdown-hygiene <filename>.md`.
2. Branch on its stdout:
   - `MISS: <abs-path>` → emit `MISS: <abs-path>`, exit 0.
   - `ERROR: <reason>` → emit `ERROR: <reason>`, exit 1.
   - `HIT: <abs-path>` → read frontmatter `result:` and translate per the Output Contract below.

## Output Contract

HIT translation depends on the `result:` value in the cached record's frontmatter:

| `result:` value | Output |
| --- | --- |
| `clean` | `clean: <abs-path>` |
| `fail` | `findings: <abs-path>` |
| `pass` | `pass: <abs-path>` |
| other | `ERROR: malformed cache record at <abs-path>` |

Special case: `report` records with `result: clean` emit `CLEAN` (no path) for host ergonomics.

| Condition | Output | Exit |
| --- | --- | --- |
| HIT — result: clean (`report` filename) | `CLEAN` | 0 |
| HIT — result: clean (other filename) | `clean: <abs-path>` | 0 |
| HIT — result: fail | `findings: <abs-path>` | 0 |
| HIT — result: pass | `pass: <abs-path>` | 0 |
| MISS | `MISS: <abs-path>` | 0 |
| Missing filename | `ERROR: missing filename argument` | 1 |
| Other error | `ERROR: <reason>` | 1 |

Forward-slash paths, ASCII, LF terminator. One line on stdout, always.

## Constraints

- Read-only. No file writes.
- Frontmatter parsing is line-based (`^result:` line, first whitespace-separated token after `:`).
- Both `result.sh` (Bash) and `result.ps1` (PowerShell 7+) must produce byte-identical stdout.
- `<filename>` is a bare name with no path separators or `.md` extension — validated before use.

## Dependencies

`hash-record-check` at `../../hash-record/hash-record-check/` relative to this sub-skill folder.
