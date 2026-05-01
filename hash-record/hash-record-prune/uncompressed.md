---
name: hash-record-prune
description: Remove orphaned hash directories from a repository's .hash-record/ store. Triggers — prune hash records, clean up hash-record, remove orphaned records, hash-record maintenance, reclaim disk.
---

# Hash Record Prune

Run the script directly. Do not reimplement the prune logic.

## Script

- PS7: `pwsh <this-skill-dir>/prune.ps1 "<repo_root>" [-target "<glob>"] [-dry_run] [-limit <N>]`
- Bash: `bash <this-skill-dir>/prune.sh "<repo_root>" [--target "<glob>"] [--dry-run] [--limit <N>]`

## Parameters

- `repo_root` (required): absolute path to the repository root containing the `.hash-record/` directory to prune.
- `--target <glob>` (optional): relative glob pattern matched against repo-relative file paths. When provided, only hash directories whose associated source path(s) include at least one match are candidates. Hash directories outside the target are skipped entirely — neither validated nor deleted. Must not be an absolute path.
- `--dry-run` (optional): list orphaned hash directories without deleting. Default: delete.
- `--limit <N>` (optional): cap the number of hash directories deleted per invocation. Default: unlimited.

## Validity Rules

Scoped to `repo_root` (active worktree only):

- **Manifest records** (have `manifest.yaml`): orphaned when re-computing the manifest hash from current `file_paths` yields a different value, or any listed file is missing under `repo_root`.
- **Non-manifest records**: orphaned when `<full-hash>` does not match any file blob hash in `repo_root`. Scan excludes `.worktrees/` paths and submodule directory paths.

## Returns

`CLEAN` | `pruned: <count>` | `dry-run: <count>` | `ERROR: <reason>`

Related: `hash-record`, `hash-record-index`, `hash-record-manifest`
