---
file_path: hash-record/hash-record-rekey/usage-guide.uncompressed.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 75: `git mv` used in prose without backticks
  Note: "The move is staged in git automatically (git mv)." — `git mv` is a shell command appearing without backtick formatting.

- SA028 [WARN] document-level: phrase "hash-record entry" appears 2 times; phrase "the old hash" appears 3 times
  Note: Repetition is intentional for clarity in a reference document; accepted as-is.

Skipped: SA028 — repetition intentional in usage context; accepted.
