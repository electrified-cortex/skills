---
file_paths:
  - .worktrees/40-0938/spec-auditing/SKILL.md
  - .worktrees/40-0938/spec-auditing/instructions.txt
  - .worktrees/40-0938/spec-auditing/instructions.uncompressed.md
  - .worktrees/40-0938/spec-auditing/spec.md
  - .worktrees/40-0938/spec-auditing/uncompressed.md
operation_kind: skill-auditing/v2
model: sonnet-class
result: findings
---

# Result

FAIL

## Skill Audit: spec-auditing

**Verdict:** FAIL
**Type:** dispatch
**Path:** spec-auditing/

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Dispatch: instructions.txt present; multi-phase gated audit appropriate for dispatch |
| Inline/dispatch consistency | PASS | File-system evidence matches dispatch invocation in SKILL.md |
| Structure | PASS | SKILL.md is minimal routing card; instructions.txt contains full executor procedure |
| Input/output double-spec (A-IS-1) | PASS | No sub-skill output path duplication |
| Sub-skill input isolation (A-IS-2) | N/A | No sub-skill dispatches |
| Frontmatter | PASS | name and description present in both SKILL.md and uncompressed.md |
| Name matches folder (A-FM-1) | PASS | name: spec-auditing matches folder name in both SKILL.md and uncompressed.md |
| H1 per artifact (A-FM-3) | PASS | SKILL.md: no H1 (correct). uncompressed.md: H1 present (correct). instructions.uncompressed.md: H1 present (correct). instructions.txt: apparent # Result is inside a yaml code fence, not a real H1 heading |
| No duplication | PASS | No redundant existing skill found |
| Orphan files (A-FS-1) | PASS | All files are well-known role files; no orphans |
| Missing referenced files (A-FS-2) | PASS | instructions.txt exists; sibling skill references (dispatch, iteration-safety) are outside skill_dir scope |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md vs uncompressed.md | PASS | Parity confirmed; uncompressed adds Variables label and bullet-formatted Parameters — wording compression only |
| instructions.txt vs instructions.uncompressed.md | FAIL | Parity failure: result field in hash-record code block uses incorrect values in uncompressed (see HIGH-1) |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present co-located with skill_dir |
| Required sections | PASS | spec.md contains Purpose, Scope, Definitions, Requirements, Constraints |
| Normative language | PASS | Requirements use must/shall/required throughout |
| Internal consistency | PASS | No internal spec contradictions found |
| Spec completeness | PASS | All terms defined; behavior explicitly stated |
| Coverage | FAIL | --kind parameter missing from host-card input signatures (MEDIUM-1); 11 checks in instruction files contradicts spec 13 checks (HIGH-2) |
| No contradictions | FAIL | Return token case/format mismatch: spec uses Title Case; all runtime artifacts use ALL_CAPS with underscores (HIGH-3) |
| No unauthorized additions | PASS | No additions without spec basis found |
| Conciseness | PASS | Instructions in decision-tree and bullet form; no excess prose |
| Completeness | PASS | All runtime instructions present |
| Breadcrumbs | PASS | iteration-safety and dispatch references valid; targets exist |
| Cost analysis | PASS | Dispatch agent used; instructions.txt approx 177 lines (under 500); single dispatch turn |
| No dispatch refs | PASS | instructions.txt contains no dispatch-other-skill instructions |
| No spec breadcrumbs | PASS | No own spec.md references in runtime artifacts; spec.md mentions in instructions are subject-matter references (this skill audits spec.md files — explicitly exempted) |
| Eval log (informational) | ABSENT | No eval.txt found |
| Description not restated (A-FM-2) | PASS | No body prose restates the description frontmatter value |
| No exposition in runtime (A-FM-5) | PASS | No rationale or background prose in any runtime artifact |
| No non-helpful tags (A-FM-6) | PASS | No bare descriptor lines found |
| No empty sections (A-FM-7) | PASS | All headings have body content |
| Iteration-safety placement (A-FM-8) | PASS | Iteration safety blurb absent from both instruction files |
| Iteration-safety pointer form (A-FM-9a) | PASS | Canonical 2-line pointer form present in both SKILL.md and uncompressed.md; relative path correct for folder depth |
| No verbatim Rule A/B (A-FM-9b) | PASS | No verbatim Rule A/B restatement beyond sanctioned pointer block |
| Cross-reference anti-pattern (A-XR-1) | PASS | No cross-file path pointers to other skills uncompressed.md or spec.md; spec.md mentions in instructions are subject-matter (exempted) |
| Launch-script form (A-FM-10) | PASS | uncompressed.md contains only: frontmatter, H1, dispatch invocation + input signature, Returns line, Parameters, iteration-safety pointer |
| Return shape declared (DS-1) | PASS | Returns line in both SKILL.md and uncompressed.md declares PATH:/PASS:/PASS_WITH_FINDINGS:/FAIL:/ERROR: shapes |
| Host card minimalism (DS-2) | PASS | No internal cache descriptions, adaptive rules, tool-fallback hints, or subjective qualifiers in host cards |
| Description trigger phrases (DS-3) | PASS | 5 trigger phrases present; correct format with Triggers — prefix |
| Inline dispatch guard (DS-4) | PASS | NEVER READ on instructions binding; Read and follow prompt form; Follow dispatch skill delegation line present |
| No substrate duplication (DS-5) | PASS | Hash-record schema is defined by this skill own spec; no external substrate skill schema inlined |
| No overbuilt sub-skill dispatch (DS-6) | N/A | No sub-skill dispatches |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| SKILL.md | Not empty | PASS | |
| SKILL.md | Frontmatter (required) | PASS | YAML frontmatter at line 1 |
| SKILL.md | No abs-path leaks | PASS | |
| uncompressed.md | Not empty | PASS | |
| uncompressed.md | Frontmatter (required) | PASS | YAML frontmatter at line 1 |
| uncompressed.md | No abs-path leaks | PASS | |
| instructions.uncompressed.md | Not empty | PASS | |
| instructions.uncompressed.md | Frontmatter (required) | N/A | Not SKILL.md or agent.md |
| instructions.uncompressed.md | No abs-path leaks | PASS | |
| instructions.txt | Not empty | PASS | |
| instructions.txt | Frontmatter (required) | N/A | Not SKILL.md or agent.md |
| instructions.txt | No abs-path leaks | PASS | |
| spec.md | Not empty | PASS | |
| spec.md | Frontmatter (required) | N/A | Not SKILL.md or agent.md |
| spec.md | No abs-path leaks | PASS | |

### Issues

**HIGH-1 — Parity failure: result field incorrect in instructions.uncompressed.md hash-record code block**
Step 2 | instructions.txt vs instructions.uncompressed.md

instructions.uncompressed.md line 179 (inside yaml code fence in Step RW section):
  result: pass | findings | error   # Pass->pass; Pass with Findings->findings; Fail->findings; error->error

instructions.txt line 129 (correct compiled form):
  result: <pass|pass_with_findings|fail|error>

Spec (section Hash-Record Cache / Record Write): result: pass | pass_with_findings | fail | error

Two errors in uncompressed: (1) uses "findings" instead of "pass_with_findings"; (2) comment maps both "Pass with Findings" and "Fail" to "findings" — Fail must map to "fail", not "findings". The compiled instructions.txt is correct. Fix: edit instructions.uncompressed.md to use result: pass | pass_with_findings | fail | error with corrected mapping comment, then recompress to instructions.txt.

---

**HIGH-2 — Spec contradiction: "11 checks" in both instruction files contradicts spec "13 checks"**
Step 3 | Coverage / No contradictions

instructions.uncompressed.md line 59: "Meta mode: run pair-audit with all 11 checks unmodified (current default behavior)."
instructions.txt line 36: "Meta mode: all 11 checks unmodified."
Spec section Audit Kind: "Meta mode: Applies full pair-audit with all 13 checks unchanged."

The pair-audit procedure in both instruction files explicitly enumerates 13 numbered steps (steps 1-13 covering: extract from spec, extract from target, Semantic Alignment, Requirement Coverage, Contradiction Detection, Completeness, Enforceability, Structural Integrity, Terminology, Change Drift Risk, Unauthorized Additions, Economy, Compression Fidelity). Both files say "11 checks" but spec says 13 and the procedure itself has 13 steps — creating internal inconsistency as well as spec contradiction. Fix: update both instruction files to say "13 checks," then recompress compiled from uncompressed.

---

**HIGH-3 — Spec contradiction: return token case/format mismatch across all artifacts**
Step 3 | No contradictions

Spec section Output Requirements / 7. Return Token defines tokens as:
  Pass: <abs-path>
  Pass with Findings: <abs-path>
  Fail: <abs-path>

Spec section Hash-Record Cache / Return Token defines same Title Case pattern.

instructions.uncompressed.md line 187: PASS: <cache_path> | PASS_WITH_FINDINGS: <cache_path> | FAIL: <cache_path>
instructions.txt line 137: same ALL_CAPS underscore form.
SKILL.md line 19 / uncompressed.md line 23 Returns lines: same ALL_CAPS form.

All four runtime artifacts are mutually consistent but all contradict both spec sections. The token strings are materially different: "Pass with Findings:" (Title Case, spaces) vs "PASS_WITH_FINDINGS:" (ALL_CAPS, underscores). An agent following instructions.txt will emit a token the caller cannot match against spec-defined expected values. Fix: governance decision required — pick canonical form and update either both spec sections or all four runtime artifacts. Given all runtime artifacts agree on ALL_CAPS form, the spec sections are likely the stale side.

---

**MEDIUM-1 — Coverage gap: --kind meta|domain parameter absent from host-card input signatures**
Step 3 | Coverage

Spec section Inputs (line 131) defines: optional audit kind flag (--kind meta or --kind domain) to control Unauthorized Additions evaluation.
Spec section Audit Kind: full auto-detection and behavioral rules defined.

SKILL.md line 13: input-args = target-path [--spec spec-path] [--fix] — --kind absent.
SKILL.md Parameters section: lists target-path, --spec, --fix only.
uncompressed.md line 17: same input-args — --kind absent.
uncompressed.md Parameters section: lists target-path, --spec, --fix only.

A caller reading only the host card has no knowledge that --kind exists. Fix: add [--kind meta|domain] to input-args variable and add a --kind (flag, optional) parameter entry to the Parameters section in both SKILL.md and uncompressed.md.

### Recommendation

Three HIGH findings trigger FAIL verdict. Fix in order: (1) correct result field values and comment in instructions.uncompressed.md code block (HIGH-1); (2) update check count from 11 to 13 in both instruction files (HIGH-2); (3) resolve return token casing with spec author — pick canonical form and update spec or all runtime artifacts (HIGH-3); (4) add --kind to host-card input-args and Parameters (MEDIUM-1). Re-audit after all fixes.