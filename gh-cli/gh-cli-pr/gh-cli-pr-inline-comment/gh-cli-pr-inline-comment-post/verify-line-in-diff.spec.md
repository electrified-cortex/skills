# verify-line-in-diff.spec.md

## Purpose

A deterministic shell tool that checks whether a given line number falls within
a commentable hunk range for a file in a pull request diff. Read-only — makes
no writes. Replaces in-context hunk-header arithmetic in the post skill, which
is error-prone due to the compact `@@ -N +M @@` form and multi-file patch output.

## Language choice

Both Bash (`verify-line-in-diff.sh`) and PowerShell 7+ (`verify-line-in-diff.ps1`)
variants are provided. Both produce byte-identical stdout for the same inputs.
Bash is the POSIX canonical implementation; PowerShell 7 (Microsoft PowerShell,
cross-platform) is the equivalent. Windows PowerShell 5.1 is NOT supported.

## Parameters

| Positional    | Type              | Required | Description                                  |
| ------------- | ----------------- | -------- | -------------------------------------------- |
| `owner`       | string            | yes      | GitHub org or user name                      |
| `repo`        | string            | yes      | Repository name                              |
| `pr_number`   | integer (string)  | yes      | PR number                                    |
| `file_path`   | string            | yes      | Repo-relative path, e.g. `src/foo.ts`        |
| `line_number` | integer (string)  | yes      | Absolute line number to check                |
| `side`        | `RIGHT` \| `LEFT` | yes      | `RIGHT` = additions/context; `LEFT` = deletions |

All six arguments are required. The `.ps1` variant also accepts named parameters
(`-owner`, `-repo`, etc.) in addition to positional.

## Flags

- `--help` / `-h`: print usage synopsis to stdout, exit 0.

## Procedure

1. Validate all six arguments are present. Validate `side` is `RIGHT` or `LEFT`.
   Validate `pr_number` and `line_number` are numeric. Exit 3 on failure.

2. Fetch the full patch:
   ```bash
   gh pr diff {pr_number} --repo {owner}/{repo} --patch
   ```
   Capture stdout+stderr. On non-zero exit, emit diagnostic to stderr and
   `API_ERROR: gh pr diff failed` to stdout; exit 4.

3. Scan patch line by line, tracking state:
   - On `diff --git a/{file_path} b/{file_path}`: enter target-file mode, mark found.
   - On any other `diff --git` line while in target-file mode: exit target-file mode.
   - On `@@ -OLD[,OLD_LEN] +NEW[,NEW_LEN] @@` while in target-file mode: parse hunk.
     - **Compact form rule**: if `OLD_LEN` or `NEW_LEN` is absent, treat it as **1**.
     - Compute range for requested side:
       - `RIGHT`: `[NEW, NEW + NEW_LEN - 1]` — skip if `NEW_LEN == 0`.
       - `LEFT`: `[OLD, OLD + OLD_LEN - 1]` — skip if `OLD_LEN == 0`.
     - Accumulate non-empty ranges.

4. If the `diff --git` header for `file_path` was never found: exit 2.

5. Iterate accumulated ranges. If `line_number` is within any range: exit 0.
   Otherwise: exit 1 with the range list.

## Hunk header parsing rules

Pattern: `@@ -OLD[,OLD_LEN] +NEW[,NEW_LEN] @@`

| Token          | Value to use                                  |
| -------------- | --------------------------------------------- |
| `-OLD,OLD_LEN` | OLD_START = OLD; OLD_LEN = OLD_LEN            |
| `-OLD` only    | OLD_START = OLD; OLD_LEN = **1**              |
| `+NEW,NEW_LEN` | NEW_START = NEW; NEW_LEN = NEW_LEN            |
| `+NEW` only    | NEW_START = NEW; NEW_LEN = **1**              |
| any LEN = 0    | That side has no lines in this hunk — skip it |

## Output

One line to stdout, LF-terminated. Forward slashes in paths on every platform.

| Condition                         | stdout                          | Exit |
| --------------------------------- | ------------------------------- | ---- |
| Line is in a hunk range           | `IN_DIFF`                       | 0    |
| Line is not in any hunk range     | `NOT_IN_DIFF ranges:<r1>[,...]` | 1    |
| File has no changes in this PR    | `FILE_NOT_IN_DIFF`              | 2    |
| Missing or invalid arguments      | `USAGE: ...`                    | 3    |
| `gh pr diff` call failed          | `API_ERROR: gh pr diff failed`  | 4    |

`NOT_IN_DIFF` includes the valid commentable ranges so the caller can
diagnose or correct: e.g. `NOT_IN_DIFF ranges:39-72,51-58`.
If no hunk exists for the requested side, ranges is empty: `NOT_IN_DIFF ranges:`.

Errors (exit ≥ 2) also write a diagnostic line to **stderr**.

## Constraints

- Read-only: never modifies any file or makes any GitHub write call.
- Must pass `--repo {owner}/{repo}` to `gh pr diff` (required outside a local clone).
- No Python, Node, or any runtime beyond bash + POSIX utilities (`awk`, `grep`, `sed`) for `.sh`; PowerShell 7+ only for `.ps1`.
- Self-contained — no helper scripts or sourced files.
- Must handle `file_path` values containing forward slashes (e.g. `src/api/foo.ts`).
- File-rename diffs (`diff --git a/old b/new`) are out of scope — the tool matches
  `diff --git a/{file_path} b/{file_path}` only. Comment on the new path.

## Dependencies

- `gh` on PATH, authenticated (`gh auth status`).
- Network access to GitHub API.

## Caller usage in the post skill

Replaces step 4 in `instructions.txt`:

```
4. Verify line:
   bash: bash verify-line-in-diff.sh {OWNER} {REPO} {PR_NUMBER} {FILE_PATH} {LINE_NUMBER} {SIDE}
   pwsh: pwsh verify-line-in-diff.ps1 {OWNER} {REPO} {PR_NUMBER} {FILE_PATH} {LINE_NUMBER} {SIDE}
   Exit 0 (IN_DIFF) → proceed.
   Exit 1 (NOT_IN_DIFF ranges:...) → stop; report the listed valid ranges to the caller.
   Exit 2 (FILE_NOT_IN_DIFF) → stop; file has no changes in this PR.
   Exit ≥ 3 → surface error to caller.
```

## Examples

```bash
# Line in diff — exit 0
bash verify-line-in-diff.sh electricessence MergeIncludes 2 README.md 45 RIGHT
# -> IN_DIFF

# Line not in diff — exit 1
bash verify-line-in-diff.sh electricessence MergeIncludes 2 README.md 1 RIGHT
# -> NOT_IN_DIFF ranges:39-72,51-58

# File not in diff — exit 2
bash verify-line-in-diff.sh electricessence MergeIncludes 2 src/main.cs 10 RIGHT
# -> FILE_NOT_IN_DIFF
```

```powershell
# Named params
pwsh verify-line-in-diff.ps1 -owner electricessence -repo MergeIncludes -pr_number 2 -file_path README.md -line_number 45 -side RIGHT
# -> IN_DIFF

# Positional
pwsh verify-line-in-diff.ps1 electricessence MergeIncludes 2 README.md 1 RIGHT
# -> NOT_IN_DIFF ranges:39-72,51-58
```
