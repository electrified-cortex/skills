# Markdown Hygiene — Analysis Executor

## Constraints

Hard prohibition: do NOT author scripts, helper files, or any file other than `<analysis_path>`. Use Read/Bash/Grep tools only for inspection.

## Procedure

1. Read `<markdown_file_path>` and evaluate every SA rule below. These are observations, not lint violations. Each entry uses `Note:` instead of `Fix:` — the host LLM decides whether to act. SA032 and SA038 require semantic reasoning — flag only when clearly and unambiguously evident.

3. **SA rule reference:**

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

2. **Determine overall result from advisory severity:**
   - Any FAIL-severity finding → `fail`.
   - WARN or SUGGEST findings only → `pass`.
   - No findings → `clean`.

3. **Write `<analysis_path>`** (overwrite if present):
   - `mkdir -p $(dirname <analysis_path>)` first.
   - Frontmatter (open `---`, close `---`):
     - `file_path: <repo-relative path>` — via `git ls-files --full-name <markdown_file_path>` or strip `<repo_root>/`.
     - `operation_kind: markdown-hygiene-analysis`
     - `result: clean` (no advisories) or `result: pass` (WARN/SUGGEST only) or `result: fail` (any FAIL-severity).
   - Body:
     - No advisories: `# Result\n\nCLEAN`.
     - Advisories: `# Result\n\n## Advisory\n\n- <list>`. Each entry is two lines:
       - `SA0XX [SEVERITY] line N: <description>` (omit line N for document-level observations)
       - Indented `Note: <observation>` — plain English, no imperative.

4. **Return** `clean` (no advisories), `pass: <analysis_path>` (WARN/SUGGEST only), or `findings: <analysis_path>` (any FAIL-severity). On any failure, return `ERROR: <reason>`.

## Output Format

### analysis.md — CLEAN

```text
# Result

CLEAN
```

### analysis.md — with advisories (`result: pass`)

```text
# Result

## Advisory

- SA014 [SUGGEST] line 22: "never" unemphasized in instruction document
  Note: consider bold or ALL CAPS to strengthen the constraint signal
- SA035 [WARN] line 47: action stated before gate condition
  Note: move "if the flag is set" to the front of the sentence
```
