---
file_paths:
  - spec-auditing/SKILL.md
  - spec-auditing/instructions.txt
  - spec-auditing/instructions.uncompressed.md
  - spec-auditing/spec.md
  - spec-auditing/uncompressed.md
operation_kind: skill-auditing/v2
model: sonnet-class
result: findings
---

# Result

NEEDS_REVISION

## Skill Audit: spec-auditing

**Verdict:** NEEDS_REVISION
**Type:** dispatch
**Path:** `spec-auditing/`

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Full audit procedure in `instructions.txt`; dispatched agent can execute from inputs alone — dispatch classification correct |
| Inline/dispatch consistency | PASS | `instructions.txt` present; `SKILL.md` delegates via `Follow dispatch skill. See ../dispatch/SKILL.md` |
| Structure | PASS | SKILL.md is a minimal routing card; no stop gates, no eligibility guards, no path-escape rules present |
| Input/output double-spec (A-IS-1) | PASS | No input parameter overrides a sub-skill-computed output path |
| Sub-skill input isolation (A-IS-2) | N/A | No sub-skills dispatched |
| Frontmatter | PASS | `name: spec-auditing`, `description` present in both `SKILL.md` and `uncompressed.md` |
| Name matches folder (A-FM-1) | PASS | `name: spec-auditing` matches folder name `spec-auditing/` in both `SKILL.md` and `uncompressed.md` |
| H1 per artifact (A-FM-3) | PASS | `SKILL.md` has no H1; `uncompressed.md` has `# Spec Auditing`; `instructions.uncompressed.md` has `# Spec Auditing Instructions`; `instructions.txt` has no H1 (the `# Result` on line 137 is inside a fenced code block — not a document heading) |
| No duplication | PASS | No existing skill in the worktree duplicates spec-auditing capability |
| Orphan files (A-FS-1) | PASS | All files are well-known role files; `.optimization/` is dot-prefixed and skipped per procedure; `optimize-log.md` is exempt |
| Missing referenced files (A-FS-2) | PASS | `instructions.txt`, `../dispatch/SKILL.md`, `../iteration-safety/SKILL.md` all exist |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| `SKILL.md` ↔ `uncompressed.md` | PASS | Functionally equivalent; `uncompressed.md` adds `Variables:` label, H1, and expanded parameter bullet list — no behavioral divergence |
| `instructions.txt` ↔ `instructions.uncompressed.md` | FAIL | Parity failure: gate numbering broken in `instructions.uncompressed.md`. After the `**Gate HC: hash-record cache check**` bold block interrupts the ordered list, the markdown list resets; gates 3–8 are all labeled `1.` (lines 57, 66, 67, 68, 69, 70). Compiled `instructions.txt` correctly uses sequential numbering 3–8, and gate 8 (`instructions.txt` line 46) cross-references "gate 4" and "gate 7" by number. In `instructions.uncompressed.md` these are all numbered `1.`, making the cross-references unresolvable and the source unsafe for editing. Fix: edit `instructions.uncompressed.md` to restore sequential numbering `3.` through `8.` for the gates following the Gate HC block, then recompress to `instructions.txt`. |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | `spec-auditing/spec.md` co-located with skill dir |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Requirements section uses `must`, `must not`, `MUST` throughout; all gating rules enforceable |
| Internal consistency | PASS | No contradictions within spec.md; all sections consistent |
| Spec completeness | PASS | All terms defined in Definitions; procedures complete in Behavior section; error handling table exhaustive |
| Coverage | PASS | All normative spec requirements represented in `instructions.txt`: pair-audit/spec-only modes, gate sequence, hash-record cache (Gate HC + STEP RW), fix mode, audit kind auto-detection, all 13 audit dimensions, severity levels, pass/fail rules, evidence standard, output section ordering |
| No contradictions | PASS | `instructions.txt` and `SKILL.md` do not contradict spec on any gating, precedence, or behavioral rule |
| No unauthorized additions | PASS | All content in `instructions.txt` traceable to spec; the `d. Ambiguous → STOP` audit-kind gate (unreachable given binary auto-detection) is Derived but Unstated — no operational effect |
| Conciseness | PASS | `SKILL.md` is a clean routing card; `instructions.txt` is dense operational reference with no rationale prose or redundant explanations |
| Completeness | PASS | All runtime instructions present; edge cases covered: git hash failure, untracked files, approve request, fix-in-spec-only |
| Breadcrumbs | PASS | `../dispatch/SKILL.md` and `../iteration-safety/SKILL.md` both resolve in the worktree |
| Cost analysis | PASS | Uses dispatch agent (zero-context isolation); `instructions.txt` is 161 lines — under 500-line limit; no sub-skills inlined |
| No dispatch refs | PASS | `instructions.txt` does not instruct the dispatched agent to invoke other skills; `dispatch skill` mention on line 98 is audit subject-matter context, not an invocation |
| No spec breadcrumbs | PASS | `SKILL.md` and `instructions.txt` do not reference this skill's own `spec.md`; `spec.md` and `*.spec.md` in `instructions.txt` are audit-target file-type references — covered by the spec-auditing exception |
| Eval log (informational) | ABSENT | No `eval.txt` found; does not affect verdict |
| Description not restated (A-FM-2) | PASS | Description appears only in frontmatter; not restated in body of any artifact |
| No exposition in runtime (A-FM-5) | PASS | No rationale, historical notes, or background prose found in any runtime artifact |
| No non-helpful tags (A-FM-6) | PASS | No bare type labels or non-operational descriptor lines found |
| No empty sections (A-FM-7) | PASS | All headings in all artifacts have body content before next heading or EOF |
| Iteration-safety placement (A-FM-8) | PASS | Iteration-safety absent from `instructions.txt` and `instructions.uncompressed.md`; pointer only in `SKILL.md` and `uncompressed.md` |
| Iteration-safety pointer form (A-FM-9a) | PASS | Exact 2-line pointer block in both `SKILL.md` and `uncompressed.md`: `Do not re-audit unchanged files.` + `` See `../iteration-safety/SKILL.md`. ``; relative path correct for folder depth |
| No verbatim Rule A/B (A-FM-9b) | PASS | No verbatim restatement of iteration-safety Rules A or B beyond the sanctioned 2-line pointer block |
| Cross-reference anti-pattern (A-XR-1) | PASS | No pointers to another skill's `uncompressed.md` or `spec.md` in any runtime artifact; `spec.md`/`*.spec.md` references in `instructions.txt` are audit-target subject-matter (permitted exception for spec-auditing) |
| Launch-script form (A-FM-10) | PASS | `uncompressed.md` contains only: frontmatter, H1, Dispatch section (dispatch variable block + parameter list + Returns line), and Iteration Safety pointer — all permitted; no executor steps, mode tables, rationale, or related sections |
| Return shape declared (DS-1) | PASS | Returns line in `uncompressed.md` explicitly declares all token variants: `PATH:` on cache hit; `Pass:` / `Pass with Findings:` / `Fail:` on verdict; `ERROR:` on failure |
| Host card minimalism (DS-2) | PASS | `SKILL.md` and `uncompressed.md` contain no internal cache descriptions, adaptive/conditional rules invisible to host, tool-fallback hints, or subjective qualifiers; "on cache hit" in Returns line is host-visible return contract — not an internal implementation detail |
| Description trigger phrases (DS-3) | PASS | Description follows `<one-line action>. Triggers — <phrases>` pattern with 5 trigger phrases (spec validation, requirements coverage, contradiction detection, document alignment, specification quality) — within 3–6 range; no impl notes |
| Inline dispatch guard (DS-4) | PASS | `<instructions>` binding includes `NEVER READ` on same line in both `SKILL.md` and `uncompressed.md`; `<prompt>` uses `Read and follow <instructions-abspath>` form; `Follow dispatch skill. See ../dispatch/SKILL.md` delegation line present |
| No substrate duplication (DS-5) | PASS | No hash-record path schema, frontmatter shape, or shard layout inlined in host card; hash-record procedure in `instructions.txt` is executor-level (appropriate location) |
| No overbuilt sub-skill dispatch (DS-6) | N/A | No sub-skills dispatched |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| `SKILL.md` | Not empty | PASS | |
| `SKILL.md` | Frontmatter (if required) | PASS | YAML frontmatter with `name` and `description` at line 1 |
| `SKILL.md` | No abs-path leaks | PASS | |
| `uncompressed.md` | Not empty | PASS | |
| `uncompressed.md` | Frontmatter (if required) | N/A | Not `SKILL.md` or `agent.md` |
| `uncompressed.md` | No abs-path leaks | PASS | |
| `instructions.txt` | Not empty | PASS | |
| `instructions.txt` | Frontmatter (if required) | N/A | Not `SKILL.md` or `agent.md` |
| `instructions.txt` | No abs-path leaks | PASS | |
| `instructions.uncompressed.md` | Not empty | PASS | |
| `instructions.uncompressed.md` | Frontmatter (if required) | N/A | Not `SKILL.md` or `agent.md` |
| `instructions.uncompressed.md` | No abs-path leaks | PASS | |
| `spec.md` | Not empty | PASS | |
| `spec.md` | Frontmatter (if required) | N/A | Spec is a governance document; frontmatter not required |
| `spec.md` | No abs-path leaks | PASS | |

### Issues

- **[Step 2 / Parity — HIGH]** Gate numbering broken in `instructions.uncompressed.md`: after the `**Gate HC: hash-record cache check**` bold block (line 26) interrupts the outer ordered list, markdown list numbering resets. Gates 3–8 are all labeled `1.` on lines 57, 66, 67, 68, 69, and 70 of `instructions.uncompressed.md`. The compiled `instructions.txt` has correct sequential numbering 3–8, and gate 8 cross-references "gate 4" and "gate 7" by number — these back-references are unresolvable in the uncompressed source. The uncompressed file is no longer a safe edit base. Fix: edit `instructions.uncompressed.md` to use explicit sequential numbers `3.`, `4.`, `5.`, `6.`, `7.`, `8.` for the gates following the Gate HC block, then recompress to `instructions.txt`.

### Recommendation

Fix broken gate numbering in `instructions.uncompressed.md` (gates 3–8 all labeled `1.` due to markdown list reset after the bold Gate HC block) to restore it as a safe and accurate edit source.
