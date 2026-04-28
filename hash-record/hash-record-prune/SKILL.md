---
name: hash-record-prune
description: Remove orphaned hash directories from a repository's .hash-record/ store. Triggers — prune hash records, clean up hash-record, remove orphaned records, hash-record maintenance, reclaim disk.
---

Dispatch isolated agent (Dispatch agent, zero context): "Read and follow `instructions.txt` (in this directory). Input: `repo_root=<absolute-path> [--dry-run] [--limit <N>]`"

- `repo_root` (string, required): absolute path to repo root containing `.hash-record/` dir.
- `--dry-run` (flag, optional): list orphaned hash dirs without deleting. Default: delete.
- `--limit <N>` (integer, optional): cap hash dirs deleted per invocation. Default: unlimited.

Returns: `CLEAN` | `pruned: <count>` | `dry-run: <count>` | `ERROR: <reason>`

Related: `hash-record`, `hash-record-index`
