# hash-record-rekey — Script Specification

## Purpose

A shell tool that re-keys a stale hash-record entry after a source file's
content changes. When lint or other formatting operations change a file's
bytes (even whitespace-only), its git blob hash changes and the existing
hash-record entry is stranded under the old hash. This tool finds the
stranded entry and moves it to the correct new hash path via `git mv`.

## Scope

This tool applies to the Phase 4A (re-sign path) step of the sealing
strategy: after a formatting pass changes a file, re-key the audit record
to the new blob hash so it is discoverable by `hash-record-check` under
the new hash, without requiring a full re-audit.

**Appropriate use:**

- A file's content changed due to whitespace-only or formatting operations
  (lint, hygiene, prettify) and its existing hash-record entry is now stale.
- A caller knows the specific `op_kind` and `record_filename` and wants to
  rekey a single record (per-file mode).
- A caller has a directory of changed files and wants to rekey all affected
  records in bulk (folder/manifest mode).

**Out of scope:**

- Re-executing the originating audit or lint operation.
- Resolving content-drift conflicts (semantic vs whitespace classification) —
  that is the caller's responsibility.
- Deleting orphaned records (that is `hash-record-prune`'s job, run AFTER
  this tool).
- Cross-folder rekey: records referencing files outside the target directory
  are ignored in folder mode.
- Records for files that have not changed (hash unchanged → `CURRENT`, no-op).

## Definitions

- **content hash**: The git blob hash (`git hash-object`) of a file's current
  on-disk bytes. Used as the directory key under `.hash-record/`.
- **op_kind**: Operation kind — a string identifying the audit or analysis
  operation that produced the record (e.g. `markdown-hygiene`,
  `skill-auditing/v2`). May contain `/` for namespaced operations; must not
  contain `..` or `\`.
- **shard**: The first two characters of the content hash, used as the first
  path segment under `.hash-record/` (e.g. `.hash-record/ab/`). Sharding
  keeps directory sizes manageable.
- **record**: A file stored at `.hash-record/<shard>/<hash>/<op_kind>/<record_filename>`.
  The path encodes the content hash of the source file at the time the audit
  ran.
- **stale entry**: A record whose path encodes an old content hash that no
  longer matches the source file's current bytes. Rekey moves it to the
  current hash path.
- **manifest hash**: For multi-file records, the canonical directory key is
  the hash of (sorted file paths + their current git hashes combined), not
  any individual member file's blob hash.
- **record_filename**: The leaf filename of a record file (e.g. `claude-haiku.md`).
  Must not contain `..`, `/`, or `\`.
- **git mv**: The git command used to rename/move a file and stage that rename
  in the index in a single operation. Rekey uses `git mv` (not plain `mv`) so
  the move is immediately staged and history is preserved.

## Requirements

1. **Argument validation**: All three positional arguments (`file_path`,
   `op_kind`, `record_filename`) are required in per-file mode. Missing
   arguments must produce an `ERROR` line on stdout and exit 1. `op_kind`
   must not contain `..` or `\`. `record_filename` must not contain `..`,
   `/`, or `\`. Path traversal attempts must be rejected. The optional
   `source_hash` positional argument, when supplied, must be a valid
   40-character lowercase hex string; an invalid value must produce an
   `ERROR` line and exit 1.

2. **Output format contract**: Each per-file invocation emits exactly one
   line on stdout, LF-terminated, with a keyword prefix (`REKEYED`,
   `CURRENT`, `NOT_FOUND`, `AMBIGUOUS`, or `ERROR`). All paths in output
   use forward slashes on every platform. WARN lines go to stderr only and
   must not appear on stdout.

3. **Exit codes**: Exit 0 on success (including `NOT_FOUND` and `CURRENT`
   outcomes). Exit 1 on any error or `AMBIGUOUS` match. In folder mode,
   exit 0 if all rekeys succeeded; exit 1 if any per-record `ERROR`
   occurred; exit 2 for invocation errors (bad path, conflicting flags).

4. **Git-state requirements**: The tool must resolve the repo root via
   `git -C $(dirname <file_path>) rev-parse --show-toplevel`. If the file is
   not in a git repo, fall back to `dirname(file_path)` with a stderr WARN.
   Each `git mv` must be preceded by a git-state smoke check: untracked and
   staged files proceed; committed-clean files proceed; modified-but-unstaged
   files surface a warning and are not silently absorbed.

5. **Idempotency requirement**: After a successful rekey pass, running the
   same rekey again on the same inputs must produce 100% `CURRENT` (or
   `MANIFEST_UPDATED-no-change`) lines with no `REKEYED` lines. This is
   the operator-defined acceptance test. Implementation must verify via
   integration test before being considered complete.

6. **Folder-mode behavior**: When the single positional argument resolves to
   an existing directory, the tool enters folder mode. It must detect changed
   files via `git status`, build a rekey set (changed files + referencing
   manifests), stage the rekey set via `git add`, apply `git mv` moves,
   perform a diff verification pass, and emit per-record lines plus a final
   `SUMMARY:` line. Folder mode runs before `hash-record-prune`; the order
   constraint is mandatory.

7. **Rekey is pure bookkeeping**: The tool moves record files and updates
   manifest path/hash references only. It must never re-run the originating
   operation, replace file contents with audit-generated content, delete any
   record or manifest, or create new audit content.

## Parameters

| Positional | Type | Required | Description |
| --- | --- | --- | --- |
| `file_path` | string | yes | Absolute path to the changed file (new content, not yet committed). |
| `op_kind` | string | yes | Operation kind, e.g. `markdown-hygiene` or `skill-auditing/v2`. May contain `/`. |
| `record_filename` | string | yes | Leaf filename, e.g. `claude-haiku.md`. No path separators. |
| `source_hash` | string | no | Known old content hash to rekey from. When provided, bypasses the full-tree scan (step 4 of the Procedure) and targets only the record at the given hash path. Prevents `AMBIGUOUS` when multiple records exist for the same `op_kind`/`record_filename`. |

The first three positional arguments are required in per-file mode. `source_hash` is optional.

## Flags

- `--help` / `-h`: print usage synopsis to stdout, exit 0.

## Procedure

1. Validate arguments: reject missing args, path traversal (`..`) or
   backslash in `op_kind`, path separators or `..` in `record_filename`.

2. Resolve repo root from `file_path` via
   `git -C $(dirname <file_path>) rev-parse --show-toplevel`.
   Fall back to `dirname(file_path)` with a stderr WARN if not in a repo.

3. Compute new blob hash: `git hash-object <file_path>`.

4. Locate the record:
   - If `source_hash` was supplied: construct the expected path
     `.hash-record/<source_hash[0:2]>/<source_hash>/<op_kind>/<record_filename>`
     directly. If that path does not exist, emit `NOT_FOUND` and exit 0.
     This bypasses the full-tree scan and prevents `AMBIGUOUS`.
   - If `source_hash` was NOT supplied: scan `.hash-record/` recursively
     for a file matching the pattern `*/<op_kind>/<record_filename>`.
     Collect all matches.

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

### Sacred invariants (operator, 2026-05-04)

Rekey is **pure mechanical bookkeeping** — it MOVES files, never
creates them, never deletes them. Audit findings inside any
record/manifest are PRESERVED byte-for-byte; only references
(paths, hashes) change.

Rekey MUST NOT:

- Re-run the originating operation (no re-audit, no re-lint).
- Replace file contents.
- Delete any record or manifest.
- Create new audit content.

The diagnostic question is "did the file change in git?" If yes,
move is required. If no, the record is current.

### Manifest semantics — multi-file records

For multi-file records (manifests), the canonical directory key
is **the hash of (sorted file paths + their current git hashes
combined)**, NOT any individual member file's blob hash. This
guarantees a single stable location per manifest state.

When rekey is invoked on a manifest:

1. For each member file in `file_paths`: recurse — ensure the
   per-file record is rekeyed (or current).
2. Compute the new manifest combined hash from the now-current
   member states.
3. If the new combined hash equals the old → CURRENT, no move.
4. Otherwise:
   - Take the existing manifest content (preserve audit findings
     byte-for-byte).
   - Update the manifest's internal `file_paths` + per-file hash
     references to current values.
   - `git mv` the manifest from `<old-combined-hash>/...` to
     `<new-combined-hash>/...`.

Operator quote: "If you tell a manifest to rekey, you're telling
all related files to rekey because they can't [be considered
current independently]." A manifest rekey ALWAYS cascades into
its member files; you cannot rekey a manifest without first
ensuring its members are current.

### Procedure (folder/manifest mode, operator-defined 2026-05-04)

Five steps, executed in order:

1. **Detect changes via `git status`.** Determine which files in
   the folder scope (and their referencing manifests) have
   changed. Build the rekey set: every changed file + every
   manifest that references a changed file.

2. **Stage the rekey set.** `git add <files>` to capture current
   content. Prevents loss of changes during the move.

3. **Apply rekey moves.** For each item in the rekey set:
   - Compute new key (single-file: blob hash; manifest: combined
     hash).
   - If new key == old key: CURRENT, no-op.
   - Else: `git mv <old> <new>` (this stages the rename
     automatically).
   - For manifests: also rewrite internal references then `git
     add` the rewritten manifest.

4. **Diff verification.** Final pass: `git diff --cached <files>`
   confirms changes look right (renames + reference updates only,
   no content corruption). If anything looks off, surface as
   error before committing.

5. **Hand off staged set.** All rekey activity is now staged.
   The caller (or operator) commits when ready. `git mv` is itself
   a staged operation, so step 5 is just "tell the caller it's
   ready."

### Pre-move git-state smoke check

Before each `git mv`, classify the file's git state:

- **Untracked** → expected baseline for an automated post-audit
  pass. The audit just produced it, no prior git history. Move
  is safe.
- **Staged but uncommitted** → file was modified, intent is
  clear. `git mv` directly.
- **Committed clean (working tree clean)** → file was sealed,
  needs relocation. `git mv` preserves history.
- **Modified but not staged** → AMBIGUOUS. Surface as
  warning; do NOT silently absorb. Likely a hand-edit not yet
  ratified.

For the common case (post-audit automated rekey pass), files
should be untracked. Anything else is a hand-edit signal worth
operator visibility.

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
