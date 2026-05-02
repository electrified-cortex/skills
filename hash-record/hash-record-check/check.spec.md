# check.spec.md — Hash-Record Check Tool

## Purpose

A deterministic shell tool that probes the hash-record cache for a given
file and returns a cache HIT or MISS. Read-only — never modifies any
file. Generic across operation kinds; not specific to any one skill.

## Language choice

Both Bash (`check.sh`) and PowerShell 7+ (`check.ps1`) variants are
provided. Both produce byte-identical stdout for the same inputs.
Bash is the POSIX canonical implementation; PowerShell 7 (Microsoft
PowerShell, cross-platform) is the equivalent. Windows PowerShell 5.1
is NOT supported — install Microsoft PowerShell 7+ on any platform.

## Parameters

| Positional | Type | Required | Description |
| ----------------- | ------ | -------- | ------------------------------------------ |
| `file_path` | string | yes | Absolute path to the file to probe. |
| `op_kind` | string | yes | Operation kind (e.g. `markdown-hygiene` or `skill-auditing/v2`). May contain `/`. |
| `record_filename` | string | yes | Leaf filename (e.g. `report.md`). |

All three positional arguments are required. Passing fewer than three
causes an ERROR output and non-zero exit.

## Flags

- `--help` / `-h`: print usage synopsis to stdout, exit 0.

## Procedure

1. Resolve repo root from `<file_path>`:

   ```bash
   target_dir=$(dirname "<file_path>")
   repo_root=$(git -C "$target_dir" rev-parse --show-toplevel 2>/dev/null)
   [ -z "$repo_root" ] && repo_root="$target_dir"
   ```

   If the fallback fires (no git repo), emit a stderr WARN line:
   `WARN: not in a git repo; falling back to file's parent dir as repo_root: <dir>`.
   Stdout is unaffected.

2. Compute `hash = git hash-object <file_path>`.

3. Construct `cache_path`:

   ```text
   <repo_root>/.hash-record/<hash[0:2]>/<hash>/<op_kind>/<record_filename>
   ```

4. Test whether `<cache_path>` exists as a regular file.

   - EXISTS -> emit `HIT: <cache_path>`, exit 0.
   - NOT EXISTS -> emit `MISS: <cache_path>`, exit 0.

5. On any error (git failure, unreadable file, missing arg, invalid
   `op_kind` or `record_filename`):
   emit `ERROR: <reason>`, exit non-zero.

## Output

All stdout output is one line, no trailing whitespace, LF terminator.
Forward slashes in paths on every platform.

| Condition       | Output format         | Exit |
| --------------- | --------------------- | ---- |
| Cache hit       | `HIT: <abs-path>`     | 0    |
| Cache miss      | `MISS: <abs-path>`    | 0    |
| Argument error  | `ERROR: <reason>`     | 1    |
| Runtime error   | `ERROR: <reason>`     | 1    |

HIT and MISS return the SAME path. On HIT, the file at that path
exists — caller reads it. On MISS, the file does not exist — caller
writes to it. Symmetric. No frontmatter parsing here; that's the
caller's job.

WARN lines (no-repo fallback) go to stderr only and never affect the
stdout contract.

## Constraints

- Read-only: never modifies the target file or any record.
- No sub-dispatches; fully self-contained.
- POSIX-friendly Bash: no `bashisms` beyond `$()` and `[[ ]]`.
- PowerShell 7+ only (no PS5.1 fallbacks).
- `op_kind` MUST NOT contain `..` or `\`. Forward slash `/` is permitted for versioned namespacing (e.g. `skill-auditing/v2`).
- `record_filename` MUST NOT contain `..`, `/`, or `\`. The tool rejects invalid values with `ERROR: invalid <field>: <value>`.
- Forward-slash output on every platform (Windows accepts forward
  slashes; cross-runtime byte-equality requires this).
- No interactive prompts.

## Dependencies

- `git` on PATH (used for `rev-parse` and `hash-object`).
- The file at `<file_path>` must be readable.

---

## Companion: misses.ps1

A parallel batch variant that accepts a glob and outputs only the files that have no cache entry.

### Purpose (misses.ps1)

Given a glob of files, quickly determine which ones still need an operation run — no cache entry exists for them yet. Designed for bulk fan-out: run `misses.ps1` first, dispatch agents only for the listed files.

### Interface

```text
pwsh misses.ps1 <glob> <op_kind> <record_filename>
```

| Positional | Required | Description |
| ----------------- | -------- | -------------------------------------------------------- |
| `glob` | yes | File glob to expand (e.g. `gh-cli/**/*.md`). |
| `op_kind` | yes | Same as `check.ps1` — e.g. `markdown-hygiene`. |
| `record_filename` | yes | Leaf filename to probe — e.g. `lint.md`, `report.md`. |

### Output (misses.ps1)

One absolute file path per line for each matched file with no cache entry. Sorted alphabetically. No output if all files have cache entries or the glob matches nothing.

### Behavior

- Probes all matched files in parallel (`ForEach-Object -Parallel`, throttle 16).
- Inlines the hash-object + path construction logic from `check.ps1` — no subprocess per file.
- Repo root resolved once from the first matched file.
- Non-matching globs silently produce no output (exit 0).
- Errors (invalid `op_kind`, bad `record_filename`) go to stderr, exit 1.

### Exit codes

- `0`: success (zero or more misses output).
- `1`: argument error.

## Examples

```bash
# HIT
bash check.sh /repo/path/to/file.md markdown-hygiene report.md
# -> HIT: /repo/.hash-record/ab/abcdef.../markdown-hygiene/report.md

# MISS
bash check.sh /repo/path/to/file.md markdown-hygiene report.md
# -> MISS: /repo/.hash-record/ab/abcdef.../markdown-hygiene/report.md

# help
bash check.sh --help
```

```powershell
# HIT
pwsh check.ps1 /example/repo/path/to/file.md markdown-hygiene report.md
# -> HIT: /example/repo/.hash-record/ab/abcdef.../markdown-hygiene/report.md

# help
pwsh check.ps1 -help
```
