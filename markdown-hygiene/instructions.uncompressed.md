# Markdown Hygiene

Detect and optionally fix markdownlint violations. Zero errors after the fix pass is the gate.

## Dispatch Parameters

- `file_path` (required): Absolute path to the .md file to scan (and optionally fix)
- `--model-id <id>` (required): The exact model identifier string the caller wants used as the record filename. Lowercase-hyphenated. Examples: `claude-haiku-4-5`, `claude-sonnet-4-6`, `claude-opus-4-7`, `gpt-5-3-codex`. The executor MUST use this string verbatim as the record filename — no inference, no appending date/year/timestamp/qualifier. If `--model-id` is not passed, output `ERROR: --model-id required` and stop.
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

0. **Guard:** If `--model-id` was not passed, output `ERROR: --model-id required` and stop immediately.
1. **Read** the target file (use the Read tool). Guard: if the file is unreadable or not a `.md` file, output `ERROR: <reason>` and stop. Check adaptive MD041: if the first non-blank line is `---`, add MD041 to the suppressed set for this run.
2. **Run:** `git hash-object <file_path>` (use the Bash tool). Save the 40-char result as `<hash>`.
3. **Cache check:** `test -f <repo-root>/.hash-record/<hash[0:2]>/<hash>/markdown-hygiene/<model-id>.md` (use the Bash tool) where `<model-id>` is the value from `--model-id`. Skip if `--force` was passed.
   - File exists: read its `result:` frontmatter field — if `pass` output `CLEAN`; if `findings` output `findings: <repo-root>/.hash-record/<hash[0:2]>/<hash>/markdown-hygiene/<model-id>.md` — and stop (cache HIT).
   - File does not exist: cache MISS. Save `<repo-root>/.hash-record/<hash[0:2]>/<hash>/markdown-hygiene` as `<detect_cache_dir>` (no trailing slash). Continue.
4. **Scan** for markdownlint violations. Prefer the `markdownlint` CLI or VS Code extension if available (see co-located `tooling.md`); otherwise use your knowledge of markdown rules. Skip any rule in `--ignore` or the adaptive suppressed set. **Cross-check** each finding against the actual line before recording — drop any finding you cannot point at on a specific verified line. Per-rule detection anchors:
   - MD001 — heading levels must increment by one (H1->H3 is a violation)
   - MD003 — heading style must be consistent (atx `#` vs setext `===`/`---`): flag any heading that differs from the first heading's style
   - MD004 — list markers must be consistent (`-`, `*`, `+`): flag any list item using a different marker than the first in its list
   - MD009 — trailing spaces: flag any line ending with one or more spaces (except two-space line-break if the file uses them)
   - MD010 — hard tabs: flag any literal tab character in non-code-block content
   - MD012 — multiple consecutive blank lines: flag runs of 2+ blank lines
   - MD022 — headings must be preceded AND followed by a blank line (except at file start/end)
   - MD023 — headings must not have leading whitespace (line must begin with `#`)
   - MD024 — duplicate heading text among siblings: flag if two headings at the same level and same parent share identical text
   - MD025 — only one H1 per file: flag every H1 after the first
   - MD026 — headings must not end with punctuation (`.`, `!`, `?`, `:`, `,`, `;`)
   - MD029 — ordered list prefixes must be consistent: either all `1.` or strictly incrementing
   - MD031 — fenced code blocks must be preceded AND followed by a blank line
   - MD032 — lists must be preceded AND followed by a blank line
   - MD033 — no inline HTML: flag `<tag>`, `</tag>`, and `<!-- comment -->` outside fenced code blocks
   - MD034 — bare URLs: flag any `http://` or `https://` not inside angle brackets, backticks, or a link
   - MD040 — fenced code blocks must have a language identifier (` ```python `, not bare ` ``` `)
   - MD041 — first non-blank line must be an H1 (suppressed when frontmatter detected or `--ignore MD041`)
   - MD047 — file must end with exactly one newline character
   - MD055 — table pipe style must be consistent across all rows in a table
   - MD056 — all rows in a table must have the same number of cells
   - MD058 — tables must be preceded AND followed by a blank line
   - MD060 — table cell separators must have a space on each side of the dash run (`| --- |` not `|---|`)
5. **Write detect record** at `<detect_cache_dir>/<model-id>.md`:
   - **Filename:** `<model-id>.md` where `<model-id>` is the value passed via the `--model-id` argument. Use it VERBATIM. Append nothing. Do NOT compute or infer your model id from your own knowledge — use only what the caller passed.

     The caller controls the filename. The executor's job is to use the supplied value as-is. If `--model-id` was not passed, stop with `ERROR: --model-id required` before writing any record.

     ```text
     Correct:   .hash-record/<sh>/<hash>/markdown-hygiene/claude-haiku-4-5.md
     Incorrect: .hash-record/<sh>/<hash>/markdown-hygiene/claude-haiku-4-5-20251001.md
     Incorrect: .hash-record/<sh>/<hash>/markdown-hygiene/skill-auditing-sonnet-claude-sonnet-4-6.md
     Incorrect: .hash-record/<sh>/<hash>/markdown-hygiene/claude-sonnet-4-6-2026-04-27T19-17-52Z.md
     ```

     In the Correct example, `claude-haiku-4-5` is whatever the caller passed as `--model-id`, not what the executor inferred. In the Incorrect examples the executor appended extra tokens or used caller context instead of the explicit argument.

   - `mkdir -p <detect_cache_dir>` (Bash tool).
   - Frontmatter (open `---`, close `---`):
     - `hash: <hash>`
     - `file_path: <repo-relative path>` — MUST be a single repo-relative path string relative to the git root containing `.hash-record/`. Compute via `git ls-files --full-name <file>` from inside the file's repo, or strip `git rev-parse --show-toplevel` from the absolute path. Example: `markdown-hygiene/instructions.uncompressed.md`. NOT an absolute path, NOT a directory-only path.
     - `operation_kind: markdown-hygiene`
     - `model: <model-id>` — set to the value passed via `--model-id`; caller-controlled, executor never modifies
     - `result: pass` (no violations) or `result: findings` (violations exist)
   - Body per Report Format: `# Result\n\nCLEAN` (no violations) or `# Result\n\nFINDINGS\n\n- <list>` (violations). For FINDINGS each entry is two lines: the finding line (`MD0XX line N: <description>`) followed immediately by an indented `Fix: <imperative instruction>` line. The `Fix:` line must be a complete, standalone instruction — the fix pass will apply it literally without any markdown-rule knowledge.
   - If no violations (CLEAN): output `CLEAN` and stop.
   - If violations and `--fix` not passed: output `findings: <detect_cache_dir>/<model-id>.md` and stop.

### Pass 2 — Fix (only when `--fix` present and violations exist)

6. If ALL violations are unfixable (manual-only rules like MD040 with no language to infer): output `findings: <detect_record_path>` (no second record) and stop.
7. **Read the detect record** written in step 5 (use the Read tool). Extract every `Fix:` line from the FINDINGS body. Each `Fix:` line is a standalone imperative instruction — apply it literally to the target file using the Edit or Write tool. No re-scan. No markdown-rule knowledge required. For each `Fix:` line: either apply it successfully or mark it as not applicable (unfixable). The file on disk MUST contain all applied fixes after this step.
8. **Compute new hash:** `git hash-object <fixed-file-path>`. Save as `<fix_hash>`. Set `<fix_cache_dir>` = `<repo-root>/.hash-record/<fix_hash[0:2]>/<fix_hash>/markdown-hygiene` (no trailing slash).
9. **Write fix record** at `<fix_cache_dir>/<model-id>.md`:
   - `mkdir -p <fix_cache_dir>` (Bash tool).
   - Frontmatter:
     - `hash: <fix_hash>`
     - `file_path: <repo-relative path>` — same rule as step 5: repo-relative, not absolute, not directory-only.
     - `operation_kind: markdown-hygiene`
     - `model: <model-id>` — set to the value passed via `--model-id`; caller-controlled, executor never modifies
     - `result: pass` (all Fix instructions applied) or `result: findings` (some not applicable / remain)
   - Body per Report Format: `# Result\n\nFIXED\n\n- <list>` (all applied) or `# Result\n\nPARTIAL\n\n...` (some remain).
   - If all fixed (FIXED): output `CLEAN` and stop. If some remain (PARTIAL): output `findings: <fix_cache_dir>/<model-id>.md` and stop.

## Report Format

**Dispatch return** (one line, always):

- Clean (no violations OR all violations fixed): `CLEAN`
- Findings (violations remain — detect-only or PARTIAL): `findings: <absolute-path-to-record.md>`
- Pre-write failure: `ERROR: <reason>`

**Record body** — minimum info not already in frontmatter. Frontmatter holds `file_path`, `result`, `hash`, `model`. Never duplicate `file_path` in the body. Body always opens with `# Result` H1.

CLEAN (no violations found):

```text
# Result

CLEAN
```

FINDINGS (violations found, no `--fix`):

```text
# Result

FINDINGS

- MD022 line 7: blank line missing before heading "Configuration"
  Fix: insert blank line before line 7
- MD047: file lacks trailing newline
  Fix: append a single newline at end of file
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
