---
file_path: gh-cli/uncompressed.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA001 [FAIL] line 24: "NEVER READ OR INTERPRET" contains 4 consecutive ALL-CAPS words.
  Note: The prohibition could be conveyed with `NEVER` alone followed by normal-case words; stacking READ, OR, INTERPRET in caps exceeds the emphasis needed.

- SA014 [SUGGEST] line 20: `Don't read \`instructions.txt\` yourself.` — directive keyword "don't" (do not) is unemphasized.
  Note: The same prohibition is restated in ALL CAPS on line 24; the earlier softer instance carries no emphasis signal, making the two occurrences inconsistent in weight.
