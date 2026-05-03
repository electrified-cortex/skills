# hash-record-rekey — Script Specification

## Purpose

A shell tool that re-keys a stale hash-record entry after a source file's
content changes. When lint or other formatting operations change a file's
bytes (even whitespace-only), its git blob hash changes and the existing
hash-record entry is stranded under the old hash. This tool finds the
stranded entry and moves it to the correct new hash path via `git mv`.

## Use case

Phase 4A (re-sign path) of the sealing strategy: after a formatting pass
changes a file, re-key the audit record to the new blob hash so it is
discoverable by `hash-record-check` under the new hash, without requiring
a full re-audit.

## Parameters

| Positional | Type | Required | Description |
| --- | --- | --- | --- |
| `file_path` | string | yes | Absolute path to the changed file (new content, not yet committed). |
| `op_kind` | string | yes | Operation kind, e.g. `markdown-hygiene` or `skill-auditing/v2`. May contain `/`. |
| `record_filename` | string | yes | Leaf filename, e.g. `claude-haiku.md`. No path separators. |

All three positional arguments are required.

## Flags

- `--help` / `-h`: print usage synopsis to stdout, exit 0.

## Procedure

1. Validate arguments: reject missing args, path traversal (`..`) or
   backslash in `op_kind`, path separators or `..` in `record_filename`.

2. Resolve repo root from `file_path` via
   `git -C $(dirname <file_path>) rev-parse --show-toplevel`.
   Fall back to `dirname(file_path)` with a stderr WARN if not in a repo.

3. Compute new blob hash: `git hash-object <file_path>`.

4. Scan `.hash-record/` recursively for a file matching the pattern
   `*/<op_kind>/<record_filename>`. Collect all matches.

5. Dispatch on match count:
   - 0 matches → `NOT_FOUND: no record for <op_kind>/<record_filename>`, exit 0.
   - >1 matches → `AMBIGUOUS: <n> records found -- manual resolution required`, exit 1.
   - Exactly 1 match → extract old hash from the matching path, continue.

6. If old hash == new hash:
   emit `CURRENT: <abs_path>`, exit 0 (no-op).

7. If old hash ≠ new hash:
   - Construct new path: `.hash-record/<new_shard>/<new_hash>/<op_kind>/<record_filename>`.
   - Create parent directory (`mkdir -p` equivalent).
   - Run `git -C <repo_root> mv <old_rel_path> <new_rel_path>`.
   - On success: emit `REKEYED: <new_abs_path>`, exit 0.
   - On git mv failure: emit `ERROR: git mv failed: <old> -> <new>`, exit 1.

## Output contract

| Output | Exit | Meaning |
| --- | --- | --- |
| `REKEYED: <abs-path>` | 0 | Record moved. New path returned. |
| `CURRENT: <abs-path>` | 0 | Hash unchanged. No move. |
| `NOT_FOUND: no record for <op_kind>/<record_filename>` | 0 | No matching record. |
| `AMBIGUOUS: <n> records found -- manual resolution required` | 1 | >1 matches; caller must resolve manually. |
| `ERROR: <reason>` | 1 | Argument or runtime error. |

One line on stdout, LF terminated. Forward slashes in all paths, every platform.

WARN lines go to stderr only.

## Scanning behaviour

Scans all shard directories under `.hash-record/`. Matches path suffix
`/<op_kind>/<record_filename>` (not just the filename alone). If `op_kind`
contains `/` (e.g. `skill-auditing/v2`), the match must include the full
nested path.

## Move semantics

Moves the individual record file (not the hash directory). Creates the
target parent directory before moving. Leaves the old hash directory
in place if other records remain there; git will prune the empty directory
at commit time if no other records are present.

## Language implementations

Both `rekey.sh` (Bash) and `rekey.ps1` (PowerShell 7+) are provided and
produce byte-identical stdout for the same inputs. Windows PowerShell 5.1
is not supported.

## Constraints

- Read-only access to the source file (only `git hash-object` is called on it).
- No sub-dispatches; fully self-contained.
- `op_kind` MUST NOT contain `..` or `\`.
- `record_filename` MUST NOT contain `..`, `/`, or `\`.
- Forward-slash output on every platform.
- No interactive prompts.
- Does NOT update the record's frontmatter `hash:` field — it only moves
  the file. Consumers that need frontmatter sync must handle that separately.

## Dependencies

- `git` on PATH.
- PowerShell 7+ for the `.ps1` variant.
- The file at `file_path` must be readable.
