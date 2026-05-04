---
file_paths:
  - hash-record/hash-record-rekey/SKILL.md
  - hash-record/hash-record-rekey/instructions.txt
  - hash-record/hash-record-rekey/instructions.uncompressed.md
  - hash-record/hash-record-rekey/spec.md
operation_kind: skill-auditing/v2
model: sonnet-class
result: findings
---

# Result

FAIL

## Skill Audit: hash-record-rekey

**Verdict:** FAIL
**Type:** inline (no dispatch invocation in SKILL.md; instructions.txt present without dispatch wiring — conflict flagged)
**Path:** hash-record/hash-record-rekey/

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | FAIL | SKILL.md states "no agent dispatch" (inline). `instructions.txt` present triggers dispatch classification by file-system evidence. Conflict — see A-FS-1. |
| Inline/dispatch consistency | FAIL | No dispatch invocation in SKILL.md (`NEVER READ`, `Follow dispatch skill`, `<instructions>` binding absent). `instructions.txt` without dispatch wiring → HIGH (A-FS-1). |
| Structure | PASS | SKILL.md is a concise routing/reference card; scripts explicitly listed; input signature and output table present. |
| Input/output double-spec (A-IS-1) | PASS | No duplicate output path specification detected. |
| Sub-skill input isolation (A-IS-2) | N/A | No sub-skills. |
| Frontmatter | PASS | `name` and `description` present and accurate. |
| Name matches folder (A-FM-1) | PASS | `name: hash-record-rekey` matches folder `hash-record-rekey`. |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no H1. `instructions.txt` has no H1. `instructions.uncompressed.md` has H1. |
| No duplication | PASS | No duplicate capability identified. |
| Orphan files (A-FS-1) | FAIL | `instructions.txt` is present but SKILL.md contains no dispatch invocation (no `NEVER READ` guard, no `Follow dispatch skill`, no `<instructions>` binding). Per A-FS-1 special case: instructions file with no dispatch wiring is a HIGH orphan. |
| Missing referenced files (A-FS-2) | PASS | `instructions.txt`, `rekey.sh`, `rekey.ps1`, `spec.md` all exist in skill dir. |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | N/A | No `uncompressed.md` present. |
| instructions.txt ↔ instructions.uncompressed.md | PASS | Both cover the same 5 output keywords and the Phase 4A workflow. Compressed form omits detail but no contradictions found. `source_hash` optional argument is absent from both (not a parity gap between the pair, but an unauthorized addition in SKILL.md — see Step 3). |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | `spec.md` present inside skill dir. |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present. |
| Normative language | PASS | Requirements use must/shall throughout. |
| Internal consistency | PASS | No contradictions detected between sections. |
| Spec completeness | PASS | Terms defined; behavior stated explicitly. |
| Coverage | FAIL | Spec §203 defines a large Folder/manifest mode (folder-path positional, --include/--exclude/--dry-run/--manifests flags, MANIFEST_UPDATED output, SUMMARY line, folder-mode procedure, idempotency requirement, order constraint). None of this is represented in SKILL.md, instructions.txt, or instructions.uncompressed.md. Missing required coverage of normative spec requirements. |
| No contradictions | PASS | SKILL.md does not contradict spec for the per-file mode it does cover. |
| No unauthorized additions | FAIL | SKILL.md documents an optional 4th positional argument `[source_hash]` on line 9 and describes it ("known old content hash to rekey from. When provided, bypasses full-tree search. Prevents AMBIGUOUS when multiple records exist."). This parameter is absent from spec.md §Parameters and §Requirements. SKILL.md introduces a normative parameter the spec does not define. |
| Conciseness | PASS | SKILL.md is 42 lines; dense reference format; no prose conditionals. |
| Completeness | FAIL | Folder-mode runtime instructions entirely absent from all compiled artifacts. Per-file mode instructions do not mention `source_hash` optional argument despite it appearing in SKILL.md. |
| Breadcrumbs | PASS | `hash-record`, `hash-record-check`, `hash-record-prune` all exist. References valid. |
| Cost analysis | N/A | Inline skill; no agent dispatch. |
| No dispatch refs | N/A | Inline skill; instructions.txt does not tell agent to dispatch other skills. |
| No spec breadcrumbs | FAIL | SKILL.md line 39: `Full CLI contract: \`spec.md\`.` — references skill's own companion spec.md at runtime. This is a spec breadcrumb in a runtime artifact. |
| Eval log (informational) | ABSENT | No `eval.txt` or `eval.md` found. |
| Description not restated (A-FM-2) | PASS | Description text not restated verbatim in body of any artifact. |
| No exposition in runtime (A-FM-5) | PASS | No rationale, root-cause narrative, or background prose found in SKILL.md, instructions.txt, or instructions.uncompressed.md. |
| No non-helpful tags (A-FM-6) | PASS | No bare type labels or non-operational descriptor lines found. |
| No empty sections (A-FM-7) | PASS | All headings in instructions.uncompressed.md have body content. |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety blurb present in any artifact. |
| Iteration-safety pointer form (A-FM-9a) | N/A | No iteration-safety pointer present. |
| No verbatim Rule A/B (A-FM-9b) | N/A | No iteration-safety rules referenced. |
| Cross-reference anti-pattern (A-XR-1) | PASS | No pointers to other skills' `uncompressed.md` or `spec.md` files found. |
| Launch-script form (A-FM-10) | N/A | No `uncompressed.md` present; inline skill. |
| Return shape declared (DS-1) | N/A | Inline skill. |
| Host card minimalism (DS-2) | N/A | Inline skill. |
| Description trigger phrases (DS-3) | N/A | Inline skill. |
| Inline dispatch guard (DS-4) | N/A | Inline skill. |
| No substrate duplication (DS-5) | N/A | Inline skill. |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Inline skill. |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| `SKILL.md` | Not empty | PASS | |
| `SKILL.md` | Frontmatter | PASS | |
| `SKILL.md` | No abs-path leaks | PASS | |
| `instructions.txt` | Not empty | PASS | |
| `instructions.txt` | Frontmatter | N/A | Not SKILL.md or agent.md |
| `instructions.txt` | No abs-path leaks | FAIL | Lines 78–79 contain a Windows drive-letter path in the PowerShell example invocation. Scrub or replace with a repo-relative placeholder. |
| `instructions.uncompressed.md` | Not empty | PASS | |
| `instructions.uncompressed.md` | Frontmatter | N/A | Not SKILL.md or agent.md |
| `instructions.uncompressed.md` | No abs-path leaks | FAIL | Lines 97–98 contain a Windows drive-letter path in the PowerShell example invocation. Scrub or replace with a repo-relative placeholder. |
| `spec.md` | Not empty | PASS | |
| `spec.md` | Frontmatter | N/A | Not SKILL.md or agent.md |
| `spec.md` | No abs-path leaks | PASS | |

### Issues

- **[HIGH — A-FS-1]** `instructions.txt` is present but SKILL.md contains no dispatch invocation (no `NEVER READ` guard, no `Follow dispatch skill` delegation, no `<instructions>` binding). This triggers the A-FS-1 special case for instructions files without dispatch wiring. Fix: either (a) convert to a proper dispatch skill by adding canonical dispatch invocation to SKILL.md and verifying the instructions.txt executor procedure, or (b) rename `instructions.txt` to a non-dispatch name (e.g., `usage-guide.md`) and reference it explicitly in SKILL.md as a documentation file.
- **[HIGH — Step 3 Coverage]** Spec §203–426 defines a Folder/manifest mode with distinct invocation signature (single `folder_path` argument), additional flags (`--include`, `--exclude`, `--dry-run`, `--manifests`), new output tokens (`MANIFEST_UPDATED`, `SUMMARY:`), a 5-step procedure, idempotency requirement, and an order constraint. None of this is represented in SKILL.md, instructions.txt, or instructions.uncompressed.md. Fix: add folder-mode invocation, flags, and output contract to SKILL.md; add folder-mode procedure to instructions.txt and instructions.uncompressed.md.
- **[HIGH — Step 3 Unauthorized Addition]** SKILL.md line 9 documents optional positional argument `[source_hash]` with a description, but this parameter is absent from spec.md §Parameters and §Requirements. Fix: either add `source_hash` to spec.md as a documented optional parameter, or remove it from SKILL.md until the spec is updated.
- **[HIGH — Step 3 No spec breadcrumbs]** SKILL.md line 39: `` Full CLI contract: `spec.md`. `` references the skill's own companion spec.md in a runtime artifact. Fix: delete this reference. If the CLI contract detail is genuinely needed at runtime, inline the relevant table.
- **[HIGH — Per-file]** `instructions.txt` lines 78–79: Windows drive-letter path in PowerShell example block. Fix: replace with a placeholder such as `pwsh rekey.ps1 /path/to/skills/foo/SKILL.md skill-auditing/v2 claude-haiku.md` or use a repo-relative example.
- **[HIGH — Per-file]** `instructions.uncompressed.md` lines 97–98: Windows drive-letter path in PowerShell example block. Fix: same as above — replace with a platform-neutral placeholder.

### Recommendation

Fix six HIGH findings: resolve the dispatch-wiring conflict for `instructions.txt`, add folder-mode coverage to all compiled artifacts, move `source_hash` to spec.md or remove from SKILL.md, delete the `spec.md` runtime breadcrumb, and replace Windows drive-letter example paths in both instructions files.
