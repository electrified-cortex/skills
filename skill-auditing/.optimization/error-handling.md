# ERROR-HANDLING — 2026-05-01

## Findings

### Finding 1 — HIGH

**Signal:** Pre-execute result check — `PASS`, `NEEDS_REVISION`, `FAIL`, and `ERROR` tokens from prior runs are all routed through "emit verbatim, stop" with no per-token handling. An `ERROR` from a prior run silently appears as a valid terminal state to the caller.

**Reasoning:** The binary MISS/otherwise split means any token including a stale ERROR passes through unchanged, giving the caller the impression the audit completed successfully.

**Recommendation:** Replace the binary split with an explicit match table: `PASS/NEEDS_REVISION/FAIL → emit verbatim, stop. ERROR → surface error, stop. MISS → bind and continue.`

**Action taken:** No change yet.

---

### Finding 2 — HIGH

**Signal:** Post-execute `MISS` token error message uses pre-bound `<report_path>` variable rather than `<abs-path>` from stdout — possible misleading mismatch.

**Reasoning:** If the executor used a different path than the one bound pre-execute, the error message cites the wrong path.

**Recommendation:** Use `<abs-path>` (from stdout) in the surfaced error message, not the pre-bound `<report_path>`.

**Action taken:** No change yet.

---

### Finding 3 — HIGH

**Signal:** Fix mode precondition (`only after NEEDS_REVISION`) is a trailing rule, not an early-exit guard in the procedure flow. An executor reading top-to-bottom may enter fix mode on PASS or FAIL verdicts.

**Reasoning:** The main Procedure section (steps 1–8) contains no conditional that checks the verdict before entering fix mode. The rule appears only at the end.

**Recommendation:** Add an explicit conditional after step 5: "If verdict != NEEDS_REVISION and `--fix` was passed → surface WARNING: fix mode requires NEEDS_REVISION; skip fix pass; return `done`."

**Action taken:** No change yet.

---

### Finding 4 — MEDIUM

**Signal:** Report write failure (step 7) has no defined error path. A failed overwrite could leave a truncated report the result script then mis-classifies.

**Reasoning:** No explicit `ERROR` token for write failure; no guard against partial overwrites of existing reports.

**Recommendation:** After write in step 7: "On failure → return `ERROR: failed to write report at <report_path>: <reason>`." Write to a temp path then rename to avoid partial overwrites.

**Action taken:** No change yet.

---

### Finding 5 — MEDIUM

**Signal:** `--report-path` is checked for presence but not for writeability or path-escape. A path into a read-only directory fails silently until write time.

**Reasoning:** Spec R14 defines path-escape as a stop condition for fix mode but no equivalent exists for the report path in normal audit mode.

**Recommendation:** Add pre-flight check after parsing `--report-path`: verify parent directory is writable (or can be created). On failure → `ERROR: report path not writable: <report_path>`.

**Action taken:** No change yet.

---

### Finding 6 — LOW

**Signal:** `ERROR: spec.md not found` is returned before the report is written (step 7 not yet reached). The post-execute result script then returns `MISS` — conflicting with the ERROR token the executor already returned.

**Reasoning:** Caller will re-enter the audit instead of surfacing the error, because result script sees MISS.

**Recommendation:** Before returning `ERROR: spec.md not found`, write a minimal error report at `<report_path>` so the result script finds it and returns the correct token.

**Action taken:** No change yet.
