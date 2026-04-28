# Hash-Record Index Specification

## Purpose

Build and maintain a `.manifest.yaml` manifest file inside each hash directory under a repository's `.hash-record/` store. The manifest aggregates the `file_path` values from every leaf record inside the hash directory, giving sibling skills (especially `hash-record-prune`) a fast per-hash lookup of which source files produced records under that hash — without requiring a full workspace walk.

This is a maintenance sub-skill of `hash-record`. It is read-only on leaf records; it only writes `.manifest.yaml` at the hash-directory level.

## Scope

Applies to any hash directory under `<repo_root>/.hash-record/<shard>/<full-hash>/`. Operates per-repository — invocations are scoped to a single `.hash-record/` tree.

Does NOT modify leaf records. Does NOT delete any file. Does NOT write outside `.hash-record/`. Does NOT write manifest for consumer skills — only this skill writes `.manifest.yaml`.

## Definitions

- **Hash directory**: the path `.hash-record/<shard>/<full-hash>/`. The indexing granularity — one `.manifest.yaml` per hash directory.
- **Leaf record**: a `.md` file anywhere beneath a hash directory (at any depth). Each leaf record contains YAML frontmatter with a `file_path` field identifying the source file.
- **Manifest file**: `.manifest.yaml` at the hash-directory level (`<shard>/<full-hash>/.manifest.yaml`). Contains ONLY the deduplicated, sorted list of `file_path` values gathered from all leaf records in that hash directory.
- **Administrative directory**: a dot-prefixed directory directly under `.hash-record/` that is NOT a shard directory (e.g., `.prune/`). Administrative directories are excluded from the hash-directory walk.

## Requirements

### Input

- `repo_root` (string, required): absolute path to the repository root containing the `.hash-record/` directory to index.

### Procedure

1. Resolve `repo_root` and verify `<repo_root>/.hash-record/` exists. If absent, output `CLEAN` and stop — nothing to index.
2. Walk every hash directory under `.hash-record/<shard>/<full-hash>/`. For each:
   a. Find every `.md` leaf file beneath the hash directory (at any depth, excluding `.manifest.yaml` itself).
   b. Read the YAML frontmatter of each leaf. Extract the `file_path` field value. If the field is absent or the file is malformed, skip that leaf silently.
   c. Deduplicate the collected `file_path` values. Sort lexically.
   d. If `.manifest.yaml` exists, read its current `file_paths` list. If the list matches the newly collected paths exactly (same set), skip — this hash directory is already up to date.
   e. Otherwise, write `.manifest.yaml` at `<shard>/<full-hash>/.manifest.yaml`:

      ```yaml
      file_paths:
        - <repo-relative-path-1>
        - <repo-relative-path-2>
      ```

      If a previous `.manifest.yaml` exists, union its `file_paths` with the newly collected ones (deduplicated, sorted) before writing.
   f. If the collected `file_paths` list is empty (no leaf records with a valid `file_path`), skip writing — do not create an empty manifest.
3. Count the number of hash directories for which a new `.manifest.yaml` was written.
4. Output the result.

### Output

Stdout return (one line):

- `CLEAN` — no hash directories needed indexing (all up to date or store absent).
- `indexed: <count>` — manifest files written for `<count>` hash directories.
- `ERROR: <reason>` — pre-execution failure.

## Constraints

- The skill MUST NOT modify any leaf record file. Read-only on all `.md` files.
- The skill MUST NOT delete any file, including existing `.manifest.yaml` files — outdated manifests are overwritten, never deleted separately.
- The skill MUST write ONLY to `.manifest.yaml` files at the hash-directory level. No other write locations are permitted.
- The skill MUST be the sole writer of `.manifest.yaml`. Other consumer skills MUST NOT write `.manifest.yaml`.
- The skill MUST be idempotent. Re-running on the same store merges/refreshes manifests and produces the same eventual state.
- The skill MUST skip leaf files with missing or malformed frontmatter silently — never raise on bad records.
- The skill MUST NOT follow symlinks when walking `.hash-record/`.
- The skill MUST reject `repo_root` values that resolve outside the repository root (path-traversal protection).

## Iteration Safety

The skill is idempotent. Re-running merges new `file_path` values into existing manifests without losing existing entries. Running on a fully-indexed, up-to-date store outputs `CLEAN` and makes no changes.

## Don'ts

- Do not modify leaf records. Index is read-only on all `.md` files.
- Do not delete `.manifest.yaml` files — overwrite outdated ones in place.
- Do not write to any path outside `<repo_root>/.hash-record/`.
- Do not write manifest for a hash directory that has no leaf records.
- Do not invoke any consumer skill (markdown-hygiene, code-review, etc.) during indexing.
- Do not expose the manifest file location as configurable — `.manifest.yaml` at the hash-directory level is the canonical and only location.
