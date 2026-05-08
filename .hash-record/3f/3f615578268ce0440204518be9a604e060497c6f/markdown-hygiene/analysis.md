---
file_path: skill-manifest/uncompressed.md
operation_kind: markdown-hygiene-analysis
result: accepted
---

# Result

## Advisory

- SA001 [FAIL] line 30: `NEVER READ THIS FILE` — 4 consecutive ALL-CAPS words, not an acronym.
  Note: Codebase-standard skip-signal convention used across all skill `instructions.txt` files. Acceptable as-is.

- SA009 [WARN] line 22: `Hit:` sub-item spans 4 sentences (imperative + 3-sentence Note block).
  Note: The Note continuation is a structured annotation pattern, not a prose paragraph. Acceptable in a compact skill doc.

- SA032 [WARN] document-level: "skill folder" (line 8) and `skill_dir` (lines 11, 17–20) name the same concept differently.
  Note: Natural split between prose description and parameter identifier. Common in skill specs.
