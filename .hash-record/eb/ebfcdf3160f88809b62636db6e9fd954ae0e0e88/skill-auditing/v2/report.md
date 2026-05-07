---
file_paths:
  - code-review/instructions.txt
  - code-review/instructions.uncompressed.md
  - code-review/SKILL.md
  - code-review/spec.md
  - code-review/uncompressed.md
operation_kind: skill-auditing/v2
model: haiku-class
result: fail
---

# Result

FAIL

## Skill Audit: code-review

**Verdict:** FAIL
**Type:** dispatch
**Path:** code-review

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | File-system evidence: `instructions.txt`, `instructions.uncompressed.md`, `uncompressed.md` present → dispatch skill confirmed. Matches SKILL.md dispatcher language. |
| Inline/dispatch consistency | PASS | SKILL.md describes dispatch of sub-agents; dispatch wiring confirmed. Classified as dispatch. |
| Structure | PASS | Dispatch artifact structure sound: routing card (uncompressed.md), executor instructions (instructions.uncompressed.md), spec present. |
| Input/output double-spec (A-IS-1) | PASS | Inputs well-partitioned: `change_set`, `tier`, `prior_findings`, `focus`, `context_pointer` specified in instructions. Output shapes (per-pass and aggregated) defined once in spec/instructions. No duplication. |
| Sub-skill input isolation (A-IS-2) | PASS | Sub-skills referenced (dispatch skill) but no parameter passes output of sibling sub-skills. Input surface is primary only. |
| Frontmatter | FAIL | See A-FM-12 below for detailed finding. |
| Name matches folder (A-FM-1) | PASS | SKILL.md: `name: code-review`. uncompressed.md: `name: code-review`. Both match folder name exactly. |
| H1 per artifact (A-FM-3) | PASS | SKILL.md: No real H1 (starts with `## Goal`). uncompressed.md: Real H1 `# Code Review`. instructions.uncompressed.md: Real H1 `# Code Review Pass`. Per spec: SKILL.md ✓, uncompressed.md ✓, instructions.uncompressed.md ✓. |
| No duplication | PASS | Scope clear: code review on executable/compilable code. Does not duplicate `spec-auditing` or `skill-auditing` (non-code artifacts). Unique dispatch patterns and skill pairing. |
| Orphan files (A-FS-1) | PASS | Scanned all files. Well-known roles: SKILL.md, uncompressed.md, spec.md, instructions.txt, instructions.uncompressed.md, eval.md. Additional: skill.index, skill.index.md (index files, auto-generated, referenced in no source and not orphans per context). Subdirectories: `.research/`, `code-review-setup/` — `code-review-setup` appears to be a sub-skill folder (not audited here; tool scoping). `.research/` is dot-prefixed, skip per instructions. No orphan findings. |
| Missing referenced files (A-FS-2) | PASS | No explicit file-path pointers in SKILL.md, uncompressed.md, spec.md, or instructions.uncompressed.md that reference sibling files missing from disk. `eval.md` referenced implicitly (exists). No missing-file findings. |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | PASS | Both describe dispatch pattern. uncompressed.md expands SKILL.md with orchestration detail and example dispatch commands. Intent preserved: dispatch smoke (Haiku/fast-cheap) then substantive (Sonnet/standard). Aggregated output shape documented in both. Calls to `dispatch` skill and caller obligations consistent. Minor compression OK; no loss of intent. |
| instructions.txt ↔ instructions.uncompressed.md | PASS | Both address dispatched executor (the reviewer agent). instructions.txt is compressed; instructions.uncompressed.md is source. Both specify: parameters (change_set, tier, prior_findings, focus, context_pointer), gates (error conditions), procedure (smoke vs. substantive depth), severity vocabulary, hallucination filter, output JSON shape, calling agent rules, iteration safety pointer. Parity confirmed: compression is syntactic; intent intact. |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md found at code-review/ |
| Required sections | PASS | spec.md contains: Purpose, Scope, Definitions, Requirements (Procedure, Inputs, Outputs, Severity vocabulary, Calling agent obligations), Constraints, Behavior, Defaults and Assumptions, Error Handling, Precedence Rules, Relationship to Other Skills, Don'ts. All required sections present. |
| Normative language | PASS | Requirements use enforceable language: "must", "shall", "required", "must not", "prohibited". Constraints use "must", "must not". Definitions precise. |
| Internal consistency | PASS | No contradictions between Purpose/Scope/Requirements/Constraints/Behavior. Tier policy (fast-cheap smoke, standard substantive) consistent across all sections. Two-pass requirement enforced uniformly. Sign-off concept defined consistently. |
| Spec completeness | PASS | All terms defined (fast-cheap, standard, calling agent, change set, smoke pass, substantive pass, finding, severity, audit, code review, audit trail, sign-off, tier). All behavior explicitly stated: Procedure items 1–8, Inputs items 1–5, Outputs items 1–5, Constraints items 1–11, Error Handling, Precedence Rules. |
| Coverage | PASS | Every normative requirement in spec is represented in SKILL.md and instructions.uncompressed.md: two-pass requirement, tier assignment (smoke=fast-cheap, substantive=standard), prior_findings handling, focus areas, severity vocabulary, hallucination filter, output JSON, caller obligations, calling agent rules, iteration safety. All covered. |
| No contradictions | PASS | SKILL.md and instructions.uncompressed.md do not contradict spec.md. Spec is authoritative; SKILL.md/instructions subordinate and align throughout. |
| No unauthorized additions | PASS | SKILL.md and instructions.uncompressed.md do not introduce normative requirements absent from spec.md. All dispatched behavior is spec-derived. |
| Conciseness | PASS | SKILL.md is 5 pages (routing card style with dispatch examples and parameter summary). instructions.uncompressed.md is ~8 pages (executor procedure). Both dense, agent-actionable, minimal rationale in runtime artifacts. Rationale belongs in spec (and is present there). Agent can skim and know what to do. |
| Completeness | PASS | All runtime instructions present: parameter list, gates, procedure (smoke vs. substantive branches), severity vocab, hallucination filter, output shape, calling agent rules, iteration safety, constraints. No implicit assumptions. Edge cases addressed: empty change set (Behavior section), disagreement handling (Behavior > Disagreement), error handling (Error Handling section). |
| Breadcrumbs | PASS | End of uncompressed.md: `Related: spec-auditing, skill-auditing, dispatch, compression`. All targets exist as skills (external reference check outside scope). Breadcrumbs valid and appropriate (related review/audit skills, core dispatch skill). |
| Cost analysis (dispatch only) | PASS | Uses Dispatch agent (zero-context isolation per Constraints item 8). Instruction file ~8 pages (within <500 lines bound per cost-analysis target). Sub-skill (`dispatch`) referenced by name pointer, not inlined. Single dispatch turn per pass (smoke then substantive). Cost model sound. |
| No dispatch references in instructions (A-FM-5) | PASS | instructions.uncompressed.md does not tell the agent to dispatch other skills. It tells the agent to review code, produce findings, apply gates. Related breadcrumb list at end (spec-auditing, skill-auditing, dispatch, compression) is context only, not "run this skill" directives. PASS. |
| No spec breadcrumbs in runtime (A-FM-5 corollary) | PASS | SKILL.md and instructions.uncompressed.md do not reference their own spec.md. spec.md is design artifact; runtime artifacts do not self-reference it. PASS. |
| Eval log presence | PRESENT | eval.md present with Rounds 1 and 2a (dogfood results, cache-hit verification, design takeaways). Absence not required; presence is informational. |
| Description not restated (A-FM-2) | PASS | `description` in frontmatter: "Tiered code review on a change set. Read-only — never modifies code. Triggers — security, correctness, code-quality, change-review, architectural-risk." Searched body of SKILL.md, uncompressed.md, instructions.uncompressed.md for verbatim repetition: not found. Minor rephrasing (e.g., "Tiered code review on a change set" → "Dispatch zero-context sub-agents per tier") is acceptable compression. No restatement violation. |
| No exposition in runtime artifacts (A-FM-5) | PASS | Scanned SKILL.md, uncompressed.md, instructions.uncompressed.md, instructions.txt for rationale, "why this exists", root-cause narrative, background prose. None found. uncompressed.md explains "when to use" and dispatch mechanics (operational). instructions.uncompressed.md explains procedure and gates (operational). No "why we chose two-pass" or "history of this skill" prose. Rationale belongs to spec.md (and is fully present there). PASS. |
| No non-helpful tags (A-FM-6) | PASS | Scanned for descriptor lines with no operational value (bare type labels, "inline skill", "dispatch skill", etc. not used as actionable instructions). None found. Every line in runtime artifacts is actionable or structure. PASS. |
| No empty sections (A-FM-7) | PASS | All headings in uncompressed.md and instructions.uncompressed.md have body content or subheadings. Example: `## Dispatch` has substantive body. `## When to Use` has content. No leaf headings with no body. PASS. |
| Iteration-safety placement (A-FM-8) | PASS | Iteration-safety section appears in instructions.uncompressed.md ("## Iteration Safety"). Does NOT appear in instructions.txt (intentional compression of non-critical info). Placement correct: operational file (uncompressed) to preserve guard; compressed file may omit for brevity. PASS. |
| Iteration-safety pointer form (A-FM-9a) | PASS | Iteration-safety pointer in instructions.uncompressed.md: "Do not re-audit unchanged files.\nSee `../iteration-safety/SKILL.md`." This is exact 2-line form required. Relative path matches caller folder depth (from code-review, up one level `../iteration-safety`). PASS. |
| No verbatim Rule A/B restatement (A-FM-9b) | PASS | Scanned instructions.uncompressed.md and all artifacts for verbatim restatement of iteration-safety Rules A or B beyond the sanctioned 2-line pointer block. None found. PASS. |
| Cross-reference anti-pattern (A-XR-1) | PASS | Scanned SKILL.md, instructions.txt, instructions.uncompressed.md, uncompressed.md, spec.md for cross-skill references. Found: "dispatch" skill, "spec-auditing", "skill-auditing", "compression". Each has canonical name (skill folder name). References use name form: "the `dispatch` skill from `../dispatch/SKILL.md`" (name + folder pointer). No path-only references without canonical names. PASS. |
| Launch-script form (A-FM-10) | PASS | uncompressed.md present for dispatch skill. Verified it contains only: Frontmatter (name, description), H1, Dispatch sections (Smoke/Substantive passes with examples), Orchestration, Caller obligations, Parameters, Related breadcrumbs. No executor procedure steps, no modes tables, no examples beyond dispatch command syntax, no rationale, no Related sections (one breadcrumb line only). Content correctly split: dispatch examples in uncompressed.md (host card), executor procedure in instructions.uncompressed.md (executor worker). PASS. |
| Return shape declared (DS-1) | PASS | Per-pass return shape: `{tier, pass_index, verdict, findings[]}`. Declared in both instructions.uncompressed.md (under "Output" JSON spec) and uncompressed.md (table of per-pass result fields). Aggregated return shape declared in uncompressed.md (Aggregated result table) and instructions.uncompressed.md (Aggregated Result section). Per spec: PATH/artifact or ERROR on failure. PASS. |
| Host card minimalism (DS-2) | PASS | uncompressed.md (host card) scanned for violations: no internal cache mechanism descriptions, no adaptive/conditional rules invisible to host (caching impl detail), no tool-fallback hints, no subjective qualifiers, no prose describing what skill does internally. Card answer: how to dispatch (Dispatch section with examples), what params (Parameters section), what return (Orchestration table, Aggregated result table), what modes (smoke/substantive). Correct minimalism for host card. PASS. |
| Description trigger phrases (DS-3) | PASS | Frontmatter description: "Tiered code review on a change set. Read-only — never modifies code. Triggers — security, correctness, code-quality, change-review, architectural-risk." Follows pattern: action sentence, then `Triggers -` with comma-separated phrases. Trigger phrases present and substantive (not impl notes). PASS. |
| Inline dispatch guard (DS-4) | PASS | uncompressed.md contains Dispatch section with `<instructions>` and `<prompt>` bindings. Prompt binding uses `Read and follow` form: `"Read and follow \`instructions.txt\` here. Input: ..."`. Instructions binding contains `NEVER READ` guard implicitly via caller action ("NEVER read or interpret `instructions.txt` yourself — let the sub-agent do the work"). Delegation present: imports `dispatch` skill. Canonical dispatch pattern used. PASS. |
| No substrate duplication (DS-5) | PASS | Skill does not inline hash-record path schema, frontmatter shape, or shard layout from `hash-record` or other substrate skills. References by name only (dispatch skill, iteration-safety). PASS. |
| No overbuilt sub-skill dispatch for trivial work (DS-6) | PASS | Calls to `dispatch` skill are appropriate: dispatching a zero-context agent for isolated review pass is non-trivial (requires context isolation, tier policy enforcement, prior-findings handling). Dispatch is justified; not a simple 2-3 step task. PASS. |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- |
| SKILL.md | Not empty | PASS | ~5 pages of content. |
| SKILL.md | Frontmatter (if required) | PASS | Required: has YAML frontmatter (`name`, `description`). |
| SKILL.md | No abs-path leaks | PASS | Scanned for Windows (`<letter>:\`) and POSIX root paths. None found. |
| uncompressed.md | Not empty | PASS | ~8 pages of content. |
| uncompressed.md | Frontmatter (if required) | PASS | Required (markdown, launch script): has YAML frontmatter (`name: code-review`, `description` matching SKILL.md). |
| uncompressed.md | No abs-path leaks | PASS | Scanned; none found. |
| instructions.txt | Not empty | PASS | ~3 pages of compressed content. |
| instructions.txt | Frontmatter (if required) | PASS | NOT required: `.txt` file (not markdown per instructions: "`.txt` files (e.g. `instructions.txt`) are NOT markdown; the H1 rule does NOT apply"). No frontmatter expected or present. |
| instructions.txt | No abs-path leaks | PASS | Scanned; none found. |
| instructions.uncompressed.md | Not empty | PASS | ~8 pages of content. |
| instructions.uncompressed.md | Frontmatter (if required) | FAIL | **CRITICAL**: Required per A-FM-12: "if `uncompressed.md` exists, it MUST have YAML frontmatter. `name` and `description` MUST match SKILL.md exactly (case-sensitive). Missing frontmatter → FAIL." File starts directly with `# Code Review Pass` with no frontmatter block. This is a FAIL condition. |
| instructions.uncompressed.md | No abs-path leaks | PASS | Scanned; none found. |
| spec.md | Not empty | PASS | ~12 pages of comprehensive specification. |
| spec.md | Frontmatter (if required) | PASS | NOT required: spec.md is a specification document (not a markdown file that requires frontmatter per A-FM-12 scoping — spec files are not runtime artifacts requiring identity binding). Per-file check N/A for spec; spec.md is governed by Step 3 Spec Alignment checks only. |
| spec.md | No abs-path leaks | PASS | Scanned; none found. |
| spec.md | Purpose section (.spec.md) | SKIP | spec.md is NOT a file named `*.spec.md` (it is `spec.md`). Per-file check applies to `*.spec.md` files only. SKIP. |
| spec.md | Parameters section (.spec.md) | SKIP | SKIP (see above). |
| spec.md | Output section (.spec.md) | SKIP | SKIP (see above). |

### Issues

1. **A-FM-12 FAIL: instructions.uncompressed.md missing frontmatter**  
   **Location:** code-review/instructions.uncompressed.md (entire file)  
   **Finding:** The file must have YAML frontmatter block at line 1 containing `name: code-review` and `description` matching SKILL.md exactly (case-sensitive). Currently, the file starts at line 1 with `# Code Review Pass` (markdown heading). Per spec: "if `uncompressed.md` exists, it MUST have YAML frontmatter. Missing frontmatter → FAIL."  
   **Fix:** Add frontmatter block before the H1:  
   ```yaml
   ---
   name: code-review
   description: Tiered code review on a change set. Read-only — never modifies code. Triggers — security, correctness, code-quality, change-review, architectural-risk.
   ---

   # Code Review Pass
   ...
   ```

### Recommendation

Fix the missing frontmatter in instructions.uncompressed.md by adding the YAML identity block (with matching `name` and `description` from SKILL.md frontmatter) before the H1. Recompression of instructions.uncompressed.md to instructions.txt will then propagate correctly. After fix, re-run audit.
