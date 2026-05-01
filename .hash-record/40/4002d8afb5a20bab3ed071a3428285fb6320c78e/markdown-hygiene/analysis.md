---
file_path: markdown-hygiene/markdown-hygiene-lint/lint.spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 43: `stdout` appears in plain prose without backticks in "No stdout on success."
  Note: `stdout` is a shell I/O channel name; the parallel item on line 44 backticks `stderr`, making the omission here inconsistent.

- SA014 [SUGGEST] line 6: `always` appears unemphasized twice in "the local baseline fixer that is always available and always runs"
  Note: In an instruction/spec document, directive-strength words like `always` are typically emphasized to signal non-negotiable behavior.

- SA014 [SUGGEST] line 42: `Always` appears unemphasized in "Always exits 0 on success, even if no changes were needed."
  Note: Same pattern — behavioral invariant stated without emphasis.

- SA014 [SUGGEST] line 35: `don't` (contraction of "do not") appears unemphasized twice in "if you don't want them, don't run the tool."
  Note: Contraction softens the directive; the instruction is clearer and more consistently emphasized if written as "do not."

- SA014 [SUGGEST] line 49: `Never` appears unemphasized in "Never CRLF."
  Note: Strong prohibition without emphasis; consistent with the other SA014 instances in this file.

- SA018 [WARN] line 58: passive construction "when run against the same input on the same platform" in R1 directive sentence.
  Note: The main clause is active ("MUST produce"), but the subordinate condition uses passive voice; "given the same input and platform" or "on identical input and platform" would be active equivalents.
