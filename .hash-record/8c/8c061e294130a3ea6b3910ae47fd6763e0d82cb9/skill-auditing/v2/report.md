---
file_paths:
  - messaging/spec.md
  - messaging/uncompressed.md
operation_kind: skill-auditing/v2
model: sonnet-class
result: fail
---

# Result

FAIL

## Skill Audit: messaging

**Verdict:** FAIL
**Type:** inline
**Path:** messaging/

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | No dispatch instruction file present; no dispatch invocation in uncompressed.md → inline |
| Inline/dispatch consistency | PASS | No instructions.txt; uncompressed.md is not a routing card |
| Structure | FAIL | SKILL.md absent — primary compiled artifact missing |
| Input/output double-spec (A-IS-1) | N/A | No sub-skills referenced |
| Sub-skill input isolation (A-IS-2) | N/A | No sub-skills |
| Frontmatter | N/A | SKILL.md absent; uncompressed.md frontmatter is valid |
| Name matches folder (A-FM-1) | PASS | uncompressed.md `name: messaging` matches folder name; SKILL.md absent |
| Valid frontmatter fields (A-FM-4) | N/A | SKILL.md absent |
| Trigger phrases (A-FM-11) | PASS | uncompressed.md description contains `Triggers -` |
| uncompressed.md frontmatter mirror (A-FM-12) | FAIL | SKILL.md absent; cannot verify name/description match |
| H1 per artifact (A-FM-3) | PASS | uncompressed.md has `# Messaging`; SKILL.md absent |
| No duplication | PASS | No equivalent capability found in workspace |
| Orphan files (A-FS-1) | PASS | implementation.md referenced by spec.md (R12, R22) |
| Missing referenced files (A-FS-2) | PASS | implementation.md exists as referenced |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | N/A | SKILL.md absent |
| instructions.txt ↔ instructions.uncompressed.md | N/A | Neither file exists |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md co-located with skill folder |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | MUST/SHALL used consistently throughout Requirements |
| Internal consistency | LOW | Section Classification table has duplicate rows: Precedence Rules, Don'ts, and Section Classification each appear twice at end of table |
| Spec completeness | PASS | All terms defined; all behavior explicitly stated |
| Coverage | FAIL | Cannot verify spec coverage in SKILL.md — SKILL.md absent |
| No contradictions | PASS | uncompressed.md is consistent with spec |
| No unauthorized additions | PASS | |
| Conciseness | PASS | |
| Completeness | PASS | All runtime behavior described in uncompressed.md |
| Breadcrumbs | PASS | markdown-hygiene, skill-auditing, compression all present in workspace |
| Cost analysis | N/A | Inline skill |
| No dispatch refs | N/A | No instructions.txt |
| No spec breadcrumbs | PASS | No references to own spec.md in runtime artifacts |
| Eval log (informational) | ABSENT | No eval.txt or eval.md in messaging/ |
| Description not restated (A-FM-2) | PASS | Body prose does not duplicate description frontmatter |
| No exposition in runtime (A-FM-5) | PASS | No rationale or background prose in uncompressed.md |
| No non-helpful tags (A-FM-6) | PASS | |
| No empty sections (A-FM-7) | PASS | All sections have content |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety references present |
| Iteration-safety pointer form (A-FM-9a) | N/A | |
| No verbatim Rule A/B (A-FM-9b) | N/A | |
| Cross-reference anti-pattern (A-XR-1) | PASS | All cross-skill references in Related use canonical names |
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
| `spec.md` | Not empty | PASS | |
| `spec.md` | Frontmatter (if required) | N/A | Not SKILL.md or agent.md |
| `spec.md` | No abs-path leaks | PASS | |
| `uncompressed.md` | Not empty | PASS | |
| `uncompressed.md` | Frontmatter (if required) | PASS | Valid YAML frontmatter present |
| `uncompressed.md` | No abs-path leaks | PASS | |
| `implementation.md` | Not empty | PASS | |
| `implementation.md` | Frontmatter (if required) | N/A | Not SKILL.md or agent.md |
| `implementation.md` | No abs-path leaks | PASS | |

### Issues

- **FAIL (Step 1 / Structure):** `messaging/SKILL.md` is absent. The primary compiled artifact is missing. The skill is incomplete and cannot be fully audited. Fix: run the `compression` skill against `messaging/uncompressed.md` to produce `messaging/SKILL.md`.
- **FAIL (Step 1 / A-FM-12):** `uncompressed.md` frontmatter cannot be verified against `SKILL.md` (absent). Resolves automatically once `SKILL.md` is generated.
- **FAIL (Step 3 / Coverage):** Spec requirement coverage in `SKILL.md` cannot be verified — `SKILL.md` absent. Resolves once `SKILL.md` is generated and re-audited.
- **LOW (Step 3 / Internal consistency):** `spec.md` Section Classification table has duplicate rows at end — Precedence Rules, Don'ts, and Section Classification each appear twice. Fix: remove the three duplicate rows.

### Recommendation

Generate `messaging/SKILL.md` via the `compression` skill, fix the duplicate rows in `spec.md`, then re-audit.
