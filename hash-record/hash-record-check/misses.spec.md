# misses.ps1 — Spec

## Purpose

A parallel batch variant of `check.ps1` that accepts a glob and outputs only
the files that have **no** cache entry for a given operation and record file.

The intended use is pre-dispatch filtering: run `misses.ps1` to find exactly
which files need work, then dispatch agents only for those paths. Files already
cached are silently excluded.

## Language choice

PowerShell 7+ (`misses.ps1`) only. Parallel file probing via
`ForEach-Object -Parallel` is a PS7 feature with no direct Bash equivalent at
the same ergonomics level. Bash callers should drive the equivalent loop
themselves or pipe `xargs -P`.

Requires Microsoft PowerShell 7+ (`pwsh`). Windows PowerShell 5.1 is NOT
supported.

## Parameters

| Positional        | Type   | Required | Description                                              |
| ----------------- | ------ | -------- | -------------------------------------------------------- |
| `glob`            | string | yes      | File glob to expand (see Glob Handling below).           |
| `op_kind`         | string | yes      | Operation kind folder, e.g. `markdown-hygiene`.          |
| `record_filename` | string | yes      | Leaf filename to probe, e.g. `lint.md`, `report.md`.     |

## Interface

```text
pwsh misses.ps1 <glob> <op_kind> <record_filename>
```

## Output

One absolute file path per line for each matched file that has no cache entry.
Paths are sorted alphabetically for deterministic output. No output if every
matched file is already cached or the glob matches nothing.

All output goes to stdout. Errors and WARN lines go to stderr only and never
appear in stdout.

## Glob Handling

PowerShell 7 does not support `**` in `-Path` natively. The script handles
both patterns explicitly:

- **Flat glob** (`path/to/*.md`): expanded via `Get-ChildItem -Path <glob>`.
- **Recursive glob** (`path/to/**/*.md`): the `**` segment is detected; the
  portion before it becomes the `-Path` base and the portion after becomes the
  `-Filter` leaf; `Get-ChildItem -Recurse` is used.

Globs that match no files produce no output and exit 0.

## Behavior

1. Validate `op_kind` and `record_filename` — reject values containing `..` or
   path separators.
2. Expand the glob using the rules above.
3. Resolve the repo root once from the first matched file via
   `git rev-parse --show-toplevel`. If not in a git repo, fall back to the
   file's parent directory and emit a WARN to stderr.
4. For each matched file, in parallel:
   a. Run `git hash-object <file>` to get the blob hash.
   b. Construct the cache path:
      `<repo_root>/.hash-record/<hash[0:2]>/<hash>/<op_kind>/<record_filename>`
   c. If the cache file does not exist, emit the file's absolute path.
5. Sort and output all misses.

Parallelism is bounded by `-ThrottleLimit 16`.

## Exit codes

| Code | Meaning                                                            |
| ---- | ------------------------------------------------------------------ |
| `0`  | Success — zero or more miss paths output.                          |
| `1`  | Argument error (`op_kind` or `record_filename` failed validation). |

A `git hash-object` failure for an individual file silently skips that file
(no output, no error). This is intentional — unreadable or non-regular files
are not candidates for caching.

## Constraints

- Read-only: never modifies the target files or any cache record.
- No sub-dispatches; fully self-contained.
- `op_kind` and `record_filename` MUST NOT contain `..` or path separators.
- Output paths use the OS-native separator (absolute path from `FullName`).
- Forward-slash paths are used internally for cache path construction to match
  the `check.ps1` convention.

## Dependencies

- `git` on PATH.
- PowerShell 7+ (`pwsh`).

## Related

- `check.ps1` / `check.sh` — single-file probe (the primitive this wraps).
- `check.spec.md` — full cache path construction spec.
