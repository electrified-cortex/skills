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
| Classification | PASS | Inline by file-system evidence — no `instructions.txt`, no `messaging.md`, no dispatch wiring present |
| Inline/dispatch consistency | FAIL | `SKILL.md` absent; compiled inline artifact missing; no compiled artifact to verify consistency against |
| Structure | FAIL | `SKILL.md` absent; inline skills require `SKILL.md` with frontmatter and full procedure body |
| Input/output double-spec (A-IS-1) | N/A | |
| Sub-skill input isolation (A-IS-2) | N/A | |
| Frontmatter | FAIL | `SKILL.md` absent; `name`/`description` frontmatter unverifiable in compiled artifact |
| Name matches folder (A-FM-1) | FAIL | `SKILL.md` absent; cannot verify `name` field matches folder name `messaging` |
| Valid frontmatter fields (A-FM-4) | FAIL | `SKILL.md` absent; cannot verify SKILL.md contains only `name` and `description` keys |
| Trigger phrases (A-FM-11) | HIGH | `uncompressed.md` frontmatter `description` uses "Use when" phrasing; required "Triggers -" token absent |
| uncompressed.md frontmatter mirror (A-FM-12) | FAIL | `SKILL.md` absent; cannot verify `uncompressed.md` frontmatter matches SKILL.md |
| H1 per artifact (A-FM-3) | FAIL | `SKILL.md` absent; H1-absence rule on SKILL.md unverifiable; `uncompressed.md` has real H1 as required |
| No duplication | PASS | No overlapping capability identified in workspace |
| Orphan files (A-FS-1) | PASS | `implementation.md` is explicitly referenced by `spec.md` at R12, R22, and C1 |
| Missing referenced files (A-FS-2) | HIGH | `spec.md` Purpose section names `post.ps1`, `post.sh`, `drain.ps1`, `drain.sh`, `status.ps1`, `status.sh` as sibling files; none exist in `messaging/` |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | N/A | `SKILL.md` absent; parity cannot be established |
| instructions.txt ↔ instructions.uncompressed.md | N/A | Neither file present |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | `spec.md` present co-located with `messaging/` |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Requirements use MUST/MUST NOT/SHALL throughout |
| Internal consistency | PASS | No contradictions between sections found |
| Spec completeness | PASS | All terms defined in Definitions; behavior explicitly stated in Requirements and Behavior sections |
| Coverage | PASS | `uncompressed.md` covers post, drain, status, inbox structure, signal file, monitoring, message format, constraints — all areas specified |
| No contradictions | PASS | `uncompressed.md` is consistent with `spec.md` throughout |
| No unauthorized additions | PASS | Option A / Option B monitoring framing is consistent with R17/R17a/R17b; no normative additions outside spec |
| Conciseness | HIGH | See A-FM-5 — rationale prose present in `uncompressed.md` |
| Completeness | PASS | All runtime instructions present; edge cases addressed |
| Breadcrumbs | N/A | No cross-skill references present in any artifact |
| Cost analysis | N/A | Inline skill |
| No dispatch refs | N/A | Inline skill |
| No spec breadcrumbs | PASS | `uncompressed.md` does not reference `spec.md` |
| Eval log (informational) | ABSENT | No `eval.txt` present |
| Description not restated (A-FM-2) | PASS | Body prose does not restate the frontmatter description verbatim |
| No exposition in runtime (A-FM-5) | HIGH | `uncompressed.md` "Option B" section contains rationale explaining WHY drain-to-quiescence is required ("A message may arrive while you are processing a previous batch. The signal will not fire again for that message.") — this is root-cause narrative; belongs in `spec.md` only |
| No non-helpful tags (A-FM-6) | PASS | No bare descriptor labels found |
| No empty sections (A-FM-7) | PASS | All sections have content |
| Iteration-safety placement (A-FM-8) | N/A | No `instructions.txt` or `instructions.uncompressed.md` present |
| Iteration-safety pointer form (A-FM-9a) | N/A | No iteration-safety references present |
| No verbatim Rule A/B (A-FM-9b) | N/A | No iteration-safety references present |
| Cross-reference anti-pattern (A-XR-1) | PASS | All references to `implementation.md` are own-folder references; no cross-skill path-only references found |
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
| `uncompressed.md` | Not empty | PASS | |
| `uncompressed.md` | Frontmatter (if required) | PASS | Has YAML frontmatter with `name` and `description` |
| `uncompressed.md` | No abs-path leaks | PASS | |
| `spec.md` | Not empty | PASS | |
| `spec.md` | Frontmatter (if required) | N/A | Not `SKILL.md` or `agent.md` |
| `spec.md` | No abs-path leaks | PASS | |
| `implementation.md` | Not empty | PASS | |
| `implementation.md` | Frontmatter (if required) | N/A | Not `SKILL.md` or `agent.md` |
| `implementation.md` | No abs-path leaks | PASS | |

### Issues

1. **[FAIL] `SKILL.md` absent** — The skill has no compiled artifact. Every skill requires a `SKILL.md` as the agent-facing entry point. `uncompressed.md` is the uncompressed source for compiling `SKILL.md`, not a substitute for it. Fix: compile `messaging/uncompressed.md` into `messaging/SKILL.md` using the `compression` skill. Checks A-FM-1, A-FM-3, A-FM-4, A-FM-12 are unresolvable until `SKILL.md` exists.

2. **[HIGH — A-FM-11] Description missing "Triggers -"** — `uncompressed.md` frontmatter `description` uses "Use when" phrasing; the required `Triggers -` canonical token is absent. Fix: replace "Use when" with "Triggers -" so the description follows the pattern: `<one-line action>. Triggers - <phrase1>, <phrase2>, ...`

3. **[HIGH — A-FS-2] Tool files referenced but absent** — `spec.md` Purpose section explicitly names `post.ps1`, `post.sh`, `drain.ps1`, `drain.sh`, `status.ps1`, `status.sh` as sibling files. None exist in `messaging/`. Fix: either implement the tool trios in `messaging/` (each stem requires `.ps1`, `.sh`, `.spec.md`) or replace explicit filename references in `spec.md` Purpose section with tool names only, deferring the file contract to a sub-skill.

4. **[HIGH — A-FM-5] Rationale prose in runtime artifact** — `uncompressed.md` "Option B" monitoring section contains root-cause narrative: "A message may arrive while you are processing a previous batch. The signal will not fire again for that message. Draining to empty ensures nothing is stranded." This explains why the rule exists, not what to do. Fix: delete these sentences from `uncompressed.md`; the rationale is already captured in `spec.md` R17b.

### Recommendation

Create `SKILL.md` via compression, fix trigger phrase format in description, resolve missing tool file references in `spec.md`, and strip rationale prose from `uncompressed.md`.
