---
file_paths:
  - hash-record/hash-record-rekey/SKILL.md
  - hash-record/hash-record-rekey/spec.md
  - hash-record/hash-record-rekey/usage-guide.md
  - hash-record/hash-record-rekey/usage-guide.uncompressed.md
operation_kind: skill-auditing/v2
model: sonnet-class
result: findings
---

# Result

FAIL

## Skill Audit: hash-record-rekey

**Verdict:** FAIL
**Type:** inline (shell-script invocation card; no agent dispatch)
**Path:** hash-record/hash-record-rekey

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Shell-script tool; self-contained with no context beyond inputs. Declared "no agent dispatch" — inline classification confirmed. |
| Inline/dispatch consistency | PASS | No `instructions.txt`, no dispatch wiring. File-system evidence matches inline. |
| Structure | PASS | SKILL.md is a concise invocation card: frontmatter, invocation modes, argument tables, output table, script locations, related. |
| Input/output double-spec (A-IS-1) | N/A | No sub-skill references. |
| Sub-skill input isolation (A-IS-2) | N/A | No sub-skills. |
| Frontmatter | PASS | `name` and `description` present; description accurate. |
| Name matches folder (A-FM-1) | PASS | `name: hash-record-rekey` matches folder `hash-record-rekey`. |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no H1. `uncompressed.md` is absent (N/A). `usage-guide.uncompressed.md` has H1. |
| No duplication | PASS | No overlap with sibling skills (`hash-record-check`, `hash-record-prune`). |
| Orphan files (A-FS-1) | PASS | `usage-guide.md` referenced by SKILL.md line 55. `usage-guide.uncompressed.md` is well-known role file (`*.uncompressed.md`). No orphans. |
| Missing referenced files (A-FS-2) | PASS | `rekey.sh` and `rekey.ps1` referenced in SKILL.md and both present. `usage-guide.md` referenced and present. |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | N/A | `uncompressed.md` absent. |
| instructions.txt ↔ instructions.uncompressed.md | N/A | Neither present. |

Advisory: `usage-guide.md` (compiled) omits `MANIFEST_UPDATED` from the folder-mode example output shown in `usage-guide.uncompressed.md` (line 141). While outside the defined parity pairs, this gap is consistent with the coverage failure identified in Step 3.

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | `spec.md` co-located in `hash-record-rekey/`. |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present. |
| Normative language | PASS | Requirements use `must`, `MUST NOT`, `required`. |
| Internal consistency | PASS | No contradictions or duplicate rules found between sections. |
| Spec completeness | PASS | All terms defined; behavior explicitly stated. |
| Coverage | FAIL | SKILL.md omits folder-mode output contract. Spec normatively defines `MANIFEST_UPDATED` (folder-mode per-record token), `SUMMARY` (folder-mode aggregate line), and exit code 2 (invocation error). SKILL.md output table covers per-file mode only ("stdout, one line") and does not enumerate folder-mode tokens or the distinct exit code 2. |
| No contradictions | PASS | SKILL.md does not contradict spec. Flags and defaults align. |
| No unauthorized additions | PASS | No normative additions beyond spec. |
| Conciseness | PASS | SKILL.md reads as a reference card; decision tables and bullets throughout. No rationale prose. |
| Completeness | PASS | All runtime instructions present for per-file invocation. |
| Breadcrumbs | PASS | Related: `hash-record`, `hash-record-check`, `hash-record-prune` — all exist as sibling directories. |
| Cost analysis | N/A | Inline skill. |
| No dispatch refs | N/A | Inline skill. |
| No spec breadcrumbs | PASS | No reference to `spec.md` in SKILL.md or `usage-guide.md`. |
| Eval log (informational) | ABSENT | No `eval.txt` present. |
| Description not restated (A-FM-2) | PASS | Description only in frontmatter; not restated in body. |
| No exposition in runtime (A-FM-5) | PASS | SKILL.md and `usage-guide.md` are free of rationale or background prose. |
| No non-helpful tags (A-FM-6) | PASS | "Invoke directly via Bash or PowerShell — no agent dispatch." is operationally meaningful (clarifies invocation method). |
| No empty sections (A-FM-7) | PASS | No headings without body content in any artifact. |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety content present. |
| Iteration-safety pointer form (A-FM-9a) | N/A | No iteration-safety pointer. |
| No verbatim Rule A/B (A-FM-9b) | N/A | No iteration-safety content. |
| Cross-reference anti-pattern (A-XR-1) | PASS | No pointers to another skill's `uncompressed.md` or `spec.md` in any artifact. |
| Launch-script form (A-FM-10) | N/A | Inline skill; `uncompressed.md` absent. |
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
| `SKILL.md` | Frontmatter | PASS | YAML block present at line 1. |
| `SKILL.md` | No abs-path leaks | PASS | |
| `spec.md` | Not empty | PASS | |
| `spec.md` | Frontmatter | N/A | Not SKILL.md or agent.md. |
| `spec.md` | No abs-path leaks | PASS | |
| `usage-guide.md` | Not empty | PASS | |
| `usage-guide.md` | Frontmatter | N/A | Not SKILL.md or agent.md. |
| `usage-guide.md` | No abs-path leaks | PASS | |
| `usage-guide.uncompressed.md` | Not empty | PASS | |
| `usage-guide.uncompressed.md` | Frontmatter | N/A | Not SKILL.md or agent.md. |
| `usage-guide.uncompressed.md` | No abs-path leaks | PASS | |

### Issues

- **Coverage (FAIL)**: SKILL.md output table is scoped to per-file mode only (`one line` annotation). Spec defines a distinct folder-mode output contract with three additional tokens and a different exit-code set: `MANIFEST_UPDATED: <manifest-path>:<entry-id>` (folder-mode per-manifest-entry line), `SUMMARY: rekeyed=<n> current=<n> manifest_updated=<n> not_found=<n> errors=<n>` (folder-mode aggregate), and exit code 2 (invocation error). None of these appear in SKILL.md. Fix: add a "**Output** (folder mode)" section to SKILL.md documenting the `MANIFEST_UPDATED` and `SUMMARY` tokens and the exit code 2 case.

### Recommendation

Add a folder-mode output contract table to SKILL.md covering `MANIFEST_UPDATED`, `SUMMARY`, and exit code 2 to match the normative requirements in `spec.md`.
