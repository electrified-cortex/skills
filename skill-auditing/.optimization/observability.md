# OBSERVABILITY — 2026-05-01

## Findings

### Finding 1 — HIGH

**Signal:** On executor mid-phase failure, the behavior is unspecified. The post-check result script returns either a stale prior verdict or MISS — both indistinguishable from legitimate states.

**Reasoning:** A caller seeing `NEEDS_REVISION` cannot tell if it came from this run or a prior run that was never overwritten. There is no completion marker in the report to distinguish a complete run from a partial one.

**Recommendation:** Executor must write a `status: error` sentinel to the report on any unhandled failure, and return `error: <reason>` to the host. The result script should surface `ERROR: executor did not complete` as a distinct verdict when the report lacks a completion marker.

**Action taken:** No change yet.

---

### Finding 2 — MEDIUM

**Signal:** Cache-hit output is emitted verbatim with no `CACHED:` label or timestamp. A caller receiving `PASS: /path/to/report` cannot tell if this reflects a current or prior run.

**Reasoning:** If the skill under audit has changed since the last run, the caller has no way to detect that the cached verdict is stale.

**Recommendation:** Prefix cache-hit output with a distinguishing token: `CACHED: <verdict> (from <report_path>)`. Optionally include report file mtime for staleness assessment.

**Action taken:** No change yet.

---

### Finding 3 — LOW

**Signal:** No intermediate signals during three-phase execution. A partial report is indistinguishable from a complete one; a caller cannot identify which phase produced a failure.

**Reasoning:** For large skill folders, callers have no indication of whether execution is progressing or hung.

**Recommendation:** Executor should write phase markers to the report as it progresses (`phase_completed: 1`, `phase_completed: 2`). A partial report becomes distinguishable, and failure phase is identifiable in post-mortem.

**Action taken:** No change yet.
