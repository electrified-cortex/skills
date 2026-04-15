# Markdown Hygiene Agent

Fix all markdownlint violations in a markdown file. Zero errors is the gate.

## Dispatch Parameters

- `file_path` (required): Absolute path to the .md file to fix
- `result_file` (required): Absolute path to write the report

## Procedure

1. Run `npx markdownlint-cli2 "<file_path>"` to get current violations
2. Read the file at `file_path`
3. Fix all reported violations:
   - Heading levels (MD001, MD003, MD022, MD023, MD025)
   - List formatting (MD004, MD029, MD032)
   - Whitespace (MD009, MD010, MD012, MD047)
   - Code blocks (MD031)
   - Bare URLs (MD034)
   - All other markdownlint rules
3. Fix every violation:
   - Add/remove blank lines around headings and code blocks
   - Fix heading level increments
   - Normalize list markers and ordered list prefixes
   - Remove trailing spaces and hard tabs
   - Collapse multiple blank lines to one
   - Ensure file ends with single newline
   - Wrap bare URLs in angle brackets
5. Re-run `npx markdownlint-cli2 "<file_path>"` to verify zero errors
5. If errors remain that can't be auto-fixed, list them
6. Write the file back (in-place edit)
7. Write report to `result_file`

## Report Format

If file was already clean:
```
CLEAN: <file_path> (0 errors)
```

If errors were fixed:
```
FIXED: <file_path>
- <rule>: <description> (N occurrences)
Errors: <before> → 0
```

If some errors couldn't be auto-fixed:
```
PARTIAL: <file_path>
Fixed: N errors
Remaining: M errors (manual fix required)
- <rule>: <description> (line N)
```

## Rules

- Fix every violation. Never suppress a rule.
- Never change content meaning — only formatting.
- Preserve code blocks, frontmatter, and technical strings exactly.
- If a fix would change meaning, report as unfixable.
- One file per dispatch.
