# Markdown Hygiene Specification

## Purpose

Detect markdownlint violations in markdown files and optionally fix them. Default invocation detects only — the file is not modified. Pass `--fix` to apply fixes. Zero errors after fixing is the gate for the fix pass.

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

- `file_path` (string, required): Absolute path to `.md` file to scan (and optionally fix)
- `--model-id <id>` (string, required): The exact model identifier string the caller wants used as the record filename. Lowercase-hyphenated. Examples: `claude-haiku-4-5`, `claude-sonnet-4-6`, `claude-opus-4-7`, `gpt-5-3-codex`. The executor MUST use this string verbatim as the record filename — no inference, no appending date/year/timestamp/qualifier. If `--model-id` is not passed, output `ERROR: --model-id required` and stop.
- `--fix` (flag, optional): Apply fixes to the file after detecting violations. Without this flag, the file is never modified — detection only.
- `--source X --target Y` (string pair, optional): Read X, fix, write to Y.
  X is untouched. No git tracking check. Implies `--fix`.
- `--ignore <RULE>[,<RULE>...]` (string, optional): Comma-separated list of
  markdownlint rule codes to suppress from the violation set. Suppressed rules
  are not flagged and not fixed. Example: `--ignore MD041` suppresses the
  top-level-heading rule for files where its absence is intentional (e.g.,
  skill instruction files). Does not affect other rules.
- `--force` (flag, optional): Re-execute even if a current cached record
  exists for the file's hash. Bypasses the cache-hit early return.
- Adaptive MD041 suppression: if the first non-blank line of the target file
  is `---` (YAML frontmatter), MD041 is automatically suppressed for the run.
  No `--ignore MD041` flag is required.

### Procedure

Two-pass model: detect first, fix second (only if `--fix` is present). The detect pass runs regardless of `--fix`. This splits cognitive load — first pass is read-only analysis, second pass is edit-only.

**Pass 1 — Detect:**

1. Read the target file. Guard: if file is unreadable or not a `.md` file,
   output `ERROR: <reason>` and stop.
2. Compute the git blob hash (`git hash-object <file>`). Check for a cached
   record at `.hash-record/<hash[0:2]>/<hash>/markdown-hygiene/<model>.md`
   (`test -f <path>`). If the file exists and `--force` was not passed, read its
   `result:` frontmatter field — if `pass` output `CLEAN`, if `findings` output
   `findings: <record-path>` — and stop (cache HIT). Otherwise save the parent
   directory as `<cache_dir>` for step 4.
3. Identify all markdownlint violations (all rules enabled, minus `--ignore`
   list and adaptive suppressions). Cross-check each finding against the actual
   line before recording. Hallucinated findings are worse than missed findings.
4. Persist a detect record at `<repo-root>/.hash-record/<hash[0:2]>/<hash>/markdown-hygiene/<model>.md` with:
   - `result: pass` if no violations found; `result: findings` if violations exist.
   - Body per the Body Format section (CLEAN or FINDINGS).
   - If no violations (CLEAN): output `CLEAN` and stop.
   - If violations and `--fix` not passed: output `findings: <record-path>` and stop.

**Pass 2 — Fix (only when `--fix` is present and violations were found):**

5. If ALL violations are unfixable: output `findings: <detect-record-path>` (only 1 record total) and stop.
6. Read the cached detect record. Extract every `Fix:` line from the FINDINGS body. Apply each instruction in-place to the target file (use Edit/Write tools). No re-scan, no markdown-rule knowledge required — pattern-match and execute.
7. If any `Fix:` instruction is not applicable (e.g., the violation is manual-only), skip it and note it as remaining.
8. Compute the new git blob hash of the modified file. Write a second record
   at `<repo-root>/.hash-record/<fix_hash[0:2]>/<fix_hash>/markdown-hygiene/<model>.md` with:
   - `result: pass` if all Fix instructions applied; `result: findings` if some remain.
   - Body per the Body Format section (FIXED or PARTIAL).
   - If all fixed (FIXED): output `CLEAN` and stop. If some remain (PARTIAL): output `findings: <second-record-path>` and stop.

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

**Dispatch return** (one line only):

- Clean (no violations OR all violations fixed): `CLEAN`
- Findings (violations remain — detect-only or PARTIAL): `findings: <absolute-path-to-record.md>`
- Failure before write: `ERROR: <reason>`

**Record frontmatter** — required fields (schema per `hash-record/SKILL.md`):
`hash`, `file_path`, `operation_kind: markdown-hygiene`, `model: <model-id>`,
`result`. The `model` field is set to the value passed via `--model-id` — caller-controlled, executor never modifies it.

`file_path` MUST be a single repo-relative path string — relative to the git root
that contains the `.hash-record/` directory being written to. Compute via
`git ls-files --full-name <file>` from inside the file's repo, or strip the
`git rev-parse --show-toplevel` prefix from the absolute path.

```yaml
# Correct:
file_path: markdown-hygiene/instructions.uncompressed.md

# WRONG (absolute path):
file_path: /abs/path/to/markdown-hygiene/uncompressed.md

# WRONG (directory only, no filename):
file_path: markdown-hygiene/
```

**Filename:** `<model-id>.md` where `<model-id>` is the value passed via the `--model-id` argument. Use it VERBATIM. Append nothing. Do NOT compute or infer your model id from your own knowledge — use only what the caller passed.

The caller controls the filename. The executor's job is to use the supplied value as-is and write the record. If `--model-id` was not passed, stop with `ERROR: --model-id required` before writing any record.

```text
Correct:   .hash-record/<sh>/<hash>/markdown-hygiene/claude-haiku-4-5.md
Incorrect: .hash-record/<sh>/<hash>/markdown-hygiene/claude-haiku-4-5-20251001.md
Incorrect: .hash-record/<sh>/<hash>/markdown-hygiene/skill-auditing-sonnet-claude-sonnet-4-6.md
Incorrect: .hash-record/<sh>/<hash>/markdown-hygiene/claude-sonnet-4-6-2026-04-27T19-17-52Z.md
```

In the Correct example above, `claude-haiku-4-5` is whatever the caller passed as `--model-id`, not what the executor inferred. In the Incorrect examples the executor appended extra tokens or used caller context instead of the explicit argument.

**Body format** — minimum information not already in frontmatter. No `file_path`
duplication in body. Body always opens with `# Result` H1.

CLEAN (detect pass, no violations):

```text
# Result

CLEAN
```

FINDINGS (detect pass, violations exist, no `--fix`):

```text
# Result

FINDINGS

- MD022 line 7: blank line missing before heading "Configuration"
  Fix: insert blank line before line 7
- MD047: file lacks trailing newline
  Fix: append a single newline at end of file
```

Each finding has two lines:

1. Rule code + line number + violation description (what's wrong).
2. Indented `Fix:` line — imperative actionable instruction (what to do).

FIXED (fix pass, all violations resolved):

```text
# Result

FIXED

- MD022: blank lines around heading (1)
- MD047: trailing newline (1)
```

PARTIAL (fix pass, some violations remain unfixable):

```text
# Result

PARTIAL

Fixed:
- MD022 (1)

Remaining (manual):
- MD040 line 14: missing language ID
```

### Verdict Mapping

Frontmatter `result` field values:

- CLEAN -> `pass`
- FIXED -> `pass` (file is now clean)
- FINDINGS -> `findings` (detect-only, no fixes attempted)
- PARTIAL -> `findings` (some fixes applied, some remain)
- Unrecoverable error -> `error`

### Gate

Zero errors after fixing. If any error cannot be auto-fixed, the verdict is PARTIAL.

## Constraints

- The skill MUST NOT infer or compute its model id from internal knowledge. The model id is determined SOLELY by the `--model-id` argument. If `--model-id` is absent, halt with `ERROR: --model-id required`.
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

The hash-record probe (Procedure step 2) is the iteration-safety primitive.
A cache HIT on the git blob hash means the file content has not changed since
the last run; the cached record's result is re-emitted (CLEAN or findings: <path>) without re-executing.

On a two-pass run (`--fix` with findings), the detect record (at the original
hash) and the fix record (at the post-fix hash) are independently cacheable.
A subsequent detect-only call on the fixed file will hit the second record.
`--force` bypasses the cache-hit check when a fresh run is required.

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
