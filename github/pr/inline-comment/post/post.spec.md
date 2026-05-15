# post — Spec

## Purpose

Post a single PR inline review comment via `gh api`. Emits the
comment's `html_url` to stdout on success. Single-purpose: no kind
matrix, no multi-line support, no dedup logic. The caller handles
dedup before invoking this tool.

## Language choice

Both Bash 4+ (`post.sh`) and PowerShell 7+ (`post.ps1`) variants are
provided. Both accept the same flag set and produce identical stdout
for the same inputs. Windows PowerShell 5.1 is not supported.

## Parameters

| Flag | Type | Required | Description |
| --- | --- | --- | --- |
| `--owner` | string | yes | GitHub org or user name |
| `--repo` | string | yes | Repository name |
| `--pr` | integer | yes | PR number |
| `--commit-sha` | string | yes | Head commit SHA |
| `--file` | string | yes | Repo-relative file path |
| `--line` | integer | yes | Absolute line number |
| `--side` | `LEFT\|RIGHT` | no | Diff side; defaults to `RIGHT` |
| `--body-file` | path | yes | Path to a markdown body file |
| `--help` / `-h` | flag | — | Print usage to stdout, exit 0 |

## Flags

- `--side` defaults to `RIGHT` when omitted.
- `--help` / `-h` prints usage to stdout and exits 0.

## Procedure

1. Parse flags. Validate all required flags are present; exit 2 with
   usage message to stderr on any missing or invalid value.
2. Validate `--body-file` exists on the filesystem; exit 2 if not
   found.
3. Validate `--line` is a positive integer; validate `--side` is
   `LEFT` or `RIGHT`; exit 2 otherwise.
4. Post the comment to the GitHub PR comments API with fields:
   `body`, `commit_id`, `path`, `line`, `side`. The body content must
   arrive at GitHub byte-for-byte identical to the contents of the
   body file — no character substitution, escaping, or truncation.

5. Capture stdout and stderr from `gh`. On non-zero exit, inspect
   stderr for the string `"line"` and HTTP status 422 to detect the
   line-not-in-diff condition (exit 3). All other non-zero gh exits
   are exit 4.
6. On success (gh exit 0), extract `html_url` from the JSON response
   using `jq -r .html_url` (bash) or `ConvertFrom-Json` (pwsh).
   Write the URL as a single LF-terminated line to stdout. Nothing
   else on stdout.

## Output

| Condition | stdout | stderr | Exit |
| --- | --- | --- | --- |
| Comment posted | `html_url` (single line) | — | 0 |
| Usage error | — | error message | 2 |
| Line not in diff (422) | — | diagnostic | 3 |
| Other gh error | — | forwarded gh stderr | 4 |

stdout is **URL only** on success. No JSON wrapper. No extra lines.

## Exit codes

| Code | Meaning |
| --- | --- |
| 0 | Comment posted; URL on stdout |
| 2 | Usage error — missing flag or invalid argument |
| 3 | Line not in diff — 422 with line-resolution error from gh |
| 4 | gh error — any other non-zero from gh |

Exit code 1 is reserved and unused by this tool.

## Constraints

- `gh` must be on PATH and authenticated.
- Body content must be posted exactly as it appears in the body file.
  No shell expansion or interpolation of body content may occur.
- No multi-line / `start_line` support — out of scope.
- No dedup logic — caller handles dedup before invoking.
- No JSON output — caller parses the URL directly (regex
  `#discussion_r(\d+)` if the comment ID is needed).
- Bash variant: use arrays for argument lists; `set -euo pipefail`.
- PowerShell variant: use `ProcessStartInfo` + `ArgumentList.Add` per
  element; never interpolate the body file path into a command string.
- Self-contained — no sourced scripts or helper files.
- No Python, Node, or runtimes beyond bash + POSIX utilities / PS7+.

## Dependencies

- `gh` CLI on PATH, authenticated.
- `jq` on PATH (bash variant only — used for `html_url` extraction).
- Network access to GitHub API.

## Examples

```bash
bash post.sh \
  --owner electricessence --repo cortex --pr 42 \
  --commit-sha abc123def456 --file src/foo.ts --line 45 \
  --body-file /tmp/body.md
# stdout: https://github.com/electricessence/cortex/pull/42#discussion_r1234567890
# exit: 0

bash post.sh --owner electricessence --repo cortex --pr 42 \
  --commit-sha abc123 --file src/foo.ts --line 1 --body-file /tmp/body.md
# stdout: (empty)
# stderr: line not in diff for side RIGHT
# exit: 3
```

```powershell
pwsh post.ps1 `
  --owner electricessence --repo cortex --pr 42 `
  --commit-sha abc123def456 --file src/foo.ts --line 45 `
  --body-file /tmp/body.md
# stdout: https://github.com/electricessence/cortex/pull/42#discussion_r1234567890
# exit: 0
```
