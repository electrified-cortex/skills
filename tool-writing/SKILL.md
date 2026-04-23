---
name: tool-writing
description: >-
  Write tool scripts with companion specs. Bash default for agents,
  PowerShell legitimate. Scripts can live in skill folders.
---

# Tool Writing

Conventions for creating tool scripts.

## Checklist

1. **Choose language**: Bash default for agents. PowerShell when more
   featured or Windows-native. Both first-class.
2. **Write spec first**: `<name>.spec.md` — purpose, params, output,
   errors, examples. No spec = suspect.
3. **Write script**: Self-documenting param block. No hardcoded paths.
   No interactive input. Works from any CWD.
4. **Place it**: Skill-embedded (inside skill dir) if skill-specific.
   Standalone (`tools/`) if general-purpose.
5. **Test**: Run with valid + invalid inputs. Verify output format.
6. **Audit**: use `tool-auditing` to verify. Fix findings, re-audit. **Repeat until PASS.**

## Completion Gate

> **The tool is NOT done until `tool-auditing` returns PASS.**

FAIL → fix all findings → re-audit. Repeat until PASS.

Do not declare a tool complete, commit it, or hand it off until a PASS
verdict is in hand. There are no exceptions. Receiving FAIL and stopping
work is a workflow violation.

## Conventions

- Bash: `set -e`, fail-fast
- PowerShell: `$ErrorActionPreference = 'Continue'`, collect errors
- Output: markdown for reports, JSON for data, plain text for status
- Paths: script-relative via `$PSScriptRoot` or `$(dirname "$0")`

Related: `tool-auditing`, `skill-writing`, `spec-writing`
