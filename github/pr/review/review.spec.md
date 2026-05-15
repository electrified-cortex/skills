# review — Spec

## Purpose

Submit or dismiss a pull request review via `gh pr review`. Emits the PR
URL to stdout on success. Single-purpose: no list, no get-review-id, no
thread-resolution logic. The caller handles dedup and ID lookup before
invoking this tool.

## Language choice

Both Bash 4+ (`review.sh`) and PowerShell 7+ (`review.ps1`) variants are
provided. Both accept the same flag set and produce identical stdout for the
same inputs. Windows PowerShell 5.1 is not supported.

## Parameters

| Flag | Type | Required | Description |
| --- | --- | --- | --- |
| `--owner` | string | yes | GitHub org or user name |
| `--repo` | string | yes | Repository name |
| `--pr` | integer | yes | PR number |
| `--decision` | enum | yes | One of: `approve`, `request-changes`, `comment`, `dismiss` |
| `--body-file` | path | cond | Required when `--decision` is `request-changes` or `comment`; optional for `approve` and `dismiss` |
| `--review-id` | string | cond | Required when `--decision` is `dismiss` |
| `--help` / `-h` | flag | — | Print usage to stdout, exit 0 |

## Decision → gh flag mapping

| `--decision` | gh flag |
| --- | --- |
| `approve` | `--approve` |
| `request-changes` | `--request-changes` |
| `comment` | `--comment` |
| `dismiss` | `--dismiss` |

## Procedure

1. Parse flags. Validate all required flags are present; exit 2 with
   usage message to stderr on any missing or invalid value.
2. Validate `--decision` is one of the four accepted values; exit 2 otherwise.
3. Validate `--pr` is a positive integer; exit 2 otherwise.
4. If `--decision` is `request-changes` or `comment`, validate `--body-file`
   is provided; exit 2 if absent.
5. If `--decision` is `dismiss`, validate `--review-id` is provided; exit 2
   if absent.
6. If `--body-file` is provided, validate the file exists on the filesystem;
   exit 2 if not found.
7. Construct the `gh pr review` invocation:

   ```sh
   gh pr review {pr} --repo {owner}/{repo} {gh-flag} [--body-file {body-file}] [--review-id {review-id}]
   ```

   The body file path is passed directly to `gh`; this tool never reads
   body content.

8. Capture stdout and stderr from `gh`. On non-zero exit, forward stderr
   and exit 4.
9. On success (gh exit 0): `gh pr review` does not emit the PR URL.
   Retrieve the URL via a follow-up call:

   ```sh
   gh pr view {pr} --repo {owner}/{repo} --json url --jq .url
   ```

   Write the URL as a single LF-terminated line to stdout. Nothing else
   on stdout.

## Output

| Condition | stdout | stderr | Exit |
| --- | --- | --- | --- |
| Review submitted | PR URL (single line) | — | 0 |
| Usage error | — | error message | 2 |
| gh error | — | forwarded gh stderr | 4 |

stdout is **PR URL only** on success. No JSON wrapper. No extra lines.

## Exit codes

| Code | Meaning |
| --- | --- |
| 0 | Review submitted; PR URL on stdout |
| 2 | Usage error — missing flag or invalid argument |
| 4 | gh error — any other non-zero from gh |

Exit codes 1 and 3 are reserved and unused by this tool.

## Constraints

- `gh` must be on PATH and authenticated.
- Body file path is passed by reference to `gh` (`--body-file <path>`);
  body content is never read, expanded, or interpolated by this tool.
- `gh pr review` emits no URL on success — a follow-up `gh pr view` call
  retrieves the PR URL.
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
bash review.sh \
  --owner electricessence --repo cortex --pr 42 \
  --decision approve
# stdout: https://github.com/electricessence/cortex/pull/42
# exit: 0

bash review.sh \
  --owner electricessence --repo cortex --pr 42 \
  --decision request-changes --body-file /tmp/body.md
# stdout: https://github.com/electricessence/cortex/pull/42
# exit: 0

bash review.sh --owner electricessence --repo cortex --pr 42 --decision dismiss
# stdout: (empty)
# stderr: USAGE_ERROR: --review-id is required when --decision is dismiss
# exit: 2
```

```powershell
pwsh review.ps1 `
  --owner electricessence --repo cortex --pr 42 `
  --decision approve
# stdout: https://github.com/electricessence/cortex/pull/42
# exit: 0
```
