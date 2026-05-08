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
| Classification | PASS | Inline — no dispatch instruction file present; full 8-step procedure in SKILL.md |
| Inline/dispatch consistency | PASS | SKILL.md contains complete self-contained procedure; no instructions.txt |
| Structure | PASS | Frontmatter present; direct instructions; self-contained |
| Input/output double-spec (A-IS-1) | N/A | Inline skill |
| Sub-skill input isolation (A-IS-2) | N/A | Inline skill |
| Frontmatter | PASS | name and description present and accurate |
| Name matches folder (A-FM-1) | PASS | `name: swarm` matches folder `swarm/`; uncompressed.md mirrors |
| Valid frontmatter fields (A-FM-4) | PASS | SKILL.md frontmatter contains only `name` and `description` |
| Trigger phrases (A-FM-11) | PASS | `Triggers -` present in description of SKILL.md and uncompressed.md |
| uncompressed.md frontmatter mirror (A-FM-12) | PASS | name and description match SKILL.md exactly |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no real H1; uncompressed.md has `# swarm — Uncompressed Reference` |
| No duplication | PASS | Unique multi-personality review infrastructure |
| Orphan files (A-FS-1) | FAIL | `swarm/.gitignore` not referenced in any skill document — LOW |
| Missing referenced files (A-FS-2) | PASS | All explicitly referenced files exist (`reviewers/devils-advocate.md`, `reviewers/security-auditor.md`, `reviewers/index.yaml`, all `specs/*.md`) |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | PASS | All requirements, constraints, behavior, defaults, error handling, and precedence faithfully expanded; no intent divergence |
| instructions.txt ↔ instructions.uncompressed.md | N/A | Inline skill; no instructions.txt |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md co-located in `swarm/` |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements (16 items), Constraints all present |
| Normative language | PASS | Requirements use `must` throughout |
| Internal consistency | PASS | No contradictions between sections; step sequence references constraints correctly |
| Spec completeness | PASS | All terms defined in Definitions; behavior explicitly stated |
| Coverage | PASS | All 16 Requirements from spec.md represented in SKILL.md |
| No contradictions | PASS | SKILL.md consistent with spec.md; no conflicts found |
| No unauthorized additions | FAIL | Two normative behavioral requirements in SKILL.md absent from spec.md — HIGH; see Issues |
| Conciseness | PASS | Dense reference-card format; no "why" exposition or prose conditionals |
| Completeness | PASS | All runtime instructions present; edge cases addressed |
| Breadcrumbs | PASS | Related section references `dispatch`, `compression`, and sub-specs in `specs/` |
| Cost analysis | N/A | Inline skill |
| No dispatch refs | N/A | Inline skill |
| No spec breadcrumbs | PASS | SKILL.md and uncompressed.md do not reference companion `spec.md` |
| Eval log (informational) | ABSENT | `eval.txt` not present |
| Description not restated (A-FM-2) | PASS | No body prose duplicates description frontmatter |
| No exposition in runtime (A-FM-5) | PASS | No rationale, historical notes, or background prose found in SKILL.md or uncompressed.md |
| No non-helpful tags (A-FM-6) | PASS | No bare descriptor labels without operational value |
| No empty sections (A-FM-7) | PASS | All sections have content |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety content present |
| Iteration-safety pointer form (A-FM-9a) | N/A | No iteration-safety reference |
| No verbatim Rule A/B (A-FM-9b) | N/A | No iteration-safety reference |
| Cross-reference anti-pattern (A-XR-1) | PASS | All cross-skill refs use canonical names (`dispatch`, `compression`, `code-review`); sub-file refs are own-folder files |
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
| `SKILL.md` | All checks pass | PASS | Not empty; frontmatter present; no abs-path leaks |
| `spec.md` | All checks pass | PASS | Not empty; no abs-path leaks |
| `uncompressed.md` | All checks pass | PASS | Not empty; frontmatter present (A-FM-12); no abs-path leaks |
| `reviewers/devils-advocate.md` | All checks pass | PASS | Not empty; no abs-path leaks |
| `reviewers/security-auditor.md` | All checks pass | PASS | Not empty; no abs-path leaks |
| `specs/arbitrator.md` | All checks pass | PASS | Not empty; no abs-path leaks |
| `specs/dispatch-integration.md` | All checks pass | PASS | Not empty; no abs-path leaks |
| `specs/glossary.md` | All checks pass | PASS | Not empty; no abs-path leaks |
| `specs/personality-file.md` | All checks pass | PASS | Not empty; no abs-path leaks |
| `specs/registry-format.md` | All checks pass | PASS | Not empty; no abs-path leaks |

### Issues

- **A-FS-1 (LOW)**: `swarm/.gitignore` is present in the skill directory but is not referenced by name or relative path in SKILL.md, uncompressed.md, spec.md, or instructions.uncompressed.md. Fix: remove it from the skill folder if it is a stray file; if it is intentional (e.g., suppressing generated output from the skill), add a brief reference or note in spec.md.

- **No unauthorized additions (HIGH)**: SKILL.md (and uncompressed.md, which mirrors it) introduces two normative behavioral requirements that are absent from spec.md:

  1. **File-existence filter (pre-arbitration)** — SKILL.md Step 6 mandates discarding any member finding that cites a file not present in the review packet's Files-affected list before forwarding to the arbitrator, using deterministic string matching (exact path). Neither spec.md Step 6 nor `specs/arbitrator.md` mention this filter. Fix: add the file-existence filter rule to spec.md Step 6 (and update `specs/arbitrator.md` Dispatch section if appropriate), then recompress to SKILL.md and uncompressed.md; or remove the filter from both SKILL.md and uncompressed.md if it is not intended behavior.

  2. **Structured-evidence requirement for HIGH/CRITICAL findings** — SKILL.md Step 5 mandates that any finding marked HIGH or CRITICAL severity must include three fields: Source (where the vulnerability/bug enters), Sink (where it causes harm), and Missing guard (what defense is absent); findings at HIGH/CRITICAL severity lacking this structure are automatically downgraded to MEDIUM. This requirement does not appear in spec.md Requirements (items 1–16), Step 5, or the Constraints section (C1–C6 address read-only mode, evidence citation, and model naming, but none define the three-field structured-evidence form). Fix: add the structured-evidence requirement to spec.md as a new Requirement and/or Constraint entry, then recompress to SKILL.md and uncompressed.md; or remove it from SKILL.md and uncompressed.md if unintended.
