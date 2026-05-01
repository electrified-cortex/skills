---
file_path: markdown-hygiene/markdown-hygiene-lint/verify.spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA003 [WARN]: `MUST` appears 9 times across Requirements (R1–R9), exceeding the 5-occurrence threshold.
  Note: Every requirement item uses `MUST` as its sole emphasis signal; repeated saturation risks reducing its prescriptive weight.

- SA010 [WARN] line 80: `bash` and `pwsh` appear as plain prose without backticks.
  Note: "uses bash 4.3+" (line 80) and "uses pwsh 7.0+" (line 81) leave program names unformatted; the same pattern recurs in C4 ("requires bash 4.3+", line 110) and C5 ("requires pwsh 7.0+", line 111).

- SA012 [WARN] line 24: `## Interface` is immediately followed by `### Inputs` with no body content between.
  Note: The Interface heading introduces no content of its own before the first subheading; a brief sentence or none at all signals an empty parent heading.

- SA014 [SUGGEST] line 67: `Never` is unemphasized in a directive context.
  Note: "Never CRLF" in the Output encoding section uses an unformatted `Never`; bold emphasis would signal its prescriptive weight alongside the surrounding constraints.

- SA018 [WARN] line 12: Passive construction on a spec-level sentence — "are handled by the co-located `lint` tool".
  Note: The Scope intro uses passive voice ("are handled by", line 12); the pattern recurs in C7 ("is tolerated by `verify.ps1`", line 114; "inputs are expected to use LF", line 116).

- SA038 [FAIL]: Contradictory scope declarations for MD009, MD012, and MD047.
  Note: Scope (lines 11–13) states these three rules are handled by the lint tool and "are NOT re-checked here," yet R3 (line 83) requires implementing "all five rules listed in Scope," R6 (line 92) specifies MD012 flagging behavior, and the test fixtures table (lines 130–134) mandates fixture coverage for MD009, MD012, and MD047.
