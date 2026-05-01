---
file_path: gh-cli/gh-cli-pr/gh-cli-pr-inline-comment/SKILL.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA014 [SUGGEST] line 53: `never` unemphasized in instruction document.
  Note: "Never use deprecated `position`" — the word "Never" appears as plain prose without bold or other emphasis; marking it as **Never** would make the directive visually distinct from surrounding text.

- SA015 [WARN]: document exceeds 400 words with zero markdown headings.
  Note: Sections are labeled using plain-text lines ("Prerequisites — verify auth:", "Step 1 — …", "Edit:", "Comments vs. Threads:", "Errors:", etc.) rather than markdown headings (`#`/`##`); readers and tooling cannot detect document structure from the heading hierarchy.
