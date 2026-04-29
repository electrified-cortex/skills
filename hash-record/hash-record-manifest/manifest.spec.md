# manifest.spec.md - Hash-Record Manifest Tool

## Purpose

A deterministic shell tool that computes a manifest hash over a set of files and probes the hash-record cache for a record at the manifest hash. Read-only — never modifies any file. Companion to `hash-record-check`: that tool takes a SINGLE file and probes; this one takes MULTIPLE files (a manifest set).

## Language choice

Both Bash (`manifest.sh`) and PowerShell 7+ (`manifest.ps1`) variants are provided. Both produce byte-identical stdout for the same inputs. PS7+ required (no PS5.1 fallback).

## Parameters

| Positional        | Type   | Required | Description                                  |
| ----------------- | ------ | -------- | -------------------------------------------- |
| `op_kind`         | string | yes      | Operation kind (e.g. `skill-auditing/v1.2`). |
| `record_filename` | string | yes      | Leaf filename (e.g. `report.md`).            |
| `files`           | array  | yes      | One or more file paths (relative or absolute). |

All three are required. Fewer than three positional groups -> ERROR + exit non-zero.

## Flags

- `--help` / `-h`: print usage to stdout, exit 0.

## Procedure

1. Resolve repo root from the first file in `files`:

   ```bash
   target_dir=$(dirname "<files[0]>")
   repo_root=$(git -C "$target_dir" rev-parse --show-toplevel 2>/dev/null)
   [ -z "$repo_root" ] && repo_root="$target_dir"
   ```

   If the fallback fires, emit a stderr WARN line: `WARN: not in a git repo; falling back to file's parent dir as repo_root: <dir>`.

2. For each file in `files`:
   - Resolve to repo-relative form: if absolute and starts with `<repo_root>`, strip prefix; canonicalize separators to `/`.
   - Compute git blob hash: `git hash-object <absolute-path>`. Failure -> `ERROR: missing: <repo-relative-path>`, exit 1.
   - Collect (repo-relative-path, blob-hash) pair.

3. Sort pairs lexically by repo-relative path (ascending, byte-order).

4. Build manifest text: one line per pair, format `<repo-relative-path> <blob-hash>\n`. Final line MUST end with `\n`.

5. Compute manifest hash: pipe manifest text through `git hash-object --stdin`. Output is 40-char lowercase hex.

6. Construct cache path:

   ```text
   <repo_root>/.hash-record/<manifest_hash[0:2]>/<manifest_hash>/<op_kind>/<record_filename>
   ```

   Note: `<op_kind>` may contain `/` (e.g. `skill-auditing/v1.2`), allowing subdirectory versioning. Path traversal characters (`..`, leading `/`) are still rejected — but `/` itself is permitted to support versioned op_kinds.

7. Test whether `<cache_path>` exists as a regular file.

   - EXISTS -> emit `HIT: <cache_path>`, exit 0.
   - NOT EXISTS -> emit `MISS: <cache_path>`, exit 0.

8. On any error: emit `ERROR: <reason>`, exit 1.

## Output

All stdout output is one line, no trailing whitespace, LF terminator. Forward slashes in paths on every platform.

| Condition        | Output format        | Exit |
| ---------------- | -------------------- | ---- |
| Cache hit        | `HIT: <abs-path>`    | 0    |
| Cache miss       | `MISS: <abs-path>`   | 0    |
| Argument error   | `ERROR: <reason>`    | 1    |
| Runtime error    | `ERROR: <reason>`    | 1    |

HIT and MISS return the SAME path. On HIT, the file at that path exists — caller reads it. On MISS, the file does not exist — caller writes to it. Symmetric.

WARN lines (no-repo fallback) go to stderr only and never affect the stdout contract.

## Constraints

- Read-only: never modifies any file or any record.
- POSIX-friendly Bash; PowerShell 7+ only.
- `record_filename` MUST NOT contain `..` or path separators. Reject with `ERROR: invalid record_filename: <value>`.
- `op_kind` may contain `/` (versioning) but MUST NOT contain `..` or `\\` or `*`. Reject otherwise.
- Forward-slash output on every platform.
- No interactive prompts.
- Manifest text uses `/` path separators regardless of host OS.
- Sorting MUST be lexical byte-order before manifest text construction.
- Trailing newline after final manifest line is MANDATORY.

## Dependencies

- `git` on PATH (used for `rev-parse` and `hash-object` and `hash-object --stdin`).
- All files in `<files>` must be readable.

## Examples

```bash
# Multi-file manifest probe
bash manifest.sh skill-auditing/v1.2 report.md /repo/skills/foo/spec.md /repo/skills/foo/uncompressed.md
# -> MISS: /repo/.hash-record/ab/abcdef.../skill-auditing/v1.2/report.md

# Single-file (degenerate but valid)
bash manifest.sh markdown-hygiene report.md /repo/path/to/file.md
# -> MISS: /repo/.hash-record/ab/abcdef.../markdown-hygiene/report.md
# (Equivalent to hash-record-check, but without the check tool's per-file optimization.)

# Help
bash manifest.sh --help
```

```powershell
# Same shape on PS7+
pwsh manifest.ps1 skill-auditing/v1.2 report.md /example/repo/skills/foo/spec.md /example/repo/skills/foo/uncompressed.md
# -> MISS: /example/repo/.hash-record/ab/abcdef.../skill-auditing/v1.2/report.md
```

## Relationship to `hash-record-check`

- `hash-record-check` (sibling): single-file hash, produces HIT/MISS path. Use when the cache key is a single file.
- `hash-record-manifest` (this tool): multi-file manifest hash, produces HIT/MISS path. Use when the cache key spans multiple sources (skill-auditing, dir code review, anything bundling).

Both tools share the cache-path layout and HIT/MISS/ERROR output contract. Consumers can swap between them based on their hash-key needs.
