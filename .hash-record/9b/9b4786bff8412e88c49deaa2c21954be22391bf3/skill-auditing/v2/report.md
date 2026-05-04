---
file_paths:
  - skill-writing/SKILL.md
  - skill-writing/spec.md
  - skill-writing/uncompressed.md
operation_kind: skill-auditing/v2
model: sonnet-class
result: findings
---

# Result

FAIL

## Skill Audit: skill-writing

**Verdict:** FAIL
**Type:** inline
**Path:** skill-writing/

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Inline correct — requires caller context and judgment |
| Inline/dispatch consistency | PASS | No instructions.txt; SKILL.md contains full procedure |
| Structure | PASS | Frontmatter present; inline structure followed |
| Input/output double-spec (A-IS-1) | N/A | Inline skill; no sub-skill output routing |
| Sub-skill input isolation (A-IS-2) | N/A | No sub-skill inputs |
| Frontmatter | PASS | name and description present in SKILL.md and uncompressed.md |
| Name matches folder (A-FM-1) | PASS | name: skill-writing matches folder name skill-writing |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no H1 (correct); uncompressed.md has H1 (correct) |
| No duplication | PASS | No duplicate skill in skills folder |
| Orphan files (A-FS-1) | PASS | All three files are well-known role files |
| Missing referenced files (A-FS-2) | PASS | No explicit file-path pointers to non-existent sibling files |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | FAIL | Two gaps: (1) uncompressed.md step 3 omits instructions.uncompressed.md from hygiene scope; SKILL.md and spec both include it. (2) uncompressed.md Related omits markdown-hygiene; SKILL.md includes it. Fix: edit uncompressed.md, then recompress to SKILL.md. |
| instructions.txt ↔ instructions.uncompressed.md | N/A | No instructions.txt; inline skill |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present co-located |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Requirements use MUST/MUST NOT throughout |
| Internal consistency | FAIL | Spec Behavior section "Skill creation workflow" is 4 steps, omitting mandatory hygiene and intermediate audit gates from the normative 6-step Skill Creation Workflow. Revision workflow has the same contradiction. |
| Spec completeness | PASS | Terms defined; behavior stated |
| Coverage | FAIL | R-FM-10 requires description MUST include ≥3 trigger phrases; skill-writing SKILL.md description has none |
| No contradictions | PASS | SKILL.md does not contradict spec |
| No unauthorized additions | FAIL | SKILL.md line 69 and uncompressed.md line 111 both state a normative rule about repo-local fallback filenames absent from spec.md |
| Conciseness | FAIL | Four named-pattern violations (see Issues) |
| Completeness | PASS | Runtime instructions present; edge cases addressed |
| Breadcrumbs | PASS | markdown-hygiene present in skills folder |
| Cost analysis | N/A | Inline skill |
| No dispatch refs | N/A | Inline skill |
| No spec breadcrumbs | PASS | SKILL.md does not point to own spec.md |
| Eval log (informational) | ABSENT | No eval.txt present |
| Description not restated (A-FM-2) | PASS | Description in frontmatter not restated in body |
| No exposition in runtime (A-FM-5) | HIGH | Four violations in SKILL.md and uncompressed.md (see Issues) |
| No non-helpful tags (A-FM-6) | PASS | No descriptor-only lines without operational value |
| No empty sections (A-FM-7) | PASS | All headings have body content |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety content in any artifact |
| Iteration-safety pointer form (A-FM-9a) | N/A | No iteration-safety pointer present |
| No verbatim Rule A/B (A-FM-9b) | N/A | No verbatim iteration-safety rules present |
| Cross-reference anti-pattern (A-XR-1) | PASS | Path forms in code fences are pedagogical counter-examples; no actual cross-file path pointers to sibling skills |
| Launch-script form (A-FM-10) | N/A | Inline skill |
| Return shape declared (DS-1) | N/A | Inline skill |
| Host card minimalism (DS-2) | N/A | Inline skill |
| Description trigger phrases (DS-3) | N/A | Inline skill — DS-3 format check N/A; trigger-phrase requirement covered under Coverage/R-FM-10 above |
| Inline dispatch guard (DS-4) | N/A | Inline skill |
| No substrate duplication (DS-5) | N/A | Inline skill |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Inline skill |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| SKILL.md | Not empty | PASS | |
| SKILL.md | Frontmatter (if required) | PASS | YAML frontmatter at line 1 |
| SKILL.md | No abs-path leaks | PASS | |
| uncompressed.md | Not empty | PASS | |
| uncompressed.md | Frontmatter (if required) | PASS | YAML frontmatter at line 1 |
| uncompressed.md | No abs-path leaks | PASS | |
| spec.md | Not empty | PASS | |
| spec.md | Frontmatter (if required) | N/A | Not SKILL.md or agent.md |
| spec.md | No abs-path leaks | PASS | Forbidden-path examples in spec prose are rule definitions, not actual leaked paths |

### Issues

**[FAIL] Unauthorized addition — repo-local fallback rule**
SKILL.md line 69 and uncompressed.md line 111 both contain the normative rule: "Don't rely on repo-local fallback filenames — those belong in skill-specific auditors, not universal spec-auditing rules." This rule is absent from spec.md.
Fix: add this requirement to spec.md under Requirements, or remove from both compiled artifacts.

**[FAIL] Spec internal contradiction — Behavior workflow**
The Behavior section "Skill creation workflow" describes a 4-step process, omitting the mandatory markdown-hygiene gate (step 3) and intermediate audit gate (step 4) defined in the normative 6-step Skill Creation Workflow. The Revision workflow has the same omission.
Fix: update the Behavior section to match the normative 6-step workflows exactly.

**[FAIL] Coverage — R-FM-10: description trigger phrases missing**
spec.md R-FM-10: "The `description` frontmatter field MUST include explicit trigger phrases — authors MUST list at least 3." The skill-writing SKILL.md description ("How to write skills — decision tree for inline vs dispatch, structure, quality criteria.") contains no trigger phrases, violating this requirement in the skill's own spec. This is the frontmatter gap referenced by task 50-0934.
Fix: add 3–6 trigger phrases to `description` in uncompressed.md, then recompress to SKILL.md.

**[HIGH] A-FM-5 — Meta-architectural label in SKILL.md**
Line: "This skill: decides whether a skill dispatches + how to structure it." Describes the skill's own role rather than instructing the agent.
Fix: remove this line; it is design rationale, not a runtime instruction.

**[HIGH] A-FM-5 — Too much why in SKILL.md**
Line: "Don't rely on repo-local fallback filenames — those belong in skill-specific auditors, not universal spec-auditing rules." Rationale clause appended to an instruction.
Fix: strip rationale clause; move to spec.md.

**[HIGH] A-FM-5 — Meta-architectural label in uncompressed.md**
Line: "This skill decides *whether* a skill dispatches and *how to structure it*." Same pattern as SKILL.md meta-architectural label.
Fix: remove this line.

**[HIGH] A-FM-5 — Too much why in uncompressed.md**
Lines: "The dispatched agent enforces them; the host doesn't need to know them before dispatch." Rationale for why stop gates belong in instructions.txt.
Fix: remove these lines; move rationale to spec.md.

**[FAIL] Parity — uncompressed.md step 3 incomplete**
Step 3 in uncompressed.md says run hygiene on uncompressed.md only. SKILL.md and spec both specify every uncompressed source file (uncompressed.md AND instructions.uncompressed.md if present).
Parity failure: omitted requirement. Fix: edit uncompressed.md step 3 to match, then recompress to SKILL.md.

**[FAIL] Parity — uncompressed.md Related missing markdown-hygiene**
uncompressed.md Related section omits markdown-hygiene; SKILL.md correctly includes it.
Parity failure: omitted entry. Fix: add markdown-hygiene to uncompressed.md Related section, then recompress to SKILL.md.

### Recommendation

Address FAIL-severity findings first: add repo-local-fallback rule to spec.md or remove from artifacts; fix the Behavior section workflow contradiction in spec.md; close the two parity gaps in uncompressed.md before recompression. Then eliminate the four A-FM-5 exposition violations in SKILL.md and uncompressed.md. Re-audit after fixes.
