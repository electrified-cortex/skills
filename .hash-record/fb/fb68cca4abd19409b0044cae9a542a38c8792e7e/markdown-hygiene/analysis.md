---
file_path: gh-cli/gh-cli-pr/SKILL.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 44: Sub-skill directory paths in the table (e.g., `gh-cli-pr-create/`) appear without backticks.
  Note: All other command and path references in the file use backticks consistently; the Sub-skill column entries are bare strings despite being path/directory references.

- SA032 [WARN]: Sub-skills named with `gh-cli-pr-` prefix in the table but `gh-cli-prs-` prefix in the Related line.
  Note: Four of the five table entries have a counterpart in the Related line where "pr" becomes "prs" (e.g., `gh-cli-pr-create/` vs `gh-cli-prs-create`); it is unclear whether these refer to the same skills under different names or are distinct.

- SA035 [WARN] line 51: "Use `--repo owner/name` when not in local clone of target repo." states the action before the gate condition.
  Note: The directive leads with the action then qualifies it; placing the condition first ("When not in a local clone of the target repo, use `--repo owner/name`") would follow gate-first directive order.
