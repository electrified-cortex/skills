# Hash-Record Prune Specification

## Purpose

Prune orphaned entries from a repository's `.hash-record/` store. A record is orphaned when no current file in the repository hashes to the record's `<full-hash>` key — the source content that produced the record no longer exists at that hash. Pruning reclaims disk and keeps the cache truthful.

This is a maintenance sub-skill of `hash-record`. It does not write records; it only deletes orphaned ones.

## Scope

Applies to any record under `<repo-root>/.hash-record/<shard>/<hash>/...`. Operates per-repository — invocations are scoped to a single `.hash-record/` tree.

Does NOT delete records whose hash currently matches a workspace file. Does NOT delete records based on age, model, or operation-kind alone — only orphan status.

## Definitions

- **Orphaned record**: a record whose `<full-hash>` key does not match the git blob hash of any current file in the repository working tree (tracked OR untracked, excluding ignored).
- **Valid-hash set**: the set of git blob hashes computed from every non-ignored file in the working tree at the moment the prune pass begins.
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
2. Build the **valid-hash set** using one of two strategies, chosen per hash directory:
   - **Manifest-preferred** (when `<repo_root>/.hash-record/<shard>/<full-hash>/manifest.yaml` exists, produced by `hash-record-index`): read `file_paths` from the manifest, run `git hash-object` on each listed path, accumulate those hashes. This is faster and avoids a full workspace walk.
   - **Full-workspace fallback** (when `manifest.yaml` is absent): enumerate every file in the working tree using `git ls-files --cached --others --exclude-standard`, compute `git hash-object <file>` for each, accumulate hashes into a set.
   The manifest-preferred strategy is used when a manifest is present; the fallback is used otherwise. The full-workspace set need only be built once if multiple hash directories lack a manifest.
3. Walk every hash directory under `.hash-record/<shard>/<full-hash>/`. For each, check whether `<full-hash>` is in the valid-hash set.
4. Each hash directory whose hash is NOT in the valid-hash set is **orphaned** — record it for deletion.
5. If `--dry-run` is set, skip deletion and output `dry-run: <count>`; stop.
6. Otherwise, delete each orphan hash directory via `rm -rf` (or equivalent) — the entire directory and all leaf records inside it. Stop if `--limit` is reached.
7. After deletion, prune any now-empty `<shard>/` parent directory.
8. Output the result.

### Output

Stdout return (one line):

- `CLEAN` — no orphans found.
- `pruned: <count>` — orphans deleted.
- `dry-run: <count>` — orphans found; nothing deleted.
- `ERROR: <reason>` — pre-execution failure.

## Constraints

- `repo_root` MUST NOT contain `..` or shell metacharacters. The skill MUST reject such values before any filesystem operation.
- The skill MUST NOT delete any record under a hash that is currently in the valid-hash set, even if the record is for an unused operation-kind, model, or version.
- The skill MUST NOT delete the `.hash-record/` directory itself or any non-hash-keyed administrative directory.
- The skill MUST scope deletions to descendants of `<repo_root>/.hash-record/`. Paths that resolve outside this tree (via symlink or otherwise) MUST be rejected.
- The skill MUST compute the valid-hash set ATOMICALLY before any deletion begins. Any file changes during the prune pass do not affect the current invocation's deletion list.
- The skill MUST NOT prune records based on age. Time-based eviction is out of scope; only orphan-status evictions are permitted.
- The skill MUST NOT follow symlinks when walking `.hash-record/`. Symlink targets are not pruned even if their hash is orphaned.
- The skill MUST be safe to interrupt. Partial deletion (some orphans removed, others remaining) is a valid intermediate state — re-running resumes from where it left off (orphans persist as orphans across invocations until pruned).

## Iteration Safety

This skill is idempotent. A second prune immediately after the first will find zero orphans (the first pass deleted them). The valid-hash set is recomputed every invocation.

## Don'ts

- Do not classify records by content (e.g., "stale results" by operation-kind). Orphan-status by content hash is the only signal.
- Do not introduce a separate `.cache/` namespace. The `.hash-record/` tree is the canonical location.
- Do not invoke any consumer skill (markdown-hygiene, code-review, etc.) during pruning.
- Do not write outside `.hash-record/`.
