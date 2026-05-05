---
file_paths:
  - instructions.txt
  - SKILL.md
  - uncompressed.md
operation_kind: skill-auditing/v2
model: haiku-class
result: fail
---

# Result

FAIL

## Skill Audit: eight-triggers

**Verdict:** FAIL
**Type:** dispatch
**Path:** wt-10-0995/test-scratch/eight-triggers

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Dispatch skill; instructions.txt present and referenced |
| Inline/dispatch consistency | PASS | SKILL.md is routing card; uncompressed.md contains dispatch machinery |
| Structure | PASS | Dispatch structure correct |
| Input/output double-spec (A-IS-1) | PASS | Input and output properly specified without duplication |
| Sub-skill input isolation (A-IS-2) | N/A | No sub-skills referenced |
| Frontmatter | PASS | All artifacts have required `name` and `description` |
| Name matches folder (A-FM-1) | PASS | Name `eight-triggers` matches folder and appears in both SKILL.md and uncompressed.md |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no H1 (correct); uncompressed.md H1 enforcement out of scope (markdown-hygiene) |
| No duplication | PASS | No capability duplication detected |
| Orphan files (A-FS-1) | PASS | All files are well-known role files; no orphans |
| Missing referenced files (A-FS-2) | PASS | Both SKILL.md and uncompressed.md reference instructions.txt, which exists |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | PASS | Core intent preserved; uncompressed is full expanded dispatch form, SKILL.md is compressed routing card |
| instructions.txt ↔ instructions.uncompressed.md | N/A | instructions.uncompressed.md not present |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | FAIL | spec.md required for dispatch skills; none found |
| Required sections | SKIP | Spec missing; downstream checks skipped |
| Normative language | SKIP | Spec missing |
| Internal consistency | SKIP | Spec missing |
| Spec completeness | SKIP | Spec missing |
| Coverage | SKIP | Spec missing |
| No contradictions | SKIP | Spec missing |
| No unauthorized additions | SKIP | Spec missing |
| Conciseness | SKIP | Spec missing |
| Completeness | SKIP | Spec missing |
| Breadcrumbs | SKIP | Spec missing |
| Cost analysis | N/A | Spec not present to evaluate |
| No dispatch refs | PASS | Neither instructions.txt nor uncompressed.md attempt to dispatch other skills |
| No spec breadcrumbs | PASS | No references to own spec.md in runtime artifacts |
| Eval log (informational) | ABSENT | No eval.txt or eval.uncompressed.md present |
| Description not restated (A-FM-2) | PASS | Description in frontmatter is not restated verbatim in artifact bodies |
| No exposition in runtime (A-FM-5) | PASS | No rationale, "why this exists," or background prose found |
| No non-helpful tags (A-FM-6) | PASS | No empty descriptor lines or bare type labels |
| No empty sections (A-FM-7) | PASS | No empty leaf sections |
| Iteration-safety placement (A-FM-8) | PASS | No iteration-safety prose present (correct for non-iteration-safe skill) |
| Iteration-safety pointer form (A-FM-9a) | N/A | No iteration-safety references |
| No verbatim Rule A/B (A-FM-9b) | N/A | No iteration-safety references |
| Cross-reference anti-pattern (A-XR-1) | PASS | No pointers to other skills' uncompressed.md or spec.md |
| Launch-script form (A-FM-10) | PASS | uncompressed.md contains only: frontmatter, dispatch invocation, return contract, routing card (no executor procedures) |
| Return shape declared (DS-1) | PASS | Both SKILL.md and uncompressed.md declare return shape: `PATH: <abs-path-to-report>` on success |
| Host card minimalism (DS-2) | PASS | uncompressed.md contains minimal routing info; no internal cache description, no adaptive rules, no tool fallbacks |
| Description trigger phrases (DS-3) | PASS | Description follows pattern with legitimate trigger phrases; no implementation notes; phrase count not policed as per spec |
| Inline dispatch guard (DS-4) | PASS | uncompressed.md includes `(NEVER READ)` guard on instructions binding and `Read and follow` form on prompt binding |
| No substrate duplication (DS-5) | N/A | No sub-skill dispatch of hash-record or similar substrate skill |
| No overbuilt sub-skill dispatch (DS-6) | N/A | No sub-skills |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| SKILL.md | Not empty | PASS | Contains frontmatter and routing info |
| SKILL.md | Frontmatter required | PASS | Has `---` block with `name` and `description` |
| SKILL.md | No abs-path leaks | PASS | No Windows or Unix root-anchored paths detected |
| uncompressed.md | Not empty | PASS | Contains frontmatter and dispatch machinery |
| uncompressed.md | Frontmatter required | PASS | Has `---` block with `name` and `description` |
| uncompressed.md | No abs-path leaks | PASS | No Windows or Unix root-anchored paths detected |
| instructions.txt | Not empty | PASS | Contains content |
| instructions.txt | Frontmatter required | N/A | .txt file; frontmatter not required |
| instructions.txt | No abs-path leaks | PASS | No paths detected |

### Issues

- **FAIL: Missing spec.md** — Dispatch skills MUST have a companion spec.md co-located with the skill directory. Spec must define Purpose, Scope, Definitions, Requirements, and Constraints. Recommendation: Create spec.md with required sections.

### Recommendation

Create spec.md companion file with all required sections before marking skill ready for use.
