---
operation_kind: skill-auditing/v2
result: findings
file_paths:
  - skills/dispatch/SKILL.md
  - skills/dispatch/spec.md
---

# Result

**NEEDS_REVISION** — two unauthorized normative additions in `SKILL.md` absent from spec; three orphan files; advisory on uncompressed source.

---

## Per-file Basic Checks

Checked all `.md` files in `skills/dispatch/` recursively (dot-prefixed dirs skipped).

| File | Empty | Frontmatter | Abs-path leak |
| --- | --- | --- | --- |
| `skills/dispatch/SKILL.md` | PASS | PASS | PASS |
| `skills/dispatch/spec.md` | PASS | N/A | PASS |
| `skills/dispatch/supplemental.md` | PASS | N/A | PASS |
| `skills/dispatch/dispatch-pattern.md` | PASS | N/A | PASS |
| `skills/dispatch/installation.md` | PASS | N/A | PASS |
| `skills/dispatch/skill.index.md` | PASS | N/A | PASS |
| `skills/dispatch/agents/README.md` | PASS | N/A | PASS |
| `skills/dispatch/dispatch-setup/SKILL.md` | PASS | PASS | PASS |
| `skills/dispatch/dispatch-setup/spec.md` | PASS | N/A | PASS |
| `skills/dispatch/dispatch-setup/uncompressed.md` | PASS | PASS | PASS |

No per-file findings.

---

## Step 1 — Compiled Artifacts

### Classification

Skill type: **INLINE**. No `instructions.txt`, no `dispatch.md`, no operative instruction file referenced by `SKILL.md`. The "See also" section references supplemental and rationale files, not an instruction file. `SKILL.md` contains the full procedure inline. File-system evidence and content are consistent.

### (A-FM-1) Name matches folder

`name: dispatch` matches folder `dispatch/`. PASS.

### (A-FM-4) Valid frontmatter fields

`SKILL.md` frontmatter contains only `name` and `description`. PASS.

### (A-FM-11) Trigger phrases

`description` value:
> `How to dispatch a sub-agent. Triggers - run in background, spawn subagent, background task, isolated agent execution, dispatch subagent, background agent.`

Contains `Triggers -`. PASS.

### (A-FM-3) H1 in SKILL.md

`SKILL.md` contains no real H1 (`^# `). Section labels are plain-text colon-terminated (`Claude Code:`, `VS Code / Copilot:`, etc.). PASS.

### (A-FS-1) Orphan files

**Finding 1 — LOW**

- File: `skills/dispatch/skill.index`
- Not a well-known role file. Not referenced by name or relative path in `SKILL.md`, `spec.md`, `uncompressed.md`, or `instructions.uncompressed.md` (no `uncompressed.md` or `instructions.uncompressed.md` exist for this skill).
- Action: delete or add an explicit reference if retained.

**Finding 2 — LOW**

- File: `skills/dispatch/skill.index.md`
- Not a well-known role file. Not referenced in any of the four key files.
- Action: delete or add an explicit reference if retained.

**Finding 3 — LOW**

- File: `skills/dispatch/agents/README.md`
- Not a well-known role file. Not directly referenced in `SKILL.md` or `spec.md`. Referenced only inside `installation.md` — which is itself referenced in the `SKILL.md` "See also" section — but `installation.md` is not one of the four key files checked under A-FS-1.
- Action: acceptable via indirect reference chain; add direct reference in `SKILL.md` "See also" to make the chain explicit, or leave as-is.

### (A-FS-2) Missing referenced files

All "See also" targets in `SKILL.md` exist: `supplemental.md`, `dispatch-pattern.md`, `installation.md`, `dispatch-setup/SKILL.md`. PASS.

---

## Step 2 — Parity Check

No `uncompressed.md` in the `dispatch/` root. Parity check is N/A.

**Advisory (LOW, non-blocking):**
`SKILL.md` exceeds 60 lines. No companion `uncompressed.md` exists. Maintaining an uncompressed source improves readability and safe editing. Does not affect verdict.

---

## Step 3 — Spec Alignment

### Spec exists

`spec.md` co-located with `SKILL.md` in `skills/dispatch/`. PASS.

### Required sections

Spec contains: Purpose ✓, Scope ✓, Definitions ✓, Requirements ✓, Constraints ✓. PASS.

### Normative language

Requirements use `must`, `shall`, `required` throughout R1–R10, C1–C7, DN1–DN13. PASS.

### Coverage — R6 update note

**Finding 4 — LOW**

Rule violated: R6 — "Must include a note to update the table when Anthropic releases a new model."

`SKILL.md` VS Code / Copilot section contains (verbatim):
```
Update minimum models as needed.
```

The note satisfies the update intent but does not name Anthropic model releases specifically. Minor wording gap against the spec's R6 requirement.

### No unauthorized additions

**Finding 5 — NEEDS_REVISION**

Rule violated: "SKILL.md mustn't introduce normative requirements absent from spec."

`SKILL.md` Concurrency section contains (verbatim):
```
When dispatching multiple instructions simultaneously, default max concurrent = 3. Use a rolling window: start up to 3, then as each returns dispatch the next pending instruction. Only exceed 3 if instructed by the caller.
```

The spec (R1–R10, C1–C7, D1–D3, P1–P3, DN1–DN13) contains no concurrency requirement, no max-concurrent default, and no rolling-window rule. This is normative behavior instructing the caller on dispatch limits — entirely absent from spec.

Fix: add a corresponding requirement to `spec.md` (e.g. under Requirements or Defaults), OR remove the Concurrency section from `SKILL.md`.

**Finding 6 — NEEDS_REVISION**

Rule violated: "SKILL.md mustn't introduce normative requirements absent from spec."

`SKILL.md` Fallback section contains (verbatim):
```
If the requested model is not available: stop and inform the caller; suggest an alternative.
```

Spec R7 defines fallback for agent-type unavailability only:
> "The runtime card must define fallback: when the 'Dispatch' agent type is unavailable, omit `subagent_type` / `agentName` and continue."

No spec requirement covers model-unavailability fallback behavior. The `SKILL.md` adds normative behavior absent from spec.

Fix: extend R7 in `spec.md` to cover model-unavailability, OR remove the model-unavailability sentence from `SKILL.md`.

### No contradictions

No `SKILL.md` content contradicts spec. PASS.

### No spec breadcrumbs in runtime

`SKILL.md` "See also" does not reference `spec.md`. PASS.

### Breadcrumbs valid

All "See also" targets exist on disk. PASS.

### Checks not applicable

- A-IS-1, A-IS-2: inline skill, N/A.
- A-FM-12: no `uncompressed.md` in dispatch root, N/A.
- A-FM-8, A-FM-9a, A-FM-9b: no iteration-safety content present, N/A.
- Cost analysis (dispatch-only): inline skill, N/A.
- No dispatch references in instructions: no `instructions.txt`, N/A.

---

## Summary of Findings

| # | Severity | Check | File | Description |
| --- | --- | --- | --- | --- |
| 1 | LOW | A-FS-1 | `skills/dispatch/skill.index` | Orphan — not referenced in key files |
| 2 | LOW | A-FS-1 | `skills/dispatch/skill.index.md` | Orphan — not referenced in key files |
| 3 | LOW | A-FS-1 | `skills/dispatch/agents/README.md` | Not directly referenced in key files |
| 4 | LOW | Step 3 / R6 | `skills/dispatch/SKILL.md` | Update note doesn't name Anthropic releases |
| 5 | NEEDS_REVISION | Step 3 / No unauthorized additions | `skills/dispatch/SKILL.md` | Concurrency section absent from spec |
| 6 | NEEDS_REVISION | Step 3 / No unauthorized additions | `skills/dispatch/SKILL.md` | Model-unavailability fallback absent from spec |
| — | LOW (advisory, non-blocking) | Step 2 | `skills/dispatch/SKILL.md` | >60 lines, no `uncompressed.md` companion |

**Verdict: NEEDS_REVISION**
