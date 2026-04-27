# Markdown Hygiene

Fix all markdownlint violations in a markdown file. Zero
errors is the gate.

## Dispatch Parameters

- `file_path` (required): Absolute path to the .md file to scan (and optionally fix)
- `--fix` (optional): Apply fixes after detecting violations. Without this flag, the file is never modified — detection only.
- `--source X --target Y` (optional): Read X, fix, write to Y. X untouched. No git check. Implies `--fix`.
- `--ignore <RULE>[,<RULE>...]` (optional): Comma-separated rule codes to skip — not scanned, not flagged, not fixed. Example: `--ignore MD041`.
- `--force` (optional): Re-execute even if a current cached record exists. Bypasses cache-hit early return.
- Adaptive MD041: if the first non-blank line of the target file is `---` (YAML frontmatter), MD041 is auto-suppressed for the run — no flag needed.

## Modes

**Detect (default, no `--fix`):** Read-only. No git-state check. Always runs regardless of whether the file is tracked, untracked, staged, or dirty. Produces one detect record.

**Fix (with `--fix`):** Requires the target file to be tracked + clean (or staged + working-tree-clean). Run `git status --porcelain -- <file>` — proceed only if output is empty or the first character is `M` and the second is a space. Otherwise output `ERROR: target_dirty: stage your changes and re-run with --fix; the cached detect record will carry forward (no rescan)` and stop. The Fix pass writes a second record at the post-fix hash.

**Source→Target:** `--source X --target Y` reads X, applies fixes, writes the clean version to Y. Source untouched. No git-state check. Implies `--fix`.

## Procedure

You are the executor, not a planner. Run each step's tool calls. Do not summarize, do not produce a "fixed version" inline. Do not stop early. The dispatch is incomplete unless a record file was written and you output its absolute path.

Two passes: detect first (always), fix second (only if `--fix` or `--source/--target` was passed).

### Pass 1 — Detect

1. **Read** the target file (use the Read tool). Guard: if the file is unreadable or not a `.md` file, output `ERROR: <reason>` and stop. Check adaptive MD041: if the first non-blank line is `---`, add MD041 to the suppressed set for this run.
2. **Run:** `git hash-object <file_path>` (use the Bash tool). Save the 40-char result as `<hash>`.
3. **Cache check:** `ls <repo-root>/.hash-record/<hash[0:2]>/<hash>/markdown-hygiene/<model>/` (use the Bash tool). Skip if `--force` was passed.
   - Any `*.md` file found: output `PATH: <abs-path-to-latest>` and stop (cache HIT).
   - Directory missing or empty: cache MISS. Save `<repo-root>/.hash-record/<hash[0:2]>/<hash>/markdown-hygiene/<model>/` as `<detect_cache_dir>`. Continue.
4. **Scan** for markdownlint violations. Prefer the `markdownlint` CLI or VS Code extension if available (see co-located `tooling.md`); otherwise use your knowledge of markdown rules. Skip any rule in `--ignore` or the adaptive suppressed set. **Cross-check** each finding against the actual line before recording — drop any finding you cannot point at on a specific verified line.
5. **Write detect record** at `<detect_cache_dir>/<timestamp>.md`:
   - `mkdir -p <detect_cache_dir>` (Bash tool).
   - Frontmatter (open `---`, close `---`):
     - `hash: <hash>`
     - `file_path: <git-relative path>`
     - `operation_kind: markdown-hygiene`
     - `model: <your-model-id>`
     - `timestamp: <YYYY-MM-DDTHH-MM-SS-mmmZ>`
     - `result: pass` (no violations) or `result: findings` (violations exist)
   - Body per Report Format: `# Result\n\nCLEAN` or `# Result\n\nFINDINGS\n\n- <list>`.
   - If no violations (CLEAN): output `PATH: <detect_cache_dir>/<timestamp>.md` and stop.
   - If violations and `--fix` not passed: output `PATH: <detect_cache_dir>/<timestamp>.md` and stop.

### Pass 2 — Fix (only when `--fix` present and violations exist)

6. If ALL violations are unfixable (manual-only rules like MD040 with no language to infer): output `PATH: <detect_record_path>` (no second record) and stop.
7. **Fix every auto-fixable violation** (use the Edit or Write tool — actually modify the file on disk). Rule list:
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
   - MD031 — blank lines BEFORE and AFTER fenced code blocks
   - MD032 — blank lines around lists
   - MD033 — no inline HTML; HTML comments `<!-- ... -->` are inline HTML; exception: HTML inside fenced code blocks is not a violation
   - MD034 — bare URLs in angle brackets
   - MD040 — language identifiers on fenced code blocks (fixable when language is determinable)
   - MD047 — file ends with single newline
   - MD055 — consistent table pipe style
   - MD056 — equal column count across table rows
   - MD058 — blank lines around tables
   - MD060 — table pipe spacing
   - all other markdownlint rules
8. **Write** the fixed content to the target path (in-place, `.fixed`, or `--target` path per the Modes section). The file on disk MUST contain the fixes after this step.
9. **Verify:** re-scan the output to confirm zero remaining errors. Remaining errors are unfixable.
10. **Compute new hash:** `git hash-object <fixed-file-path>`. Save as `<fix_hash>`. Set `<fix_cache_dir>` = `<repo-root>/.hash-record/<fix_hash[0:2]>/<fix_hash>/markdown-hygiene/<model>/`.
11. **Write fix record** at `<fix_cache_dir>/<timestamp>.md`:
    - `mkdir -p <fix_cache_dir>` (Bash tool).
    - Frontmatter:
      - `hash: <fix_hash>`
      - `file_path: <git-relative path>`
      - `operation_kind: markdown-hygiene`
      - `model: <your-model-id>`
      - `timestamp: <YYYY-MM-DDTHH-MM-SS-mmmZ>`
      - `result: pass` (all fixed) or `result: findings` (some remain)
    - Body per Report Format: `# Result\n\nFIXED\n\n- <list>` or `# Result\n\nPARTIAL\n\n...`.
    - Output `PATH: <fix_cache_dir>/<timestamp>.md` and stop.

## Report Format

**Dispatch return** (one line, always):
- Success: `PATH: <absolute-path-to-record.md>`
- Pre-write failure: `ERROR: <reason>`

**Record body** — minimum info not already in frontmatter. Frontmatter holds `file_path`, `result`, `hash`, `timestamp`, `model`. Never duplicate `file_path` in the body. Body always opens with `# Result` H1.

CLEAN (no violations found):

```text
# Result

CLEAN
```

FINDINGS (violations found, no `--fix`):

```text
# Result

FINDINGS

- MD022 line 7: blank line missing
- MD047: trailing newline missing
```

FIXED (all violations resolved):

```text
# Result

FIXED

- MD022: blank lines around heading (1)
- MD047: trailing newline (1)
```

PARTIAL (some violations remain unfixable):

```text
# Result

PARTIAL

Fixed:
- MD022 (1)

Remaining (manual):
- MD040 line 14: missing language ID
```

Verdict mapping for `result` frontmatter:
- CLEAN -> `pass`
- FIXED -> `pass` (file is now clean)
- FINDINGS -> `findings`
- PARTIAL -> `findings`
- Unrecoverable error -> `error`

## Iteration Safety

Cache HIT (Pass 1, step 3) is the iteration-safety primitive. A HIT on the git blob
hash means file content is unchanged — return stored PATH immediately.
On a two-pass run, the detect record (original hash) and fix record (post-fix hash)
are independently cacheable. A subsequent detect-only call on the fixed file hits the
second record. `--force` bypasses the HIT check when a fresh run is required.

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

- Fix every violation. Never suppress a rule unless it appears in the `--ignore` list.
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
