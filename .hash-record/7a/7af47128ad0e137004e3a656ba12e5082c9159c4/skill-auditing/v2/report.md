---
file_paths:
  - hash-record/hash-record-rekey/SKILL.md
  - hash-record/hash-record-rekey/instructions.txt
  - hash-record/hash-record-rekey/instructions.uncompressed.md
  - hash-record/hash-record-rekey/spec.md
operation_kind: skill-auditing/v2
model: haiku-class
result: findings
---

# Result

NEEDS_REVISION

## Skill Audit: hash-record-rekey

**Verdict:** NEEDS_REVISION
**Type:** dispatch
**Path:** hash-record/hash-record-rekey

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | File-system evidence shows dispatch (instructions.txt present). Skill invokes shell tools directly. |
| Inline/dispatch consistency | PASS | SKILL.md contains minimal routing: invocation forms, argument table, output contract, Related section. |
| Structure | PASS | Dispatch structure correct: SKILL.md is routing card, instructions.txt is CLI spec. |
| Input/output double-spec (A-IS-1) | PASS | No duplication. Tool takes file_path, op_kind, record_filename; outputs status line. |
| Sub-skill input isolation (A-IS-2) | N/A | Tool is self-contained; does not dispatch sub-skills. |
| Frontmatter | PASS | SKILL.md has frontmatter with name and description. |
| Name matches folder (A-FM-1) | PASS | Folder name matches name field exactly. |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no H1. instructions.txt has no H1. instructions.uncompressed.md has H1. |
| No duplication | PASS | No existing capability duplication. |
| Orphan files (A-FS-1) | PASS | Tool files referenced in SKILL.md and instructions. No orphan files. |
| Missing referenced files (A-FS-2) | PASS | All referenced files exist. |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | N/A | No uncompressed.md for SKILL.md (optional). SKILL.md-only dispatch valid. |
| instructions.txt ↔ instructions.uncompressed.md | PASS | Both contain same operational content: use-case, invocation, output handling, constraints, examples. |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md exists co-located with skill directory. |
| Required sections | FAIL | Spec MUST contain: Purpose, Scope, Definitions, Requirements, Constraints. Missing: Scope (has "Use case"), Definitions (inline only), Requirements (absent). |
| Normative language | PASS | Uses enforceable language: MUST, MUST NOT, required. |
| Internal consistency | PASS | No contradictions. Rules consistent. |
| Spec completeness | FAIL | Definitions not in standalone section. Requirements section absent. |
| Coverage | PASS | Major operational requirements represented in artifacts. |
| No contradictions | PASS | SKILL.md reflects spec faithfully. |
| No unauthorized additions | PASS | SKILL.md adds no unauthorized normative requirements. |
| Conciseness | PASS | SKILL.md is concise routing card. |
| Completeness | PASS | All runtime instructions present. Edge cases addressed. |
| Breadcrumbs | PASS | Related section references valid skills by name. |
| Cost analysis | PASS | Tool-based dispatch. Self-contained in shell scripts. |
| No dispatch refs | N/A | Tool dispatch, not MCP dispatch. |
| No spec breadcrumbs | PASS | No spec.md references in runtime artifacts. |
| Eval log (informational) | ABSENT | No eval.txt present. |
| Description not restated (A-FM-2) | PASS | Description not duplicated in body. |
| No exposition in runtime (A-FM-5) | PASS | SKILL.md minimal. Instructions contain procedural steps appropriate to runtime. |
| No non-helpful tags (A-FM-6) | PASS | All content is actionable. |
| No empty sections (A-FM-7) | PASS | All sections have body content. |
| Iteration-safety placement (A-FM-8) | PASS | No iteration-safety language in instructions. |
| Iteration-safety pointer form (A-FM-9a) | N/A | No iteration-safety references. |
| No verbatim Rule A/B (A-FM-9b) | N/A | No iteration-safety content. |
| Cross-reference anti-pattern (A-XR-1) | PASS | No cross-references to other skill's spec.md or uncompressed.md. |
| Launch-script form (A-FM-10) | N/A | SKILL.md-only dispatch valid. |
| Return shape declared (DS-1) | PASS | Output contract explicitly declared with exit codes. |
| Host card minimalism (DS-2) | PASS | SKILL.md contains only routing: invocation, arguments, output, Related. |
| Description trigger phrases (DS-3) | PASS | Description has 6 trigger phrases (within 3-6 range). |
| Inline dispatch guard (DS-4) | N/A | Shell tool dispatch, not prompt-based. |
| No substrate duplication (DS-5) | PASS | Operational details in spec are necessary, not unnecessary duplication. |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Tool does not dispatch sub-skills. |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| SKILL.md | Not empty | PASS | Contains frontmatter and tables. |
| SKILL.md | Frontmatter (required) | PASS | YAML frontmatter present. |
| SKILL.md | No abs-path leaks | PASS | No absolute path leaks. |
| instructions.txt | Not empty | PASS | Contains procedures and examples. |
| instructions.txt | Frontmatter | N/A | Text file; frontmatter not required. |
| instructions.txt | No abs-path leaks | PASS | Uses placeholders, no hardcoded paths. |
| instructions.uncompressed.md | Not empty | PASS | Structured with multiple sections. |
| instructions.uncompressed.md | Frontmatter | N/A | Dispatch instructions; frontmatter not required. |
| instructions.uncompressed.md | No abs-path leaks | PASS | No absolute path leaks. |
| spec.md | Not empty | PASS | Comprehensive specification. |
| spec.md | Frontmatter | N/A | Spec files do not require frontmatter. |
| spec.md | No abs-path leaks | PASS | No absolute path leaks. |

### Issues

**FAIL: Missing required spec sections**

Issue: Spec structure incomplete. Auditing instructions require Purpose, Scope, Definitions, Requirements, Constraints.

Current state:
- Purpose: Present (line 3)
- Scope: Absent (file has "Use case" instead, which is a different concept)
- Definitions: Absent (terms scattered inline, no standalone section)
- Requirements: Absent (operational details in Procedure, but no formal Requirements section)
- Constraints: Present (line 95)

Fix: Restructure spec.md:
1. Keep Purpose and Constraints as-is.
2. Add Scope section: Define the domain of applicability (when rekey is appropriate vs not).
3. Add Definitions section: Bullet list of key terms (content hash, operation kind, shard, record, git mv, stale entry).
4. Add Requirements section: Formalize what spec mandates (argument validation rules, output format, exit codes, git-state checks, idempotency requirement).
5. Relocate "Use case" into Scope or background context.

This brings spec into compliance with audit standards.

### Recommendation

Restructure spec.md to include Purpose, Scope, Definitions, Requirements, Constraints sections. Resubmit for audit.
