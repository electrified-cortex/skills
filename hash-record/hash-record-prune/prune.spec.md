# prune.spec.md — Hash-Record Prune Tool

## Purpose

A deterministic shell tool that removes orphaned hash directories from a
repository's `.hash-record/` store. A directory is orphaned when no current
file in the repo hashes to its key — the source content no longer exists at
that hash. Pruning reclaims disk and keeps the cache truthful.

Write-destructive — deletes orphan directories and their contents. Never
writes new records; never modifies source files.

## Language choice

Both Bash (`prune.sh`) and PowerShell 7+ (`prune.ps1`) variants are
provided. Both produce byte-identical stdout for the same inputs.
Bash is the POSIX canonical implementation. PowerShell 7+ required
(no PS5.1 fallback).

## Parameters

| Positional   | Type   | Required | Description                                              |
| ------------ | ------ | -------- | -------------------------------------------------------- |
| `repo_root`  | string | yes      | Absolute path to the repository root containing `.hash-record/`. Must not contain `..` or shell metacharacters (`;`, `|`, `&`, `$`, `>`, `<`, `` ` ``, `(`, `)`, `{`, `}`). |

## Flags

| Flag              | Type    | Default  | Description                                              |
| ----------------- | ------- | -------- | -------------------------------------------------------- |
| `--target <glob>` | string  | none     | Glob pattern matched against repo-relative file paths. Only hash directories whose associated source path(s) match are candidates. Must be a relative pattern — absolute paths rejected. |
| `--dry-run`       | boolean | false    | Report orphan count without deleting.                    |
| `--limit <N>`     | integer | none     | Cap deletions at N per invocation. Must be non-negative. |
| `--help`/`-h`     | boolean | false    | Print usage synopsis to stdout and exit 0.               |

## Procedure

1. Validate `repo_root` — reject `..` or shell metacharacters; require
   absolute path. Reject `--target` if it is an absolute path.
2. Verify `<repo_root>/.hash-record/` exists. If absent: output `CLEAN`,
   exit 0.
3. Walk `.hash-record/` two levels deep (`<shard>/<hash>` dirs). Skip
   dot-prefixed directories directly under `.hash-record/` (admin dirs).
   Do not follow symlinks. If `--target <glob>` is provided, filter
   candidates: for each hash directory, read associated paths (manifest
   records: `file_paths` from `manifest.yaml`; non-manifest records:
   `file_path` from any one readable leaf `.md` frontmatter). Retain only
   directories with at least one associated path matching the glob. Hash
   directories with no readable associated paths are skipped.
4. Build valid-hash set (for non-manifest directories, always from the
   full worktree even when `--target` is active):
   - Collect submodule paths from `.gitmodules` (to exclude).
   - Run `git ls-files -z --cached --others --exclude-standard` in
     `repo_root`. For each file not under `.worktrees/` and not a
     submodule path: run `git hash-object <file>`, add hash to set.
   - Build set atomically before any deletion begins.
5. Classify each candidate hash directory:
   - **Manifest strategy** (when `manifest.yaml` exists inside the hash
     dir): re-derive the manifest hash from the listed `file_paths`.
     Read each path, hash each file, sort by repo-relative path, build
     manifest text (`<path> <hash>\n` per line), hash via
     `git hash-object --stdin`. If derived hash matches dir name: VALID;
     else ORPHANED.
   - **Full-workspace fallback** (no `manifest.yaml`): if the dir name is
     in the valid-hash set: VALID; else ORPHANED.
6. If `--dry-run`: output `dry-run: <count>`, exit 0.
7. Delete each orphan directory (entire tree) up to `--limit`.
8. Prune now-empty shard directories.
9. Output result.

See `spec.md` in this directory for the full canonical procedure and
constraint set.

## Output

All stdout output is one line, no trailing whitespace, LF terminator.

| Condition            | Output format          | Exit |
| -------------------- | ---------------------- | ---- |
| No orphans           | `CLEAN`                | 0    |
| Orphans deleted      | `pruned: <N>`          | 0    |
| Dry-run with orphans | `dry-run: <N>`         | 0    |
| Argument error       | `ERROR: <reason>`      | 1    |
| Runtime error        | `ERROR: <reason>`      | 1    |

`CLEAN` means zero orphans were found. `pruned: 0` means orphans existed
but none were deleted (e.g., `--limit 0`).

## Error handling

- Missing `repo_root` argument: `ERROR: missing required argument: repo_root`
- Non-absolute `repo_root`: `ERROR: repo_root must be an absolute path: <value>`
- `..` in `repo_root`: `ERROR: repo_root must not contain '..': <value>`
- Metacharacters in `repo_root`: `ERROR: repo_root contains shell metacharacters: <value>`
- Unknown flag: `ERROR: unknown flag: <flag>`
- `--limit` with non-integer value: `ERROR: --limit must be a non-negative integer, got: <value>`
- Errors inside the orphan walk (e.g., git failures for individual files)
  are treated as ORPHANED for that entry — not as top-level errors.
- Errors in stdlib operations (mktemp, rm, rmdir) may produce stderr
  diagnostics but do not change the stdout contract.

## Constraints

- `repo_root` MUST NOT contain `..` or the following shell metacharacters:
  `;`, `|`, `&`, `$`, `>`, `<`, `` ` ``, `(`, `)`, `{`, `}`.
- Deletion is scoped to `<repo_root>/.hash-record/`. Paths resolving outside
  this tree are skipped with a stderr diagnostic.
- Dot-prefixed directories directly under `.hash-record/` are never deleted.
- `.hash-record/` itself is never deleted.
- Symlinks are not followed when walking `.hash-record/`.
- Valid-hash set is computed atomically before any deletion begins.
- Records are NOT pruned based on age, model, or operation-kind — only orphan
  status determines deletion.
- Safe to interrupt: partial deletion is valid. Re-running resumes from the
  remaining orphans.

## Dependencies

- `git` on PATH (`hash-object`, `ls-files`, `config`).
- PowerShell 7+ for `prune.ps1`. Windows PowerShell 5.1 is not supported.

## Examples

```bash
# Prune orphans in a repo
bash prune.sh /path/to/repo

# Dry-run: report count only
bash prune.sh /path/to/repo --dry-run

# Limit deletions to 10 per invocation
bash prune.sh /path/to/repo --limit 10

# Help
bash prune.sh --help
```

```powershell
# Prune orphans
pwsh prune.ps1 -repo_root /path/to/repo

# Dry-run
pwsh prune.ps1 -repo_root /path/to/repo -dry_run

# Limit
pwsh prune.ps1 -repo_root /path/to/repo -limit 10

# Help
pwsh prune.ps1 -help
```
