# Markdown Hygiene Specification

## Purpose

Detect markdownlint violations in a `.md` file and produce a cache record with
imperative `Fix:` instructions for each finding. The target file is never modified
by the executor. Fixes are applied by a separate ad-hoc dispatch at the host
orchestration layer, which also drives an iteration loop until the file is clean
or the iteration limit is reached.

## Architecture

The skill has two distinct layers. They are separate concerns implemented in
separate files.

### Executor Layer (`instructions.txt`)

The executor is a detect-only agent dispatched via the `dispatch` skill. It:

- Reads `<markdown_file_path>`, computes violations, delegates cache path lookup
  to `hash-record-check`, and writes a `report.md` record at the path provided.
- Returns one of three values to its dispatch caller:
  - `CLEAN` — no violations, or cache HIT with `result: pass`
  - `findings: <abs-path-to-record.md>` — violations found (or cache HIT with findings)
  - `ERROR: <reason>` — failure before record write
- Never modifies the target file.
- Hard prohibition on script authoring (see Constraints).
- THIS LAYER IS UNCHANGED by the iteration logic — the executor always runs a
  single detect pass.

### Host Orchestration Layer (`SKILL.md` / `uncompressed.md`)

The host is the agent that reads `SKILL.md` and drives the full workflow. It:

1. Optionally runs a linter auto-fix pre-pass if a linter is available (cheap
   mechanical fixes; skip if absent).
2. Composes the detect `<prompt>` and invokes the executor via the `dispatch` skill
   (`fast-cheap` tier). See Dispatch Surface below.
3. Enters the iteration loop:
   - `CLEAN` -> stop.
   - `ERROR` -> stop, surface reason.
   - `findings: <report-path>` -> compose the fix `<prompt>` and dispatch a
     **fix pass** (`standard` tier), then re-invoke the detect pass.
4. Max 3 detect iterations. If findings remain after the 3rd detect pass, stop and
   return the last `<report-path>` to the caller.

The fix pass is an ad-hoc dispatch — it is NOT the executor. It uses the `dispatch`
skill with a free-form prompt, operates on the original `<markdown_file_path>`, and
uses the report file only as guidance. The executor and the fix pass are completely
separate agents.

### Dispatch Surface

The `dispatch` skill takes a single `<prompt>` — a verbatim string sent to the
sub-agent. It does NOT perform template substitution. The host composes the full
prompt before calling dispatch.

**Detect (Inspect) prompt** — host-composed variables:

- `<instructions-abspath>` = absolute path to `instructions.txt` in this skill folder
- `<input-args>` = `<markdown_file_path> [--ignore <RULE>[,<RULE>...]]`
- `<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`

The `<instructions-abspath>` variable is internal to the host. It is NOT passed as a
dispatch input — it is substituted by the host when constructing `<prompt>`.

**Fix pass prompt** — host-composed variables:

- `<prompt>` = `For this <markdown_file_path>, read <report-path> and fix any issues.`

Both passes use the same `dispatch` envelope. No special cases in the dispatch
primitive itself.

## Scope

Any `.md` file in the workspace. Primary consumers: skill-writing flow
(pre-commit hygiene pass), spec-writing, agent docs, task docs.

## Why Dispatch

Markdown linting is mechanical — the executor doesn't need caller context.
It reads a file, applies lint rules, records findings with actionable fix
instructions. Self-contained input/output. Textbook dispatch pattern.

## Model Tier Rationale

Haiku-class is the designated tier for the detect (executor) dispatch. The task is
mechanical pattern-matching; sonnet-class adds no value and wastes tokens.
The fix pass uses `standard` tier (sonnet-class) because editing requires more
judgment.

## Definitions

No domain-specific terms. Rule identifiers (MD001, MD022, etc.) are markdownlint
rule codes — their meaning is defined by the markdownlint rule set, not by this spec.

## Requirements

### Inputs (Host Layer)

Input shape: `<markdown_file_path> [--ignore <RULE>[,<RULE>...]]`

- `<markdown_file_path>` (positional, required): Absolute path to the `.md` file
  to scan. No other positional argument exists.
- `--ignore <RULE>[,<RULE>...]` (optional): Comma-separated list of markdownlint
  rule codes to suppress from the violation set for this run only. Suppressed rules
  are not flagged. Example: `--ignore MD041` for files where no top-level heading
  is intentional.
- Adaptive MD041 suppression: if the first non-blank line of the target file is
  `---` (YAML frontmatter), MD041 is automatically suppressed. No `--ignore MD041`
  flag is required.

There are no `--fix`, `--force`, `--source`, `--target`, or `--filename` flags.

### Executor Procedure

Cache-first ordering: hash check before reading the file. A cache HIT short-circuits
with no file Read tool call.

**Step 1 — Cache check.**

Invoke the `hash-record-check` skill located at
`electrified-cortex/hash-record/hash-record-check/` with:

```text
<markdown_file_path> markdown-hygiene report.md
```

Branch on the skill's one-line stdout:

- `HIT: <abs-path>` — read the record. Frontmatter `result: pass` -> output `CLEAN`,
  stop. Otherwise -> output `findings: <abs-path>`, stop.
- `MISS: <abs-path>` — save as `<record_path>`; this is the path to write in step 4.
  Continue to step 2.
- `ERROR: <reason>` — output `ERROR: <reason>`, stop.

The executor does NOT compute the git blob hash or build the cache path inline —
that is hash-record-check's responsibility.

**Step 2 — Scan** `<markdown_file_path>` for violations. Order of preference:

1. Available markdown linter (`markdownlint` CLI, VS Code/Cursor extension, or
   equivalent). Read its output to build the findings list.
2. If no linter is available: read the file and apply rule-knowledge from the
   reference list in step 3 directly. Cross-check each suspected finding against
   the actual line — drop any finding that cannot be pointed at on a specific
   verified line. Hallucinated findings are worse than missed findings.

Skip rules in `--ignore`. Cover every rule in step 3, including all four table
rules (MD055/MD056/MD058/MD060) — tables are high-frequency residual violators.

**Step 3 — Adaptive MD041.** Read the first non-blank line (e.g. `head -n 5`).
If it is `---` (YAML frontmatter), drop any MD041 finding and record
`adaptive: MD041 suppressed` in the cache record.

**Step 4 — Write record** at `<record_path>` (path from step 1):

- `mkdir -p <cache_dir>` (Bash).
- Frontmatter fields (between `---` delimiters):
  - `hash: <hash>`
  - `file_path: <repo-relative path>` — repo-relative string, NOT absolute, NOT
    directory-only. Compute via `git ls-files --full-name <file>` or strip
    `<repo_root>/` from the absolute path.
  - `operation_kind: markdown-hygiene`
  - `result: pass` (no violations) or `result: findings` (violations found)
- Body (see Body Format section):
  - No violations: output `CLEAN`, stop.
  - Violations: output `findings: <record_path>`, stop.

`file_path` examples:

```yaml
# Correct:
file_path: markdown-hygiene/instructions.uncompressed.md

# WRONG (absolute path):
file_path: /abs/path/to/markdown-hygiene/uncompressed.md

# WRONG (directory only, no filename):
file_path: markdown-hygiene/
```

The record filename is hardcoded `report.md`. It is not configurable.

### Host Iteration Loop

After each detect dispatch, the host branches:

- `CLEAN` -> stop. Return `CLEAN` to caller.
- `ERROR` -> stop. Surface `ERROR: <reason>` to caller.
- `findings: <report-path>` -> dispatch fix pass, then re-invoke detect.

**Detect pass dispatch:**

- Skill: `dispatch`
- Tier: `fast-cheap`
- Description: `Inspecting Markdown Hygiene: <markdown_file_path>`
- Prompt (host-composed): `Read and follow <instructions-abspath>; Input: <markdown_file_path> [--ignore <RULE>[,<RULE>...]]`

**Fix pass dispatch** (separate from executor):

- Skill: `dispatch`
- Tier: `standard`
- Description: `Fixing Markdown Hygiene: <markdown_file_path>`
- Prompt (host-composed): `For this <markdown_file_path>, read <report-path> and fix any issues.`
- This is a free-form agent prompt, not the executor instructions. The fix agent
  reads the report and edits `<markdown_file_path>` directly.

Both passes go through the same `dispatch` primitive. The dispatch primitive receives
only `<prompt>` — it does not perform template substitution. The host is the only
party that constructs prompt strings.

**Max 3 detect iterations.** If findings remain after the 3rd detect pass, stop
and return `findings: <last-report-path>` to caller.

### Rules to enforce (Executor)

- MD001 — heading levels increment by one (H1 to H3 violates)
- MD003 — heading style consistent (atx `#` vs setext `===`/`---`); flag headings differing from the first
- MD004 — list markers consistent (`-`, `*`, `+`); flag items using a different marker than the first in the list
- MD009 — trailing spaces; flag lines ending with 1+ spaces (except two-space line-break)
- MD010 — hard tabs; flag tabs in non-code content
- MD012 — multiple consecutive blanks; flag runs of 2+
- MD022 — headings need blank before AND after (except start/end)
- MD023 — headings must not have leading whitespace
- MD024 — duplicate heading text among siblings
- MD025 — only one H1 per file; flag every H1 after the first
- MD026 — headings must not end with `.`, `!`, `?`, `:`, `,`, `;`
- MD029 — ordered list prefixes consistent (all `1.` or strictly incrementing)
- MD031 — fenced code blocks need blanks before AND after
- MD032 — lists need blanks before AND after
- MD033 — no inline HTML outside fenced blocks
- MD034 — bare URLs (not in angle brackets, backticks, or links)
- MD040 — fenced code blocks need a language identifier
- MD041 — first non-blank line must be H1 (suppressed for frontmatter or `--ignore MD041`)
- MD047 — file must end with exactly one newline
- MD055 — table pipe style consistent across rows
- MD056 — all rows in a table same number of cells
- MD058 — tables need blanks before AND after
- MD060 — table cell separators need a space on each side of the dash run

### Output Contract

**Executor returns to dispatch caller** (one line only):

- `CLEAN` — no violations, or cache HIT with `result: pass`
- `findings: <absolute-path-to-record.md>` — violations found, or cache HIT with `result: findings`
- `ERROR: <reason>` — failure before record write

**Host returns to its own caller** after the iteration loop completes (one line only):

- `CLEAN` — final detect pass returned `CLEAN`
- `findings: <last-report-path>` — findings still present after the 3rd iteration
- `ERROR: <reason>` — executor or fix pass returned an error

**Record frontmatter** — required fields:

- `hash` — git blob hash of the scanned file
- `file_path` — repo-relative path (see above)
- `operation_kind: markdown-hygiene`
- `result` — `pass` or `findings`

There is no `model` field in the frontmatter schema.

**Body format** — minimum information not already in frontmatter. No `file_path`
duplication in body. Body always opens with `# Result` H1.

CLEAN (no violations):

```text
# Result

CLEAN
```

FINDINGS (violations found):

```text
# Result

FINDINGS

- MD022 line 7: blank line missing before heading "Configuration"
  Fix: insert blank line before line 7
- MD047: file lacks trailing newline
  Fix: append a single newline at end of file
- MD058 line 23: table missing blank line before
  Fix: insert blank line before line 23
- MD056 line 31: table row 3 has 4 cells, table has 3 columns
  Fix: split or remove the extra cell on line 31; ensure all rows have 3 cells
```

Each finding is two lines:

1. Rule code + line number + violation description (what's wrong).
2. Indented `Fix:` line — imperative, complete, standalone. The fix-stage agent
   applies it literally with no markdown-rule knowledge.

### Verdict Mapping

Frontmatter `result` field values:

- No violations -> `pass`
- Violations found -> `findings`

### Fix Line Philosophy

The `Fix:` line is a complete, standalone imperative. The fix-stage agent applies
it literally — no markdown-rule knowledge, no rule-name interpretation. Two tests:
would a human applying only the `Fix:` line (without the finding line, without the
rule code) produce a correct result? Would two different agents produce identical edits?

If either test fails, the `Fix:` line is too vague. Rewrite it with explicit content
(what bytes to insert, what bytes to remove, what cell count to enforce, what column
to align).

Bad: `Fix: fix the table` — no rule knowledge transferred to the agent; ambiguous.
Bad: `Fix: enforce MD058` — assumes rule knowledge.
Good: `Fix: insert blank line before line 23` — explicit, byte-precise.
Good: `Fix: split the cell on line 31 into two cells; ensure all rows have exactly 3 cells` — explicit, no rule knowledge needed.

### Table Fix Examples

Tables (MD055/MD056/MD058/MD060) are high-frequency violators that markdown linters
flag but agents often miscorrect. Worked examples per rule:

```text
- MD058 line 23: table missing blank line before
  Fix: insert blank line before line 23

- MD058 line 28: table missing blank line after
  Fix: insert blank line after line 27 (between the last table row and the next non-blank line)

- MD056 line 31: table row 3 has 4 cells, header declares 3 columns
  Fix: examine line 31; either remove the trailing extra cell to make it 3 cells, or, if the cell is intentional, add a 4th column to the header on line 28 and the separator on line 29

- MD055 line 30: table separator uses ":---:" (centered) but header on line 28 is left-aligned
  Fix: change line 30 separator to `| --- | --- | --- |` to match left-aligned header style; OR change the header's alignment style consistently

- MD060 line 29: table separator uses `|---|---|---|` (no spaces)
  Fix: replace line 29 with `| --- | --- | --- |` — exactly one space on each side of every dash run
```

Every table `Fix:` line names the exact column count, the exact separator format,
or the exact line numbers. Generic instructions like "fix the table" or "make rows
consistent" will fail the apply test.

## Constraints

- **Hard prohibition on script authoring (executor).** The executor MUST NOT author
  scripts (`.ps1`, `.sh`, `.py`, etc.), helper files, workspace artifacts, or "fix"
  files outside the single cache-record write. The only file the executor creates is
  `<cache_dir>/report.md`. If the executor reaches for Write or Edit tools to
  produce any other file, it is off-script. Read/Bash/Grep are for inspection only.
  The target file is read-only.
- **Fix is NOT done by the executor.** The executor writes the report; the host
  dispatches a separate fix pass agent. These are two different agents with different
  instructions.
- **No rule suppression without explicit caller instruction.** Suppressed rules
  (via `--ignore`) are excluded from the violation set for this run only.
- **Adaptive MD041 suppression is automatic** when first non-blank line is `---`;
  no flag required from the caller.
- The executor uses built-in tools and agent intelligence only. "markdownlint" in
  this spec refers to the rule set, not any CLI package. Never suggest installing
  anything — if tooling is not already present, the skill proceeds without it.
- Never modify content meaning — only formatting violations are in scope.
- Preserve all technical strings, code blocks, and frontmatter.
- Cache delegation is mandatory. The executor never computes the git blob hash or
  constructs the cache path inline; hash-record-check owns that logic entirely.

## Integration

Markdown hygiene should run:

1. After compression (compressed files may have lint issues)
2. Before stamping (only stamp clean files)
3. As part of skill-auditing checklist
4. Before any commit of `.md` files

## Tables

### Canonical Separator Modes

Two modes are acceptable. Choose one per table and never mix them within a single table.

#### Mode A — minimum / default (RECOMMENDED)

1-3 dashes per separator cell with pipe padding. Cell widths do not need to match
header widths. This is the default; prefer it unless explicitly optimizing for
human readability.

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
reliable gate. Codifying two explicit modes eliminates ambiguity about when
width-matching is required.

## Known Gotchas

- **MD060 — table separator, no auto-fix:** Table separator rows using `|---|---|`
  (no spaces) trigger MD060. Canonical form is `| --- | --- |` (spaces around
  hyphens). The markdownlint CLI does not auto-fix this rule. This skill produces
  a `Fix:` line for it regardless — the downstream fix-pass agent applies the
  correction.

## Don'ts

- Content quality (that's spec-auditing/skill-auditing)
- Spell checking
- Link validation (future skill)
- Applying fixes to the target file from the executor (detect-only; fix pass is a
  separate host-dispatched concern)
