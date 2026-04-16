---
name: markdown-hygiene
description: Spec for the markdown-hygiene dispatch skill — zero-error markdownlint enforcement.
type: spec
---

# Markdown Hygiene Specification

## Purpose

Enforce zero markdownlint errors in markdown files. This is a dispatch
skill — the agent reads the file, fixes all linting issues, and reports
what it changed. Zero errors is the gate, not "fewer" or "minimize."

## Scope

Any `.md` file in the workspace. Primary consumers: skill-writing flow
(pre-commit hygiene pass), spec-writing, agent docs, task docs.

## Why Dispatch

Markdown fixing is mechanical — the agent doesn't need caller context.
It reads a file, applies lint rules, fixes violations, verifies zero
errors remain. Self-contained input/output. Textbook dispatch pattern.

## Requirements

### Input

- `file_path` (string, required): Absolute path to `.md` file to fix
- `result_file` (string, required): Path to write the report

### Procedure

1. Read the target file
2. Identify all markdownlint violations (all rules enabled)
3. Fix every violation in-place
4. Verify zero errors remain after fixes
5. Write report to `result_file`

### Rules to enforce (non-exhaustive, all markdownlint rules apply)

- MD001: Heading levels should only increment by one
- MD003: Heading style consistency
- MD004: Unordered list style consistency
- MD009: Trailing spaces
- MD010: Hard tabs
- MD012: Multiple consecutive blank lines
- MD022: Headings should be surrounded by blank lines
- MD023: Headings must start at the beginning of the line
- MD025: Single top-level heading (per file)
- MD029: Ordered list item prefix (1. 2. 3. not 1. 1. 1.)
- MD031: Fenced code blocks should be surrounded by blank lines
- MD032: Lists should be surrounded by blank lines
- MD034: Bare URLs
- MD047: Files should end with a single newline

### Output

Report format:

```text
CLEAN: <file_path> (0 errors)
```

or

```text
FIXED: <file_path>
- <rule>: <description of fix> (N occurrences)
- <rule>: <description of fix> (N occurrences)
Errors: <before> → 0
```

### Gate

Zero errors after fixing. If any error cannot be auto-fixed:

```text
PARTIAL: <file_path>
Fixed: N errors
Remaining: M errors (manual fix required)
- <rule>: <description> (line N)
```

## Constraints

- Never suppress rules — fix them
- Never modify content meaning — only formatting
- Preserve all technical strings, code blocks, frontmatter
- If a fix would change meaning (e.g., reordering list items), report
  it as unfixable instead of guessing

## Integration

Markdown hygiene should run:
1. After compression (compressed files may have lint issues)
2. Before stamping (only stamp clean files)
3. As part of skill-auditing checklist (future addition)
4. Before any commit of `.md` files

## Non-Goals

- Content quality (that's spec-auditing/skill-auditing)
- Spell checking
- Link validation (future skill)
