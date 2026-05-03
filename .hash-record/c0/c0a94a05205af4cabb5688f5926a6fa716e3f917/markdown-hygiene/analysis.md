---
file_path: markdown-hygiene/markdown-hygiene-lint/instructions.uncompressed.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA004 [WARN]: Bold is used for all seven procedure step labels and all MD rule identifiers in "MD Rule Reference", densely concentrating bold across a long list.
  Note: Step labels serve a structural/navigational role; MD rule identifiers already carry code semantics and don't require additional emphasis layering.

- SA037 [WARN] line 31: Step 5 closes with "Hallucinated findings are worse than missed findings." — an observation bundled into a command step.
  Note: The rationale sentence is descriptive, not imperative; a reader executing the step may be uncertain whether to act on it or treat it as explanatory context.
