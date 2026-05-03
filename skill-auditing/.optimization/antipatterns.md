# ANTIPATTERNS — 2026-05-01

## Findings

### Finding 1 — HIGH

**Signal:** No self-reference guard. `<skill_dir>` accepts any path, including the skill-auditing folder itself.

**Reasoning:** If an agent audits `skill-auditing/`, the executor reads the same `instructions.txt` it is currently executing under. This creates circular evaluation — the executor is both auditor and subject. Results would be formally produced but semantically meaningless, with no error surfaced.

**Recommendation:** Add a guard at the top of the host procedure: if `<skill_dir>` resolves to the skill-auditing directory, emit `ERROR: self-audit not permitted` and stop before dispatching.

**Action taken:** No change yet.

---

### Finding 2 — MEDIUM

**Signal:** Executor returns only `done`, splitting the output contract across two systems (executor + result script). A silent mid-phase failure produces a verdict indistinguishable from a successful one.

**Reasoning:** If the executor writes a partial or malformed report, the result script reads whatever is on disk and returns a potentially stale or corrupt verdict. The host cannot distinguish "executor completed normally" from "executor exited unexpectedly."

**Recommendation:** Have the executor return a structured token — `done: PASS | done: NEEDS_REVISION | done: FAIL | error: <reason>` — matching the result script's vocabulary. Host can fast-fail on `error:` before running the post-check.

**Action taken:** No change yet.

---

### Finding 3 — LOW

**Signal:** `--fix` is passed through to executor with no host-side precondition check. The "(only after NEEDS_REVISION verdict)" note is unenforced at the dispatch layer.

**Reasoning:** A caller can invoke `--fix` on a skill that last produced PASS or has never been audited. The executor is the sole enforcer.

**Recommendation:** Before dispatching with `--fix`, the host should run the result script and verify stdout contains `NEEDS_REVISION`. If not, emit `ERROR: --fix requires prior NEEDS_REVISION verdict` and stop.

**Action taken:** No change yet.
