# ERROR HANDLING — 2026-04-30

**Severity:** MEDIUM (acted)

**Finding:** Three error path gaps:

1. Step 1 precondition check was absent for missing source files
   (actually already existed — `ERROR: no skill source files found at <path>`).
   Confirmed OK.
2. Step 3b had no handling for `TOPIC: none` qualifier result — the assessor
   would have nothing to select, producing undefined behavior.
3. Step 4 had no handling for malformed sub-agent responses — a non-standard
   format would be recorded silently.

**Action taken:**
- Added `TOPIC: none` handling to Step 3b: "If qualifier returned `TOPIC: none`,
  stop and emit `No applicable topics found — all topics already logged or
  none apply to this skill.`"
- Added malformed response guard to Step 4 collect instruction: "If the
  response is not in the standard finding format, record `ERROR: unexpected
  analysis format` in the log and stop."
