---
file_paths:
  - skills/capability-cache/SKILL.md
  - skills/capability-cache/spec.md
  - skills/capability-cache/uncompressed.md
operation_kind: skill-auditing/v2
model: sonnet-class
result: findings
---

# Result

NEEDS_REVISION

## Skill Audit: capability-cache

**Verdict:** NEEDS_REVISION
**Type:** inline
**Path:** skills/capability-cache/

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Inline; no dispatch instruction file present |
| Inline/dispatch consistency | PASS | SKILL.md contains full procedure; no external dispatch file |
| Structure | PASS | Frontmatter, inputs/outputs table, procedure, rules, dependencies — self-contained |
| Input/output double-spec (A-IS-1) | N/A | No referenced sub-skills |
| Sub-skill input isolation (A-IS-2) | N/A | No sub-skills |
| Frontmatter | PASS | `name` and `description` both present |
| Name matches folder (A-FM-1) | PASS | `capability-cache` matches folder name; uncompressed.md name also matches |
| Valid frontmatter fields (A-FM-4) | PASS | SKILL.md frontmatter contains only `name` and `description` |
| Trigger phrases (A-FM-11) | PASS | "Triggers -" present in description with five comma-separated phrases |
| `uncompressed.md` frontmatter mirror (A-FM-12) | PASS | `name` and `description` match SKILL.md exactly (case-sensitive) |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no real H1; `uncompressed.md` has `# Capability Cache` |
| No duplication | PASS | No existing skill covers Copilot CLI model-availability caching |
| Orphan files (A-FS-1) | PASS | All three files are well-known role files; no unknown file present |
| Missing referenced files (A-FS-2) | PASS | No explicit sibling-file pointers found in any artifact |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | FAIL | **HIGH** — Intro line conflict: see Issues |
| instructions.txt ↔ instructions.uncompressed.md | N/A | No `instructions.txt` present |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | `spec.md` present co-located |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | All R1–R9 use must/must not throughout |
| Internal consistency | PASS | No contradictions within spec |
| Spec completeness | PASS | All terms defined; all behavior paths explicitly stated |
| Coverage | PASS | R1–R9 all represented in SKILL.md |
| No contradictions | FAIL | **HIGH** — SKILL.md intro contradicts spec Don'ts: see Issues |
| No unauthorized additions | PASS | All SKILL.md Rules traceable to R1–R9 |
| Conciseness | PASS | Reference-card density; no rationale prose in SKILL.md |
| Completeness | PASS | All runtime paths and edge cases addressed |
| Breadcrumbs | PASS | `copilot-cli` and `hash-record` referenced by canonical name |
| Cost analysis | N/A | Inline skill |
| No dispatch refs | N/A | No `instructions.txt` |
| No spec breadcrumbs | PASS | No reference to own `spec.md` anywhere in SKILL.md or uncompressed.md |
| Eval log (informational) | ABSENT | No `eval.txt` present |
| Description not restated (A-FM-2) | PASS | Body prose does not restate description value |
| No exposition in runtime (A-FM-5) | PASS | No rationale, historical notes, or background prose |
| No non-helpful tags (A-FM-6) | PASS | No bare type labels or descriptor lines without operational value |
| No empty sections (A-FM-7) | PASS | All leaf headings contain body content |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety content present |
| Iteration-safety pointer form (A-FM-9a) | N/A | |
| No verbatim Rule A/B (A-FM-9b) | N/A | |
| Cross-reference anti-pattern (A-XR-1) | PASS | All cross-refs (`copilot-cli`, `hash-record`) use canonical name |
| Launch-script form (A-FM-10) | N/A | Inline skill |
| Return shape declared (DS-1) | N/A | Inline skill |
| Host card minimalism (DS-2) | N/A | Inline skill |
| Description trigger phrases (DS-3) | N/A | Inline skill (covered by A-FM-11) |
| Inline dispatch guard (DS-4) | N/A | Inline skill |
| No substrate duplication (DS-5) | N/A | Inline skill |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Inline skill |
| Tool integration alignment (DS-7) | N/A | No tool trio present |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| `SKILL.md` | Not empty | PASS | |
| `SKILL.md` | Frontmatter required | PASS | YAML frontmatter at line 1 |
| `SKILL.md` | No abs-path leaks | PASS | Only template placeholders (`<cache_root>`, `<repo-root>`) |
| `uncompressed.md` | Not empty | PASS | |
| `uncompressed.md` | Frontmatter required | PASS | YAML frontmatter at line 1 |
| `uncompressed.md` | No abs-path leaks | PASS | Only template placeholders |
| `spec.md` | Not empty | PASS | |
| `spec.md` | No abs-path leaks | PASS | Only template placeholders |

### Issues

- **[HIGH — Step 2 Parity / Step 3 No Contradictions]** SKILL.md opening sentence states "This skill never invokes CLI commands itself." This claim is factually wrong — the WRITE path explicitly invokes `gh copilot models` — and directly contradicts (a) `uncompressed.md` which says "The WRITE path invokes `gh copilot models` when no valid cache exists," and (b) `spec.md` Don'ts section: "Must not claim 'this skill never invokes CLI commands' — the WRITE path explicitly invokes `gh copilot models`." Parity failure: SKILL.md intro contradicts uncompressed.md on CLI invocation behavior. Fix: edit `uncompressed.md` to confirm the correct statement is present (it already is), then recompress to `SKILL.md` — removing "This skill never invokes CLI commands itself." and replacing with the accurate "The WRITE path invokes `gh copilot models` when no valid cache exists." (or equivalent accurate phrasing).
