---
name: tool-auditing
description: >-
  Audit tool scripts for companion spec, conventions, error handling.
  Lightweight — haiku-class model can run it.
---

# Tool Auditing

Verify tool scripts follow conventions. Dispatch with haiku-class model.

## Checklist (per script)

1. Companion spec (`<name>.spec.md`) exists — FAIL if missing
2. Parameter block at top — WARN if missing
3. No hardcoded absolute paths — FAIL if found
4. Error handling (set -e / $ErrorActionPreference) — WARN if missing
5. Self-documenting (comments/descriptions) — WARN if sparse
6. No interactive input (Read-Host, read -p) — FAIL if found
7. Consistent output format — WARN if unclear

## Report

```
# Tool Audit: <name>
- Status: PASS | FAIL | WARN
- Companion spec: YES/NO
| # | Check | Status | Notes |
```

Read-only. Report only.

Related: `tool-writing`, `skill-auditing`, `spec-auditing`
