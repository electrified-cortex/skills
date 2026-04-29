# result.spec.md - tool-auditing result tool

## Purpose

Wraps `hash-record-manifest` for `tool-auditing` and translates a HIT into the cached audit verdict. Resolves the **tool trio** — `<stem>.sh`, `<stem>.ps1`, `<stem>.spec.md` — from any input path, then hashes whichever members exist as a manifest. Drift in any member invalidates the cache.

Read-only.

## Parameters

| Positional | Type | Required | Description                              |
| ---------- | ---- | -------- | ---------------------------------------- |
| `tool_path` | string | yes | Absolute path to ANY member of the tool trio: `<stem>.sh`, `<stem>.ps1`, or `<stem>.spec.md`. |

`--help` / `-h` — print usage, exit 0.

The tool derives `<stem>` and `<dir>` from `tool_path`, then resolves siblings:

- Bash variant: `<dir>/<stem>.sh` (if present)
- PowerShell variant: `<dir>/<stem>.ps1` (if present)
- Spec: `<dir>/<stem>.spec.md` (if present)

`<stem>` rules:

- If filename ends with `.spec.md`, stem = filename minus `.spec.md`.
- If filename ends with `.sh` or `.ps1`, stem = filename minus that suffix.
- Other extensions -> `ERROR: unsupported tool extension`, exit 1.

Missing trio members are reported as audit FAIL by the executor (Check 1). `result` does not pre-check which members exist — it builds the manifest from whichever exist (0-3) and emits MISS or HIT unconditionally.

## Procedure

1. Validate `<tool_path>` is an existing file. If not -> `ERROR: tool_path not found: <path>`, exit 1.

2. Derive `<stem>` per rules above. ERROR on unsupported extension.

3. Resolve trio in `<dir>`. Build the file list from whichever members exist:
   - `<stem>.sh` (if file)
   - `<stem>.ps1` (if file)
   - `<stem>.spec.md` (if file)

4. Invoke `hash-record-manifest` (sibling tool — do NOT reimplement) with:
   - `op_kind` = `tool-auditing/v2`
   - `record_filename` = `report.md`
   - `files` = ordered file list from step 3 (sort by repo-relative path inside manifest tool)

5. Branch on its stdout:
   - `MISS: <abs-path>` -> emit `MISS: <abs-path>`, exit 0.
   - `ERROR: <reason>` -> emit `ERROR: <reason>`, exit 1.
   - `HIT: <abs-path>` -> read frontmatter `result:`:
     - `pass` -> emit `PASS: <abs-path>`, exit 0.
     - `pass-with-findings` -> emit `PASS_WITH_FINDINGS: <abs-path>`, exit 0.
     - `fail` -> emit `FAIL: <abs-path>`, exit 0.
     - other -> emit `ERROR: malformed cache record at <abs-path>`, exit 1.

## Output contract

| Condition          | Output                                | Exit |
| ------------------ | ------------------------------------- | ---- |
| HIT, `result: pass` | `PASS: <abs-path>`                   | 0    |
| HIT, `result: pass-with-findings` | `PASS_WITH_FINDINGS: <abs-path>` | 0 |
| HIT, `result: fail` | `FAIL: <abs-path>`                   | 0    |
| MISS               | `MISS: <abs-path>`                    | 0    |
| Argument or runtime error | `ERROR: <reason>`              | 1    |

## Constraints

- Read-only. Never writes. Never modifies the target or cache.
- `op_kind` is `tool-auditing/v2` (v1 was single-script; v2 is trio). v1 records become orphans on next prune.
- Frontmatter parsing: `^result:` line, first whitespace-separated token after `:`.
- Forward-slash paths. ASCII output.
- Both `result.sh` (Bash) and `result.ps1` (PS7+); byte-identical stdout.
- Delegates manifest computation entirely to `hash-record-manifest`.

## Dependencies

- `hash-record-manifest` (sibling at `../hash-record/hash-record-manifest/`).
