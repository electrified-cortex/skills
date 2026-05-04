---
file_paths:
  - gh-cli/gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-post/SKILL.md
  - gh-cli/gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-post/instructions.txt
  - gh-cli/gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-post/instructions.uncompressed.md
  - gh-cli/gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-post/uncompressed.md
  - gh-cli/gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-post/verify-line-in-diff.spec.md
  - gh-cli/gh-cli-pr/gh-cli-pr-inline-comment/spec.md
operation_kind: skill-auditing/v2
model: haiku-class
result: pass
---

# Result

PASS

## Skill Audit: gh-cli-pr-inline-comment-post

**Verdict:** PASS
**Type:** dispatch
**Path:** gh-cli/gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-post

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Dispatch skill; instructions.txt and instructions.uncompressed.md present |
| Inline/dispatch consistency | PASS | Routing card contains dispatch invocation variables and return specification |
| Structure | PASS | Dispatch routing card structure correct: frontmatter, dispatch variables, return contract |
| Input/output double-spec (A-IS-1) | PASS | Input parameters do not duplicate output path; output is JSON object |
| Sub-skill input isolation (A-IS-2) | PASS | Verify-line-in-diff.spec.md is internal tool, not input parameter |
| Frontmatter | PASS | Both SKILL.md and uncompressed.md have YAML frontmatter with name and description |
| Name matches folder (A-FM-1) | PASS | Folder name matches frontmatter name in both artifacts |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no H1; uncompressed.md has H1 at line 6; instructions.txt has no H1 |
| No duplication | PASS | Distinct scope as post-only sub-skill |
| Orphan files (A-FS-1) | PASS | All files referenced: verify-line-in-diff.spec.md in instructions.uncompressed.md |
| Missing referenced files (A-FS-2) | PASS | All referenced files present |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | PASS | Identical routing card; SKILL.md is compressed, uncompressed.md adds readability |
| instructions.txt ↔ instructions.uncompressed.md | PASS | Identical procedure; txt is dense, uncompressed expands with gotchas |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md co-located at parent level; required for dispatch complex skill |
| Required sections | PASS | Purpose, Scope, Definitions, Inputs, Step Order, Requirements, Error Handling, Gotchas, Constraints, Return Shape all present |
| Normative language | PASS | Uses must, shall, required, never |
| Internal consistency | PASS | No contradictions; Requirements align with Error Handling |
| Spec completeness | PASS | All terms defined; all behaviors explicit |
| Coverage | PASS | Every spec requirement in SKILL.md/instructions |
| No contradictions | PASS | SKILL.md/instructions follow spec |
| No unauthorized additions | PASS | No extra requirements in instructions |
| Conciseness | PASS | Agent-facing density; each line affects behavior |
| Completeness | PASS | All runtime instructions present; edge cases addressed |
| Breadcrumbs | N/A | Dispatch sub-skill; parent routing skill covers related |
| Cost analysis | PASS | Dispatch agent appropriate; instructions under 500 lines |
| No dispatch refs | PASS | verify-line-in-diff called as shell tool, not sub-skill |
| No spec breadcrumbs | PASS | No self-references to spec.md or instructions.uncompressed.md |
| Eval log (informational) | ABSENT | No eval.txt; optional for dispatch |
| Description not restated (A-FM-2) | PASS | No body prose duplicates frontmatter description |
| No exposition in runtime (A-FM-5) | PASS | No rationale or narrative in runtime artifacts |
| No non-helpful tags (A-FM-6) | PASS | All labels actionable |
| No empty sections (A-FM-7) | PASS | All sections have content |
| Iteration-safety placement (A-FM-8) | N/A | Not applicable; skill makes destructive write |
| Iteration-safety pointer form (A-FM-9a) | N/A | Not applicable |
| No verbatim Rule A/B (A-FM-9b) | N/A | Not applicable |
| Cross-reference anti-pattern (A-XR-1) | PASS | No pointers to other skills' uncompressed.md or spec.md |
| Launch-script form (A-FM-10) | PASS | Contains: frontmatter, H1, dispatch variables, return contract |
| Return shape declared (DS-1) | PASS | Declares JSON object with status, comment_id, comment_url, message |
| Host card minimalism (DS-2) | PASS | No internal mechanisms, adaptive rules, or tool-fallback hints |
| Description trigger phrases (DS-3) | PASS | Follows pattern with 5 trigger phrases |
| Inline dispatch guard (DS-4) | PASS | Has NEVER READ guard, Read and follow form, Follow dispatch skill |
| No substrate duplication (DS-5) | PASS | No hash-record schema inlining |
| No overbuilt sub-skill dispatch (DS-6) | PASS | Verify-line-in-diff is shell tool, not sub-skill |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| SKILL.md | Not empty | PASS | 17 lines |
| SKILL.md | Frontmatter | PASS | Lines 1-4 |
| SKILL.md | No abs-path leaks | PASS | Clean |
| uncompressed.md | Not empty | PASS | 40 lines |
| uncompressed.md | Frontmatter | PASS | Lines 1-4 |
| uncompressed.md | No abs-path leaks | PASS | Clean |
| instructions.txt | Not empty | PASS | 20 lines |
| instructions.txt | No abs-path leaks | PASS | Clean |
| instructions.uncompressed.md | Not empty | PASS | 110 lines |
| instructions.uncompressed.md | No abs-path leaks | PASS | Clean |
| verify-line-in-diff.spec.md | Not empty | PASS | 146 lines |
| verify-line-in-diff.spec.md | Purpose section | PASS | Present |
| verify-line-in-diff.spec.md | Parameters section | PASS | Present |
| verify-line-in-diff.spec.md | Output section | PASS | Present |
| verify-line-in-diff.spec.md | No abs-path leaks | PASS | Clean |

### Issues

None identified.

### Recommendation

Skill is production-ready. All dispatch checks pass. Spec alignment complete. Parity exact. Return shape well-defined.

