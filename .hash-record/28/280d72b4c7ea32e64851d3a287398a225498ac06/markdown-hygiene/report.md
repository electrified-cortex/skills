---
operation_kind: markdown-hygiene
result: fixed
file_path: gh-cli/SKILL.md
---

# Result

lint: `findings: .hash-record/28/280d72b4c7ea32e64851d3a287398a225498ac06/markdown-hygiene/lint.md`
analysis: `pass: .hash-record/28/280d72b4c7ea32e64851d3a287398a225498ac06/markdown-hygiene/analysis.md`

## Fixes Applied

- MD026 line 9: removed trailing colon from "When to Use:" heading
- MD026 line 13: removed trailing colon from "How It Works:" heading
- MD026 line 19: removed trailing colon from "Domain Routing:" heading
- MD026 line 38: removed trailing colon from "PR Sub-skills:" heading
- MD026 line 44: removed trailing colon from "Rules:" heading
- SA010: wrapped directory paths in backticks (lines 36–39)
- SA014: bolded "Never" directive in Rules section
- SA032: changed "domain skill" to "sub-skill" for consistency
- SA035: reordered condition before action in auth-check rule
- SA037: changed item 4 from description to agent instruction
- SA038: resolved contradiction — replaced `gh auth status` command with delegation to `gh-cli-setup/`
