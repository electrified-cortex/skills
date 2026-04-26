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
(unstaged changes), or output shows `??` (untracked), or
output shows `MM` (staged AND additional unstaged changes),
and no `--target` was given, create `<file>.fixed` alongside.

## Procedure

1. Read the file and scan for markdownlint violations
   using your own knowledge of markdown rules.
2. Use any tools already available to you (built-in,
   MCP) to assist — do not install or invoke external
   packages.
3. Fix every violation. Format: `MD<NNN> — description`.
   - MD001 — heading level increments
   - MD003 — heading style consistency (atx vs setext, uniform across file)
   - MD004 — list markers consistent
   - MD009 — no trailing spaces
   - MD010 — no hard tabs
   - MD012 — collapse multiple blank lines to one
   - MD022 — blank lines BEFORE and AFTER headings
   - MD023 — headings start at line beginning, no leading whitespace
   - MD024 — no duplicate headings among siblings
   - MD025 — single H1 per document
   - MD026 — no trailing punctuation in headings
   - MD029 — ordered list prefixes consistent
   - MD031 — blank lines BEFORE and AFTER fenced code blocks (text immediately before/after ` ``` ` triggers this; check every fence)
   - MD032 — blank lines around lists
   - MD033 — no inline HTML; HTML comments `<!-- ... -->` ARE inline HTML and trigger MD033; don't treat as metadata; exception: HTML inside fenced code blocks is not a violation
   - MD034 — bare URLs in angle brackets
   - MD040 — language identifiers on fenced code blocks
   - MD047 — file ends with single newline
   - MD055 — consistent table pipe style
   - MD056 — equal column count across table rows
   - MD058 — blank lines around tables
   - MD060 — table pipe spacing
   - all other markdownlint rules
4. Write to target (in-place, `.fixed`, or `--target` path).
5. Verify: re-run linter on output to confirm zero errors.
6. Cross-check each reported finding by re-reading the cited line. Confirm the rule actually applies. Do NOT report a violation that you cannot point at on a specific line. Hallucinated findings are worse than missed findings — they erode trust in the skill.
7. Compute report path via `audit-reporting` path shape (target-kind from the target file path); write report there.

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

## Iteration Safety

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
- **Intentional bad markdown (edge case):** If a violation appears
  inside an inline code span (`` `...` ``) or is clearly content
  (e.g., a tutorial demonstrating incorrect syntax marked as such),
  preserve as-is and report PARTIAL with the line. Do not fix content
  meant to demonstrate a violation.
