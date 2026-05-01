# DISPATCH — 2026-05-01

## Findings

### Finding 1: Missing `<tier>` with justification for S5 and S6 dispatch calls

**Severity:** MEDIUM
**Finding:** Neither the S5 personality-batch dispatch nor the S6 arbitrator dispatch declares a `<tier>` field (`fast-cheap` | `standard` | `deep`) with justification. The skill describes in prose what each dispatch receives but omits the canonical tier selection. For S5, personality reviews involve moderate reasoning over a supplied review packet — `standard` tier is the defensible choice but is never stated. For S6, the arbitrator consolidates N outputs and applies judgment — again `standard` is appropriate but absent. Missing tier means the dispatch skill cannot route invocations correctly and the operator cannot audit the cost/latency intent.
**Action taken:** Added explicit `<tier> = standard` with one-line justifications to both S5 and S6 in `uncompressed.md`.

### Finding 2: Missing `Should return:` output contract for S5 and S6 dispatch calls

**Severity:** MEDIUM
**Finding:** Neither S5 nor S6 states a `Should return:` output contract after the dispatch call. S5 personalities should return findings in a structured format (evidence-cited findings list or "No findings"). S6 arbitrator should return a structured two-section action list (Obvious actions / Critical actions). Without `Should return:`, the host step (S7 aggregate / S8 synthesize) must guess what format to expect from each sub-agent, making the interface ambiguous and harder to validate.
**Action taken:** Added `Should return:` contracts to both S5 and S6 in `uncompressed.md`.
