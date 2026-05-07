---
file_paths:
  - swarm/SKILL.md
  - swarm/spec.md
  - swarm/uncompressed.md
operation_kind: skill-auditing/v2
model: sonnet-class
result: fail
---

# Result

FAIL

## Skill Audit: swarm

**Verdict:** FAIL
**Type:** inline
**Path:** swarm/

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Inline — no dispatch instruction file present; full procedure in SKILL.md/uncompressed.md |
| Inline/dispatch consistency | PASS | No instruction file; SKILL.md contains full step sequence |
| Structure | PASS | Frontmatter, direct instructions, self-contained |
| Input/output double-spec (A-IS-1) | PASS | |
| Sub-skill input isolation (A-IS-2) | N/A | |
| Frontmatter | PASS | `name` and `description` only (A-FM-4); `Triggers -` present (A-FM-11); uncompressed.md mirrors exactly (A-FM-12) |
| Name matches folder (A-FM-1) | PASS | `name: swarm` matches folder name in both SKILL.md and uncompressed.md |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no real H1; uncompressed.md has `# swarm — Uncompressed Reference` |
| No duplication | PASS | No overlap with existing skills identified |
| Orphan files (A-FS-1) | PASS | `reviewers/*.md` generically referenced; `reviewers/index.yaml` referenced by name; `specs/*.md` referenced by path in Related section |
| Missing referenced files (A-FS-2) | PASS | `specs/` directory present with all five referenced sub-specs; `reviewers/devils-advocate.md` and `reviewers/security-auditor.md` present |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | PASS | Both consistently omit C3; Step 5 dangling reference identical in both; artifacts match each other |
| instructions.txt ↔ instructions.uncompressed.md | N/A | Neither file present |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md co-located with skill |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Requirements use must/must not/required throughout |
| Internal consistency | PASS | |
| Spec completeness | PASS | All terms defined; all behavior stated; Footguns section present |
| Coverage | **FAIL** | spec.md Constraint C3 absent from SKILL.md and uncompressed.md; Step 5 in both files contains dangling reference to C3 |
| No contradictions | PASS | |
| No unauthorized additions | PASS | C8 in compiled artifacts corresponds to DN9 in spec |
| Conciseness | PASS | SKILL.md is terse and decision-tree structured |
| Completeness | PASS | All runtime instructions present except C3 gap (captured under Coverage) |
| Breadcrumbs | PASS | All Related targets exist on disk |
| Cost analysis | N/A | Inline skill |
| No dispatch refs | N/A | Inline skill |
| No spec breadcrumbs | PASS | No reference to own companion spec.md in SKILL.md or uncompressed.md |
| Eval log (informational) | ABSENT | |
| Description not restated (A-FM-2) | PASS | |
| No exposition in runtime (A-FM-5) | PASS | Rationale blocks confirmed absent from uncompressed.md Steps 2 and 4 |
| No non-helpful tags (A-FM-6) | PASS | |
| No empty sections (A-FM-7) | PASS | |
| Iteration-safety placement (A-FM-8) | N/A | |
| Iteration-safety pointer form (A-FM-9a) | N/A | |
| No verbatim Rule A/B (A-FM-9b) | N/A | |
| Cross-reference anti-pattern (A-XR-1) | PASS | All cross-skill references use canonical names; own sub-file paths are not violations |
| Launch-script form (A-FM-10) | N/A | Inline skill |
| Return shape declared (DS-1) | N/A | Inline skill |
| Host card minimalism (DS-2) | N/A | Inline skill |
| Description trigger phrases (DS-3) | N/A | Inline skill |
| Inline dispatch guard (DS-4) | N/A | Inline skill |
| No substrate duplication (DS-5) | N/A | Inline skill |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Inline skill |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| `SKILL.md` | Not empty | PASS | |
| `SKILL.md` | Frontmatter | PASS | `---` block at line 1 |
| `SKILL.md` | No abs-path leaks | PASS | |
| `uncompressed.md` | Not empty | PASS | |
| `uncompressed.md` | Frontmatter | PASS | |
| `uncompressed.md` | No abs-path leaks | PASS | |
| `spec.md` | Not empty | PASS | |
| `spec.md` | No abs-path leaks | PASS | |
| `reviewers/devils-advocate.md` | Not empty | PASS | |
| `reviewers/devils-advocate.md` | Frontmatter | N/A | Metadata in index.yaml by design |
| `reviewers/devils-advocate.md` | No abs-path leaks | PASS | |
| `reviewers/security-auditor.md` | Not empty | PASS | |
| `reviewers/security-auditor.md` | Frontmatter | N/A | Metadata in index.yaml by design |
| `reviewers/security-auditor.md` | No abs-path leaks | PASS | |

### Issues

- **[FAIL] Coverage — Spec Constraint C3 absent from compiled artifacts.**
  `spec.md` Constraints section defines C3: "The skill does not technically prevent a sub-agent from calling mutating tools; the constraint is behavioral, enforced by prompt instruction. If a sub-agent violates it, the violation is a prompt-design defect, not a dispatch-skill defect. The spec flags this as a known limitation (see Footguns, F3)."
  Neither `swarm/SKILL.md` nor `swarm/uncompressed.md` includes this constraint — their Constraints lists jump directly from C2 to C4.
  Additionally, Step 5 in `swarm/SKILL.md` contains "see Constraints C1–C3" and Step 5 in `swarm/uncompressed.md` contains "see C1–C3" — both are dangling references since C3 is not defined in either file.
  Fix: add C3 to the Constraints section of `swarm/uncompressed.md` between C2 and C4, then recompress to `swarm/SKILL.md`.

### Recommendation

Add spec.md Constraint C3 to `uncompressed.md` Constraints section between C2 and C4; recompress to `SKILL.md` to resolve the dangling reference in Step 5.
