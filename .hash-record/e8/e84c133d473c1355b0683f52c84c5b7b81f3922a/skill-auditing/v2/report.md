---
operation_kind: skill-auditing/v2
result: findings
file_paths:
  - swarm/SKILL.md
  - swarm/spec.md
  - swarm/uncompressed.md
---

# Result

**Verdict: NEEDS_REVISION** — 2 HIGH findings. All quotes verbatim from files read.

---

## Per-file Basic Checks

| File | Not empty | Frontmatter | No abs paths | H1 rule |
| --- | --- | --- | --- | --- |
| `swarm/SKILL.md` | PASS | PASS | PASS | PASS — no real H1 |
| `swarm/uncompressed.md` | PASS | PASS | PASS | PASS — `# swarm — Uncompressed Reference` present |
| `swarm/spec.md` | PASS | N/A | PASS | N/A |
| `swarm/specs/arbitrator.md` | PASS | N/A | PASS | N/A |
| `swarm/reviewers/devils-advocate.md` | PASS | N/A | PASS | N/A |
| `swarm/reviewers/security-auditor.md` | PASS | N/A | PASS | N/A |

All per-file basic checks: PASS.

---

## Step 1 — Compiled Artifacts

**Skill type**: inline. No `instructions.txt` or separate dispatch instruction file present. SKILL.md contains the full procedure.

**A-FM-1 Name matches folder**: `name: swarm` in both SKILL.md and uncompressed.md; folder is `swarm`. PASS.

**A-FM-4 Valid frontmatter fields**: SKILL.md frontmatter contains only `name` and `description`. PASS.

**A-FM-11 Trigger phrases**: Both SKILL.md and uncompressed.md `description` contain `Triggers -`. PASS.

**A-FM-12 Frontmatter mirror**: uncompressed.md `name` and `description` match SKILL.md exactly (case-sensitive). PASS.

**A-FM-3 H1 rule**: SKILL.md contains no real H1. uncompressed.md contains real H1 (`# swarm — Uncompressed Reference`). PASS.

**A-FM-2 Description not restated**: No body prose duplicates the frontmatter description in SKILL.md or uncompressed.md. PASS.

**A-FM-5 No exposition in runtime artifacts**: FINDING — see F-1 below.

**A-FM-6 No non-helpful tags**: No bare descriptor lines found. PASS.

**A-FM-7 No empty leaves**: All sections have body content. PASS.

**A-FM-8 / A-FM-9a / A-FM-9b Iteration-safety**: No iteration-safety blurb or pointer found in SKILL.md or uncompressed.md. PASS.

**A-XR-1 Cross-reference anti-pattern**: Cross-skill references (`dispatch`, `compression`) identified by canonical name. References to `specs/*.md` and `reviewers/*` are own sub-files — not violations per rule. PASS.

**A-FS-1 Orphan files**: All non-well-known files in `swarm/` (dot-prefixed dirs and `optimize-log.md` skipped) are referenced:

| File | Referenced in |
| --- | --- |
| `reviewers/devils-advocate.md` | SKILL.md Step 4 (filename pattern) |
| `reviewers/security-auditor.md` | SKILL.md Step 4 (filename pattern) |
| `reviewers/index.yaml` | SKILL.md and uncompressed.md (`reviewers/index.yaml`) |
| `specs/arbitrator.md` | SKILL.md and uncompressed.md Related section |
| `specs/dispatch-integration.md` | SKILL.md and uncompressed.md Related section |
| `specs/glossary.md` | SKILL.md and uncompressed.md Related section |
| `specs/personality-file.md` | SKILL.md and uncompressed.md Related section |
| `specs/registry-format.md` | SKILL.md and uncompressed.md Related section |

PASS.

**A-FS-2 Missing referenced files**: All five `specs/*.md` files referenced in Related section confirmed present in `swarm/specs/`. PASS.

**DS-1 through DS-7**: N/A — inline skill.

---

## Step 2 — Parity Check

SKILL.md and uncompressed.md both present. Intent compared.

All steps, constraints, behaviors, defaults, error handling, and precedence rules align between the two files **except** Step 6 dispatch tier parameter.

**SKILL.md Step 6** (verbatim):

```
`<tier>` = `standard` — arbitration requires comparing N member outputs and applying judgment; fast-cheap insufficient.
```

**uncompressed.md Step 6** (verbatim):

```
- `<tier>` = `standard`
```

Parity failure: SKILL.md Step 6 dispatch tier line contains inline rationale absent from uncompressed.md — compiled artifact diverges from uncompressed source. Fix: edit `swarm/uncompressed.md` Step 6 to remove the inline rationale from the tier line, then recompress to `swarm/SKILL.md`. (Note: the correct resolution is removal from SKILL.md to match the clean uncompressed source, not adding the rationale to uncompressed.md.) See also F-1.

---

## Step 3 — Spec Alignment

**Spec structure**: `swarm/spec.md` co-located with skill. Contains all required sections: Purpose, Scope, Definitions, Requirements, Constraints. PASS.

**Normative language**: All 16 Requirements use enforceable language (`must`, `shall`, `required`). PASS.

**Internal consistency**: No contradictions within spec.md. PASS.

**Coverage**: All 16 spec Requirements represented in SKILL.md. No gaps detected. PASS.

**No contradictions**: SKILL.md does not contradict spec on any requirement. PASS.

**No unauthorized additions**: All normative content in SKILL.md traces to spec Requirements, Constraints, Behavior, Defaults, Error Handling, or Precedence Rules. PASS.

**Conciseness — named patterns**:

FINDING (F-1) — `too much why` in SKILL.md Step 6. See Findings section.

No other named patterns ("essay not reference card," "prose conditionals," "meta-architectural label") detected.

**Breadcrumbs**: Related sections in SKILL.md and uncompressed.md reference valid targets; all files confirmed present. PASS.

**No spec breadcrumbs in runtime**: SKILL.md does not reference `swarm/spec.md`. Sub-spec references in Related section (`specs/arbitrator.md`, etc.) are own sub-files, not the companion `spec.md`. PASS.

---

## Findings

### F-1 — A-FM-5 (HIGH) — too much why in SKILL.md Step 6

**Check**: A-FM-5 / named pattern "too much why"
**Severity**: HIGH
**Location**: `swarm/SKILL.md`, Step 6 — Arbitrator consolidation, dispatch parameters

**Verbatim quote**:

```
`<tier>` = `standard` — arbitration requires comparing N member outputs and applying judgment; fast-cheap insufficient.
```

The clause `arbitration requires comparing N member outputs and applying judgment; fast-cheap insufficient` is rationale explaining why `tier: standard` is used — it is not an operational instruction. Rationale belongs exclusively in `spec.md`.

**Fix**: Remove the rationale clause. After fix, the line reads:

```
`<tier>` = `standard`
```

The rationale is already implicit in `specs/arbitrator.md` (arbitrator dispatch role). No spec change needed.

---

### F-2 — Step 2 Parity (HIGH) — SKILL.md diverges from uncompressed.md at Step 6

**Check**: Step 2 Parity
**Severity**: HIGH
**Location**: `swarm/SKILL.md` Step 6 vs `swarm/uncompressed.md` Step 6

Same content as F-1. SKILL.md was hand-edited after compression to add the inline rationale clause; uncompressed.md does not contain it. The uncompressed source is the correct state.

**Parity failure**: SKILL.md Step 6 dispatch tier line contains `— arbitration requires comparing N member outputs and applying judgment; fast-cheap insufficient` which is absent from uncompressed.md. Fix: edit `swarm/uncompressed.md`, then recompress to `swarm/SKILL.md`. (Correct direction: strip the clause from SKILL.md to match the clean uncompressed.md source.)

---

## Verdict

**NEEDS_REVISION**

2 HIGH findings (F-1, F-2) — same underlying content, two applicable checks. Single fix resolves both: remove the inline rationale clause from the SKILL.md Step 6 tier parameter line.

No FAIL findings. All spec requirements covered. No contradictions. No orphan files. No missing referenced files. No absolute-path leaks. No frontmatter issues.
