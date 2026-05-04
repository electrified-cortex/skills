---
name: spec-auditing
description: >-
  Audit a spec/companion pair or a spec alone for alignment and completeness.
  Triggers — spec validation, requirements coverage, contradiction detection,
  document alignment, specification quality.
---

# Spec Auditing

## Input

`<target-path>` — path to spec file or companion file to audit.
`[--spec <spec-path>]` — explicit spec path (pair-audit mode).
`[--fix]` — fix mode; modifies target to match spec, up to 3 passes.
`[--kind meta|domain]` — force audit kind; default auto-detects from path.

## Inline Hash Check

Run inline result check for `spec-auditing`. DON'T READ the script source — before, during, or after invocation.

Resolve repo root: `repo_root=$(git -C "$(dirname <target-path>)" rev-parse --show-toplevel 2>/dev/null); [ -z "$repo_root" ] && repo_root="$(dirname <target-path>)"`

Input files: spec-only mode → target only; `--spec` provided → target + spec-path; default → target + sibling `<basename>.spec.md`.

- Bash: `bash ../hash-record/hash-record-manifest/manifest.sh spec-auditing/v1 report.md <input-file-1> [<input-file-2>]`
- PS7: `pwsh ../hash-record/hash-record-manifest/manifest.ps1 spec-auditing/v1 report.md <input-file-1> [<input-file-2>]`

- `HIT: <abs-path>` → emit `PATH: <abs-path>`, stop. Do NOT dispatch.
- `MISS: <abs-path>` → bind `<report_path>` = `<abs-path>`, continue to Dispatch.
- `ERROR: <reason>` (untracked / non-git) → bind `<report_path>` = `""` (no caching), continue to Dispatch.

## Dispatch

Variables:

`<instructions>` = `instructions.txt` (NEVER READ)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `<target-path> [--spec <spec-path>] [--fix] [--kind meta|domain] --report-path <report_path>`
`<tier>` = `fast-cheap`
`<description>` = `Spec Audit: <target-path>`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`
Optional: `<model-override>` = `sonnet-class` (set only during fix pass; detection passes use `<tier>=fast-cheap`)

Follow `dispatch` skill. See `../dispatch/SKILL.md`.
Returns: `Pass: <abs-path>` | `Pass with Findings: <abs-path>` | `Fail: <abs-path>` on verdict; `ERROR: <reason>` on failure

One skill per invocation. Chain multiple subjects as separate runs.

## Result

If `ERROR:` stop here and return the result to the caller.

Otherwise rerun the inline hash check (same inputs, same command).
If it returns `MISS: <abs-path>` for the bound `<report_path>`, something went wrong — surface: `ERROR: Expected report at <abs-path>. None found.`

If `Pass: <abs-path>`, return the result to the caller and stop here.

If `Pass with Findings: <abs-path>` or `Fail: <abs-path>`, review the report and decide:
- **Acceptable as-is** → return to caller.
- **Address** → run the iteration loop below, then return to caller.
- **Defer** → return to caller with the report path; caller decides.

### Iteration loop (when `--fix` is set and findings remain)

Each iteration:
1. **Fix pass** — re-dispatch with `<model-override>=sonnet-class`; target file is modified.
2. **Re-audit (detect)** — re-dispatch with `<tier>=fast-cheap` (no model-override); produces new report.
3. If `Pass`, stop. If still `Pass with Findings` or `Fail`, continue.

Cap at **3 iterations**. If findings remain after 3 passes, return the last report path; caller decides escalation.

## Iteration Safety

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.
