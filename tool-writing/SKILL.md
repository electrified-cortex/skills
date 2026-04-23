---
name: tool-writing
description: >-
  Write tool scripts with companion specs. PowerShell to prototype and prove,
  Bash as the agent runtime baseline. Spec first, build, audit, port, repeat until PASS.
---

# Tool Writing

Conventions for creating tool scripts.

## Language Tiers

| Tier | Language | When |
|------|----------|------|
| 1 (baseline) | **Bash** | Agent runtime default. If Git is present, Bash is present. What agents actually execute. |
| 2 (prototype) | **PowerShell** | Developer/builder default. Better tooling — VS Code + PSScriptAnalyzer catches errors statically without running. Easier to write correct code fast. |
| 3 (future) | **C# scripts** (.NET `dotnet-script`) | High complexity or performance demands. Not in regular use yet. |
| 4 (future) | **Rust binary** | Distribution, concurrency, or performance requirements. Not in regular use yet. |

**Development workflow:** Prototype in PowerShell → validate statically (VS Code
PSScriptAnalyzer) → prove correct → port to Bash. The PS1 becomes the reference
implementation; the Bash port is its analog.

**Why PowerShell first:** Better static analysis (VS Code can lint without running),
clearer error messages, cleaner param handling. Once the logic is proven in PS1,
translating to Bash is straightforward.

**Why Bash as runtime baseline:** Available wherever Git is installed. Agents running
on remote hosts or in containers may not have PowerShell. Bash is the safe assumption.

## Checklist

1. **Write spec first**: `<name>.spec.md` — purpose, params, output,
   errors, examples. No spec = suspect.
2. **Write prototype** (PowerShell): self-documenting param block, no
   hardcoded paths, no interactive input, works from any CWD.
3. **Validate statically**: Open in VS Code with PowerShell extension.
   PSScriptAnalyzer warnings must be resolved before moving on.
4. **Place it**: Skill-embedded (inside skill dir) if skill-specific.
   Standalone (`tools/`) if general-purpose.
5. **Audit**: dispatch `tool-auditing` to check spec alignment. Fix all
   findings, re-audit. **Repeat until PASS.**
6. **Port to Bash**: Once PS1 is at PASS, write the Bash analog.
   Same logic, same gates, same output format.

## Completion Gate

> **The tool is NOT done until `tool-auditing` returns PASS on the PS1.**

FAIL -> fix all findings -> re-audit. Repeat until PASS.

Bash port can follow after PASS — it does not block the gate.

## Conventions

- PowerShell: `$ErrorActionPreference = 'Continue'`, collect errors, `$PSScriptRoot` for paths
- Bash: `set -e`, fail-fast, `$(dirname "$0")` for paths
- Output: markdown for reports, JSON for data, plain text for status
- Never: hardcoded absolute paths, `Read-Host`, `read -p`, or `Get-Credential`

Related: `tool-auditing`, `skill-writing`, `spec-writing`
