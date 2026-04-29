# result.spec.md - skill-auditing result tool

## Purpose

Wraps `hash-record-manifest` for `skill-auditing` and translates a HIT into the cached audit verdict. Host calls `result` to read the on-disk audit-record state — at cache-check time AND at post-execute validation time. Same script, same return shape, both calls.

Read-only.

## Parameters

| Positional | Type | Required | Description                                 |
| ---------- | ---- | -------- | ------------------------------------------- |
| `skill_dir` | string | yes | Absolute path to the skill folder being audited. |

`--uncompressed` (optional) — toggle audit focus from compiled artifacts (default: `SKILL.md` + `instructions.txt`) to uncompressed sources (`uncompressed.md` + `instructions.uncompressed.md` + `spec.md`). Passed through to the executor; does NOT affect manifest scope (manifest is always all-files).

`--help` / `-h` — print usage, exit 0.

The tool enumerates ALL files inside `<skill_dir>`, recursively, excluding any file whose path passes through a dot-prefixed DIRECTORY (e.g. `.hash-record/`, `.tests/`, `.worktrees/`). Dot-prefixed FILES (e.g. `.gitignore`, `.markdownlint.json`) ARE included — they are skill-significant. The manifest hash covers the entire skill bundle — any file change invalidates the cache. The result tool then delegates to `hash-record-manifest` for the cache lookup.

## Procedure

1. Validate `<skill_dir>` is an existing directory. If not -> `ERROR: skill_dir not found: <path>`, exit 1.

2. Enumerate ALL regular files inside `<skill_dir>`, recursively. Skip any file whose path passes through a dot-prefixed DIRECTORY (e.g. `.hash-record/foo`, `subdir/.tests/x.md`). Dot-prefixed FILES at any depth ARE included. Sort lexically by path (byte order). At least one MUST be found or -> `ERROR: no files found in skill_dir`, exit 1.

3. Invoke `hash-record-manifest` (sibling tool — do NOT reimplement) with:
   - `op_kind` = `skill-auditing/v1.2-compiled` (default) OR `skill-auditing/v1.2-uncompressed` (when `--uncompressed` is set). Two distinct caches so the same manifest hash + flag yields independent records.
   - `record_filename` = `report.md`
   - `files` = the enumerated list (absolute paths).

4. Branch on its stdout:
   - `MISS: <abs-path>` -> emit `MISS: <abs-path>`, exit 0.
   - `ERROR: <reason>` -> emit `ERROR: <reason>`, exit 1.
   - `HIT: <abs-path>` -> read the frontmatter `result:` field of `<abs-path>`:
     - `pass` -> emit `PASS: <abs-path>`, exit 0.
     - `findings` -> emit `NEEDS_REVISION: <abs-path>`, exit 0.
     - `error` -> emit `FAIL: <abs-path>`, exit 0.
     - any other value -> emit `ERROR: malformed cache record at <abs-path>`, exit 1.

## Output contract

One line, no trailing whitespace, LF terminator. Forward-slash paths.

| Condition          | Output                          | Exit |
| ------------------ | ------------------------------- | ---- |
| HIT, `result: pass`     | `PASS: <abs-path>`         | 0    |
| HIT, `result: findings` | `NEEDS_REVISION: <abs-path>` | 0  |
| HIT, `result: error`    | `FAIL: <abs-path>`         | 0    |
| MISS               | `MISS: <abs-path>`              | 0    |
| Argument or runtime error | `ERROR: <reason>`        | 1    |

The host:

- `PASS: <path>` -> done; cached audit said pass.
- `NEEDS_REVISION: <path>` -> done with findings; caller may dispatch a fix pass.
- `FAIL: <path>` -> done with audit error verdict; caller surfaces.
- `MISS: <path>` -> dispatch the skill-auditing executor with `--report-path <path>`.
- `ERROR: <reason>` -> stop, surface reason.

## Constraints

- Read-only. Never writes. Never modifies the target or the cache record.
- Frontmatter parsing is line-based (`^result:` line, first whitespace-separated token after `:`).
- Forward-slash paths. ASCII output.
- Both `result.sh` (Bash) and `result.ps1` (PowerShell 7+); byte-identical stdout.
- Delegates manifest computation entirely to `hash-record-manifest` — no duplication.
- Skill version (`v1.2`) is hardcoded in the script. Bump version + update script in lockstep when contract changes.

## Dependencies

- `hash-record-manifest` (sibling at `../hash-record/hash-record-manifest/`).

## Examples

```bash
bash result.sh /repo/skills/some-skill
# -> MISS: /repo/.hash-record/ab/abcdef.../skill-auditing/v1.2/report.md
# -> PASS: /repo/.hash-record/ab/abcdef.../skill-auditing/v1.2/report.md
# -> NEEDS_REVISION: /repo/.hash-record/ab/abcdef.../skill-auditing/v1.2/report.md
# -> FAIL: /repo/.hash-record/ab/abcdef.../skill-auditing/v1.2/report.md

bash result.sh --help
```
