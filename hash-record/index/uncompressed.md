---
name: hash-record-index
description: Build and refresh manifest.yaml index files inside each hash directory under .hash-record/. Triggers — index hash records, refresh hash-record index, build manifest.yaml.
---

# Hash Record Index

Dispatch an isolated agent (use Dispatch agent, zero context): "Read and follow `instructions.txt` (in this directory). Input: `repo_root=<absolute-path>`"

Parameters:

- `repo_root` (string, required): absolute path to the repository root containing the `.hash-record/` directory to index.

Returns: `CLEAN` | `indexed: <count>` | `ERROR: <reason>`
