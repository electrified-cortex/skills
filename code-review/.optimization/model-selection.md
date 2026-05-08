# MODEL-SELECTION — 2026-05-08

## Findings

### Single-Adversary Tier Tradeoff Undocumented — MEDIUM

**Finding:** Single-adversary pass uses fast-cheap (Haiku) but the task — finding exploitable paths, logic errors, correctness failures from an attacker perspective — has genuine cognitive demand. While the adversarial framing and structured output improve Haiku performance, subtle security vulnerabilities may be missed. The `model` override exists as an escape hatch but callers aren't informed of the tradeoff.

**Action taken (Option C):** Added explicit caveat to spec.md Defaults and Assumptions section and updated tier justification parenthetical in SKILL.md/uncompressed.md: "catches obvious logic errors; may miss subtle security flaws — use `model=standard` for security-critical code."

## Clean

### Smoke — CLEAN
Haiku is correct for surface lint/style/obvious bugs. Fully explicit instructions, structured schema, no deep judgment required.

### Substantive — CLEAN
Sonnet is correct for design, correctness, security, architectural analysis. Multi-step judgment across full context; no instruction-quality lever available to downgrade.
