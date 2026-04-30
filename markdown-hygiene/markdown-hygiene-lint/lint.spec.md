# lint — Spec

## Purpose

Auto-fix deterministic, safe MD violations in-place. This is step 1 of preparation
in `markdown-hygiene-lint` — the local baseline fixer that is always available and
always runs. Step 1a (any installed markdown linter) runs after this and may fix
additional rules. Together they ensure the scan pass operates on the cleanest
possible baseline.

## Scope

| Rule | Fix applied |
|------|-------------|
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
lint.sh  <file>
lint.ps1 <file>
```

- `<file>` (positional, required): absolute or relative path to the `.md`
  file to fix. Must exist and be writable.

No `--ignore` flag. These fixes are unconditional — if you don't want them,
don't run the tool.

## Behavior

- Modifies `<file>` in-place.
- Idempotent: running twice on the same file produces the same result.
- Always exits 0 on success, even if no changes were needed.
- No stdout on success.
- Errors (file not found, not writable) go to stderr, exit 1.

## Output encoding

- Writes UTF-8, no BOM.
- LF line endings (`0x0A`). Never CRLF.

## Exit codes

- `0`: success (file fixed or already clean).
- `1`: usage error or file not found / not writable (message on stderr).

## Requirements

R1. Both scripts MUST produce byte-identical file content when run against
    the same input on the same platform.
R2. No external packages or tools required — pure shell logic only.
R3. After the tool runs, `verify` must report CLEAN for MD009, MD012, and
    MD047 on the same file.
