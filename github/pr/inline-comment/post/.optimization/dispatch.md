# DISPATCH — 2026-05-01

## Findings

### Tier Unjustified — MEDIUM

**Finding:** `<tier>` = `fast-cheap` in both `uncompressed.md` and `SKILL.md` dispatch block with no justification comment. Canonical form requires `— <reason>`. The skill spans 7 steps including diff parsing and 422 error diagnosis, making `fast-cheap` a non-obvious choice.

**Action taken:** Added `— scripted API sequence; sub-agent executes fixed CLI steps, no LLM judgment required` to the `<tier>` line in both `uncompressed.md` and `SKILL.md`.

### Non-Canonical Returns Label — LOW

**Finding:** `uncompressed.md` places the output contract in a separate `## Return` section disconnected from the dispatch call. `SKILL.md` uses `Returns:` instead of the canonical `Should return:`. Callers reading the dispatch block in isolation cannot immediately see the output contract.

**Action taken:** Added `Should return: <contract>` immediately after `Follow dispatch skill:` in `uncompressed.md`. Changed `Returns:` to `Should return:` in `SKILL.md`.
