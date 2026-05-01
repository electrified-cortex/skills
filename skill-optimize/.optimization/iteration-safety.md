# ITERATION SAFETY — 2026-04-30

**Severity:** LOW (acted)

**Finding:** The "second candidate" qualifier instruction had no explicit
cap — it said "run another qualifier starting from the next topic" without
bounding how many additional qualifier calls could be chained per invocation.
All other loops (qualifier scan, outer session loop) are safely bounded.

**Action taken:** Changed instruction in `uncompressed.md` Step 3a to:
"Run at most one additional qualifier call per invocation. Do not chain
more qualifier calls in a single invocation."
