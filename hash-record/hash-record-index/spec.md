# Hash-Record Index Specification

## Purpose

Build and maintain a `.meta.yaml` index file inside each hash directory under a repository's `.hash-record/` store. The index aggregates the `file_path` values from every leaf record inside the hash directory, giving sibling skills (especially `hash-record-prune`) a fast per-hash lookup of which source files produced records under that hash — without requiring a full workspace walk.

This is a maintenance sub-skill of `hash-record`. It is read-only on leaf records; it only writes `.meta.yaml` at the hash-directory level.

## Scope

Applies to any hash directory under `<repo_root>/.hash-record/<shard>/<full-hash>/`. Operates per-repository — invocations are scoped to a single `.hash-record/` tree.

Does NOT modify leaf records. Does NOT delete any file. Does NOT write outside `.hash-record/`. Does NOT write meta for consumer skills — only this skill writes `.meta.yaml`.

## Definitions

- **Hash directory**: the path `.hash-record/<shard>/<full-hash>/`. The indexing granularity — one `.meta.yaml` per hash directory.
- **Leaf record**: a `.md` file anywhere beneath a hash directory (at any depth). Each leaf record contains YAML frontmatter with a `file_path` field identifying the source file.
- **Meta file**: `.meta.yaml` at the hash-directory level (`<shard>/<full-hash>/.meta.yaml`). Contains the deduplicated, sorted list of `file_path` values gathered from all leaf records in that hash directory, plus a `last_seen` timestamp.
- **Stale meta**: a `.meta.yaml` whose `last_seen` timestamp is older than the `--max-age-hours` threshold. Stale meta is re-generated on the next invocation.
- **Recent meta**: a `.meta.yaml` whose `last_seen` timestamp is within the `--max-age-hours` window. Recent meta is skipped — the hash directory is not re-indexed.
- **Administrative directory**: a dot-prefixed directory directly under `.hash-record/` that is NOT a shard directory (e.g., `.prune/`). Administrative directories are excluded from the hash-directory walk.

## Requirements

### Input

- `repo_root` (string, required): absolute path to the repository root containing the `.hash-record/` directory to index.
- `--max-age-hours <N>` (integer, optional): number of hours a `.meta.yaml` may be before it is considered stale and regenerated. Default: 24.

### Procedure

1. Resolve `repo_root` and verify `<repo_root>/.hash-record/` exists. If absent, output `CLEAN` and stop — nothing to index.
2. Walk every hash directory under `.hash-record/<shard>/<full-hash>/`. For each:
   a. Check whether `.meta.yaml` exists in that hash directory.
   b. If it exists, read the `last_seen` field. If the timestamp is within the `--max-age-hours` window, skip — this hash directory is already indexed.
   c. If `.meta.yaml` is absent or stale, re-index the hash directory.
3. To index a hash directory:
   a. Find every `.md` leaf file beneath the hash directory (at any depth, excluding `.meta.yaml` itself).
   b. For each leaf file, read the YAML frontmatter. Extract the `file_path` field value. If the field is absent or the file is malformed, skip that leaf silently.
   c. Deduplicate the collected `file_path` values. Sort lexically.
   d. Write `.meta.yaml` at `<shard>/<full-hash>/.meta.yaml`:

      ```yaml
      file_paths:
        - <repo-relative-path-1>
        - <repo-relative-path-2>
      last_seen: <ISO-8601 UTC timestamp>
      ```

   e. If a previous `.meta.yaml` exists, merge its `file_paths` with the newly collected ones before writing (union, deduplicated, sorted). This ensures paths from records added since the last index are captured.
4. Count the number of hash directories for which a new `.meta.yaml` was written.
5. Output the result.

### Output

Stdout return (one line):

- `CLEAN` — no hash directories needed indexing (all recent or store absent).
- `indexed: <count>` — meta files written for `<count>` hash directories.
- `ERROR: <reason>` — pre-execution failure.

## Constraints

- The skill MUST NOT modify any leaf record file. Read-only on all `.md` files.
- The skill MUST NOT delete any file, including stale `.meta.yaml` files — stale meta is overwritten, never deleted separately.
- The skill MUST write ONLY to `.meta.yaml` files at the hash-directory level. No other write locations are permitted.
- The skill MUST be the sole writer of `.meta.yaml`. Other consumer skills MUST NOT write `.meta.yaml`.
- The skill MUST be idempotent. Re-running on the same store merges/refreshes meta and produces the same eventual state.
- The skill MUST skip leaf files with missing or malformed frontmatter silently — never raise on bad records.
- The skill MUST NOT follow symlinks when walking `.hash-record/`.
- The skill MUST reject `repo_root` values that resolve outside the repository root (path-traversal protection).
- The `--max-age-hours` threshold MUST default to 24 when not specified.

## Iteration Safety

The skill is idempotent. Re-running merges new `file_path` values into existing meta without losing existing entries. Running on a fully-indexed, up-to-date store outputs `CLEAN` and makes no changes.

## Don'ts

- Do not modify leaf records. Index is read-only on all `.md` files.
- Do not delete `.meta.yaml` files — overwrite stale ones in place.
- Do not write to any path outside `<repo_root>/.hash-record/`.
- Do not write meta for a hash directory that has no leaf records.
- Do not invoke any consumer skill (markdown-hygiene, code-review, etc.) during indexing.
- Do not expose the meta file location as configurable — `.meta.yaml` at the hash-directory level is the canonical and only location.
