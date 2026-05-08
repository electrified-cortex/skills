---
file_paths:
  - skills/swarm/SKILL.md
  - skills/swarm/spec.md
  - skills/swarm/uncompressed.md
operation_kind: skill-auditing/v2
model: haiku-class
result: findings
---

# Result

NEEDS_REVISION

## Skill Audit: swarm

**Verdict:** NEEDS_REVISION
**Type:** inline
**Path:** skills/swarm

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | No dispatch instruction files present; SKILL.md contains full procedure; skill is inline |
| Inline/dispatch consistency | PASS | Correct; inline skills have no instruction files |
| Structure | PASS | Well-organized with steps, constraints, behavior rules; mirrors spec structure |
| Input/output double-spec (A-IS-1) | N/A | Inline skill; not applicable |
| Sub-skill input isolation (A-IS-2) | N/A | Inline skill; not applicable |
| Frontmatter | PASS | Both SKILL.md and uncompressed.md have valid YAML frontmatter with name and description |
| Name matches folder (A-FM-1) | PASS | Folder "swarm" matches name "swarm" in both SKILL.md and uncompressed.md (exact case match) |
| H1 per artifact (A-FM-3) | FAIL | SKILL.md contains a real H1 at line 8 (`# swarm`). Per A-FM-3, SKILL.md must NOT contain a real H1. Violation found: HIGH |
| No duplication | PASS | No files appear to be orphans or duplicates |
| Orphan files (A-FS-1) | PASS | All files in skill_dir are accounted for: SKILL.md, uncompressed.md, spec.md, reviewers/, specs/, optimize-log.md, .gitignore, .optimization/, .research/ (dot-prefixed skipped) |
| Missing referenced files (A-FS-2) | PASS | All referenced sub-specs in specs/ directory exist: arbitrator.md, dispatch-integration.md, glossary.md, personality-file.md, registry-format.md |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | PASS | Both present; uncompressed.md is expanded source with additional explanatory prose; SKILL.md is faithful compressed form with no loss of normative intent |
| instructions.txt ↔ instructions.uncompressed.md | N/A | Inline skill; no instruction files present |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present and well-structured |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements (Personality Registry, Custom Menu, Inputs, Step Sequence, Constraints, Behavior, Defaults, Error Handling, Precedence, Don'ts), Section Classification all present |
| Normative language | PASS | Uses "must", "shall", "required", "must not" throughout with clear normative force |
| Internal consistency | PASS | No contradictions detected; behavior rules align with requirements |
| Spec completeness | PASS | All terms defined; all behavior explicitly stated; edge cases addressed |
| Coverage | PASS | Every normative requirement in spec is represented in SKILL.md |
| No contradictions | PASS | SKILL.md and spec.md align perfectly; spec is authoritative, SKILL.md subordinate |
| No unauthorized additions | PASS | SKILL.md does not introduce normative requirements absent from spec |
| Conciseness | PASS | SKILL.md is appropriately concise; agent can skim and understand in one pass |
| Completeness | PASS | All runtime instructions present; no implicit assumptions |
| Breadcrumbs | PASS | Both SKILL.md and spec.md end with Related sections pointing to valid sub-specs in specs/ directory |
| Cost analysis | N/A | Inline skill; not applicable |
| No dispatch refs | N/A | Inline skill; not applicable |
| No spec breadcrumbs | PASS | SKILL.md does not reference its own spec.md; references are to sub-specs only |
| Eval log (informational) | ABSENT | No eval.txt or eval.uncompressed.md present; not required for verdict |
| Description not restated (A-FM-2) | PASS | Description in frontmatter is not restated in SKILL.md body; Key Terms section begins without recapitulating frontmatter |
| No exposition in runtime (A-FM-5) | PASS | No background prose, root-cause narrative, or historical notes; "Pre-implementation gate" line is operational guidance, not rationale |
| No non-helpful tags (A-FM-6) | PASS | No descriptor lines with no operational value |
| No empty sections (A-FM-7) | PASS | All headings have corresponding body content |
| Iteration-safety placement (A-FM-8) | N/A | No instructions.uncompressed.md or instructions.txt present |
| Iteration-safety pointer form (A-FM-9a) | N/A | Not applicable for inline skills |
| No verbatim Rule A/B (A-FM-9b) | N/A | Not applicable for inline skills |
| Cross-reference anti-pattern (A-XR-1) | PASS | Related section uses canonical names with optional file pointers; sub-spec references are within-skill files, exempt from naming rules |
| Launch-script form (A-FM-10) | N/A | Inline skill; not applicable |
| Return shape declared (DS-1) | N/A | Inline skill; not dispatch |
| Host card minimalism (DS-2) | N/A | Inline skill; not dispatch |
| Description trigger phrases (DS-3) | PASS | Description contains "Triggers — swarm review, multi-reviewer, parallel personalities, run all reviewers, arbitrate findings" meeting trigger phrase requirement |
| Inline dispatch guard (DS-4) | N/A | Inline skill; not dispatch |
| No substrate duplication (DS-5) | N/A | Inline skill; not dispatch |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Inline skill; not dispatch |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| SKILL.md | Not empty | PASS | File contains substantive content |
| SKILL.md | Frontmatter (required) | PASS | YAML frontmatter present with name and description |
| SKILL.md | No abs-path leaks | PASS | No Windows (`<letter>:\`) or Unix root-anchored paths found |
| uncompressed.md | Not empty | PASS | File contains substantive content |
| uncompressed.md | Frontmatter (required) | PASS | YAML frontmatter present with name and description matching SKILL.md |
| uncompressed.md | No abs-path leaks | PASS | No absolute-path leaks detected |
| spec.md | Not empty | PASS | File contains substantive content |
| spec.md | Frontmatter (N/A for .spec.md) | N/A | Purpose/Parameters/Output sections present; frontmatter not required for .spec.md |
| spec.md | No abs-path leaks | PASS | No absolute-path leaks detected |
| specs/arbitrator.md | Not empty | PASS | Contains substantive role definition |
| specs/arbitrator.md | No abs-path leaks | PASS | No absolute-path leaks |
| specs/dispatch-integration.md | Not empty | PASS | Substantive content present |
| specs/dispatch-integration.md | No abs-path leaks | PASS | No absolute-path leaks |
| specs/glossary.md | Not empty | PASS | Contains term definitions |
| specs/glossary.md | No abs-path leaks | PASS | No absolute-path leaks |
| specs/personality-file.md | Not empty | PASS | Substantive content present |
| specs/personality-file.md | No abs-path leaks | PASS | No absolute-path leaks |
| specs/registry-format.md | Not empty | PASS | Substantive content present |
| specs/registry-format.md | No abs-path leaks | PASS | No absolute-path leaks |
| reviewers/devils-advocate.md | Not empty | PASS | Contains personality definition |
| reviewers/devils-advocate.md | No abs-path leaks | PASS | No absolute-path leaks |
| reviewers/security-auditor.md | Not empty | PASS | Contains personality definition |
| reviewers/security-auditor.md | No abs-path leaks | PASS | No absolute-path leaks |

### Issues

- **A-FM-3 violation — H1 in SKILL.md**: SKILL.md line 8 contains `# swarm`, a real H1 marker. Per audit specification A-FM-3: "Rule: `SKILL.md` MUST NOT contain a real H1." This is a violation. Remediation: Remove the H1 from SKILL.md line 8. The title information is already present in the frontmatter description; the H1 is redundant and violates the spec. Uncompressed.md correctly retains its H1 (`# swarm — Uncompressed Reference`) as required.

### Recommendation

Remove the `# swarm` H1 from SKILL.md line 8. The frontmatter description field already serves as the title and is the correct location per specification A-FM-3.

