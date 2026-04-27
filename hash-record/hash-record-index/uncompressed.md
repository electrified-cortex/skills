---
name: hash-record-index
description: Build and refresh .meta.yaml index files inside each hash directory under .hash-record/. Triggers — index hash records, refresh hash-record meta, build meta.yaml, hash-record-index, accelerate prune.
---

# Hash Record Index

Dispatch an isolated agent (use Dispatch agent, zero context): "Read and follow `instructions.txt` (in this directory). Input: `repo_root=<absolute-path> [--max-age-hours <N>]`"

Parameters:

- `repo_root` (string, required): absolute path to the repository root containing the `.hash-record/` directory to index.
- `--max-age-hours <N>` (integer, optional): hours before a `.meta.yaml` is considered stale. Default: 24.

Returns: `CLEAN` | `indexed: <count>` | `ERROR: <reason>`
