# DEFAULTS-COMPLETENESS — 2026-05-08

## Findings

### HASH-RECORD BASE PATH UNANCHORED — HIGH

**Severity:** HIGH
**Finding:** Steps 1, 5, and 8 reference `.hash-record/XX/HASH/swarm/v1/...` paths. The internal structure is fully specified but the base directory anchor is never stated — not in Defaults, Constraints, or anywhere in the skill. The base path is not a host infrastructure decision; it is a skill-controlled cache location that must be consistent across invocations. Two agents writing to different base paths would never produce a cache hit, silently causing B10 to re-dispatch instead of recover.
**Action taken:** Added D7 to both files: `.hash-record/` base path is workspace root (root of the repository or project containing the reviewed artifact). If workspace root is ambiguous, use directory containing the `problem` artifact's nearest root marker (e.g., `.git`).

### ARBITRATOR_MODEL ABSENT FROM D-TABLE — LOW

**Severity:** LOW
**Finding:** `arbitrator_model` default (`sonnet-class`) is stated in the Inputs table and inline in Step 6, but absent from the D-table. Pattern D1–D6 covers every other optional input default. A reader scanning the D-table would not find it.
**Action taken:** Added D4b in both files: "Default `arbitrator_model`: `sonnet-class`."
