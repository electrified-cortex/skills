---
name: tool-auditing
description: >-
  Audit tool scripts for companion spec, conventions, error handling.
  Lightweight — haiku-class model can run it.
---

# Tool Auditing

Verify tool scripts follow conventions. Dispatch with haiku-class model.

## Checklist (per script)

1. Companion spec (`<name>.spec.md`) in same dir — FAIL if missing.
2. Parameter/usage block at top of script — WARN if missing.
3. No hardcoded absolute paths (e.g., `D:\...`, `/home/...`) — FAIL if found.
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

Related: `tool-writing`, `skill-auditing`, `spec-auditing`
