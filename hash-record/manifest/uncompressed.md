---
name: hash-record-manifest
description: Compute a manifest hash for a set of files and probe the hash-record cache using that combined key. Triggers — multi-file cache key, compute manifest hash, cache key for directory.
---

# Hash-Record Manifest

Probe the hash-record cache for a set of files via a combined manifest hash. Returns the cache path as `HIT` (exists) or `MISS` (absent); the caller reads or writes at that path.

## Inputs

| Parameter         | Required | Description                                                                   |
| ----------------- | -------- | ----------------------------------------------------------------------------- |
| `op_kind`         | yes      | Operation kind, e.g. `skill-auditing/v2`. May contain `/`; no `..`, `\`, `*`. |
| `record_filename` | yes      | Leaf filename, e.g. `report.md`. No path separators or `..`.                  |
| `files`           | yes      | One or more file paths (absolute or relative). At least one required.         |

## Procedure

Call the local tool directly — no sub-agent dispatch.

**bash:**

```bash
bash manifest.sh <op_kind> <record_filename> <file1> [<file2> ...]
```

**pwsh:**

```powershell
pwsh manifest.ps1 <op_kind> <record_filename> <file1> [<file2> ...]
```

The tool resolves repo root from the first file, computes a git blob hash per file, sorts pairs lexically, builds manifest text, hashes it via `git hash-object --stdin`, and tests the resulting cache path.

## Return

| Output            | Exit | Meaning                                      |
| ----------------- | ---- | -------------------------------------------- |
| `HIT: <abs-path>` | 0    | Cache file exists; caller reads its contents |
| `MISS: <abs-path>`| 0    | No cache entry; caller writes to this path   |
| `ERROR: <reason>` | 1    | Argument or runtime error                    |

Related: `hash-record`, `index/`, `prune/`
