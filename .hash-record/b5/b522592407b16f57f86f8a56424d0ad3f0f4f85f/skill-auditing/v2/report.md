---
file_paths:
  - model-detect/SKILL.md
  - model-detect/spec.md
  - model-detect/uncompressed.md
operation_kind: skill-auditing/v2
model: haiku-class
result: findings
---

# Result

NEEDS_REVISION

## Skill Audit: model-detect

**Verdict:** NEEDS_REVISION
**Type:** inline
**Path:** model-detect/

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Inline skill confirmed; no dispatch instruction files present. |
| Inline/dispatch consistency | PASS | SKILL.md contains full procedure. No instruction.txt conflict. |
| Structure | PASS | Inline structure correct: frontmatter + procedure sections. |
| Input/output double-spec (A-IS-1) | PASS | No double-specification. Pure detection skill. |
| Sub-skill input isolation (A-IS-2) | PASS | No sub-skill references. N/A. |
| Frontmatter | PASS | name and description present in SKILL.md and uncompressed.md. |
| Name matches folder (A-FM-1) | PASS | Folder "model-detect" matches name field in both SKILL.md and uncompressed.md. |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no real H1 (correct for compiled). uncompressed.md has real H1 "# Model Detect" (correct). |
| No duplication | PASS | No overlapping capability detected. |
| Orphan files (A-FS-1) | PASS | Only SKILL.md, uncompressed.md, spec.md present; all accounted for. |
| Missing referenced files (A-FS-2) | PASS | No file references in SKILL.md, uncompressed.md, or spec.md. |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | PASS | Minor stylistic compression in frontmatter description. Intent preserved: priority-ordered detection across five signal sources. Wording differs ("env variable" vs "environment variables", ":" vs "across") but represents acceptable compression. |
| instructions.txt ↔ instructions.uncompressed.md | N/A | No instructions files present. |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md co-located with skill_dir. |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements (R-1 through R-6), Constraints, Acceptance Criteria all present. |
| Normative language | PASS | Requirements use "MUST", "SHALL" and specific enforceable language. |
| Internal consistency | PASS | No contradictions between sections. No duplicate rules. |
| Spec completeness | PASS | All terms defined. Behavior explicitly stated. |
| Coverage | PASS | All six requirements (R-1 through R-6) represented in SKILL.md: priority-ordered detection, confidence tagging, hedged responses, source attribution, alias awareness, no fabrication. |
| No contradictions | PASS | SKILL.md faithfully represents spec requirements. |
| No unauthorized additions | PASS | No new normative requirements introduced beyond spec. |
| Conciseness | PASS | SKILL.md uses numbered lists and bullet points. Agent can skim procedure in one pass. |
| Completeness | PASS | All runtime instructions present. Edge cases (alias handling) addressed. Defaults stated. |
| Breadcrumbs | PASS | No stale references. Related skills section absent but not required for detection skill. |
| Cost analysis | N/A | Inline skill; N/A. |
| No dispatch refs | N/A | Inline skill; N/A. |
| No spec breadcrumbs | PASS | SKILL.md and uncompressed.md do not reference their own spec.md. |
| Eval log (informational) | ABSENT | No eval.txt present. |
| Description not restated (A-FM-2) | LOW | uncompressed.md opening line "Use when asked: "What model are you?" or "What is your model/version?"" slightly restates description. Not verbatim, minor violation. |
| No exposition in runtime (A-FM-5) | FAIL | uncompressed.md contains background prose: "The core problem: training-time self-knowledge is unreliable. Models frequently state wrong or outdated version numbers with false confidence." This rationale belongs in spec.md (already present), not in runtime artifact. |
| No non-helpful tags (A-FM-6) | PASS | No bare type labels or non-operational descriptors detected. |
| No empty sections (A-FM-7) | PASS | All headings contain body content. |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety content. |
| Iteration-safety pointer form (A-FM-9a) | N/A | Not applicable. |
| No verbatim Rule A/B (A-FM-9b) | N/A | Not applicable. |
| Cross-reference anti-pattern (A-XR-1) | PASS | References to CLAUDE.md, copilot-instructions.md, .github/copilot-instructions.md are generic file paths, not cross-references to other skills. No canonical-name-free cross-skill pointers detected. |
| Launch-script form (A-FM-10) | N/A | Inline skill; N/A. |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| SKILL.md | Not empty | PASS | Contains frontmatter and procedure sections. |
| SKILL.md | Frontmatter | PASS | YAML frontmatter present with name and description. |
| SKILL.md | No abs-path leaks | PASS | No Windows drive-letter or POSIX root-anchored paths detected. |
| uncompressed.md | Not empty | PASS | Contains frontmatter, H1, and procedure content. |
| uncompressed.md | Frontmatter | PASS | YAML frontmatter present. name and description match SKILL.md. |
| uncompressed.md | No abs-path leaks | PASS | No Windows drive-letter or POSIX root-anchored paths detected. |
| spec.md | Not empty | PASS | Contains all required sections. |
| spec.md | Frontmatter | N/A | spec.md does not require frontmatter. |
| spec.md | No abs-path leaks | PASS | No Windows drive-letter or POSIX root-anchored paths detected. |

### Issues

1. **A-FM-5: Exposition in runtime artifacts — HIGH**
   - Location: uncompressed.md, "The core problem" paragraph (lines ~7–9)
   - Issue: Background prose explaining the problem belongs in spec.md (already present), not in the runtime operative artifact.
   - Expected: uncompressed.md should open directly with "Use when asked..." and proceed to numbered procedure. Leave "The core problem..." rationale in spec.md.
   - Fix: Remove or move exposition prose from uncompressed.md. Compress to operational procedure only.

2. **A-FM-2: Description not restated — LOW**
   - Location: uncompressed.md, opening line
   - Issue: "Use when asked: "What model are you?" or "What is your model/version?"" restates the description in different form.
   - Expected: uncompressed.md should avoid repeating frontmatter description.
   - Fix: Remove or rephrase opening line to avoid restatement.

### Recommendation

Remove exposition paragraph from uncompressed.md and streamline opening to avoid description restatement. Ensure uncompressed.md contains only the operative procedure, leaving rationale exclusively in spec.md.
