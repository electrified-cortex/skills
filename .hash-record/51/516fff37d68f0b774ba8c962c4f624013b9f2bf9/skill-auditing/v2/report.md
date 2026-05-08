---
operation_kind: skill-auditing/v2
result: findings
file_paths:
  - swarm/SKILL.md
  - swarm/spec.md
  - swarm/uncompressed.md
---

# Result

**Verdict: NEEDS_REVISION**

Multiple HIGH findings require cleanup. The known rolling-window / spec contradiction is the only intentional deviation; the remaining findings are independent and addressable. None are catastrophic — the skill functions — but several runtime artifacts carry exposition that belongs in the spec, and one compiled artifact references an undefined rule.

---

## Per-file Basic Checks

All `.md` files in `swarm/` contain non-whitespace content. `SKILL.md` and `uncompressed.md` have valid YAML frontmatter at line 1. No Windows-style or POSIX root-anchored path leaks found in any file. No violations.

---

## Step 1 — Compiled Artifacts

**Skill type:** Inline. No `instructions.txt` or dispatch-named instruction file present. `SKILL.md` contains the full step procedure. File-system evidence consistent with inline classification.

| Check | Result |
| --- | --- |
| A-FM-1 — name matches folder | PASS — `name: swarm` in both artifacts; folder name `swarm` |
| A-FM-4 — only `name`/`description` in frontmatter | PASS |
| A-FM-12 — `uncompressed.md` frontmatter mirror | PASS — `name` and `description` match exactly |
| A-FM-3 — H1 rule | PASS — `SKILL.md` has no real H1; `uncompressed.md` opens with `# swarm — Uncompressed Reference` |
| A-FS-2 — missing referenced files | PASS — all explicitly referenced files exist |
| A-IS-1 / A-IS-2 — input/sub-skill isolation | PASS |

**Finding S1-1** [HIGH — A-FM-11]
`SKILL.md` `description` contains `Triggers —` (em-dash, U+2014). The literal substring `Triggers -` (hyphen-minus, U+002D) required by A-FM-11 is absent. Substance is present; the character differs by one codepoint.
Fix: replace `—` with `-` in the `description` trigger separator in both `swarm/SKILL.md` and `swarm/uncompressed.md`.

**Finding S1-2** [HIGH — A-FM-5]
`SKILL.md` Step 2 includes the line: "Separate dispatch for personality selection is not used." This is a meta-architectural label describing the execution pattern rather than instructing the agent. The corresponding instruction ("Selection logic MUST be inline within skill") is sufficient; the descriptive note is exposition.
Fix: remove the sentence from `swarm/SKILL.md` Step 2 (and from the parallel location in `swarm/uncompressed.md`); then recompress.

**Finding S1-3** [HIGH — A-FM-5]
`SKILL.md` Steps 5 and 6 include inline rationale attached to dispatch tier values:
- Step 5: `` `<tier>` = `standard` — personality reviews require moderate reasoning; fast-cheap insufficient for evidence-cited findings ``
- Step 6: `` `<tier>` = `standard` — arbitration requires comparing N member outputs and applying judgment; fast-cheap is insufficient ``

Both clauses explain why `standard` was chosen. Rationale belongs in `swarm/spec.md` (where it is already captured via `specs/dispatch-integration.md`). Fix: strip the `—` rationale clause from each tier line in `swarm/uncompressed.md`; recompress to `swarm/SKILL.md`.

**Finding S1-4** [LOW — A-FS-1]
`.gitignore` at `swarm/` root is not a well-known role file and is not referenced in `SKILL.md`, `uncompressed.md`, or `spec.md`. Orphan by enumeration rules.
Note: standard SCM file; operational impact is nil. Flag only for completeness.

---

## Step 2 — Parity Check

`uncompressed.md` is present. Both artifacts were compared for intent.

**Finding S2-1** [HIGH — Parity]
`SKILL.md` Step 5 contains: "Apply diversity preference rule (B8) after model selection." Rule B8 is not defined anywhere in `SKILL.md`. An agent reading only the compiled artifact cannot determine what B8 requires. `uncompressed.md` D3 defines the rule ("Default dispatch: rolling window of 3. Never more than 3 personalities in flight at once."), and `uncompressed.md` B8 defines cross-vendor diversity preference — but neither definition is present in `SKILL.md`.
Parity failure: compiled diverges from source by omitting rule definition that the compiled text references.
Fix: edit `swarm/uncompressed.md` to inline the B8 cross-vendor diversity rule text at Step 5 (or replace the opaque reference with the rule stated in full); then recompress to `swarm/SKILL.md`.

**Finding S2-2** [HIGH — Parity]
Constraint C8 ("Do not expand the personality registry with new built-in entries without a spec amendment and audit pass") is present in `swarm/uncompressed.md` but absent from `swarm/SKILL.md`. An agent following the compiled artifact is unaware of this gate. Normative constraint lost during compression.
Fix: ensure C8 is not dropped during the next compression pass of `swarm/uncompressed.md` → `swarm/SKILL.md`.

**Finding S2-3** [HIGH — A-FM-5 in uncompressed.md]
`swarm/uncompressed.md` contains two named rationale blocks that belong exclusively in `swarm/spec.md`:
- Step 2: "Rationale: the token cost of a selection dispatch exceeds the cost of inline evaluation for registries of the current scale (under 12 entries). This decision should be revisited if the registry grows beyond approximately 20 entries."
- Step 4: "Rationale for sub-skill files over inline data: inline prompts bloat the context regardless of which personalities are selected, defeating lazy loading. Dynamic data loading at dispatch time keeps the skill's base context minimal. This is a normative decision; implementors must not revert to inline prompts."

Both rationale blocks already appear verbatim in `swarm/spec.md` Steps 2 and 4. They are duplicated in `uncompressed.md` in violation of A-FM-5. Fix: remove both rationale blocks from `swarm/uncompressed.md`; they are authoritative in `swarm/spec.md`.

**Finding S2-4** [HIGH — A-FM-5 in uncompressed.md]
`swarm/uncompressed.md` Steps 5 and 6 include the same tier rationale clauses identified in S1-3, plus the meta-architectural label identified in S1-2. Same fix applies: remove from `swarm/uncompressed.md`, then recompress.

---

## Step 3 — Spec Alignment

**Spec exists:** Yes, `swarm/spec.md` co-located with skill. PASS.

| Spec check | Result |
| --- | --- |
| Required sections (Purpose, Scope, Definitions, Requirements, Constraints) | PASS — all five present |
| Normative language | PASS — Requirements 1–16 use "must" / "must not" throughout |
| Internal consistency (within spec) | PASS — spec is self-consistent; see Finding S3-1 for SKILL.md contradiction |
| Coverage — Requirements 1–16 represented in SKILL.md | PASS for 15 of 16; Requirement 7 is the known contradiction (S3-1) |
| No unauthorized additions | PASS — dispatch tier/description parameters are implementation detail; `specs/dispatch-integration.md` sub-spec governs |
| Spec completeness | PASS — all behavior, defaults, error handling, precedence defined |

**Finding S3-1** [KNOWN / INTENTIONAL — Spec contradiction]
`SKILL.md` Step 5 and `swarm/uncompressed.md` D3 specify:
> "Maximum concurrency: rolling window of 3. Dispatch up to 3 personalities in parallel; as each completes, dispatch the next. Do not dispatch more than 3 at once."

`swarm/spec.md` Requirement 7, Step 5, and D3 mandate:
> "All swarm personalities must be dispatched in a single parallel batch; sequential dispatch is not permitted." / "parallel (all at once, single batch)"

This is a direct contradiction. Per operator-supplied context: the rolling window was an approved fix for an unbounded concurrency bug introduced after the spec was written. The spec is stale on this point; a spec update is pending governor approval.

Treated as **known, intentional deviation**. No novel fault. Spec update must be completed before the next audit pass to close this finding.

---

## Summary of Findings

| ID | Severity | Check | Location | Description |
| --- | --- | --- | --- | --- |
| S1-1 | HIGH | A-FM-11 | `swarm/SKILL.md` frontmatter | Em-dash in trigger phrase; literal `Triggers -` absent |
| S1-2 | HIGH | A-FM-5 | `swarm/SKILL.md` Step 2 | Meta-architectural label — not an instruction |
| S1-3 | HIGH | A-FM-5 | `swarm/SKILL.md` Steps 5–6 | Tier rationale prose in runtime artifact |
| S1-4 | LOW | A-FS-1 | `swarm/.gitignore` | Unreferenced non-role file |
| S2-1 | HIGH | Parity | `swarm/SKILL.md` Step 5 | B8 referenced but not defined in compiled artifact |
| S2-2 | HIGH | Parity | `swarm/SKILL.md` Constraints | C8 present in source, absent from compiled |
| S2-3 | HIGH | A-FM-5 | `swarm/uncompressed.md` Steps 2, 4 | Named Rationale blocks — belong in spec only |
| S2-4 | HIGH | A-FM-5 | `swarm/uncompressed.md` Steps 2, 5–6 | Meta-architectural label + tier rationale duplicates |
| S3-1 | KNOWN/INTENTIONAL | Spec contradiction | `swarm/SKILL.md` + `swarm/uncompressed.md` Step 5 | Rolling window of 3 vs spec single-batch mandate |

**HIGH count:** 7 (plus 1 known/intentional)
**LOW count:** 1

---

## Fix Priority

1. **S2-3 / S2-4 / S1-2 / S1-3** — Remove all rationale prose and meta-architectural labels from `swarm/uncompressed.md`; recompress to `swarm/SKILL.md`. These are the root edits; compression produces all compiled fixes.
2. **S2-1** — Inline B8 rule text at Step 5 in `swarm/uncompressed.md`; recompress.
3. **S2-2** — Verify C8 survives compression; add to `swarm/SKILL.md` if still absent.
4. **S1-1** — Change em-dash to hyphen in `description` trigger separator in `swarm/uncompressed.md`; recompress.
5. **S3-1** — Update `swarm/spec.md` D3 and Requirement 7 to reflect the rolling-window-of-3 default once governor approves spec amendment.
