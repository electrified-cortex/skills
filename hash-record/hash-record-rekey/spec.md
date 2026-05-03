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

## Folder/manifest mode (extension, 2026-05-03)

### Motivation

The per-file mode above requires the caller to know `op_kind` and
`record_filename` for the record being rekeyed. After a sealing chain
(skill-optimize → skill-audit → spec-audit → tool-audit → hygiene
analysis → hygiene lint), many records exist across many op_kinds, and
the caller may not know which op_kinds were touched. Folder/manifest
mode lets the caller hand the tool a directory and say "rekey
everything in scope."

This is the closer step of the sealing strategy
(`skill-auditing/sealing-strategy.spec.md`). Run BEFORE
`hash-record-prune`.

### Invocation

When called with a single positional argument that resolves to an
existing **directory** (not a file), the tool enters folder mode.

| Positional | Type | Required | Description |
| --- | --- | --- | --- |
| `folder_path` | string | yes | Absolute path to the target directory (sealing-target scope). |

Flags:

- `--include <glob>`: optional. Restrict scope to files matching the
  glob (relative to `folder_path`). Repeatable. Default: all files.
- `--exclude <glob>`: optional. Skip files matching the glob.
  Repeatable. Default: none.
- `--dry-run`: optional. Report what would be rekeyed without making
  changes. No `git mv`, no filesystem mutation.
- `--manifests`: optional, default `true`. Include manifest files in
  the rekey pass. When `false`, only direct hash-record entries are
  rekeyed.
- `--help` / `-h`: as in per-file mode.

### Discovery

For each file under `folder_path` (filtered by include/exclude):

1. Compute the file's current git blob hash (`git hash-object`).
2. Scan `.hash-record/` recursively for any entry whose path indicates
   it was keyed against this file's PRIOR hash. Heuristic: scan all
   record entries; for each, check whether the record body or
   frontmatter `path:` field references the file. (Implementation may
   maintain an index for performance.)
3. Collect every `(record_path, recorded_hash, op_kind, record_filename)`
   tuple referencing the file.
4. **If `--manifests` is true**, also scan manifest files (output of
   `hash-record-manifest`) for entries referencing the file. Collect
   their entries for rekey.

### Rekey rule

For each discovered record/manifest-entry:

- If `recorded_hash == file_current_hash`: `CURRENT` (no action).
- If `recorded_hash != file_current_hash`:
  - Run the per-file rekey logic (§ Procedure above) for this record.
  - For manifest entries: update the manifest file's entry in place
    (rewrite the JSON/markdown line) to the current hash. Stage the
    manifest file via `git add` after editing.

### Safety guard — semantic vs whitespace

Folder/manifest mode does NOT distinguish whitespace-only from semantic
changes. It assumes the caller has decided the rekey is safe (typically
because hygiene lint just ran and produced whitespace-only diffs). If
the caller has unknown content drift, run a content audit first; do not
use folder mode as a blanket "make everything green" hammer.

This guard mirrors the per-file caller's responsibility — the per-file
tool also blindly rekeys without inspecting diff semantics. Folder mode
inherits that contract.

### Output contract — folder mode

Per-record line on stdout (one per discovered record/manifest entry):

| Output | Meaning |
| --- | --- |
| `REKEYED: <abs-path>` | Record moved to new hash. |
| `CURRENT: <abs-path>` | Hash unchanged. No move. |
| `MANIFEST_UPDATED: <manifest-path>:<entry-id>` | Manifest entry rewritten. |
| `NOT_FOUND: no record for <file-rel-path>` | File has no records. |
| `ERROR: <reason>` | Per-record failure (e.g. git mv failed). |

After all records, a summary line:

`SUMMARY: rekeyed=<n> current=<n> manifest_updated=<n> not_found=<n> errors=<n>`

Exit codes:

- `0`: all rekeys succeeded (or `--dry-run` completed without errors).
- `1`: any per-record `ERROR` occurred (after attempting the rest).
- `2`: invocation error (bad path, conflicting flags).

### Idempotency requirement

After a successful folder-mode rekey:

- Running the same folder-mode rekey again MUST produce 100% `CURRENT`
  + `MANIFEST_UPDATED-no-change` lines (no `REKEYED`).
- Re-running any of the upstream operations
  (skill-audit, spec-audit, tool-audit, hygiene) on the same folder
  MUST hit cache (operation's executor sees a record with current hash
  and short-circuits).

This is the operator-defined acceptance test for the sealing strategy.
Implementation MUST verify this via integration test before being
considered complete.

### Order constraint

Folder-mode rekey runs BEFORE `hash-record-prune`. Pruning before
rekeying would delete records the rekey is trying to preserve (the
records still match a file in the folder, just under a stale hash).
The strategy doc (`sealing-strategy.spec.md`) restates this constraint.

### Out of scope (folder mode)

- Re-executing any of the upstream operations. Folder mode rekeys; it
  does not audit, lint, or analyze.
- Resolving content-drift conflicts (semantic vs whitespace
  classification). Caller's responsibility.
- Deleting orphaned records (that's `hash-record-prune`'s job, run
  AFTER folder mode).
- Cross-folder rekey (records referencing files outside `folder_path`
  are ignored).
