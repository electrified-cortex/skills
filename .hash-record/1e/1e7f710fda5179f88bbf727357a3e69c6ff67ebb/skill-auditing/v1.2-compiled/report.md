---
file_paths:
  - swarm/SKILL.md
  - swarm/spec.md
operation_kind: skill-auditing
model: sonnet-class
result: findings
---

# Result

NEEDS_REVISION

## Skill Audit: swarm

**Verdict:** NEEDS_REVISION
**Type:** inline
**Path:** swarm/
**Failed phase:** none

### Phase 1 — Spec Gate

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | `swarm/spec.md` present |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Requirements 1–15 use "must" / "must not" throughout |
| Internal consistency | PASS | No contradictions; Precedence P1–P5 consistent across spec and SKILL.md |
| Completeness | PASS | All terms defined in Definitions; behavior exhaustively stated |

### Phase 2 — Skill Smoke Check

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Complex orchestration skill; host agent executes inline as intended by spec |
| Inline/dispatch consistency | PASS | No `instructions.txt` present; SKILL.md contains full procedure — consistent with inline |
| Structure | PASS | Frontmatter present; step sequence, behaviors, precedence, constraints all self-contained |
| Input/output double-spec (A-IS-1) | PASS | Inputs (`problem`, `personality_filter`, `model_overrides`) do not duplicate sub-skill output conventions |
| Frontmatter | PASS | `name` and `description` accurate |
| Name matches folder (A-FM-1) | PASS | `name: swarm` matches `swarm/` folder |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no H1; `uncompressed.md` opens with H1 |
| No duplication | PASS | No existing skill with equivalent scope found |

### Phase 3 — Spec Compliance

| Check | Result | Notes |
| --- | --- | --- |
| Coverage | PASS | S1–S8, B1–B8, P1–P5, Don'ts, Scope — all spec requirements represented |
| No contradictions | PASS | SKILL.md and spec agree on all behavioral rules |
| No unauthorized additions | PASS | No normative rules in SKILL.md absent from spec |
| Conciseness | PASS | Decision-tree style; no "too much why"; no prose conditionals; no essay prose |
| Completeness | PASS | Edge cases via B1–B5; error cases via Don'ts; defaults stated |
| Breadcrumbs | PASS | Related section lists `dispatch`, `compression`, `skill-index` by name |
| Cost analysis | N/A | Inline skill |
| No dispatch refs | N/A | No `instructions.txt` |
| No spec breadcrumbs | PASS | SKILL.md does not reference its own `spec.md` |
| Description not restated (A-FM-2) | PASS | No verbatim duplication of description in body |
| No exposition in runtime (A-FM-5) | FAIL | `uncompressed.md` Constraints section (C3) contains rationale prose — see Issues |
| No non-helpful tags (A-FM-6) | PASS | No bare type labels or non-operational descriptor lines found |
| No empty sections (A-FM-7) | PASS | All headings in SKILL.md and `uncompressed.md` have body content |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety content present |
| Iteration-safety pointer form (A-FM-9a) | N/A | Not applicable |
| No verbatim Rule A/B (A-FM-9b) | N/A | Not applicable |
| Cross-reference anti-pattern (A-XR-1) | PASS | Related sections reference skills and sub-specs by name or relative sibling path only; no paths to another skill's `uncompressed.md` or `spec.md` |
| Launch-script form (A-FM-10) | N/A | Inline skill |
| Return shape declared (DS-1) | N/A | Inline skill |
| Host card minimalism (DS-2) | N/A | Inline skill |
| Description trigger phrases (DS-3) | N/A | Inline skill |
| No substrate duplication (DS-5) | N/A | Inline skill |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Inline skill |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| `SKILL.md` | Not empty | PASS | |
| `SKILL.md` | Frontmatter required | PASS | YAML frontmatter at line 1 |
| `SKILL.md` | No abs-path leaks | PASS | |
| `spec.md` | Not empty | PASS | |
| `spec.md` | No abs-path leaks | PASS | |
| `uncompressed.md` | Not empty | PASS | |
| `uncompressed.md` | No abs-path leaks | PASS | |
| `reviewers/devils-advocate.md` | Not empty | PASS | |
| `reviewers/devils-advocate.md` | No abs-path leaks | PASS | |
| `reviewers/index.md` | Not empty | PASS | |
| `reviewers/index.md` | No abs-path leaks | PASS | |
| `reviewers/security-auditor.md` | Not empty | PASS | |
| `reviewers/security-auditor.md` | No abs-path leaks | PASS | |
| `specs/arbitrator.md` | Not empty | PASS | |
| `specs/arbitrator.md` | No abs-path leaks | PASS | |
| `specs/dispatch-integration.md` | Not empty | PASS | |
| `specs/dispatch-integration.md` | No abs-path leaks | PASS | |
| `specs/glossary.md` | Not empty | PASS | |
| `specs/glossary.md` | No abs-path leaks | PASS | |
| `specs/personality-file.md` | Not empty | PASS | |
| `specs/personality-file.md` | No abs-path leaks | PASS | |
| `specs/registry-format.md` | Not empty | PASS | |
| `specs/registry-format.md` | No abs-path leaks | PASS | |
| `.gitignore` | Orphan (A-FS-1) | LOW | Not a well-known role file; not referenced in SKILL.md, `uncompressed.md`, or `instructions.uncompressed.md` |

### Issues

- **[HIGH — A-FM-5] Exposition in `uncompressed.md` Constraints section (C3)**: The C3 block contains background rationale ("The skill does not technically prevent a sub-agent from calling mutating tools; the constraint is behavioral, enforced by prompt instruction only. A sub-agent violation is a prompt-design defect, not a dispatch-skill defect. Known limitation (see F3)."). This is "why this works this way" prose, not an operative instruction. Fix: remove this sentence from `uncompressed.md`. The equivalent explanation already lives in `spec.md` Constraints (C3) and Footguns (F3) where rationale belongs.

- **[LOW — A-FS-1] `.gitignore` orphan**: `.gitignore` at the skill root is not referenced in any primary skill artifact. If intentional (e.g., suppresses `.hash-record/` or build artifacts), add a brief comment in `uncompressed.md` Related section or a README noting its purpose, or confirm it belongs to the parent repo and not this skill folder.

### Recommendation

Remove the rationale sentence from `uncompressed.md` Constraints C3 (move to `spec.md` if not already present) to resolve the one HIGH finding; the skill is otherwise well-structured and spec-compliant.
