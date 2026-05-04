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
| Classification | PASS | Dispatch correct; spec/companion auditing requires isolated context |
| Inline/dispatch consistency | PASS | instructions.txt present; SKILL.md is minimal routing card |
| Structure | PASS | All required dispatch variables and delegation line present |
| Input/output double-spec (A-IS-1) | PASS | No input duplication of sub-skill output |
| Sub-skill input isolation (A-IS-2) | N/A | No sub-skills |
| Frontmatter | PASS | name and description present and accurate in SKILL.md and uncompressed.md |
| Name matches folder (A-FM-1) | PASS | name: spec-auditing matches folder name in both SKILL.md and uncompressed.md |
| H1 per artifact (A-FM-3) | PASS | SKILL.md no H1; uncompressed.md has H1; instructions.txt no H1; instructions.uncompressed.md has H1 |
| No duplication | PASS | No equivalent skill found in sibling directories |
| Orphan files (A-FS-1) | PASS | All files are well-known role files; no orphans |
| Missing referenced files (A-FS-2) | PASS | instructions.txt exists; ../dispatch/SKILL.md and ../iteration-safety/SKILL.md both present |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md vs uncompressed.md | PASS | Minor wording compression only; intent preserved |
| instructions.txt vs instructions.uncompressed.md | PASS | Compressed form faithfully represents uncompressed; all gates, modes, and output sections present |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec-auditing/spec.md co-located with skill dir |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Requirements use must/shall/required throughout |
| Internal consistency | PASS | No contradictions within spec |
| Spec completeness | PASS | All terms defined; procedures complete |
| Coverage | FINDINGS | --kind meta|domain documented in spec and instructions but absent from SKILL.md input-args and uncompressed.md input-args and Parameters section |
| No contradictions | PASS | Routing card does not contradict spec |
| No unauthorized additions | PASS | No additions beyond spec scope |
| Conciseness | PASS | Routing card is terse; instructions are dense and agent-facing |
| Completeness | PASS | All runtime instructions present in instructions.txt |
| Breadcrumbs | PASS | ../dispatch/SKILL.md and ../iteration-safety/SKILL.md both valid and present |
| Cost analysis | PASS | instructions.txt is 156 lines (under 500); dispatch pattern correct |
| No dispatch refs | PASS | instructions.txt does not direct agent to dispatch other skills |
| No spec breadcrumbs | PASS | Neither SKILL.md nor instructions.txt reference own spec.md |
| Eval log (informational) | ABSENT | No eval.txt co-located |
| Description not restated (A-FM-2) | PASS | Description in frontmatter only; not restated in body prose of any artifact |
| No exposition in runtime (A-FM-5) | PASS | No rationale or background prose in any runtime artifact |
| No non-helpful tags (A-FM-6) | PASS | No bare type labels or non-operational descriptors |
| No empty sections (A-FM-7) | PASS | All headings have body content |
| Iteration-safety placement (A-FM-8) | PASS | Blurb absent from instructions.txt and instructions.uncompressed.md; 2-line pointer in SKILL.md and uncompressed.md only |
| Iteration-safety pointer form (A-FM-9a) | PASS | Exact 2-line form; relative path ../iteration-safety/SKILL.md correct for skill depth |
| No verbatim Rule A/B (A-FM-9b) | PASS | No verbatim iteration-safety rule text beyond the pointer block |
| Cross-reference anti-pattern (A-XR-1) | PASS | No pointers to another skill uncompressed.md or spec.md; spec.md mentions in instructions.txt are subject-matter references (this skill audits spec.md files as inputs) |
| Launch-script form (A-FM-10) | FINDINGS | uncompressed.md Parameters section includes executor-level stop-gate text for --fix |
| Return shape declared (DS-1) | PASS | Returns line covers PATH on cache hit, Pass/Pass with Findings/Fail on verdict, ERROR on failure |
| Host card minimalism (DS-2) | PASS | uncompressed.md contains no internal cache descriptions, adaptive rules, or subjective qualifiers |
| Description trigger phrases (DS-3) | PASS | 5 trigger phrases within 3-6 range; no impl notes in description |
| Inline dispatch guard (DS-4) | PASS | NEVER READ guard on instructions binding; Read and follow form on prompt; Follow dispatch skill delegation line present |
| No substrate duplication (DS-5) | PASS | hash-record path schema not inlined in host card |
| No overbuilt sub-skill dispatch (DS-6) | N/A | No sub-skills dispatched |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| SKILL.md | Not empty | PASS | |
| SKILL.md | Frontmatter (required) | PASS | YAML frontmatter at line 1 |
| SKILL.md | No abs-path leaks | PASS | |
| uncompressed.md | Not empty | PASS | |
| uncompressed.md | Frontmatter (required) | PASS | YAML frontmatter at line 1 |
| uncompressed.md | No abs-path leaks | PASS | "absolute path to instructions" is descriptive placeholder text |
| instructions.txt | Not empty | PASS | |
| instructions.txt | Frontmatter | N/A | Not required |
| instructions.txt | No abs-path leaks | PASS | absolute_path is a template placeholder |
| instructions.uncompressed.md | Not empty | PASS | |
| instructions.uncompressed.md | Frontmatter | N/A | Not required |
| instructions.uncompressed.md | No abs-path leaks | PASS | absolute_path is a template placeholder |
| spec.md | Not empty | PASS | |
| spec.md | Frontmatter | N/A | spec.md correctly has no YAML frontmatter |
| spec.md | No abs-path leaks | PASS | |

### Issues

**MEDIUM-1 — --kind meta|domain absent from routing card input signature**

Files: spec-auditing/SKILL.md (line 13), spec-auditing/uncompressed.md (lines 17, 27-29)

The input-args binding in both SKILL.md and uncompressed.md reads:
  `<input-args> = <target-path> [--spec <spec-path>] [--fix]`
omitting `[--kind meta|domain]`. The Parameters section in uncompressed.md also omits this parameter entirely.

The parameter is fully specified in spec-auditing/spec.md (Inputs section and Audit Kind section) and correctly implemented in instructions.txt (line 5) and instructions.uncompressed.md (line 5). A caller reading only the routing card would not know this parameter exists or how to use it.

Fix: Add `[--kind meta|domain]` to the input-args binding in both SKILL.md and uncompressed.md. Add a parameter entry to uncompressed.md Parameters section: `--kind meta|domain` (flag, optional): audit kind override — meta for spec-writing authority, domain for domain specs; auto-detected from path if omitted.

**MEDIUM-2 — Executor-level stop-gate constraint in uncompressed.md Parameters section (A-FM-10)**

File: spec-auditing/uncompressed.md (line 29)

The --fix parameter description reads: `fix mode — target must be git-tracked and clean; modifies target to match spec, up to 3 passes`. The phrase "target must be git-tracked and clean" is an executor-level eligibility gate. Per A-FM-10, uncompressed.md for a dispatch skill must contain only: frontmatter, optional H1, dispatch invocation and input signature, Returns line, optional iteration-safety pointer, and optional inline result check protocol. Behavioral preconditions belong in instructions.uncompressed.md, not the host card.

The full gate is already present in instructions.txt Gate 6 and instructions.uncompressed.md Gate 6.

Fix: Shorten --fix description in uncompressed.md to: `fix mode — modifies target to match spec, up to 3 passes`. Remove the git-clean precondition from the host card.

### Recommendation

Two targeted edits required: (1) add [--kind meta|domain] to input-args binding and Parameters section in both SKILL.md and uncompressed.md; (2) trim git-clean precondition from --fix parameter description in uncompressed.md.