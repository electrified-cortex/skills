# ERROR-HANDLING — 2026-05-08

## Findings

### Partial change_set Ambiguity — HIGH

**Finding:** Gate 1 said "Path missing, ref unreachable → STOP" but didn't specify all-or-nothing vs partial-success behavior. Partial resolution (some files found, some not) could produce incomplete review without error.

**Action taken:** Rewrote Gate 1 in instructions.txt: "If ANY file path is missing, ref unreachable, or PR not found — STOP (all-or-nothing): return `verdict: error`, `failure_reason: "change_set incomplete: <detail>"`."

### context_pointer Missing Soft-Fail — MEDIUM

**Finding:** If caller supplies `context_pointer` path that doesn't exist, executor had no guidance. Silent omission or error both inappropriate.

**Action taken:** Added to Pre-dispatch step 1: "If `context_pointer` supplied but file not found: continue without it; add `info` finding with path."

## Clean (reviewed, no action)

- Unrecognized `model`: executor can't validate model availability at runtime; low severity
- Unrecognized `focus` area: best-effort guidance; unknown values = skip/deprioritize, don't error
