# HASH RECORD — 2026-04-29

**Severity:** MEDIUM

**Finding:** spec.md R5 mandated a hash-record manifest procedure but
`uncompressed.md` uses an optimize-log (per-topic iteration tracking) instead.
The two are not contradictory in purpose but the spec had not been updated to
reflect the new design.

**Action taken:** Updated spec.md R5 to replace the hash-record mandate with
the optimize-log as the primary tracking mechanism. Hash-record is now noted
as optional/caller-controlled for full-skip caching on unchanged inputs.
`uncompressed.md` already used the log correctly — no change needed there.
