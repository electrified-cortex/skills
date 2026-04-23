---
name: tool-writing
description: >-
  Write tool scripts with companion specs. PowerShell for prototypes,
  Bash as fallback. Spec first, build, audit, repeat until PASS.
---

# Tool Writing

Conventions for creating tool scripts.

## Language Tiers

1. **PowerShell** — default prototype language. Easier to read, better
   error handling, cross-platform (Windows, macOS, Linux). If you have
   Git you almost certainly have Bash too, but PowerShell is preferred
   for readability and development speed.
2. **Bash** — lowest common denominator. If you have Git, you have Bash.
   Use for very simple tools or where PowerShell is unavailable.
3. **C# scripts** (.NET `dotnet-script`) — future tier. Use when complexity
   demands it. Not yet in regular use.

**Rule:** Prototype in PowerShell. Add a Bash counterpart when the tool
is stable. Never prototype in Bash and rewrite — start with the better
language.

## Checklist

1. **Write spec first**: `<name>.spec.md` — purpose, params, output,
   errors, examples. No spec = suspect.
2. **Write prototype** (PowerShell): self-documenting param block, no
   hardcoded paths, no interactive input, works from any CWD.
3. **Place it**: Skill-embedded (inside skill dir) if skill-specific.
   Standalone (`tools/`) if general-purpose.
4. **Audit**: dispatch `tool-auditing` to check spec alignment. Fix all
   findings, re-audit. **Repeat until PASS.**
5. **Add Bash counterpart** (optional but preferred): same logic, same
   gates, same output format. Bash version is not required to unblock
   PASS — it can follow after.

## Completion Gate

> **The tool is NOT done until `tool-auditing` returns PASS.**

FAIL → fix all findings → re-audit. Repeat until PASS.

Do not declare a tool complete, commit it, or hand it off until a PASS
verdict is in hand. There are no exceptions. Receiving FAIL and stopping
work is a workflow violation.

## Conventions

- PowerShell: `$ErrorActionPreference = 'Continue'`, collect errors, `$PSScriptRoot` for paths
- Bash: `set -e`, fail-fast, `$(dirname "$0")` for paths
- Output: markdown for reports, JSON for data, plain text for status
- Never: hardcoded absolute paths, `Read-Host`, `read -p`, or `Get-Credential`

Related: `tool-auditing`, `skill-writing`, `spec-writing`
