---
file_paths:
  - spec-auditing/SKILL.md
  - spec-auditing/instructions.txt
  - spec-auditing/instructions.uncompressed.md
  - spec-auditing/spec.md
  - spec-auditing/uncompressed.md
operation_kind: skill-auditing/v2
model: haiku-class
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
| Classification | PASS | Dispatch classification confirmed by presence of instructions.txt and dispatch invocation in SKILL.md |
| Inline/dispatch consistency | PASS | Dispatch instructions file present and reachable; SKILL.md is minimal routing card |
| Structure | PASS | Frontmatter (name, description), dispatch invocation, parameters typed, delegation to dispatch skill present |
| Input/output double-spec (A-IS-1) | PASS | No input duplication; parameters focused on routing |
| Sub-skill input isolation (A-IS-2) | PASS | No reference to sibling sub-skill outputs in input surface |
| Frontmatter | PASS | name and description present in all artifacts requiring it |
| Name matches folder (A-FM-1) | PASS | name: spec-auditing matches folder name exactly |
| H1 per artifact (A-FM-3) | FAIL | uncompressed.md MUST contain H1 but does not. SKILL.md correctly has no H1; instructions.txt correctly has no H1; instructions.uncompressed.md correctly has H1 |
| No duplication | PASS | No existing similar capability identified |
| Orphan files (A-FS-1) | PASS | All files serve known roles or are referenced |
| Missing referenced files (A-FS-2) | PASS | instructions.txt exists and is referenced in dispatch line |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | PASS | Compression acceptable; minor wording differences, intent preserved. uncompressed.md adds "Variables" label and fuller parameter type annotations |
| instructions.txt ↔ instructions.uncompressed.md | PASS | Compression acceptable; structural reformatting (section headers, bullet formatting) with intent preserved |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present and co-located |
| Required sections | PASS | Spec contains Purpose, Scope, Definitions, Requirements, Constraints |
| Normative language | PASS | Uses must/shall/required consistently |
| Internal consistency | PASS | No contradictions within spec.md |
| Spec completeness | PASS | All terms defined; all behavior explicitly stated |
| Coverage | PASS | Every normative requirement in spec represented in compiled artifacts |
| No contradictions | PASS | SKILL.md and instructions files faithfully represent spec |
| No unauthorized additions | PASS | No requirements exceed spec scope |
| Conciseness | PASS | Agent can skim and know what to do |
| Completeness | PASS | All runtime instructions present |
| Breadcrumbs | PASS | References to ../dispatch/SKILL.md and ../iteration-safety/SKILL.md are valid |
| Cost analysis | PASS | Dispatch agent, instruction file appropriately sized |
| No dispatch refs | PASS | instructions.txt does not tell agent to dispatch other skills |
| No spec breadcrumbs | PASS | References to spec.md are operational content, not cross-file pointers |
| Eval log (informational) | ABSENT | No eval.txt present; not required |
| Description not restated (A-FM-2) | PASS | Description is not duplicated in body |
| No exposition in runtime (A-FM-5) | PASS | No rationale in runtime artifacts |
| No non-helpful tags (A-FM-6) | PASS | No zero-value descriptor lines |
| No empty sections (A-FM-7) | PASS | Every heading has body content |
| Iteration-safety placement (A-FM-8) | PASS | Pointer correctly placed at end of uncompressed.md and SKILL.md |
| Iteration-safety pointer form (A-FM-9a) | PASS | Correct 2-line form with relative path matching caller depth |
| No verbatim Rule A/B (A-FM-9b) | PASS | No restatement beyond sanctioned pointer block |
| Cross-reference anti-pattern (A-XR-1) | PASS | No cross-file pointers to other skills' uncompressed.md or spec.md |
| Launch-script form (A-FM-10) | FAIL | uncompressed.md missing H1; see A-FM-3 finding |
| Return shape declared (DS-1) | FAIL | Return shape vague. States "Should return: Pass | Pass with Findings | Fail" but this is text, not path. Canonical: PATH on success, ERROR on failure |
| Host card minimalism (DS-2) | PASS | No internal cache descriptions, adaptive rules, or prose about workings |
| Description trigger phrases (DS-3) | PASS | 5 trigger phrases present: spec validation, requirements coverage, contradiction detection, document alignment, specification quality |
| Inline dispatch guard (DS-4) | PASS | Has NEVER READ guard, Read and follow form, Follow dispatch delegation |
| No substrate duplication (DS-5) | PASS | No hash-record schema inlining |
| No overbuilt sub-skill dispatch (DS-6) | PASS | Dispatch appropriate for procedure scope |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| spec.md | Not empty | PASS | 827 lines |
| spec.md | Frontmatter | N/A | Correctly absent (specs must not have frontmatter) |
| spec.md | No abs-path leaks | PASS | No absolute paths |
| spec.md | Purpose section | PASS | Present at line 3 |
| SKILL.md | Not empty | PASS | 32 lines |
| SKILL.md | Frontmatter | PASS | Present with name and description |
| SKILL.md | No abs-path leaks | PASS | None found |
| uncompressed.md | Not empty | PASS | 34 lines |
| uncompressed.md | Frontmatter | PASS | Present |
| uncompressed.md | No abs-path leaks | PASS | None found |
| instructions.txt | Not empty | PASS | 152 lines |
| instructions.txt | Frontmatter | N/A | Correctly absent |
| instructions.txt | No abs-path leaks | PASS | None found |
| instructions.uncompressed.md | Not empty | PASS | 153 lines |
| instructions.uncompressed.md | Frontmatter | N/A | Correctly absent |
| instructions.uncompressed.md | No abs-path leaks | PASS | None found |

### Issues

**Issue 1: A-FM-3 (H1 per artifact) — HIGH**

`uncompressed.md` MUST contain H1 per dispatch launch-script form (A-FM-10). Currently starts with frontmatter followed by `## Dispatch` section. 

Evidence: File lines 1-9 are frontmatter and blank line; H1 never appears.

Fix: Add H1 after frontmatter (after line 8). Suggested: `# Spec Auditing` or `# Spec-Auditing Dispatch Card`.

**Issue 2: DS-1 (Return shape declared) — HIGH**

Return shape is vague and incorrect for dispatch skill producing an artifact. Current text: "Should return: `Pass` | `Pass with Findings` | `Fail`"

This states text output, not artifact path. Per instructions, canonical form for dispatch skills producing artifacts:
- Success: `PATH: <abs-path-to-artifact>`
- Pre-write failure: `ERROR: <reason>`

Evidence: uncompressed.md line 21 and SKILL.md line 19.

Fix: Replace "Should return:" with explicit return contract. Example: `Returns: PATH: <hash-record-artifact-path>` (exact format depends on dispatcher's path convention for this skill's output). Clarify what artifact path the dispatcher should expect to receive on success.

### Recommendation

Fix HIGH violations: add H1 to uncompressed.md and clarify return contract to canonical PATH/ERROR form in both SKILL.md and uncompressed.md.

