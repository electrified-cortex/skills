# lint — Spec

## Purpose

Auto-fix deterministic, safe MD violations in-place. This is step 1 of preparation
in `lint` — the local baseline fixer that is always available and
always runs. Step 1a (any installed markdown linter) runs after this and may fix
additional rules. Together they ensure the scan pass operates on the cleanest
possible baseline.

## Scope

| Rule | Fix applied |
| ---- | ----------- |
| MD009 | Strip trailing whitespace from every line |
| MD012 | Collapse runs of 2+ consecutive blank lines to exactly one blank line |
| MD047 | Ensure file ends with exactly one LF |

Does NOT fix:

- MD010 (hard tabs): converting tabs to spaces requires knowing indentation
  width — invasive without context.
- MD041 (missing H1): adding a heading is semantic, not mechanical.
- All other MD rules: require judgment; left to the executor scan pass.

## Interface

```text
lint.sh  <path-or-glob> [<path-or-glob> ...]
lint.ps1 <path-or-glob> [<path-or-glob> ...]
```

`<path-or-glob>` (positional, one or more required): absolute or relative path or glob pattern resolving to `.md` files to fix.

- A plain path must point to an existing, writable file.
- A glob is expanded by the shell (bash) or by the script (PowerShell via `Get-ChildItem`). Non-matching globs are silently skipped.
- Any mix of plain paths and globs is accepted in a single invocation.

No `--ignore` flag. These fixes are unconditional — if you don't want them,
don't run the tool.

## Behavior

- Modifies each matched file in-place.
- Idempotent: running twice on the same file produces the same result.
- Always exits 0 on success, even if no changes were needed.
- No stdout on success.
- Per-file errors (not found, not writable) go to `stderr`; processing continues for remaining files.
- If no arguments are provided, prints usage to `stderr` and exits `1`.
- Exits `1` if any argument is a plain path that does not exist (not a glob).

## Output encoding

- Writes UTF-8, no BOM.
- LF line endings (`0x0A`). Never CRLF.

## Exit codes

- `0`: all matched files processed successfully (fixed or already clean).
- `1`: no arguments provided, OR one or more plain (non-glob) paths do not exist or are not writable.

## Requirements

R1. Both scripts MUST produce byte-identical file content when run against
    the same input on the same platform.
R2. Requires no external packages or tools — pure shell logic only.
R3. After the tool runs, all MD009, MD012, and MD047 violations in the file
    are resolved.
