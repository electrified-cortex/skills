---
hash: af3ff43332ab79e3e76b6ae64d6aae390c34e22d
file_path: tool-auditing/spec.md
operation_kind: markdown-hygiene
result: findings
---

# Result

FINDINGS

- MD025 line 58: multiple H1 headings; only one H1 permitted per file
  Fix: change line 58 from `# Tool Audit: <script-name>` to `## Tool Audit: <script-name>` (atx H2)
