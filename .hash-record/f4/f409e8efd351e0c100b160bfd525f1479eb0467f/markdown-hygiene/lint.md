---
file_path: messaging/SKILL.md
operation_kind: markdown-hygiene-lint
result: fail
---

# Result

FINDINGS

- MD032 line 100: Ordered list begins without a blank line before it (`On Startup:` on line 99 immediately precedes list item `1.` on line 100).
  Fix: Insert a blank line between line 99 (`On Startup:`) and line 100 (`1. \`init --name <own-name>\``).
- MD032 line 118: Ordered list begins without a blank line before it (`For each msg object in JSON array from \`drain\`:` on line 117 immediately precedes list item `1.` on line 118).
  Fix: Insert a blank line between line 117 (`For each msg object in JSON array from \`drain\`:`) and line 118 (`1. Read fields: \`from\`, \`sent\`, \`body\`. Check for optional \`subject\`.`).
