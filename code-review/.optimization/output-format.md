# OUTPUT-FORMAT — 2026-05-08

## Findings

### Single-Adversary Output Schema Inconsistency — HIGH

**Finding:** SKILL.md Single-Adversary Mode stated output as `{file, line_or_range, severity, description}` + 1-3 sentence summary — incompatible with the JSON schema in instructions.txt (`{severity, location, snippet, description, recommended_action}` inside `{tier, pass_index, verdict, findings[], failure_reason?}`). Field names differed, structure differed.

**Action taken:** Updated SKILL.md and uncompressed.md Single-Adversary Output line to: "same JSON schema as tiered passes — `{tier: \"single-adversary\", pass_index, verdict, findings[{severity, location, snippet, description, recommended_action}], failure_reason?}`"

### `preserved_contradictions` Structure Undefined — HIGH

**Finding:** Both instructions.txt and spec.md described `preserved_contradictions` in prose ("each paired with contradicting commentary") without specifying the JSON entry shape. Callers couldn't implement the contract.

**Action taken:** Defined entry schema in instructions.txt Aggregated Result: `{smoke_finding: <finding>, contradiction: {verdict: "false_positive"|"out_of_scope", commentary: "<string>"}}`. Updated spec.md to match.

### `severity_aggregate` Null Case Ambiguous — MEDIUM

**Finding:** "zero per bucket when null or clean" in instructions.txt didn't specify whether the object was present (all zeros) or omitted entirely.

**Action taken:** Clarified in instructions.txt: "`{critical, high, medium, low, info}` counts from sign-off pass only. All buckets zero when `sign_off_pass_index` is `null` or result is `clean`." — object always present, all zeros.

## Clean

- Per-pass JSON schema: complete and consistent for smoke and substantive
- Field semantics: well-defined (`location`, `snippet`, `description`, `recommended_action`)
- `verdict` vocabulary: explicit (`clean`, `findings`, `error`)
