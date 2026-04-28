---
name: tool-auditing
description: Audit tool scripts for companion spec, conventions, and error handling. Triggers — audit tool, check tool script, review tool conventions, tool compliance, tool script audit.
---

Verify tool scripts follow conventions. Run checklist against each script directly.

## Checklist (per script)

1. Companion spec (`<name>.spec.md`) in same dir — FAIL if missing.
2. Parameter/usage block at top of script — WARN if missing.
3. No hardcoded absolute paths (Windows drive-letter prefixes or unix `/home/...`, `/Users/...` roots) — FAIL if found.
4. Error handling: Bash `set -e` (or equivalent); PowerShell `$ErrorActionPreference` — WARN if missing.
5. Self-documenting: parameter descriptions or leading comments — WARN if sparse (fewer than one comment per logical block).
6. No interactive input (`Read-Host`, `read -p`, `Get-Credential`) — FAIL if found.
7. Consistent output format (markdown / JSON / plain text, one mode) — WARN if mixed or unclear.

## Report

```markdown
# Tool Audit: <script-name>

- Status: PASS | FAIL | WARN
- Companion spec: YES/NO
- Checks: X/7 passed

| # | Check | Status | Notes |
|---|-------|--------|-------|
```

Read-only. Report only — caller decides remediation.

## Output

Write findings to `.hash-record/` via the `hash-record` skill. Targets are `tools/**` — use target-kind `tool`. Verdict enum: `PASS`, `FAIL`, `PASS_WITH_FINDINGS` (maps from internal `WARN`). The `## Report` body may keep `WARN`; the `result` frontmatter field in the hash-record must use the verdict enum above.

## Iteration Safety

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.

Related: `tool-writing`, `skill-auditing`, `spec-auditing`
