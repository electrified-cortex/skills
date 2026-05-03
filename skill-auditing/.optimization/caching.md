# CACHING — 2026-05-01

**Severity:** MEDIUM
**Finding:** spec.md R10 declares `PATH:` as the success return token. The actual implementation emits verdict tokens (`PASS:`, `NEEDS_REVISION:`, `FAIL:`). SKILL.md post-execute branching correctly matches verdict tokens. The contradiction means a dogfood self-audit would flag the host's branching as a spec violation — incorrectly, since the behavior is sound.
**Action taken:** Fixed spec.md R10 — replaced stale `PATH: <abs-path-to-record.md>` return token with the full verdict token table matching the actual implementation.
