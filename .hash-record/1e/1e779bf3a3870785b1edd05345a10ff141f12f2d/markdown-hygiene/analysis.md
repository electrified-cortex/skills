---
file_path: hash-record/hash-record-rekey/rekey.spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA006 [FAIL] line 123: `## Flags` section contains a single-item list
  Note: The Flags section has exactly one item (`--help` / `-h`). Could be written as a sentence or inline with the section intro.

- SA032 [WARN] document-level: the concept of "re-keying" is referred to inconsistently as both "rekey" (unhyphenated, dominant usage, 39 occurrences) and "re-key" (hyphenated, 2 occurrences at lines 5 and 14)
  Note: "re-keys" (line 5) and "re-key" (line 14) appear in introductory prose while "rekey" is used throughout the rest of the document; using one form consistently would reduce ambiguity.
