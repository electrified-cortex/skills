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
**Path:** spec-auditing/

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Skill dispatches a spec/companion auditor; requires dispatch agent — dispatch correct |
| Inline/dispatch consistency | PASS | instructions.txt present; SKILL.md is routing card; dispatch wiring present |
| Structure | PASS | No stop gates in routing card; --fix gate previously removed |
| Input/output double-spec (A-IS-1) | PASS | No duplicated output paths; return shape declared once |
| Sub-skill input isolation (A-IS-2) | N/A | No sub-skill dispatches |
| Frontmatter | PASS | name and description present and accurate in both SKILL.md and uncompressed.md |
| Name matches folder (A-FM-1) | PASS | name: spec-auditing matches folder name in both SKILL.md and uncompressed.md |
| H1 per artifact (A-FM-3) | PASS | SKILL.md: no H1 (correct); instructions.txt: `# Result` is inside fenced code block (template), not document H1; uncompressed.md has H1; instructions.uncompressed.md has H1 |
| No duplication | PASS | No equivalent skill found in repo |
| Orphan files (A-FS-1) | PASS | All files are well-known role files; no orphans (dot-prefixed .audit dir skipped per rules) |
| Missing referenced files (A-FS-2) | PASS | instructions.txt present; ../dispatch/SKILL.md exists; ../iteration-safety/SKILL.md exists |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | FAIL | SKILL.md Parameters section omits `--kind` bullet present in uncompressed.md — see F-1 |
| instructions.txt ↔ instructions.uncompressed.md | PASS | result field uses correct four-value mapping (pass/pass_with_findings/fail/error); return token uses title-case form matching spec; both files aligned |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md co-located in skill dir |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Uses must/shall/required throughout |
| Internal consistency | PASS | No internal contradictions detected in spec |
| Spec completeness | PASS | All terms defined; audit procedure, severity, output format, hash-record behavior fully specified |
| Coverage | PASS | instructions.txt covers all normative requirements from spec |
| No contradictions | PASS | Previously-flagged F-1/F-2 token and result-field contradictions resolved; no new contradictions |
| No unauthorized additions | PASS | No additions in instructions.txt beyond what spec defines |
| Conciseness | PASS | SKILL.md is compact routing card; instructions.txt is dense procedure without rationale |
| Completeness | PASS | All runtime instructions present; edge cases addressed |
| Breadcrumbs | PASS | References to ../dispatch/SKILL.md and ../iteration-safety/SKILL.md both resolve |
| Cost analysis | PASS | Uses dispatch agent; instructions.txt ~157 lines (under 500); no inlined sub-skill procedure |
| No dispatch refs | PASS | instructions.txt does not tell agent to dispatch other skills |
| No spec breadcrumbs | PASS | No runtime artifact references its own spec.md; spec.md mentions in instructions are to audited target files — stated exception applies |
| Eval log (informational) | ABSENT | No eval.txt present |
| Description not restated (A-FM-2) | PASS | Description frontmatter value not restated verbatim in body prose |
| No exposition in runtime (A-FM-5) | PASS | No rationale or historical notes in runtime artifacts; "why" occurrences are operational instructions, not background prose |
| No non-helpful tags (A-FM-6) | PASS | No bare type labels found |
| No empty sections (A-FM-7) | PASS | All headings have body content |
| Iteration-safety placement (A-FM-8) | PASS | Iteration-safety blurb absent from instructions.txt and instructions.uncompressed.md |
| Iteration-safety pointer form (A-FM-9a) | PASS | Exact 2-line pointer block form; path `../iteration-safety/SKILL.md` correct for folder depth |
| No verbatim Rule A/B (A-FM-9b) | PASS | No verbatim restatement of iteration-safety rules |
| Cross-reference anti-pattern (A-XR-1) | PASS | References to spec.md in instructions are to files being audited; stated exception for spec-auditing applies |
| Launch-script form (A-FM-10) | PASS | uncompressed.md contains only frontmatter, H1, dispatch block with Variables label, Parameters, Returns line, and Iteration Safety pointer — no prohibited content |
| Return shape declared (DS-1) | PASS | Returns line present in SKILL.md and uncompressed.md with full token vocabulary (PATH/Pass/Pass with Findings/Fail/ERROR) |
| Host card minimalism (DS-2) | PASS | No cache internals, adaptive rules, tool-fallback hints, or subjective qualifiers in routing card; "on cache hit" in Returns line is return-shape label, not impl description |
| Description trigger phrases (DS-3) | PASS | Description uses Triggers pattern with 5 comma-separated trigger phrases |
| Inline dispatch guard (DS-4) | PASS | (NEVER READ) guard on instructions binding; `Read and follow` form on prompt; `Follow dispatch skill. See ../dispatch/SKILL.md` delegation line present; no stale standalone opener/closer |
| No substrate duplication (DS-5) | PASS | spec-auditing implements hash-record caching per its own spec; no duplication of referenced substrate skill schema |
| No overbuilt sub-skill dispatch (DS-6) | N/A | No sub-skill dispatches |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| SKILL.md | Not empty | PASS | |
| SKILL.md | Frontmatter | PASS | YAML frontmatter present at line 1 |
| SKILL.md | No abs-path leaks | PASS | |
| uncompressed.md | Not empty | PASS | |
| uncompressed.md | Frontmatter | PASS | YAML frontmatter present at line 1 |
| uncompressed.md | No abs-path leaks | PASS | |
| instructions.txt | Not empty | PASS | |
| instructions.txt | Frontmatter | N/A | Not required |
| instructions.txt | No abs-path leaks | PASS | |
| instructions.uncompressed.md | Not empty | PASS | |
| instructions.uncompressed.md | Frontmatter | N/A | Not required |
| instructions.uncompressed.md | No abs-path leaks | PASS | |
| spec.md | Not empty | PASS | |
| spec.md | Frontmatter | PASS | No YAML frontmatter present (correct for spec files) |
| spec.md | No abs-path leaks | PASS | |

### Issues

**F-1 (MEDIUM) — Parity failure: SKILL.md Parameters section omits `--kind` bullet**

`uncompressed.md` (lines 25–31) includes four parameter bullets in its Parameters section:

```
- `target-path` (string, required): ...
- `--spec <spec-path>` (string, optional): ...
- `--fix` (flag, optional): ...
- `--kind meta|domain` (optional): force audit kind — `meta` for spec-writing skills, `domain` for all others; default auto-detects from path
```

`SKILL.md` (lines 22–25) lists only three parameters and omits `--kind`:

```
Parameters:
`target-path` (required): path to spec or companion file
`--spec <spec-path>` (optional): explicit spec path (pair-audit mode)
`--fix` (flag, optional): fix mode; modifies target to match spec, up to 3 passes
```

The `--kind` parameter was added to `uncompressed.md` during prior fix (MEDIUM-1) and to the `<input-args>` binding in SKILL.md (line 13), but the compiled SKILL.md Parameters section was not updated to match. This is a half-applied fix — the input signature includes `--kind` but the Parameters documentation does not.

Fix: edit `SKILL.md` to add the `--kind` parameter bullet, e.g.:
`` `--kind meta|domain` (optional): audit kind; default auto-detects from path ``

### Recommendation

Add the missing `--kind` parameter bullet to SKILL.md Parameters section to complete the MEDIUM-1 fix — all prior HIGH findings (F-1/F-2 result field and return token) are confirmed resolved; one MEDIUM parity gap remains.
