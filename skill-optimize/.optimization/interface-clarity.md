# INTERFACE CLARITY — 2026-04-29

**Severity:** MEDIUM

**Finding:** Two contract gaps: (1) R6 output format stale — spec said
`PATH: <path>` but actual output is `TOPIC: X | FINDINGS: N | LOG: path`.
(2) "What This Skill Does" intro still said "no sub-agent dispatch" after
the DISPATCH fix.

**Action taken:** Updated spec.md R6 to `TOPIC: <slug> | FINDINGS: <N> |
LOG: <path>`. Removed stale R10 hash-record scope rule. Fixed "What This
Skill Does" intro in `uncompressed.md` to describe the hybrid dispatch
pattern correctly.
