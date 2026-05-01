---
file_path: gh-cli/gh-cli-setup/uncompressed.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 105: Shell commands in the Safety Classification table Command column appear without backticks.
  Note: `gh auth login`, `gh auth logout`, `gh auth status`, `gh config set`, `gh config get`, and `gh repo set-default` are unformatted shell commands in table cells that function as prose.

- SA012 [WARN] line 18: `## Installation` is immediately followed by `### Windows` with no content between.
  Note: The Installation section has no introductory sentence before the first platform subsection.

- SA012 [WARN] line 40: `## Authentication` is immediately followed by `### Interactive — Browser-Based` with no content between.
  Note: The Authentication section has no introductory sentence before the first method subsection.

- SA014 [SUGGEST] line 60: `Never` in "Never hard-code the token value in the command." is unemphasized.
  Note: This is a security-critical directive; bold emphasis would reinforce the constraint.
