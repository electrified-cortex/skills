---
file_paths:
  - swarm/SKILL.md
  - swarm/spec.md
  - swarm/uncompressed.md
operation_kind: skill-auditing/v2
model: sonnet-class
result: findings
---

# Result

NEEDS_REVISION

## Skill Audit: swarm

**Verdict:** NEEDS_REVISION
**Type:** inline
**Path:** swarm/

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Host-executed, 8-step procedure with stateful orchestration — inline is correct |
| Inline/dispatch consistency | PASS | No instructions.txt; uncompressed.md contains full procedure, not a dispatch card |
| Structure | PASS | SKILL.md contains full inline procedure; all 8 steps present |
| Input/output double-spec (A-IS-1) | PASS | N/A — no sub-skill outputs consumed as inputs |
| Sub-skill input isolation (A-IS-2) | N/A | |
| Frontmatter | PASS | name and description present and accurate |
| Name matches folder (A-FM-1) | PASS | name: swarm matches folder swarm/ in both SKILL.md and uncompressed.md |
| Valid frontmatter fields (A-FM-4) | PASS | Only name and description in frontmatter |
| Trigger phrases (A-FM-11) | PASS | description contains "Triggers -" with comma-separated phrases |
| uncompressed.md frontmatter mirror (A-FM-12) | PASS | name and description match SKILL.md exactly |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no real H1; uncompressed.md has real H1 at line 7 |
| No duplication | PASS | No overlapping capability found |
| Orphan files (A-FS-1) | PASS | All non-role files (reviewers/*, specs/*, reviewers/index.yaml) referenced by SKILL.md, uncompressed.md, or spec.md |
| Missing referenced files (A-FS-2) | PASS | All explicitly referenced local files exist |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | PASS | Both carry identical behavior across all 8 steps, B8 resolution order, calibration examples, and synthesis template |
| instructions.txt ↔ instructions.uncompressed.md | N/A | Inline skill; no instructions.txt |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md co-located with skill |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Requirements use must/shall throughout |
| Internal consistency | FAIL | Sub-spec index filename divergence (see Issues) |
| Spec completeness | PASS | All terms defined; behavior explicitly stated |
| Coverage | PASS | All 16 normative requirements represented in SKILL.md |
| No contradictions | FAIL | B8 step 1 behavioral divergence between spec and compiled artifacts (see Issues) |
| No unauthorized additions | PASS | No normative requirements in SKILL.md absent from spec |
| Conciseness | PASS | SKILL.md is decision-tree and table-oriented; no prose conditionals |
| Completeness | PASS | All runtime instructions present; edge cases addressed |
| Breadcrumbs | PASS | Related section present; all referenced sub-specs exist |
| Cost analysis | N/A | Inline skill |
| No dispatch refs | N/A | Inline skill; no instructions.txt |
| No spec breadcrumbs | PASS | SKILL.md and uncompressed.md contain no reference to own spec.md |
| Eval log (informational) | ABSENT | No eval.txt found; does not affect verdict |
| Description not restated (A-FM-2) | PASS | No restatement of description in body prose |
| No exposition in runtime (A-FM-5) | PASS | No rationale or background prose in SKILL.md or uncompressed.md |
| No non-helpful tags (A-FM-6) | PASS | "Usage:" line is operational (prohibits dispatch); informative labels on table are annotations, not bare type labels |
| No empty sections (A-FM-7) | PASS | All sections in uncompressed.md have body content |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety content present |
| Iteration-safety pointer form (A-FM-9a) | N/A | |
| No verbatim Rule A/B (A-FM-9b) | N/A | |
| Cross-reference anti-pattern (A-XR-1) | PASS | All cross-skill references in SKILL.md, uncompressed.md, and spec.md use canonical names (dispatch, code-review, compression) |
| Launch-script form (A-FM-10) | N/A | Inline skill |
| Return shape declared (DS-1) | N/A | Inline skill |
| Host card minimalism (DS-2) | N/A | Inline skill |
| Description trigger phrases (DS-3) | N/A | Inline skill |
| Inline dispatch guard (DS-4) | N/A | Inline skill |
| No substrate duplication (DS-5) | N/A | Inline skill |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Inline skill |
| Tool integration alignment (DS-7) | N/A | No tool trio present |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| SKILL.md | Not empty | PASS | |
| SKILL.md | Frontmatter required | PASS | |
| SKILL.md | No abs-path leaks | PASS | |
| uncompressed.md | Not empty | PASS | |
| uncompressed.md | Frontmatter required | PASS | |
| uncompressed.md | No abs-path leaks | PASS | |
| spec.md | Not empty | PASS | |
| spec.md | Frontmatter required | N/A | Not SKILL.md or agent.md |
| spec.md | No abs-path leaks | PASS | |
| specs/arbitrator.md | All basic checks | PASS | Not empty; no frontmatter required; no abs paths |
| specs/dispatch-integration.md | All basic checks | PASS | |
| specs/glossary.md | All basic checks | PASS | |
| specs/personality-file.md | All basic checks | PASS | |
| specs/registry-format.md | All basic checks | PASS | |
| reviewers/devils-advocate.md | All basic checks | PASS | |
| reviewers/security-auditor.md | All basic checks | PASS | |

### Issues

- **HIGH — Step 3, No contradictions:** B8 step 1 in SKILL.md and uncompressed.md reads "find any gated personality on a different family" (meaning an external-backend personality to unlock or substitute), while spec.md B8 step 1 reads "find any available personality on a different model family." These describe structurally different lookup strategies: the spec searches for any available personality (already in the selected or unselected registry) on a distinct model family, while the compiled artifacts restrict the search to external-backend (copilot-cli) personalities that may have failed the availability probe. A swarm where a `dispatch-sonnet` personality is registered on a different vendor would be missed by the compiled form but caught by the spec. Fix: edit swarm/uncompressed.md and recompress to swarm/SKILL.md — align B8 step 1 to spec language ("find any available personality on a different model family"), or amend spec.md to authorize the external-backend-unlock approach and reaudit.

- **LOW — Step 3, Internal consistency:** specs/glossary.md and specs/registry-format.md both reference `reviewers/index.md` as the recommended/default registry index filename ("index at `reviewers/index.md`" and "The recommended default is `reviewers/index.md` for human readability"), while SKILL.md and uncompressed.md explicitly state `reviewers/index.yaml` and the actual file on disk is `reviewers/index.yaml`. Sub-spec recommendations diverge from the implementation. Fix: update the default filename reference in specs/glossary.md and specs/registry-format.md from `index.md` to `index.yaml` to match the actual implementation.
