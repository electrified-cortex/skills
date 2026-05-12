# comment — Spec

## Purpose

Post a comment on an existing GitHub issue via `gh issue comment`. Emits the
comment's URL to stdout on success. Single-purpose: no dedup logic, no edit or
delete support. The caller handles dedup before invoking this tool.

## Language choice

Both Bash 4+ (`comment.sh`) and PowerShell 7+ (`comment.ps1`) variants are
provided. Both accept the same flag set and produce identical stdout for the
same inputs. Windows PowerShell 5.1 is not supported.

## Parameters

| Flag | Type | Required | Description |
| --- | --- | --- | --- |
| `--owner` | string | yes | GitHub org or user name |
| `--repo` | string | yes | Repository name |
| `--issue` | integer | yes | Issue number |
| `--body-file` | path | yes | Path to a markdown body file |
| `--help` / `-h` | flag | — | Print usage to stdout, exit 0 |

## Procedure

1. Parse flags. Validate all required flags are present; exit 2 with usage
   message to stderr on any missing or invalid value.
2. Validate `--body-file` exists on the filesystem; exit 2 if not found.
3. Validate `--issue` is a positive integer; exit 2 otherwise.
4. Construct the `gh issue comment` invocation:

   ```
   gh issue comment {issue} --repo {owner}/{repo} --body-file {body-file}
   ```

   The body file path is passed directly to `gh`; this tool never reads body
   content.

5. Capture stdout and stderr from `gh`. On non-zero exit, forward stderr and
   exit 4.
6. On success (gh exit 0), capture the URL that `gh issue comment` prints to
   stdout. Write the URL as a single LF-terminated line to stdout. Nothing
   else on stdout.

## Output

| Condition | stdout | stderr | Exit |
| --- | --- | --- | --- |
| Comment posted | URL (single line) | — | 0 |
| Usage error | — | error message | 2 |
| gh error | — | forwarded gh stderr | 4 |

stdout is **URL only** on success. No JSON wrapper. No extra lines.

## Exit codes

| Code | Meaning |
| --- | --- |
| 0 | Comment posted; URL on stdout |
| 2 | Usage error — missing flag or invalid argument |
| 4 | gh error — any other non-zero from gh |

Exit codes 1 and 3 are reserved and unused by this tool.

## Constraints

- `gh` must be on PATH and authenticated.
- Body file path is passed by reference to `gh` (`--body-file <path>`);
  body content is never read, expanded, or interpolated by this tool.
- No dedup logic — caller handles dedup before invoking.
- No JSON output — caller uses the URL directly.
- Bash variant: use arrays for argument lists; `set -euo pipefail`.
- PowerShell variant: use `ProcessStartInfo` + `ArgumentList.Add` per
  element; never interpolate the body file path into a command string.
- Self-contained — no sourced scripts or helper files.
- No Python, Node, or runtimes beyond bash + POSIX utilities / PS7+.

## Dependencies

- `gh` CLI on PATH, authenticated.
- Network access to GitHub API.

## Examples

```bash
bash comment.sh \
  --owner electricessence --repo cortex --issue 42 \
  --body-file /tmp/body.md
# stdout: https://github.com/electricessence/cortex/issues/42#issuecomment-1234567890
# exit: 0

bash comment.sh --owner electricessence --repo cortex --issue 42
# stdout: (empty)
# stderr: USAGE_ERROR: missing required flags: --body-file
# exit: 2
```

```powershell
pwsh comment.ps1 `
  --owner electricessence --repo cortex --issue 42 `
  --body-file /tmp/body.md
# stdout: https://github.com/electricessence/cortex/issues/42#issuecomment-1234567890
# exit: 0
```
