# post — Tool Specification

## Purpose

Atomically write a single message file into the recipient's inbox and write the signal
file. The caller supplies intent only; the tool owns all mechanics.

## Parameters

| Flag | Required | Description |
| --- | --- | --- |
| `--from` | Yes | Posting agent's canonical name (kebab-case) |
| `--to` | Yes | Recipient agent's canonical name (kebab-case) |
| `--subject` | No | Short human-readable description of message intent |
| `--body` | Yes | Message body text |
| `--workspace` | No | Workspace root path. Defaults to `$PWD`. |
| `--help` | No | Print usage and exit zero. |

## Behavior

1. Resolve inbox path: `<workspace>/.inbox/<to>/`.
2. Create inbox directory if absent (including `archive/` subdir).
3. Generate UTC timestamp in `YYYYMMDDTHHmmssZ` format.
4. Generate 8-character lowercase hex nonce from CSPRNG.
5. If `<timestamp>-<nonce>.json` already exists in inbox, regenerate nonce and retry.
6. Assemble JSON object with fields `from`, `sent`, `body`, and optionally `subject`
   (omit `subject` key entirely when not provided):

   ```json
   {"from":"<from>","sent":"<ISO 8601 UTC>","subject":"<subject>","body":"<body>"}
   ```

7. Write to temp file outside inbox, then rename into inbox as `<timestamp>-<nonce>.json` (atomic).
8. Write signal file `<workspace>/.inbox/<to>/.signal` with the timestamp as content.
   Signal write failure is tolerated — exit zero regardless.

## Output

No output on success (stdout empty). Errors written to stderr.

## Exit Codes

| Code | Meaning |
| --- | --- |
| 0 | Message written successfully |
| 1 | Missing required argument |
| 2 | Write failure (inbox not writable, filesystem error) |

## Constraints

- MUST NOT post to the poster's own inbox (`--from` == `--to` is an error).
- Temp file MUST be on the same filesystem as the inbox.
- MUST NOT use `Copy-Item`+`Remove-Item` or `cp`+`rm` for the write step.
- Errors MUST go to stderr. No output to stdout on success.
