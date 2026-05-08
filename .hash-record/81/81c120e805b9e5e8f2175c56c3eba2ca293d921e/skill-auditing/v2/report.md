---
operation_kind: skill-auditing/v2
result: clean
file_paths:
  - messaging/SKILL.md
  - messaging/spec.md
  - messaging/uncompressed.md
---

# Result

CLEAN — no findings.

## Skill Summary

- **Skill:** `messaging`
- **Type:** Inline (no `instructions.txt`; no dispatch pattern; full procedure in `SKILL.md`)
- **Files audited:** `SKILL.md`, `spec.md`, `uncompressed.md`, `implementation.md` (referenced support doc), `drain.spec.md`, `init.spec.md`, `post.spec.md`, `status.spec.md`
- **Tool files (out of scope):** `drain.ps1`, `drain.sh`, `init.ps1`, `init.sh`, `post.ps1`, `post.sh`, `status.ps1`, `status.sh`

## Per-file Basic Checks

| File | Not Empty | Frontmatter | No Abs Paths | Notes |
|---|---|---|---|---|
| `messaging/SKILL.md` | PASS | PASS | PASS | Frontmatter required; present |
| `messaging/uncompressed.md` | PASS | PASS | PASS | Frontmatter required; present |
| `messaging/spec.md` | PASS | N/A | PASS | Not SKILL.md/agent.md; no frontmatter required |
| `messaging/implementation.md` | PASS | N/A | PASS | Not SKILL.md/agent.md; no frontmatter required |
| `messaging/drain.spec.md` | PASS | N/A | PASS | Purpose ✓, Parameters ✓, Output ✓ |
| `messaging/init.spec.md` | PASS | N/A | PASS | Purpose ✓, Parameters ✓, Output ✓ |
| `messaging/post.spec.md` | PASS | N/A | PASS | Purpose ✓, Parameters ✓, Output ✓ |
| `messaging/status.spec.md` | PASS | N/A | PASS | Purpose ✓, Parameters ✓, Output ✓ |

## Step 1 — Compiled Artifacts

**Classification:** Inline. No `instructions.txt` present; `SKILL.md` contains full procedure. Agents apply protocol directly without dispatching a sub-agent. Correct classification.

| Check | Result | Notes |
|---|---|---|
| A-FM-1 Name matches folder | PASS | `name: messaging` equals folder `messaging` in both `SKILL.md` and `uncompressed.md` |
| A-FM-4 Valid frontmatter fields | PASS | Both `SKILL.md` and `uncompressed.md` contain only `name` and `description` |
| A-FM-11 Trigger phrases | PASS | `description` contains `Triggers -` in both `SKILL.md` and `uncompressed.md` |
| A-FM-12 `uncompressed.md` frontmatter mirror | PASS | `name` and `description` match `SKILL.md` exactly (case-sensitive) |
| A-FM-3 H1 per artifact | PASS | `SKILL.md` has no real H1; `uncompressed.md` has `# Messaging` at line 1 after frontmatter |
| A-FM-2 Description not restated | PASS | Opening prose rephrases in different words; not verbatim duplication |
| A-FM-5 No exposition in runtime artifacts | PASS | No rationale or background prose in `SKILL.md` or `uncompressed.md` |
| A-FM-6 No non-helpful tags | PASS | No bare type labels found |
| A-FM-7 No empty leaves | PASS | All headings in `uncompressed.md` and `spec.md` have body content |
| A-FM-8 Iteration-safety placement | PASS | No iteration-safety blurb in any instruction file |
| A-FM-9a/9b Iteration-safety pointer form | N/A | No iteration-safety references present |
| A-FM-10 Launch-script form | N/A | Inline skill |
| A-XR-1 Cross-reference anti-pattern | PASS | Related section in `SKILL.md` and `uncompressed.md` references all targets by canonical name (`markdown-hygiene`, `skill-auditing`, `compression`) |
| A-FS-1 Orphan files | PASS | `implementation.md` referenced by name in `spec.md`; all others are well-known role files |
| A-FS-2 Missing referenced files | PASS | `implementation.md` referenced in `spec.md` exists; no other file-path pointers found |
| A-IS-1 Input/output double-specification | N/A | Inline skill; no sub-skill outputs |
| A-IS-2 Sub-skill input isolation | N/A | No sub-skills |

## Step 2 — Parity Check

| Pair | Result | Notes |
|---|---|---|
| `SKILL.md` ↔ `uncompressed.md` | PASS | `SKILL.md` is a faithful compressed form of `uncompressed.md`; all operational content covered: init, post, drain, monitoring (Options A and B), startup sequence, processing, ordering, constraints, don'ts, related |
| `instructions.txt` ↔ `instructions.uncompressed.md` | N/A | Neither file present |

## Step 3 — Spec Alignment

**Spec exists:** `messaging/spec.md` ✓

**Required sections:**

| Section | Present |
|---|---|
| Purpose | ✓ |
| Scope | ✓ |
| Definitions | ✓ |
| Requirements | ✓ |
| Constraints | ✓ |

Additional sections present and well-formed: Content Modes, Behavior, Defaults and Assumptions, Error Handling, Precedence Rules, Don'ts, Section Classification.

**Normative language:** All requirements use `MUST`, `MUST NOT`, `SHALL`. ✓

**Internal consistency:** No contradictions between sections. No duplicate rules. Normative and informational sections clearly delineated via Section Classification table. ✓

**Spec completeness:** All terms defined in Definitions. All behavior explicitly stated. ✓

**Coverage:** All agent-facing normative requirements represented in `SKILL.md`: startup sequence (R0, R18), posting (R11), monitoring options (R16, R17a/b), drain behavior (R19–R24), status (R_N1–R_N5), constraints (C1–C5), don'ts. Tool-internal implementation details (R4, R6, R7, R9, R12 mechanism) appropriately omitted from agent-facing card. ✓

**No contradictions:** `SKILL.md` is subordinate to and consistent with `spec.md`. ✓

**No unauthorized additions:** `SKILL.md` introduces no normative requirements absent from `spec.md`. ✓

**Conciseness:** `SKILL.md` reads as a dense reference card. Decision-tree-like structure. Agent can skim in one pass. ✓

**Breadcrumbs:** Related section references `markdown-hygiene`, `skill-auditing`, `compression` — all exist in workspace. No stale references. ✓

**Dispatch checks (DS-1..DS-6):** N/A — inline skill.

**Eval log presence:** No `eval.md` present. Informational only; does not affect verdict.
