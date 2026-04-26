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

## Model Tier Rationale

Haiku-class is the designated tier for dispatch. Sonnet-class passes are
equivalent or have diminishing returns for mechanical lint fixing.

## Definitions

No domain-specific terms. Rule identifiers (MD001, MD022, etc.) are markdownlint rule codes — their meaning is defined by the markdownlint rule set, not by this spec.

## Requirements

### Input

- `file_path` (string, required): Absolute path to `.md` file to fix
- `--ignore <RULE>[,<RULE>...]` (string, optional): Comma-separated list of
  markdownlint rule codes to suppress from the violation set. Suppressed rules
  are not flagged and not fixed. Example: `--ignore MD041` suppresses the
  top-level-heading rule for files where its absence is intentional (e.g.,
  skill instruction files). Does not affect other rules.

### Procedure

1. Read the target file
2. Identify all markdownlint violations (all rules enabled)
3. Fix every violation in-place
4. Verify zero errors remain after fixes
5. Write report to the path computed via `audit-reporting` path shape (target-kind derived from the target file path)

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

- The dispatch agent must not invoke, recommend, or install any specific
  external tool. It uses built-in tools and agent intelligence only.
  "markdownlint" here refers to the rule set, not any CLI package.
- Never suggest installing anything — if tooling is not already present
  in the caller's environment, dispatch this skill rather than installing.
- If the calling environment already has linting tooling in place
  (e.g. an active IDE markdown extension, a CLI linter already installed),
  using that directly is preferred over dispatching — it saves tokens
  and avoids LLM-based parsing. `tooling.md` (co-located) lists options.
- Never suppress rules unless the caller explicitly passes `--ignore`; suppressed rules are excluded from the violation set for this run only
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

## Iteration Safety

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.

## Tables

### Canonical Separator Modes

Two modes are acceptable. Choose one per table and never mix them within a single table.

#### Mode A — minimum / default (RECOMMENDED)

1-3 dashes per separator cell with pipe padding. Cell widths do not need to match header widths. This is the default; prefer it unless explicitly optimizing for human readability.

```markdown
| N | Header | Other Header |
| - | --- | --- |
| 1 | value | value |
```

#### Mode B — aligned (acceptable when human readability matters)

Dashes match the header label width. Cells and separators are visually aligned.

```markdown
| Header | Other Header |
| ------ | ------------ |
| value  | value        |
```

### Prohibitions

- **No unpadded pipes.** `|---|---|` violates MD060. Every separator cell must have
  at least one space on each side of the dashes: `| --- |`.
- **No extra whitespace in header labels.** `|  Header  |` must be `| Header |`.
- **No inconsistent separator widths within a single table.**
  All separator cells must follow the same mode (all Mode A or all Mode B).
- **No mixed modes.** Do not combine Mode A separators in some columns with
  Mode B in others.

### Rationale

MD055 (pipe style) and MD060 (table column style) are the primary markdownlint rules
covering tables. Neither is auto-fixable by the CLI, so correct authorship is the only
reliable gate. Codifying two explicit modes eliminates ambiguity about when width-matching
is required.

## Known Gotchas

- **MD060 — table separator, no auto-fix:** Table separator rows using `|---|---|`
  (no spaces) trigger MD060. Canonical form is `| --- | --- |` (spaces around hyphens).
  markdownlint CLI does not auto-fix this rule — author must write canonical form from
  the start or catch it manually. Generated tables commonly produce the wrong form.

## Don'ts

- Content quality (that's spec-auditing/skill-auditing)
- Spell checking
- Link validation (future skill)
