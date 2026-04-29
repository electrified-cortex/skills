# Hash-Record Prune Specification

## Purpose

Prune orphaned entries from a repository's `.hash-record/` store. A record is orphaned when no current file in the repository hashes to the record's `<full-hash>` key — the source content that produced the record no longer exists at that hash. Pruning reclaims disk and keeps the cache truthful.

This is a maintenance sub-skill of `hash-record`. It does not write records; it only deletes orphaned ones.

## Scope

Applies to any record under `<repo-root>/.hash-record/<shard>/<hash>/...`. Operates per-repository — invocations are scoped to a single `.hash-record/` tree.

Does NOT delete records whose hash currently matches a workspace file. Does NOT delete records based on age, model, or operation-kind alone — only orphan status.

## Definitions

- **Orphaned record**: a record whose hash can no longer be re-derived from the active worktree (`repo_root`). For **non-manifest records** (no `manifest.yaml`): `<full-hash>` does not match the git blob hash of any current file in `repo_root`. For **manifest records** (has `manifest.yaml`): re-computing the manifest hash from the current `file_paths` (resolving each path under `repo_root`) yields a different value — because one or more listed files are missing or changed.
- **Valid-hash set**: for non-manifest records — the set of git blob hashes computed from every file in the target worktree (`repo_root`), enumerated via `git ls-files --cached --others --exclude-standard`, excluding `.worktrees/` paths (prevents crawling into linked worktree checkouts stored as subdirectories) and submodule directory paths.
- **Active worktree**: the worktree rooted at `repo_root`. Prune is scoped to this worktree only. Linked worktrees stored under `.worktrees/` are excluded from all scans — each worktree is responsible for pruning its own records independently.
- **Hash directory**: the path `.hash-record/<shard>/<full-hash>/`. Pruning operates at this granularity — an entire hash directory and all its descendants are removed when the hash is orphaned.
- **Administrative directory**: a dot-prefixed directory directly under `.hash-record/` that is NOT a shard directory (e.g., any dot-prefixed dirs). Administrative directories are excluded from the hash-directory walk and MUST NOT be deleted.
- **Dry-run**: a mode that reports what would be deleted without modifying the filesystem.

## Requirements

### Input

- `repo_root` (string, required): absolute path to the repository root containing the `.hash-record/` directory to prune.
- `--dry-run` (flag, optional): list orphaned hash directories without deleting. Default behavior is to delete.
- `--limit <N>` (integer, optional): cap the number of hash directories deleted in one invocation. Default unlimited. Useful for incremental pruning during heavy load.

### Procedure

1. Resolve `repo_root` and verify `<repo_root>/.hash-record/` exists. If absent, output `CLEAN` and stop — nothing to prune.
2. Determine validity for each hash directory via the appropriate strategy:
   - **Manifest strategy** (when `<repo_root>/.hash-record/<shard>/<full-hash>/manifest.yaml` exists): the directory name is a **manifest hash** (not a file blob hash) — it must be re-derived:
     1. Read `file_paths` from the manifest YAML.
     2. For each listed path, check if the file exists under `repo_root`. If missing, mark ORPHANED and stop.
     3. Run `git hash-object <repo_root>/<path>` for each found file. Collect (repo-relative-path, blob-hash) pairs.
     4. Sort pairs lexically by repo-relative path.
     5. Build manifest text: one line per pair in format `<repo-relative-path> <blob-hash>`, each ending with `\n` (including the final line).
     6. Run `git hash-object --stdin` (or equivalent via temp file) on the manifest text. If the result equals `<full-hash>`, mark VALID; otherwise mark ORPHANED.
   - **Full-workspace fallback** (when `manifest.yaml` is absent): the directory name is a single-file blob hash. Build the **valid-hash set** once (shared across all non-manifest directories): enumerate files in `repo_root` via `git ls-files --cached --others --exclude-standard`, filter out any paths under `.worktrees/` and any submodule paths, run `git hash-object <file>` for each, and collect hashes into a set. If `<full-hash>` is in the set, mark VALID; otherwise mark ORPHANED.
3. Collect all hash directories marked ORPHANED in step 2.
4. If `--dry-run` is set, skip deletion and output `dry-run: <count>`; stop.
5. Otherwise, delete each orphan hash directory via `rm -rf` (or equivalent) — the entire directory and all leaf records inside it. Stop if `--limit` is reached.
6. After deletion, prune any now-empty `<shard>/` parent directory.
7. Output the result.

### Output

Stdout return (one line):

- `CLEAN` — no orphans found.
- `pruned: <count>` — orphans deleted.
- `dry-run: <count>` — orphans found; nothing deleted.
- `ERROR: <reason>` — pre-execution failure.

## Constraints

- `repo_root` MUST NOT contain `..` or shell metacharacters. The skill MUST reject such values before any filesystem operation.
- The skill MUST NOT delete any record under a hash that is currently valid (in the valid-hash set for non-manifest records, or whose manifest hash re-derives correctly for manifest records), even if the record is for an unused operation-kind, model, or version.
- The skill MUST NOT delete the `.hash-record/` directory itself or any non-hash-keyed administrative directory.
- The skill MUST scope deletions to descendants of `<repo_root>/.hash-record/`. Paths that resolve outside this tree (via symlink or otherwise) MUST be rejected.
- The skill MUST compute the valid-hash set ATOMICALLY before any deletion begins. Any file changes during the prune pass do not affect the current invocation's deletion list.
- The skill MUST NOT prune records based on age. Time-based eviction is out of scope; only orphan-status evictions are permitted.
- The skill MUST NOT follow symlinks when walking `.hash-record/`. Symlink targets are not pruned even if their hash is orphaned.
- The skill MUST be safe to interrupt. Partial deletion (some orphans removed, others remaining) is a valid intermediate state — re-running resumes from where it left off (orphans persist as orphans across invocations until pruned).

## Iteration Safety

This skill is idempotent. A second prune immediately after the first will find zero orphans (the first pass deleted them). The valid-hash set is recomputed every invocation.

**Previously-deleted records cannot be recovered.** Pruning is destructive and forward-only — if a bug causes over-deletion, the affected records are gone. Re-running after a bug-induced over-prune will not restore lost records; re-running only re-derives validity from the current working trees.

## Don'ts

- Do not classify records by content (e.g., "stale results" by operation-kind). Orphan-status by content hash is the only signal.
- Do not introduce a separate `.cache/` namespace. The `.hash-record/` tree is the canonical location.
- Do not invoke any consumer skill (markdown-hygiene, code-review, etc.) during pruning.
- Do not write outside `.hash-record/`.
