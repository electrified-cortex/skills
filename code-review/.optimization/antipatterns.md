# ANTIPATTERNS — 2026-05-08

## Findings

### Four Common Caller Misuses — HIGH

**Finding:** Four silent failures unguarded in SKILL.md: (1) smoke used as sign-off, (2) prior_findings forwarded to smoke (silently ignored), (3) single-adversary on security-critical code without model override, (4) same inputs twice expecting different results (cache hit).

**Action taken:** Added `## Anti-patterns` section to SKILL.md and uncompressed.md with all four items listed concisely.
