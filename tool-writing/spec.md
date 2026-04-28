# Tool Writing — Spec

How to write tool scripts in the workspace.

## Purpose

Define conventions for creating, placing, and documenting tool scripts
so they are discoverable, auditable, and maintainable.

## Scope

### In Scope

- Shell script creation (Bash and PowerShell)
- Companion spec file requirements
- Placement conventions (standalone tools/ or inside skill folders)
- Parameter documentation
- Error handling patterns

### Out of Scope

- Skill creation (see skill-writing)
- Agent file creation (see agent-builder)
- TypeScript/Node.js tool development

## Definitions

- **Tool script**: A shell script (.sh or .ps1) that performs a specific
  operation. Invoked directly or by agents via Bash/PowerShell tools.
- **Companion spec**: A `.spec.md` file that defines the tool's behavior,
  parameters, and expected output. Named `<tool-name>.spec.md`.
- **Standalone tool**: A script in a `tools/` directory.
- **Skill-embedded tool**: A script inside a skill's directory, paired
  with the skill it supports.

## Requirements

### Language Choice

#### Normative

1. Bash (.sh) is the default for agent-facing tools — universally
   accepted across environments.
2. PowerShell (.ps1) is a legitimate choice, especially for Windows-
   native operations, complex object manipulation, or when PowerShell
   is more featured for the task.
3. Both languages are first-class. Neither is villainized.
4. If both exist for the same tool, one may wrap the other.

### Companion Spec

#### Normative

Every tool script must have a companion `.spec.md` file that defines:

1. Purpose — what the tool does
2. Parameters — all inputs with types, defaults, required/optional
3. Output — what the tool produces (stdout format, files created)
4. Error handling — how failures are reported
5. Dependencies — what must exist for the tool to work
6. Examples — at least one usage example

No spec = suspect. A tool without a spec has not been through the
proper lifecycle.

### Placement

#### Normative

Tools can live in two locations:

1. **Standalone**: `<agent>/tools/` or `.agents/tools/` for shared tools
2. **Skill-embedded**: Inside a skill directory alongside SKILL.md

Skill-embedded tools are preferred when the tool only makes sense in
the context of that skill. Standalone tools are for general-purpose
utilities.

### Script Conventions

#### Normative

1. Scripts must be self-documenting — parameter block at the top with
   descriptions.
2. Use `$ErrorActionPreference = 'Continue'` in PowerShell for non-
   fatal error collection.
3. Use `set -e` in Bash for fail-fast behavior.
4. Output format should be predictable — markdown for reports, JSON
   for data, plain text for status.
5. No hardcoded absolute paths — use relative paths or environment
   variables.
6. Scripts must handle missing inputs gracefully with clear error
   messages.

## Constraints

- Tools must not modify files outside their documented scope.
- Tools must not require interactive input (agents can't interact).
- Tools must work from any CWD (use script-relative paths).
- Scripts in skill folders follow the same naming and spec conventions.

## Defaults and Assumptions

- Default shell for new tools: Bash (unless PowerShell is clearly better)
- Default spec location: same directory as the script
- Default output: stdout (markdown format for reports)

## Behavior

- An agent producing a tool script must create the companion `.spec.md` in the same directory before or alongside the script.
- Bash is selected by default unless PowerShell is clearly more appropriate for the task; the choice must be documented in the companion spec.
- A tool script must emit predictable output: markdown for reports, JSON for structured data, plain text for status. The format must be stated in the companion spec.
- Scripts must not prompt for interactive input; agents cannot respond to prompts.
- All inputs must be validated at script entry; a missing required parameter must print a clear error and exit non-zero.

## Error Handling

- Scripts must report failures with a non-zero exit code.
- Bash scripts must use `set -e` so unexpected errors halt execution rather than continuing silently.
- PowerShell scripts must use `$ErrorActionPreference = 'Continue'` for non-fatal error collection; callers check exit code.
- Error messages must name the missing or invalid input and state what was expected.
- A tool that exits non-zero must not produce partial output that callers might treat as valid.

## Precedence Rules

- Companion spec governs the script — any conflict, spec wins.
- This spec governs tool-writing.

## Don'ts

- Defining tool execution permissions (see agent hooks)
- Tool deployment or distribution
- IDE integration
