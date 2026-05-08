---
file_paths:
  - messaging/SKILL.md
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
| Classification | PASS | Inline — protocol reference agents apply directly; no discrete computed output to dispatch. |
| Inline/dispatch consistency | PASS | No `instructions.txt`; SKILL.md contains full self-contained procedure. |
| Structure | PASS | Frontmatter present; direct instructions; self-contained. |
| Input/output double-spec (A-IS-1) | N/A | |
| Sub-skill input isolation (A-IS-2) | N/A | |
| Frontmatter | PASS | `name` and `description` present. |
| Name matches folder (A-FM-1) | PASS | `name: messaging` matches folder `messaging` in both SKILL.md and uncompressed.md. |
| Valid frontmatter fields (A-FM-4) | PASS | Only `name` and `description` in SKILL.md frontmatter. |
| Trigger phrases (A-FM-11) | PASS | `description` contains `Triggers -` block with multiple phrases. |
| Frontmatter mirror (A-FM-12) | PASS | uncompressed.md `name` and `description` match SKILL.md exactly (case-sensitive). |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no real H1; uncompressed.md has `# Messaging`. |
| No duplication | PASS | No overlapping capability found elsewhere. |
| Orphan files (A-FS-1) | PASS | `implementation.md` referenced by spec.md. Tool files are well-known role files. |
| Missing referenced files (A-FS-2) | PASS | `implementation.md` exists; all four tool trios present. |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | PASS | Compressed form faithfully represents all concepts, procedures, constraints, Don'ts, and Related breadcrumbs. No omitted requirements or changed behavior detected. |
| instructions.txt ↔ instructions.uncompressed.md | N/A | No `instructions.txt` present (inline skill). |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | `messaging/spec.md` present and co-located. |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present. |
| Normative language | PASS | Requirements use MUST, MUST NOT, SHALL consistently. |
| Internal consistency | FAIL | Definitions section defines "Message file" as "a single `.md` file" but R5/R8 specify `.json` filenames and JSON object format. Direct internal contradiction. |
| Spec completeness | PASS | All behavior explicitly stated; edge cases addressed. |
| Coverage | PASS | All normative requirements represented in SKILL.md. |
| No contradictions | PASS | SKILL.md uses `.json` consistent with R5/R8; does not contradict the normative requirements. |
| No unauthorized additions | PASS | |
| Conciseness | PASS | Agent-facing density; bullet/table structure; no rationale prose. |
| Completeness | PASS | All runtime instructions present; startup, posting, monitoring, draining, processing all covered. |
| Breadcrumbs | PASS | Related section present in both SKILL.md and uncompressed.md; canonical skill names used (`markdown-hygiene`, `skill-auditing`, `compression`). |
| Cost analysis | N/A | Inline skill. |
| No dispatch refs | N/A | Inline skill; no `instructions.txt`. |
| No spec breadcrumbs | PASS | Neither SKILL.md nor uncompressed.md references own `spec.md`. |
| Eval log (informational) | ABSENT | No `eval.txt` found. Does not affect verdict. |
| Description not restated (A-FM-2) | PASS | Body prose does not restate the description value. |
| No exposition in runtime (A-FM-5) | PASS | No rationale, root-cause narrative, or background prose in SKILL.md or uncompressed.md. |
| No non-helpful tags (A-FM-6) | PASS | No bare type labels or non-operational descriptors. |
| No empty sections (A-FM-7) | PASS | All headings have body content. |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety reference present. |
| Iteration-safety pointer form (A-FM-9a) | N/A | |
| No verbatim Rule A/B (A-FM-9b) | N/A | |
| Cross-reference anti-pattern (A-XR-1) | PASS | All cross-skill references in Related sections use canonical names; no path-only references. |
| Launch-script form (A-FM-10) | N/A | Inline skill. |
| Return shape declared (DS-1) | N/A | Inline skill. |
| Host card minimalism (DS-2) | N/A | Inline skill. |
| Description trigger phrases (DS-3) | N/A | Inline skill (dispatch-specific validation). |
| Inline dispatch guard (DS-4) | N/A | Inline skill. |
| No substrate duplication (DS-5) | N/A | Inline skill. |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Inline skill. |
| DS-7: Orphan tool | PASS | `drain`, `init`, `post`, `status` all referenced by SKILL.md and spec.md. |
| DS-7: Missing tool | PASS | All four complete trios present (each with `.sh`, `.ps1`, `.spec.md`). |
| DS-7: Tool-spec alignment | PASS | Tool-specs are consistent with spec.md normative requirements (R5, R8, R20). The erroneous `.md` wording is in spec.md Definitions only and does not govern tool behavior; normative requirements are authoritative. |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| `SKILL.md` | Not empty | PASS | |
| `SKILL.md` | Frontmatter | PASS | |
| `SKILL.md` | No abs-path leaks | PASS | |
| `uncompressed.md` | Not empty | PASS | |
| `uncompressed.md` | No abs-path leaks | PASS | |
| `spec.md` | Not empty | PASS | |
| `spec.md` | No abs-path leaks | PASS | |
| `implementation.md` | Not empty | PASS | |
| `implementation.md` | No abs-path leaks | PASS | |
| `drain.spec.md` | Not empty | PASS | |
| `drain.spec.md` | Purpose section | PASS | |
| `drain.spec.md` | Parameters section | PASS | |
| `drain.spec.md` | Output section | PASS | |
| `init.spec.md` | Not empty | PASS | |
| `init.spec.md` | Purpose section | PASS | |
| `init.spec.md` | Parameters section | PASS | |
| `init.spec.md` | Output section | PASS | |
| `post.spec.md` | Not empty | PASS | |
| `post.spec.md` | Purpose section | PASS | |
| `post.spec.md` | Parameters section | PASS | |
| `post.spec.md` | Output section | PASS | |
| `status.spec.md` | Not empty | PASS | |
| `status.spec.md` | Purpose section | PASS | |
| `status.spec.md` | Parameters section | PASS | |
| `status.spec.md` | Output section | PASS | |

### Issues

- **[Step 3 — Internal consistency — FAIL]** `spec.md` Definitions section defines "Message file" as "a single `.md` file placed in a recipient's inbox" but Requirements R5 specifies the filename pattern `<utc-timestamp>-<nonce>.json` and R8 requires the file to be "a valid JSON object." R20 (drain) also enumerates `*.json` files. The `.md` wording in Definitions appears to be a stale remnant from an earlier design. **Fix:** In `spec.md` Definitions, change "a single `.md` file placed in a recipient's inbox" to "a single `.json` file placed in a recipient's inbox." Normative requirements (R5, R8, R20) and all tool-specs are already correct.

- **[Step 3 — related — MEDIUM]** `implementation.md` Claim Mechanism section describes the rename as "rename `<name>.md` to `<name>.md.claimed`" — echoing the erroneous Definitions wording. The tool code blocks use variable substitution so runtime behavior is correct, but the descriptive text conflicts with `drain.spec.md` (which correctly says `.json.claimed`) and R5/R8. **Fix:** In `implementation.md` Claim Mechanism prose, change `<name>.md` to `<name>.json` and `<name>.md.claimed` to `<name>.json.claimed`.

### Recommendation

Fix the stale `.md`-vs-`.json` wording in `spec.md` Definitions and the matching prose in `implementation.md` Claim Mechanism — two targeted one-line edits; all other artifacts are correct.
