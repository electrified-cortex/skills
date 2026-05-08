# DISPATCH — 2026-05-08

## Findings

### Missing "Should return:" Contracts — HIGH

**Finding:** All three dispatch blocks (smoke, substantive, single-adversary) lack `Should return:` output contracts. Callers cannot determine the output shape from SKILL.md without reading instructions.txt.

**Action taken:** Added `Should return:` line after each dispatch block in SKILL.md and uncompressed.md.

### Missing Tier Justifications — MEDIUM

**Finding:** Tier assignments (`fast-cheap`, `standard`) have no parenthetical rationale. Canonical form requires context for tier choice.

**Action taken:** Added parenthetical justification after each `<tier>` value.

### Missing Dispatch Block Descriptions — MEDIUM

**Finding:** Each dispatch block lacks a `<description>` variable line. Canonical pattern requires a short run label per block.

**Action taken:** Added `<description>` line to each dispatch block in SKILL.md and uncompressed.md.

### Implicit Aggregation — LOW

**Finding:** Calling agent's aggregation responsibility not documented in SKILL.md.

**Action taken:** Added brief aggregation note to the Returns section.
