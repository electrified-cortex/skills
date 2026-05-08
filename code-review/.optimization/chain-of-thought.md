# CHAIN-OF-THOUGHT — 2026-05-08

## Findings

### Implicit Reasoning in Adversarial + Prior-Findings Steps — MEDIUM

**Finding:** Procedure steps 1-6 define what to do but not how to think before analysis. Hallucination filter, prior-findings contradiction decisions, and adversarial framing all benefit from explicit pre-analysis scaffolding.

**Action taken:** Added `Before analysis:` step to Procedure section in instructions.txt: map affected code paths, identify scope (new code, modified logic, API surface, security-sensitive areas), set review frame for tier.
