# Markdown Hygiene — RETIRED

This file is superseded by the two-phase executor split.

- Lint executor (Haiku-class): `markdown-hygiene-lint/instructions.uncompressed.md`
- Analysis executor (Sonnet-class): `markdown-hygiene-analysis/instructions.uncompressed.md`
- Orchestrator: `SKILL.md`

Do not read further. Read `SKILL.md` instead.

## Procedure

**Hard prohibition:** do NOT author scripts (`.ps1`, `.sh`, `.py`, etc.), helper files, or any file other than `<report_path>`. The target file is read-only. Use Read/Bash/Grep only for inspection.

1. **Run verify**, whichever your runtime has:
   - Bash: `bash <skill-dir>/verify.sh <markdown_file_path> [--ignore <RULE>[,<RULE>...]]`
   - PS7: `pwsh <skill-dir>/verify.ps1 <markdown_file_path> [-Ignore <RULE>[,<RULE>...]]`

   Verify lists every rule it determined and the result. Take its output and include it in the report findings. You (LLM) are responsible for everything verify did not determine — covered in step 2.
2. **Scan** `<markdown_file_path>` for the remaining rules. Read the file (Read tool) and apply rule-knowledge from step 3. Cross-check each finding against the actual line; drop any you cannot point at on a verified line. Skip rules in `--ignore`. Cover every rule in step 3, including all four table rules (MD055/MD056/MD058/MD060).
3. **Reference rule list** (use to compose `Fix:` imperatives for rules verify did not determine):

   - MD001 — heading levels increment by one (H1 to H3 violates).
   - MD003 — heading style consistent (atx `#` vs setext `===`/`---`).
   - MD004 — list markers consistent (`-`, `*`, `+`).
   - MD022 — headings need blank before AND after (except start/end).
   - MD023 — headings must not have leading whitespace.
   - MD024 — duplicate heading text among siblings.
   - MD025 — only one H1 per file.
   - MD026 — headings must not end with `.`, `!`, `?`, `:`, `,`, `;`.
   - MD029 — ordered list prefixes consistent.
   - MD031 — fenced code blocks need blanks before AND after.
   - MD032 — lists need blanks before AND after.
   - MD033 — no inline HTML outside fenced blocks.
   - MD034 — bare URLs (not in angle brackets, backticks, or links).
   - MD040 — fenced code blocks need a language identifier.
   - MD055 — table pipe style consistent across rows.
   - MD056 — all rows in a table same number of cells.
   - MD058 — tables need blanks before AND after.
   - MD060 — table cell separators need a space on each side of the dash run.
4. **Semantic advisory scan** — read the file and evaluate the advisory rules below. These are not lint violations; they are observations about emphasis abuse, structural smells, and missed opportunities. Each entry uses `Note:` instead of `Fix:`. The host LLM decides whether to act. Skip rules in `--ignore`.

   Advisory rules:
   - SA001 — ALL CAPS: 3 or more consecutive ALL CAPS words that are not an acronym or known term (e.g. `THIS IS WRONG`). Severity: FAIL.
   - SA002 — ALL CAPS: entire sentence in ALL CAPS. Severity: FAIL.
   - SA003 — ALL CAPS budget: same ALL CAPS word appears 5 or more times in the document — signal collapse. Severity: WARN.
   - SA004 — Bold overuse: more than approximately 15% of non-code body text is bold — emphasis signal diluted. Severity: WARN.
   - SA005 — Bold run: bold spans 3 or more consecutive sentences in the same section. Severity: WARN.
   - SA006 — Single-item list: a list with exactly one item — use a sentence instead. Severity: FAIL.
   - SA007 — Two-item list: a list with exactly two items that reads naturally as `X and Y`. Severity: WARN.
   - SA008 — Over-nested list: list nesting reaches 3 or more levels deep. Severity: WARN.
   - SA009 — Paragraph list items: list items that are multi-sentence paragraphs — consider using sections with headings instead. Severity: WARN.
   - SA010 — Unbackticked reference: a file path, shell command, or environment variable appears in plain prose without backticks. Severity: WARN.
   - SA011 — Signal stack: ALL CAPS and bold applied to the same word or phrase (e.g. `**NEVER**`) — redundant double-emphasis. Severity: FAIL.
   - SA012 — Empty heading: a heading is immediately followed by another heading with no content between them. Severity: WARN.
   - SA013 — Trivial heading: a heading introduces only a single sentence — use a bold label (`**Label:**`) instead. Severity: WARN.
   - SA014 — Unemphasized constraint: the words `never`, `must not`, `do not`, or `always` appear in plain lowercase in an instruction document — consider bold or ALL CAPS. Severity: SUGGEST.
   - SA015 — Long document without headings: the document exceeds approximately 400 words and contains zero headings — long documents need structural landmarks. Severity: WARN.
   - SA016 — Heading too long: a heading exceeds approximately 60 characters — headings should be labels, not sentences. Severity: WARN.
   - SA017 — Question as heading: a heading ends with `?` outside a FAQ context — use a declarative label instead. Severity: WARN.
   - SA018 — Passive voice on directive: a directive sentence in an instruction or spec document uses passive voice (e.g. "it should be noted", "errors are handled by") — rewrite as active with a clear subject. Severity: WARN.
   - SA019 — Very long paragraph: a paragraph exceeds approximately 8 sentences — split or restructure. Severity: WARN.
   - SA020 — Numbered list without sequence dependency: a numbered list is used for items with no sequential order dependency — use bullets instead. Severity: WARN.
   - SA021 — Raw URL as link text: a markdown link uses the full URL as display text — replace with a descriptive label. Severity: WARN.
   - SA022 — Generic link text: a hyperlink uses text such as "click here", "here", "this link", or "read more" — replace with text that identifies the destination. Severity: WARN.
   - SA023 — Empty fenced code block: a fenced code block contains no content — remove it or fill it with the intended example. Severity: FAIL.
   - SA024 — Decorative backtick: a backtick is applied to a plain prose word that is not a code token, path, command, or literal — use bold or italics for prose emphasis. Severity: WARN.
   - SA025 — Strikethrough in non-draft document: strikethrough text appears in a document not marked as a draft — remove the struck text or restore it. Severity: WARN.
   - SA026 — Horizontal rule as section divider: `---` or `***` divides sections where a heading should be used — horizontal rules carry no semantic weight. Severity: WARN.
   - SA027 — Repeated word in sibling headings: the same word appears in every heading within a section — restructure so the distinguishing term leads. Severity: WARN.
   - SA028 — Duplicate phrase or sentence: a phrase of five or more words or an entire sentence appears verbatim more than once — almost always a copy-paste artifact. Severity: WARN.
   - SA029 — Positional reference: the document contains "see above", "see below", "as mentioned earlier", or similar positional pointer — these break when content moves. Severity: WARN.
   - SA030 — Blockquote as callout: a blockquote (`>`) is used for visual emphasis rather than to quote external material — use a bold label or heading instead. Severity: WARN.
   - SA031 — Heading case inconsistency: sibling headings within a section mix Title Case and Sentence case — pick one style and hold it. Severity: WARN.
   - SA032 — Inconsistent terminology: the same concept is referred to by multiple distinct names in the document (LLM-detected) — commit to one canonical term. Severity: WARN.
   - SA033 — Negation stacking: a directive contains stacked or double negation (e.g. "do not fail to avoid") — LLMs parse negation chains unreliably; rewrite as a positive instruction. Severity: FAIL.
   - SA034 — Vague qualifier on directive: a directive is modified by "sometimes", "usually", "often", "generally", or similar without specifying the exception condition — either commit unconditionally or state the exact condition. Severity: WARN.
   - SA035 — Condition buried after consequence: an instruction states the action before its gate condition ("Delete X if Y" rather than "If Y, delete X") — front-load the condition. Severity: WARN.
   - SA036 — Multi-clause directive sentence: a single directive sentence has 3+ coordinating conjunctions (and/or/but) — split into one instruction per sentence. Severity: WARN.
   - SA037 — Mixed imperative and declarative in list: a list mixes command items and observation/description items without a signal distinguishing them — LLMs may execute observations or skip commands. Severity: WARN.
   - SA038 — Contradictory instructions: two statements in the document directly contradict each other (LLM-detected) — reconcile the contradiction explicitly. Severity: FAIL.
4. **Write report** at `<report_path>` (overwrite if present):
   - `mkdir -p $(dirname <report_path>)` first.
   - Frontmatter (open `---`, close `---`):
     - `file_path: <repo-relative path>` — repo-relative, NOT absolute. Compute via `git ls-files --full-name <markdown_file_path>` or strip `<repo_root>/` from the absolute path.
     - `operation_kind: markdown-hygiene`
     - `result: clean` (no violations, no advisories), `result: fail` (lint violations present), or `result: pass` (no lint violations, but advisory observations present). If both lint violations and advisories are present, use `result: fail`.
   - Body:
     - No violations, no advisories: `# Result\n\nCLEAN`.
     - Lint violations: `# Result\n\nFINDINGS\n\n- <list>`. Each entry is two lines:
       - `MD0XX line N: <description>`
       - Indented `Fix: <imperative instruction>` — complete, standalone, byte-precise.
     - Advisory observations (append after FINDINGS if both present, or as sole body if only advisories): `## Advisory\n\n- <list>`. Each entry is two lines:
       - `SA0XX [SEVERITY] line N: <description>` (line N is omitted for document-level observations)
       - Indented `Note: <observation>` — plain English, no imperative. The host LLM decides whether to act.
5. **Return** the literal string `done`. On any failure, return `ERROR: <reason>`.

## Report Format

Record body always opens with `# Result` H1.

CLEAN:

```text
# Result

CLEAN
```

FINDINGS (`result: fail`):

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

ADVISORY only (`result: pass`):

```text
# Result

## Advisory

- SA001 [FAIL] line 14: 3 consecutive ALL CAPS words "THIS IS WRONG" — not an acronym
  Note: rephrase in sentence case or replace with a single bolded constraint term
- SA014 [SUGGEST]: the word "never" appears unemphasized on line 22 in an instruction document
  Note: consider bolding or converting to ALL CAPS to strengthen the constraint signal
```

FINDINGS with advisories (`result: fail`):

```text
# Result

FINDINGS

- MD022 line 7: blank line missing before heading "Configuration"
  Fix: insert blank line before line 7

## Advisory

- SA006 [FAIL] line 44: single-item list
  Note: convert to a plain sentence — a list with one item adds no structure
```

Each entry is two lines: the finding line (`MD0XX line N: <description>`), then an indented `Fix:` line.

### Fix line philosophy

The `Fix:` line is a complete, standalone imperative applied verbatim by a downstream agent with no markdown-rule knowledge. Two tests: would a human applying only the `Fix:` line (without the finding line, without the rule code) produce a correct result? Would two different agents produce identical edits?

Bad: `Fix: fix the table` — ambiguous.
Bad: `Fix: enforce MD058` — assumes rule knowledge.
Good: `Fix: insert blank line before line 23` — explicit, byte-precise.
Good: `Fix: split the cell on line 31 into two cells; ensure all rows have exactly 3 cells` — explicit, no rule knowledge needed.

### Table fix examples

Tables (MD055/MD056/MD058/MD060) are high-frequency violators agents often miscorrect.

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

Every table `Fix:` line names the exact column count, the exact separator format, or the exact line numbers. Generic instructions will fail the apply test.
