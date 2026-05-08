# DISPATCH — 2026-05-07

## Findings

### BEHAVIORAL DIVERGENCE (B8) — HIGH

**Severity:** HIGH
**Finding:** Auditor reported uncompressed.md B8 contained stale "degrade to code-review" third resolution step and "MUST NOT proceed as-is" framing, contradicting spec.md and SKILL.md. On inspection, both files already had the correct two-step B8 with `homogeneity_warning` (updated earlier this session). Finding was a false positive due to auditor reading stale context.
**Action taken:** No change required — already resolved.

### ROLLING WINDOW TIMEOUT CONTRACT — MEDIUM

**Severity:** MEDIUM
**Finding:** Step 5 specifies "as each completes, dispatch the next" but defines no timeout duration. B4 acknowledges timeout as a termination condition without specifying when it triggers. Rolling window can stall indefinitely on a hung dispatch.
**Action taken:** Added timeout language to Step 5 in SKILL.md and uncompressed.md: "Treat any personality that has not returned within a host-defined threshold (recommended: typical sonnet-class response time + 20%) as timed out per B4."

### ARBITRATOR FAILURE PATH — LOW

**Severity:** LOW
**Finding:** E3 covers individual personality dispatch failures but explicitly scopes to personalities. Arbitrator is not a personality — no error case covers arbitrator dispatch failure. Steps 7-8 have no defined behavior if arbitrator returns nothing.
**Action taken:** Added E6 to both SKILL.md and uncompressed.md: arbitrator dispatch failure returns error to caller with per-personality summary; no synthesis from raw member outputs.

### DISPATCH UNAVAILABLE — LOW

**Severity:** LOW
**Finding:** Error table (E1-E5) covers all per-dispatch failures but has no entry for the primary dispatch mechanism being entirely unavailable (no Agent tool, no runSubagent).
**Action taken:** Added note to Caller Tier in both SKILL.md and uncompressed.md: "If no dispatch mechanism is available in the host runtime, return error: 'Swarm requires dispatch capability; no dispatch mechanism available.'"
