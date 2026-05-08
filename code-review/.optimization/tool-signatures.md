# TOOL-SIGNATURES — 2026-05-08

## Findings

### prior_findings Shape Implicit — MEDIUM

**Finding:** `prior_findings` parameter described as "all prior-pass findings forwarded unmodified" — callers must infer it's the `findings[]` array from prior pass JSON output.

**Action taken:** Updated parameter description in SKILL.md, uncompressed.md, and instructions.txt to: "the `findings[]` array from all prior passes, forwarded unmodified."

## Clean

- Output JSON schema: fully typed with explicit field names and types
- Input fields: all required vs optional clearly marked
- Aggregated result fields: well-defined (after OUTPUT-FORMAT fixes)
