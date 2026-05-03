# ITERATION-SAFETY — 2026-05-01

## Findings

### Finding 1 — MEDIUM

**Signal:** If the executor crashes after creating the report file but before completing frontmatter, the hash-record entry exists but is malformed. Every subsequent run produces `ERROR: malformed cache record` with no recovery guidance — user is blocked indefinitely.

**Reasoning:** The executor writes the report in a single non-atomic pass. `result.ps1` fails the `result:` parse on every subsequent HIT and emits ERROR. SKILL.md routes all ERROR to stop+surface with no recovery branch.

**Recommendation:** In `result.ps1`, when HIT resolves to a file but `result:` is absent or unparseable, treat as MISS and log warning to stderr:
```powershell
if (-not $result_line) {
    [Console]::Error.Write("WARN: malformed cache record at $report_path — treating as MISS`n")
    [Console]::Out.Write("MISS: $report_path`n")
    exit 0
}
```

**Action taken:** No change yet.

---

### Finding 2 — MEDIUM

**Signal:** SKILL.md never passes `--uncompressed` to either result tool invocation. Result script always uses compiled-mode cache slot regardless of executor invocation mode.

**Reasoning:** If caller injects `--uncompressed`, the executor audits source artifacts but both result checks use the compiled cache slot. Produces false HITs or slot corruption — a prior compiled-mode result served as verdict for an uncompressed-mode audit, or vice versa. Both fail silently.

**Recommendation:** Expose `--uncompressed` as a named input in SKILL.md and propagate to both result invocations:
```
`<result-flags>` = `` | `--uncompressed`  (derived from input)
Bash: `bash result.sh <skill_dir> <result-flags>`
PS7:  `pwsh result.ps1 <skill_dir> <result-flags>`
```

**Action taken:** No change yet.

---

### Finding 3 — LOW

**Signal:** `result.ps1` enumerates ALL files in `skill_dir` for the hash regardless of `--uncompressed` flag, causing over-invalidation across modes.

**Reasoning:** A change to `uncompressed.md` busts the compiled-mode cache entry unnecessarily; a `SKILL.md` edit busts the uncompressed cache. Over-invalidation is safe but causes unnecessary re-runs and obscures what actually changed.

**Recommendation:** Scope enumerated files per mode: compiled uses `SKILL.md` + `instructions.txt`; uncompressed uses `uncompressed.md` + `instructions.uncompressed.md` + `spec.md`.

**Action taken:** No change yet.
