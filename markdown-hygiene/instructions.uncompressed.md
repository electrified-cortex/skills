Fix all markdownlint violations in a markdown file. Zero
errors is the gate.

## Dispatch Parameters

- `file_path` (required): Absolute path to the .md file to fix
- `result_file` (required): Absolute path to write the report
- `--source X --target Y` (optional): Read X, fix, write to Y. No git check. X untouched.

## Modes

**Source→Target:** `--source X --target Y` → read X, fix
all violations, write clean version to Y. Source untouched.

**In-place (default):** Run
`git status --porcelain -- <file>`. If output is empty
(completely clean) or the first character is `M` and the
second character is a space (staged only, working tree
clean), fix directly.

**Fallback:** If the second character is not a space
(unstaged changes), or output shows `??` (untracked), and
no `--target` was given, create `<file>.fixed` alongside.

## Procedure

1. Run `npx markdownlint-cli2 "<file_path>"` if available. Otherwise scan manually.
2. Use any available linting tools (CLI, MCP, built-in) to identify violations.
3. Read the file.
4. Fix every violation:
   - Add/remove blank lines around headings and code blocks (MD022, MD031)
   - Fix heading level increments (MD001)
   - Normalize list markers and ordered list prefixes (MD004, MD029)
   - Remove trailing spaces and hard tabs (MD009, MD010)
   - Collapse multiple blank lines to one (MD012)
   - Ensure file ends with single newline (MD047)
   - Wrap bare URLs in angle brackets (MD034)
   - Add language identifiers to fenced code blocks (MD040)
   - Fix table pipe spacing for consistent style (MD060)
   - Ensure blank lines around tables (MD058)
   - Ensure equal column count across table rows (MD056)
   - Ensure consistent table pipe style (MD055)
   - No trailing punctuation in headings (MD026)
   - No inline HTML where markdown works (MD033)
   - Fix all other markdownlint rules
5. Write to target (in-place, `.fixed`, or `--target` path).
6. Verify: re-run linter on output to confirm zero errors.
7. Write report to `result_file`.

## Report Format

If file was already clean:

```text
CLEAN: <file_path> (0 errors)
```

If errors were fixed:

```text
FIXED: <file_path>
- <rule>: <description> (N occurrences)
Errors: <before> → 0
```

If some errors couldn't be auto-fixed (e.g., embedded HTML for images):

```text
PARTIAL: <file_path>
Fixed: N errors
Remaining: M errors (manual fix required)
- <rule>: <description> (line N)
```

## Rules

- Fix every violation. Never suppress a rule.
- Never change content meaning — only formatting.
- Never introduce new violations while fixing others.
- Preserve code blocks, frontmatter, and technical strings exactly.
- If a fix would change meaning, report as unfixable.
- One file per dispatch.
- Use available tools (markdownlint CLI, MCP tools, etc.) — don't rely on one tool.
