---
name: spec-auditing
description: >-
  Audit a spec/companion pair or a spec alone for alignment and completeness.
  Triggers — spec validation, requirements coverage, contradiction detection,
  document alignment, specification quality.
---

Input:
`<target-path>` (required): path to spec or companion file
`--spec <spec-path>` (optional): explicit spec path (pair-audit mode)
`--fix` (flag, optional): fix mode — modifies target to match spec, up to 3 passes
`--kind meta|domain` (optional): force audit kind; default auto-detects from path

Inline hash check:
Run inline result check for `spec-auditing`. DON'T READ script source — before, during, or after. Run it, branch on stdout, move on.

Resolve repo root: `repo_root=$(git -C "$(dirname <target-path>)" rev-parse --show-toplevel 2>/dev/null); [ -z "$repo_root" ] && repo_root="$(dirname <target-path>)"`

Input files: spec-only mode → target only; `--spec` provided → target + spec-path; default → target + sibling `<basename>.spec.md`.

Bash: `bash ../hash-record/hash-record-manifest/manifest.sh spec-auditing/v1 report.md <input-file-1> [<input-file-2>]`
PS7: `pwsh ../hash-record/hash-record-manifest/manifest.ps1 spec-auditing/v1 report.md <input-file-1> [<input-file-2>]`

`HIT: <abs-path>` -> emit `PATH: <abs-path>`, stop. Do NOT dispatch.
`MISS: <abs-path>` -> bind `<report_path>` = `<abs-path>`, continue to Dispatch.
`ERROR: <reason>` (untracked/non-git) -> bind `<report_path>` = `""`, continue to Dispatch.

## Dispatch

`<instructions>` = `instructions.txt` (NEVER READ)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `<target-path> [--spec <spec-path>] [--fix] [--kind meta|domain] --report-path <report_path>`
`<tier>` = `fast-cheap`
`<description>` = `Spec Audit: <target-path>`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`
Optional: `<model-override>` = `sonnet-class` (fix pass only; detection passes use `<tier>=fast-cheap`)

Follow `dispatch` skill. See `../dispatch/SKILL.md`.
Returns: `Pass: <abs-path>` | `Pass with Findings: <abs-path>` | `Fail: <abs-path>` on verdict; `ERROR: <reason>` on failure

One skill per invocation. Chain multiple subjects as separate runs.

## Result

If `ERROR:` stop, return to caller.
Otherwise rerun inline hash check. If `MISS: <abs-path>` at bound `<report_path>` → surface `ERROR: Expected report at <abs-path>. None found.`

If `Pass: <abs-path>` → return to caller, stop.

If `Pass with Findings: <abs-path>` or `Fail: <abs-path>` → review report, caller decides:
- Acceptable as-is → return to caller.
- Address (run fix pass on target) → iterate (see below), then return.
- Defer → return to caller with report path.

Iteration loop (when `--fix` set, cap 3):
1. Fix pass — dispatch with `<model-override>=sonnet-class`.
2. Re-audit — dispatch with `<tier>=fast-cheap` (no override).
3. `Pass` → stop. Still findings → continue. After 3 passes return last report; caller decides.

## Iteration Safety

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.
