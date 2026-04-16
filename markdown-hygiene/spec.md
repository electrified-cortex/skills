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

- MD001: Heading levels increment by one only
- MD003: Heading style consistency
- MD004: Unordered list style consistency
- MD009: No trailing spaces
- MD010: No hard tabs
- MD012: No multiple consecutive blank lines
- MD022: Blank lines around headings
- MD023: Headings start at line beginning
- MD024: No duplicate heading text
- MD025: Single top-level heading per file
- MD026: No trailing punctuation in headings
- MD029: Ordered list prefix consistency
- MD031: Blank lines around fenced code blocks
- MD032: Blank lines around lists
- MD033: No inline HTML
- MD034: No bare URLs
- MD040: Fenced code blocks must specify language
- MD047: Single trailing newline at end of file
- MD055: Consistent table pipe style
- MD056: Equal column count across table rows
- MD058: Blank lines around tables
- MD060: Table column style (consistent pipe spacing)

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

- Do not recommend, install, or invoke specific external
  tools (e.g. npx, markdownlint-cli2). Use available
  built-in tools and agent intelligence to identify and
  fix violations. "markdownlint" here refers to the rule
  set, not a specific CLI package.
- Never suppress rules — fix them
- Never modify content meaning — only formatting
- Never introduce new violations while fixing others (e.g.,
  adding blank lines while reflowing causes MD012)
- Preserve all technical strings, code blocks, frontmatter
- If a fix would change meaning (e.g., reordering list items),
  report it as unfixable instead of guessing

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
