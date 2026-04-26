# Markdown Hygiene

Fix all markdownlint violations in a markdown file. Zero
errors is the gate.

## Dispatch Parameters

- `file_path` (required): Absolute path to the .md file to fix
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

1. Read the file and scan for markdownlint violations
   using your own knowledge of markdown rules.
2. Use any tools already available to you (built-in,
   MCP) to assist — do not install or invoke external
   packages.
3. Fix every violation:
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
4. Write to target (in-place, `.fixed`, or `--target` path).
5. Verify: re-run linter on output to confirm zero errors.
6. Compute report path via `audit-reporting` path shape (target-kind from the target file path); write report there.

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

Verdict mapping for `audit-reporting` frontmatter: `CLEAN → PASS`, `FIXED → PASS_WITH_FINDINGS`, `PARTIAL → NEEDS_REVISION`.

## Iteration safety

Do not re-audit unchanged files. Check git status or mtime before processing — a file already at zero errors with no recent edit should return early with `CLEAN`.

## Tables

Two canonical separator modes — pick one per table, never mix.

### Mode A (default)

1–3 dashes per cell, pipe-padded.
Widths stay flexible.

```markdown
| N | Header | Other Header |
| - | --- | --- |
| 1 | value | value |
```

### Mode B (aligned)

Dashes match header width.
Use only when human readability matters.

```markdown
| Header | Other Header |
| ------ | ------------ |
| value  | value |
```

### Table prohibitions

- No unpadded pipes: `|---|---|` violates MD060. Canonical: `| --- | --- |`.
- No extra whitespace in header labels: `|  Header  |` must be `| Header |`.
- No inconsistent separator widths within one table.
- No mixed Mode A + Mode B in the same table.

The unpadded-pipe case (`|---|---|`) is pattern-detectable and pattern-fixable: insert a space on each side of every dash run. Treat it as a normal violation, not a partial.

## Rules

- Fix every violation. Never suppress a rule.
- Never change content meaning — only formatting.
- Never introduce new violations while fixing others.
- Preserve code blocks, frontmatter, and technical strings exactly.
- If a fix would change meaning, report as unfixable.
- One file per dispatch.
- Use available tools and your own knowledge — do not
  install or invoke external packages.
