# create — Spec

## Purpose

Create a new GitHub issue via `gh issue create`. Emits the issue's URL to
stdout on success. Single-purpose: no dedup logic, no edit or delete support.
The caller handles body prep and metadata before invoking this tool.

## Language choice

Both Bash 4+ (`create.sh`) and PowerShell 7+ (`create.ps1`) variants are
provided. Both accept the same flag set and produce identical stdout for the
same inputs. Windows PowerShell 5.1 is not supported.

## Parameters

| Flag | Type | Required | Description |
| --- | --- | --- | --- |
| `--owner` | string | yes | GitHub org or user name |
| `--repo` | string | yes | Repository name |
| `--title` | string | yes | Issue title |
| `--body-file` | path | yes | Path to a markdown body file |
| `--label` | string | no | Comma-separated label names |
| `--help` / `-h` | flag | — | Print usage to stdout, exit 0 |

## Procedure

1. Parse flags. Validate all required flags are present; exit 2 with usage
   message to stderr on any missing or invalid value.
2. Validate `--body-file` exists on the filesystem; exit 2 if not found.
3. Construct the `gh issue create` invocation:

   ```
   gh issue create --repo {owner}/{repo} --title {title} --body-file {body-file}
   ```

   When `--label` is supplied, append `--label {label}` to the argument list.
   The body file path is passed directly to `gh`; this tool never reads body
   content.

4. Capture stdout and stderr from `gh`. On non-zero exit, forward stderr and
   exit 4.
5. On success (gh exit 0), capture the URL that `gh issue create` prints to
   stdout. Write the URL as a single LF-terminated line to stdout. Nothing
   else on stdout.

## Output

| Condition | stdout | stderr | Exit |
| --- | --- | --- | --- |
| Issue created | URL (single line) | — | 0 |
| Usage error | — | error message | 2 |
| gh error | — | forwarded gh stderr | 4 |

stdout is **URL only** on success. No JSON wrapper. No extra lines.

## Exit codes

| Code | Meaning |
| --- | --- |
| 0 | Issue created; URL on stdout |
| 2 | Usage error — missing flag or invalid argument |
| 4 | gh error — any other non-zero from gh |

Exit codes 1 and 3 are reserved and unused by this tool.

## Constraints

- `gh` must be on PATH and authenticated.
- Body file path is passed by reference to `gh` (`--body-file <path>`);
  body content is never read, expanded, or interpolated by this tool.
- Labels passed as a single comma-separated string to `--label`; no splitting.
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
bash create.sh \
  --owner electricessence --repo cortex \
  --title "Found a bug" \
  --body-file /tmp/body.md \
  --label bug,high-priority
# stdout: https://github.com/electricessence/cortex/issues/42
# exit: 0

bash create.sh --owner electricessence --repo cortex --title "Bug"
# stdout: (empty)
# stderr: USAGE_ERROR: missing required flags: --body-file
# exit: 2
```

```powershell
pwsh create.ps1 `
  --owner electricessence --repo cortex `
  --title "Found a bug" `
  --body-file /tmp/body.md `
  --label bug,high-priority
# stdout: https://github.com/electricessence/cortex/issues/42
# exit: 0
```
