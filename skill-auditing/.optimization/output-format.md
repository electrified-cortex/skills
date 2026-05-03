# OUTPUT-FORMAT — 2026-05-01

## Findings

### Finding 1 — HIGH

**Signal:** Executor return value is defined three incompatible ways: `instructions.uncompressed.md` Step 8 says `Return done`; spec.md Behavior/Output Contract says `PATH: <record-path>`; SKILL.md says `PASS: <path> | NEEDS_REVISION: <path> | FAIL: <path> | ERROR: <reason>`.

**Reasoning:** The caller parses the last line of stdout — only one contract can be correct. A host agent reading SKILL.md expects verdict tokens; the executor following instructions emits `done`; the spec expects `PATH:`. The result tool's role as intermediary is nowhere stated.

**Recommendation:** Converge: executor returns `done | ERROR: <reason>`; result tool reads the report and surfaces the verdict token. Update SKILL.md Inspect section to `Should return: done | ERROR: <reason>`, update spec.md R10 to clarify this applies to the result tool, and document in instructions Step 8 that the result tool — not the executor — surfaces the verdict token.

**Action taken:** No change yet.

---

### Finding 2 — HIGH

**Signal:** `PASS_WITH_FINDINGS` appears in `instructions.uncompressed.md` Step 5 as a verdict state but is absent from every return token contract (SKILL.md, uncompressed.md, spec.md, post-execute branch table).

**Reasoning:** Step 5 maps `PASS_WITH_FINDINGS / NEEDS_REVISION / FAIL → findings` for the `result` frontmatter field. What the result tool emits when the report says `result: findings` but the body says `PASS_WITH_FINDINGS` is undefined. Caller behavior is undefined.

**Recommendation:** Either (a) eliminate `PASS_WITH_FINDINGS` and fold it into `PASS` with a body note, or (b) add it to the return token contract and post-execute branch table with explicit handling.

**Action taken:** No change yet.

---

### Finding 3 — HIGH

**Signal:** The `result` frontmatter field collapses `NEEDS_REVISION` and `FAIL` into the same value (`findings`), making the report non-self-describing.

**Reasoning:** The result tool must emit `NEEDS_REVISION: <path>` vs `FAIL: <path>` to the caller, but must parse the report body to determine which — because both produce `result: findings` in frontmatter. The body format for the verdict declaration is never specified.

**Recommendation:** Add a `verdict` frontmatter field with constrained values: `pass | pass_with_findings | needs_revision | fail | error`. Result tool becomes a trivial frontmatter reader. Alternatively, document the exact line/pattern in the body where the verdict word appears.

**Action taken:** No change yet.

---

### Finding 4 — MEDIUM

**Signal:** Report body structure is underspecified — `instructions.uncompressed.md` Step 7 says only "open with # Result H1, state verdict, list findings (with phase and check references)."

**Reasoning:** Whether findings appear as a flat list, nested under phase sub-headings, or in a table is undefined. Whether the verdict is on a dedicated line vs embedded in prose is undefined. Per-file vs Phase finding ordering is undefined. Two executors would produce structurally incompatible reports.

**Recommendation:** Define a report template: verdict declaration format, findings section name and grouping (per-phase sub-sections vs flat), canonical finding entry format.

**Action taken:** No change yet.

---

### Finding 5 — MEDIUM

**Signal:** Individual finding format is not defined anywhere. "list findings (with phase and check references)" is the entire specification.

**Reasoning:** No schema for severity label, check code, affected file, line number, or excerpt. Per-file checks name severities (HIGH/MEDIUM/LOW) but instructions never specify how they appear in the report.

**Recommendation:** Define a canonical finding format, e.g.: `- [SEVERITY] [CHECK-CODE] <file>: <description>` or a 4-column markdown table per phase section.

**Action taken:** No change yet.

---

### Finding 6 — MEDIUM

**Signal:** Verdict threshold for `NEEDS_REVISION` vs `PASS` when all phases pass is never declared.

**Reasoning:** Phase-level failure → FAIL is clear. But whether HIGH per-file findings flip the verdict to `NEEDS_REVISION`, or whether LOW-only findings produce `PASS`, is entirely implicit. Leads to inconsistent verdicts across executors.

**Recommendation:** Add explicit verdict assignment rule, e.g.: "FAIL if any phase fails. NEEDS_REVISION if any HIGH or MEDIUM finding and no phase fails. PASS if all findings are LOW or absent."

**Action taken:** No change yet.
