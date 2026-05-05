---
file_paths:
  - gh-cli/gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-post/instructions.txt
  - gh-cli/gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-post/instructions.uncompressed.md
  - gh-cli/gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-post/SKILL.md
  - gh-cli/gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-post/spec.md
  - gh-cli/gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-post/uncompressed.md
  - gh-cli/gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-post/verify-line-in-diff.spec.md
operation_kind: skill-auditing/v2
model: haiku-class
result: findings
---

# Result

NEEDS_REVISION

## Skill Audit: gh-cli-pr-inline-comment-post

**Verdict:** NEEDS_REVISION
**Type:** dispatch
**Path:** gh-cli/gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-post/

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Dispatch skill with instructions.txt present |
| Inline/dispatch consistency | PASS | instructions.txt confirms dispatch type |
| Structure | PASS | SKILL.md is routing card; instructions.txt has procedure |
| Input/output double-spec (A-IS-1) | PASS | No input duplication |
| Sub-skill input isolation (A-IS-2) | PASS | Tool takes only primary inputs |
| Frontmatter | PASS | name and description present |
| Name matches folder (A-FM-1) | PASS | gh-cli-pr-inline-comment-post matches folder |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no H1; uncompressed.md and instructions.uncompressed.md have H1 |
| No duplication | PASS | Distinct from sibling edit/delete skills |
| Orphan files (A-FS-1) | PASS | Tool files referenced in instructions.txt |
| Missing referenced files (A-FS-2) | PASS | instructions.txt exists |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | PASS | Identical frontmatter; uncompressed.md adds H1 and Return section |
| instructions.txt ↔ instructions.uncompressed.md | PASS | Same step sequence; uncompressed.md provides detailed code blocks |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present |
| Required sections | PASS | Purpose, Scope, Definitions, Inputs, Requirements, Constraints, Return Shape |
| Normative language | PASS | Must, always, never used correctly |
| Internal consistency | PASS | No contradictions |
| Spec completeness | PASS | All terms defined; all steps explicit |
| Coverage | PASS | All requirements in instructions.txt |
| No contradictions | PASS | instructions.txt implements spec faithfully |
| No unauthorized additions | PASS | No new rules beyond spec |
| Conciseness | PASS | Decision-tree form, fully actionable |
| Completeness | PASS | All steps, defaults, edge cases present |
| Breadcrumbs | PASS | No dangling references |
| Cost analysis | PASS | Zero-context dispatch; sub-skill justified |
| No dispatch refs | PASS | No recursive dispatch instructions |
| No spec breadcrumbs | PASS | No spec.md references in runtime files |
| Eval log (informational) | ABSENT | Not required |
| Description not restated (A-FM-2) | PASS | No body duplication of description |
| No exposition in runtime (A-FM-5) | PASS | No rationale or why-prose |
| No non-helpful tags (A-FM-6) | PASS | No bare type labels |
| No empty sections (A-FM-7) | PASS | All sections have body content |
| Iteration-safety placement (A-FM-8) | PASS | N/A — no iteration-safety |
| Iteration-safety pointer form (A-FM-9a) | PASS | N/A — no iteration-safety |
| No verbatim Rule A/B (A-FM-9b) | PASS | N/A — no iteration-safety |
| Cross-reference anti-pattern (A-XR-1) | PASS | No pointers to other skills' specs |
| Launch-script form (A-FM-10) | PASS | uncompressed.md follows correct form |
| Return shape declared (DS-1) | N/A | Returns JSON inline, not artifact |
| Host card minimalism (DS-2) | PASS | SKILL.md routing only, no cache/hints |
| Description trigger phrases (DS-3) | PASS | 5 trigger phrases (3-6 required) |
| Inline dispatch guard (DS-4) | FAIL | Missing path in delegation line (HIGH) |
| No substrate duplication (DS-5) | PASS | No hash-record schema inlined |
| No overbuilt sub-skill (DS-6) | PASS | Tool justifiably handles complex hunk parsing |

### Dispatch Skill Checks (DS-7)

| Check | Result | Notes |
| --- | --- | --- |
| Tool integration — Orphan (DS-7a) | PASS | verify-line-in-diff files referenced |
| Tool integration — Missing (DS-7b) | PASS | All tool files present |
| Tool integration — Spec alignment (DS-7c) | PASS | Tool-spec exit codes match instructions |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| SKILL.md | Not empty | PASS | 16 lines |
| SKILL.md | Frontmatter (required) | PASS | Present with name, description |
| SKILL.md | No abs-path leaks | PASS | No hardcoded paths |
| uncompressed.md | Not empty | PASS | 39 lines |
| uncompressed.md | Frontmatter (required) | PASS | Present |
| uncompressed.md | No abs-path leaks | PASS | No hardcoded paths |
| instructions.txt | Not empty | PASS | 19 lines |
| instructions.txt | No abs-path leaks | PASS | API paths use variables only |
| instructions.uncompressed.md | Not empty | PASS | 109 lines |
| instructions.uncompressed.md | No abs-path leaks | PASS | No hardcoded paths |
| spec.md | Not empty | PASS | 80 lines |
| spec.md | No abs-path leaks | PASS | No hardcoded paths |
| verify-line-in-diff.spec.md | Not empty | PASS | 145 lines |
| verify-line-in-diff.spec.md | Purpose | PASS | Present |
| verify-line-in-diff.spec.md | Parameters | PASS | Present |
| verify-line-in-diff.spec.md | Output | PASS | Present |
| verify-line-in-diff.spec.md | No abs-path leaks | PASS | No hardcoded paths |

### Issues

- **DS-4 Violation (HIGH)**: Delegation line in SKILL.md (line 15) and uncompressed.md (line 32) is "Follow dispatch skill." but must include path reference: "Follow dispatch skill. See <relative_path>/dispatch/SKILL.md". Missing path fails canonical dispatch pattern requirement.

### Recommendation

Append path reference to delegation lines: change "Follow dispatch skill." to "Follow dispatch skill. See dispatch/SKILL.md" in both SKILL.md and uncompressed.md.
