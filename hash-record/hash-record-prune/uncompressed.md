---
name: hash-record-prune
description: Remove orphaned hash directories from a repository's .hash-record/ store. Triggers — prune hash records, clean up hash-record, remove orphaned records, hash-record maintenance, reclaim disk.
---

# Hash Record Prune

Dispatch an isolated agent (use Dispatch agent, zero context): "Read and follow `instructions.txt` (in this directory). Input: `repo_root=<absolute-path> [--dry-run] [--limit <N>]`"

Parameters:

- `repo_root` (string, required): absolute path to the repository root containing the `.hash-record/` directory to prune.
- `--dry-run` (flag, optional): list orphaned hash directories without deleting. Default behavior is to delete.
- `--limit <N>` (integer, optional): cap the number of hash directories deleted in one invocation. Default unlimited.

Returns: `CLEAN` | `pruned: <count>` | `dry-run: <count>` | `ERROR: <reason>`
