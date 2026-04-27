---
name: hash-record-index
description: Build and refresh .meta.yaml index files inside each hash directory under .hash-record/. Triggers — index hash records, refresh hash-record meta, build meta.yaml, hash-record-index, accelerate prune.
---

Walks every `<shard>/<full-hash>/` dir under `.hash-record/`. For each, reads leaf record frontmatter, collects distinct `file_path` values, writes `<shard>/<full-hash>/.meta.yaml`. Skips hash dirs with recent meta (within `--max-age-hours`). Never modifies leaf records; never deletes.

Dispatch isolated agent (Dispatch, zero context): "Read and follow `instructions.txt` (in this directory). Input: `repo_root=<absolute-path> [--max-age-hours <N>]`"

- `repo_root` (required): absolute path to repo root containing `.hash-record/`.
- `--max-age-hours <N>` (optional): hours before `.meta.yaml` is stale. Default: 24.

Returns: `CLEAN` | `indexed: <count>` | `ERROR: <reason>`

Related: `hash-record`, `hash-record-prune`
