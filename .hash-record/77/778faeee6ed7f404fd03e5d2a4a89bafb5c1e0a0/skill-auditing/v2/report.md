---
file_paths:
  - test-scratch/two-triggers/instructions.txt
  - test-scratch/two-triggers/SKILL.md
  - test-scratch/two-triggers/uncompressed.md
operation_kind: skill-auditing/v2
model: haiku-class
result: fail
---

# Result

FAIL

## Skill Audit: two-triggers

**Verdict:** FAIL
**Type:** dispatch
**Path:** test-scratch/two-triggers

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Dispatch skill identified by presence of uncompressed.md and instructions.txt |
| Inline/dispatch consistency | PASS | File presence confirms dispatch (uncompressed.md + instructions.txt present) |
| Structure | PASS | SKILL.md and uncompressed.md follow dispatch routing card form |
| Input/output double-spec (A-IS-1) | PASS | No duplicate output specifications detected |
| Sub-skill input isolation (A-IS-2) | PASS | Dispatch target (dispatch/SKILL.md) is independent skill, not input-parameter consumer |
| Frontmatter | PASS | name and description present in both SKILL.md and uncompressed.md |
| Name matches folder (A-FM-1) | PASS | name: two-triggers matches folder name exactly |
| H1 per artifact (A-FM-3) | FAIL | uncompressed.md missing required H1 heading; SKILL.md correctly has no H1 |
| No duplication | PASS | Skill does not replicate existing capability |
| Orphan files (A-FS-1) | PASS | instructions.txt is referenced via dispatch variables and is part of skill bundle |
| Missing referenced files (A-FS-2) | PASS | instructions.txt exists as referenced |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | PASS | Uncompressed version faithfully expands routing card; variable bindings, explicit return contract on success/failure; no lost intent |
| instructions.txt ↔ instructions.uncompressed.md | N/A | instructions.uncompressed.md not present; instructions.txt only |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | FAIL | spec.md not found; required for dispatch skill |
| Required sections | SKIP | Spec missing; cannot audit |
| Normative language | SKIP | Spec missing; cannot audit |
| Internal consistency | SKIP | Spec missing; cannot audit |
| Spec completeness | SKIP | Spec missing; cannot audit |
| Coverage | FAIL | Spec absent; cannot verify requirements coverage in SKILL.md |
| No contradictions | SKIP | Spec missing; cannot audit |
| No unauthorized additions | SKIP | Spec missing; cannot audit |
| Conciseness | SKIP | Spec missing; cannot audit |
| Completeness | SKIP | Spec missing; cannot audit |
| Breadcrumbs | SKIP | Spec missing; cannot audit |
| Cost analysis | SKIP | Spec missing; cannot audit |
| No dispatch refs | N/A | Dispatch skill; references to dispatch/SKILL.md are invocation not sub-dispatch |
| No spec breadcrumbs | SKIP | Spec missing; cannot audit own spec references |
| Eval log (informational) | ABSENT | No eval.txt or eval.uncompressed.md found |
| Description not restated (A-FM-2) | PASS | Body does not duplicate frontmatter description |
| No exposition in runtime (A-FM-5) | PASS | No rationale or background prose in SKILL.md, uncompressed.md, instructions.txt |
| No non-helpful tags (A-FM-6) | PASS | "Follow dispatch skill" is helpful routing instruction |
| No empty sections (A-FM-7) | PASS | No section headings present; no empty sections |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety blurb present |
| Iteration-safety pointer form (A-FM-9a) | N/A | No iteration-safety pointer present |
| No verbatim Rule A/B (A-FM-9b) | N/A | No iteration-safety reference present |
| Cross-reference anti-pattern (A-XR-1) | PASS | References dispatch/SKILL.md (not uncompressed.md or spec.md of other skills) |
| Launch-script form (A-FM-10) | PASS | uncompressed.md contains: frontmatter, variable bindings (dispatch form), return contract, routing breadcrumb; within acceptable bounds for dispatch launch script |
| Return shape declared (DS-1) | PASS | Both SKILL.md and uncompressed.md declare return shape; success path: PATH:, failure path: ERROR: |
| Host card minimalism (DS-2) | PASS | uncompressed.md (host card) contains no cache mechanisms, impl details, tool fallbacks, or subjective qualifiers |
| Description trigger phrases (DS-3) | FINDINGS | Format deviation: description uses "Triggers —" (em-dash) instead of canonical "Triggers -" (hyphen); semantic content correct: 2 phrases ("analyze file", "generate summary") present; phrase count not policed per spec |
| Inline dispatch guard (DS-4) | PASS | NEVER READ guard present on `<instructions>` binding; Read and follow form present on `<prompt>` binding; delegation line present |
| No substrate duplication (DS-5) | N/A | Skill does not reference hash-record or similar substrate skills |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Dispatch to external skill is primary purpose, not a sub-skill for trivial work |
| Tool integration alignment (DS-7) | N/A | No .sh, .ps1, or *.spec.md tool files present |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| SKILL.md | Not empty | PASS | Contains frontmatter and routing instructions |
| SKILL.md | Frontmatter (required) | PASS | YAML frontmatter present with name and description |
| SKILL.md | No abs-path leaks | PASS | No absolute paths detected |
| SKILL.md | Real H1 (A-FM-3) | PASS | Correctly contains no real H1 (line 1 is frontmatter delimiter, body lines do not start with `# `) |
| uncompressed.md | Not empty | PASS | Contains frontmatter and dispatch form |
| uncompressed.md | Frontmatter (required) | PASS | YAML frontmatter present with name and description |
| uncompressed.md | No abs-path leaks | PASS | No absolute paths detected |
| uncompressed.md | Real H1 (A-FM-3) | FAIL | MUST contain real H1 for uncompressed.md; none found (expected: `# two-triggers` or similar at column 0) |
| instructions.txt | Not empty | PASS | Contains stub instructions |
| instructions.txt | No abs-path leaks | PASS | No absolute paths detected |

### Issues

1. **Missing spec.md (FAIL)** — Dispatch skill MUST have companion spec.md co-located with skill_dir. This spec establishes requirements, scope, definitions, constraints, and normative language for the skill. Without it, runtime correctness and intent are not formally documented. Fix: create test-scratch/two-triggers/spec.md with required sections (Purpose, Scope, Definitions, Requirements, Constraints).

2. **Missing H1 in uncompressed.md (HIGH)** — Uncompressed artifacts MUST contain real H1 heading at line 1 or shortly after frontmatter. This heading provides quick identification and document structure. The uncompressed.md currently lacks this. Fix: add `# two-triggers` or similar real H1 at start of uncompressed.md body.

3. **DS-3 Format Deviation (LOW)** — Description frontmatter uses "Triggers —" (em-dash U+2014) instead of canonical "Triggers -" (hyphen). Semantic content is correct (2 trigger phrases present, phrase count not policed per spec). Fix: normalize to "Triggers - analyze file, generate summary" for canonical format consistency.

### Recommendation

Create spec.md and add H1 to uncompressed.md before releasing. Normalize trigger phrase punctuation. After fixes, re-audit.
