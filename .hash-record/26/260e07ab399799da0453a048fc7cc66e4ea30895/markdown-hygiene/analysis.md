---
file_path: hash-record/hash-record-rekey/usage-guide.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 26: `git mv` used in prose without backticks
  Note: "git mv already staged the rename." — `git mv` is a shell command and should appear in backticks.

- SA010 [WARN] line 46: `git mv` used in prose without backticks
  Note: "git mv auto-stages the rename;" — same command used without backticks.

- SA010 [WARN] line 7: `hash-record-check` used in prose without backticks
  Note: "hash-record-check returns MISS for new hash" — tool name used as a bare identifier in prose.

- SA010 [WARN] line 8: `hash-record-rekey` used in prose without backticks
  Note: "Run hash-record-rekey to find/move the old record" — tool name used as a bare identifier in prose.

- SA010 [WARN] line 27: `hash-record-check` used in prose without backticks
  Note: "Record now discoverable via hash-record-check." — tool name used as bare identifier.

- SA015 [WARN] document-level: document is over 400 words with zero headings (compressed format uses label-prefixed sections instead)
  Note: Compressed usage guide format intentionally omits headings in favour of inline labels like "Use when:", "Steps:", "Constraints:". This is an accepted structural pattern for compressed skill documents.

Skipped: SA015 — compressed format omits headings by design; accepted for usage-guide.md in this skill.
