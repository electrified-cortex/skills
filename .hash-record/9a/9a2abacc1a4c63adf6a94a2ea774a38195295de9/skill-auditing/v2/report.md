---
file_paths:
  - swarm/SKILL.md
  - swarm/spec.md
  - swarm/uncompressed.md
operation_kind: skill-auditing/v2
model: haiku-class
result: findings
---

# Result

NEEDS_REVISION

## Skill Audit: swarm

**Verdict:** NEEDS_REVISION
**Type:** inline
**Path:** swarm/

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Inline skill — no dispatch instruction file present (no instructions.txt). Classification confirmed by file-system evidence. |
| Inline/dispatch consistency | PASS | Consistent: SKILL.md is complete self-contained inline skill, not a routing card. |
| Structure | PASS | SKILL.md contains complete step sequence (Step 1–Step 8), constraints, behaviors, defaults, error handling, and precedence rules. Proper density and decision-tree format. |
| Input/output double-spec (A-IS-1) | PASS | Inputs table in SKILL.md clearly defined; outputs specified per step (synthesis template, hash record write). No duplication. |
| Sub-skill input isolation (A-IS-2) | PASS | Skill launches sub-agents via dispatch mechanism; no input parameter accepts sibling skill's output path. Dispatch is isolated. |
| Frontmatter | PASS | Both SKILL.md and uncompressed.md have valid YAML frontmatter with `name` and `description` only. |
| Name matches folder (A-FM-1) | PASS | Both SKILL.md and uncompressed.md: `name: swarm` matches folder name "swarm" exactly. |
| H1 per artifact (A-FM-3) | PASS | SKILL.md: no H1 (first non-frontmatter line is "Usage:..."). uncompressed.md: H1 present ("# swarm — Uncompressed Reference"). Correct per spec. |
| No duplication | PASS | Skill introduces new capability (multi-personality review arena, distinct from code-review). Registry-based personality system is novel. |
| Orphan files (A-FS-1) | PASS | specs/ sub-directory contains 5 files (arbitrator.md, dispatch-integration.md, glossary.md, personality-file.md, registry-format.md). All referenced by spec.md or SKILL.md. reviewers/ directory contains 10 personality files (.md) plus index.yaml; all properly formatted and referenced. No orphans. |
| Missing referenced files (A-FS-2) | PASS | SKILL.md references `specs/arbitrator.md` (exists). uncompressed.md references dispatch, compression, and all specs/*.md (all exist within skill dir or are external skills by name). |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | PASS | Content faithfully preserved. SKILL.md is compressed: Key Terms condensed into single-line defs, Step Sequence condensed into key procedural blocks. uncompressed.md expands with fuller prose, more section headings, and explanatory text. Core procedures, constraints, defaults, and error handling align. No contradictions. Compression parity verified. |
| instructions.txt ↔ instructions.uncompressed.md | N/A | No dispatch instruction files present (inline skill). |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md co-located with skill_dir. Skill is complex (>30 lines); spec is present and required. |
| Required sections | PASS | spec.md contains: Purpose, Scope, Definitions, Requirements, Constraints, Behavior, Defaults and Assumptions, Error Handling, Precedence Rules, Don'ts. All required normative sections present. |
| Normative language | PASS | Requirements section uses "must", "shall", "required" throughout. Enforceable language present. E.g., "The personality registry must be runtime-crawled...", "All dispatched sub-agents must operate in read-only mode...". |
| Internal consistency | PASS | No contradictions detected. Requirements, Constraints, Behavior, Defaults, and Error Handling sections form coherent whole. Precedence Rules section explicitly handles priority conflicts. |
| Spec completeness | PASS | All terms defined in Definitions section with canonical meanings. All behavior explicitly stated in Step Sequence and Behavior sections. Edge cases (empty swarm, partial recovery, diversity) explicitly addressed. |
| Coverage | PASS | Every normative requirement in spec is represented in SKILL.md. E.g., spec Req 7 (rolling window of 3 dispatch) → SKILL.md Step 5 specifies "Maximum concurrency — dispatch up to 3 in parallel". Spec Req 18 (generated personas) → SKILL.md Step 2 and E3. |
| No contradictions | PASS | SKILL.md does not contradict spec. Spec is authoritative; SKILL.md subordinate and faithful. Hash record version bump rules in spec match hash record section in SKILL.md. |
| No unauthorized additions | PASS | SKILL.md introduces no normative requirements absent from spec. New procedural details (e.g., "Personality name lowercased with spaces and apostrophes replaced by hyphens") are implementation notes, not new requirements. |
| Conciseness | PASS | SKILL.md is appropriately dense. Agent can skim step sequence in one pass and know exactly what to do. No rationale or "why" in SKILL.md; all belongs in spec.md. Decision trees and procedural flow are clear. Tables for registry and inputs are appropriate. |
| Completeness | PASS | All runtime instructions present in SKILL.md: step sequence, input/output contracts, constraint enforcement, error handling precedence, cache mechanism, and synthesis template. No implicit assumptions. |
| Breadcrumbs | PASS | References point to `dispatch` skill, `specs/arbitrator.md`. Related section guides to companion artifacts. References are valid and exist. |
| Cost analysis | PASS | Inline skill (not dispatch). But inline complexity warrants sub-specifications (5 specs/ files). Token cost traded for clarity and maintainability — appropriate trade. |
| No dispatch references in instructions | N/A | No instructions.txt file (inline skill). |
| No spec breadcrumbs in runtime | PASS | SKILL.md does not reference spec.md as a pointer or breadcrumb. uncompressed.md does not reference spec.md. spec.md is not exposed in runtime artifacts. |
| Eval log presence (informational) | ABSENT | No eval.txt or eval.uncompressed.md files present. Absence is not a finding per instructions. |
| Description not restated (A-FM-2) | PASS | Frontmatter description: "Multi-personality review infrastructure...Triggers - swarm review...". Body prose does not duplicate this text. Skill introduces term definitions and procedures, not restatement. |
| No exposition in runtime (A-FM-5) | PASS | SKILL.md contains operational steps, constraints, defaults, and error handling. No rationale about why rules exist. uncompressed.md expands procedural sections but does not include "why this design" prose — rationale belongs in spec.md (present there). |
| No non-helpful tags (A-FM-6) | PASS | No bare type labels ("inline", "dispatch", "meta-architectural") in runtime. No filler tags. |
| No empty sections (A-FM-7) | PASS | All headings in SKILL.md, uncompressed.md, spec.md have substantive body or subheadings. No empty leaf sections. |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety blurb present in skill. Not applicable. |
| Iteration-safety pointer form (A-FM-9a) | N/A | No iteration-safety references present. N/A. |
| No verbatim Rule A/B (A-FM-9b) | N/A | No iteration-safety rules to restate. N/A. |
| Cross-reference anti-pattern (A-XR-1) | FAIL | SKILL.md Related section: "`../dispatch/SKILL.md` — agent-launching skill." This is a path with descriptive label but no canonical name. Per A-XR-1 rule, should be: "the `dispatch` skill (`../dispatch/SKILL.md`) — agent-launching skill." uncompressed.md Related section correctly uses canonical names: "`dispatch` — agent-launching skill...". This inconsistency is a violation. |
| Launch-script form (A-FM-10) | N/A | Inline skill. No uncompressed.md launch-script form requirement. N/A. |
| Return shape declared (DS-1) | N/A | Inline skill, not dispatch. N/A. |
| Host card minimalism (DS-2) | N/A | Inline skill, not dispatch. N/A. |
| Description trigger phrases (DS-3) | N/A | Inline skill, not dispatch. N/A. |
| Inline dispatch guard (DS-4) | N/A | Inline skill, not dispatch. N/A. |
| No substrate duplication (DS-5) | N/A | Inline skill, not dispatch. N/A. |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Inline skill, not dispatch. N/A. |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| `swarm/SKILL.md` | Not empty | PASS | File contains 900+ lines of substantial procedural content. |
| `swarm/SKILL.md` | Frontmatter (required) | PASS | YAML frontmatter present with `name: swarm` and `description: Multi-personality review...`. |
| `swarm/SKILL.md` | No abs-path leaks | PASS | Body scanned; no Windows-style (`C:\`, `D:/`) or Unix root-anchored paths (`/Users/`, `/home/`, `/d/`) detected. |
| `swarm/uncompressed.md` | Not empty | PASS | File contains 600+ lines of detailed procedural content. |
| `swarm/uncompressed.md` | Frontmatter (required) | PASS | YAML frontmatter present with `name: swarm` and `description: Multi-personality review...` matching SKILL.md. |
| `swarm/uncompressed.md` | No abs-path leaks | PASS | Body scanned; no absolute paths detected. |
| `swarm/spec.md` | Not empty | PASS | File contains 500+ lines of specification content. |
| `swarm/spec.md` | Frontmatter (required for .spec.md) | N/A | spec.md is NOT a `.spec.md` file (does not match `*.spec.md` pattern — it is named `spec.md` not `something.spec.md`). No frontmatter required. |
| `swarm/spec.md` | No abs-path leaks | PASS | Body scanned; no absolute paths detected. |
| `swarm/spec.md` | Purpose section | PASS | Present: "## Purpose" at line 3. |
| `swarm/spec.md` | Parameters section | PASS | Present: "## Inputs" section at line 76 covers parameters. |
| `swarm/spec.md` | Output section | PASS | Present: "## Step Sequence" and "## Behavior" define output (synthesis template, error handling). Detailed in Step 8 subsection. |

### Issues

1. **A-XR-1 Cross-reference anti-pattern — HIGH**: SKILL.md Related section contains `../dispatch/SKILL.md` as a path-first reference with no canonical name. Per A-XR-1, cross-skill references must use canonical names as the primary identifier. Current: "Related: `../dispatch/SKILL.md` — agent-launching skill." Fix: "Related: the `dispatch` skill (`../dispatch/SKILL.md`) — agent-launching skill."

### Recommendation

Update SKILL.md Related section to use canonical skill name (`dispatch`) as primary reference, with path as optional pointer. This aligns cross-references across SKILL.md and uncompressed.md, both of which reference the same external skills.
