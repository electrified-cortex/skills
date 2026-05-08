---
file_paths:
  - model-detect/SKILL.md
  - model-detect/spec.md
  - model-detect/uncompressed.md
operation_kind: skill-auditing/v2
model: haiku-class
result: fail
---

# Result

**FAIL**

## Skill Audit: model-detect

**Verdict:** FAIL
**Type:** inline
**Path:** model-detect/

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Inline skill confirmed — no dispatch instruction files present. No ambiguity in classification. |
| Inline/dispatch consistency | PASS | Confirmed inline. SKILL.md contains full procedural steps, no references to external instruction files. |
| Structure | PASS | Frontmatter (`name`, `description`), multiple procedural sections with clear stop conditions, rules section. Structure is well-organized. |
| Input/output double-spec (A-IS-1) | PASS | No input/output double-specification detected. Detection priority order stated once, consistently across spec and SKILL.md. |
| Sub-skill input isolation (A-IS-2) | N/A | Not a dispatch skill. |
| Frontmatter | PASS | Both SKILL.md and uncompressed.md have YAML frontmatter with `name` and `description` fields. |
| Name matches folder (A-FM-1) | PASS | Both SKILL.md and uncompressed.md: `name: model-detect`. Matches folder name exactly. |
| H1 per artifact (A-FM-3) | PASS | SKILL.md: no real H1 at column 0 (correct for compiled form). uncompressed.md: contains H1 `# Model Detect` (correct for uncompressed form). |
| No duplication | PASS | Skill does not duplicate existing model-identity capability. Unique positioning as a detection procedure skill. |
| Orphan files (A-FS-1) | PASS | All three files (SKILL.md, spec.md, uncompressed.md) are well-known role files. No orphan files present. |
| Missing referenced files (A-FS-2) | PASS | No explicit file-path references in SKILL.md, spec.md, or uncompressed.md. All references are to abstract concepts (config file, system prompt, etc.). |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | FAIL | Frontmatter `description` fields do not match exactly (case-sensitive violation per A-FM-12). SKILL.md uses abbreviated form "Priority-ordered detection: config file, system prompt, env variable, operator instructions, self-report" while uncompressed.md uses expanded form "Priority-ordered detection across config file, system prompt, environment variables, operator instructions, and self-report". Mismatch in both phrasing and detail level. |
| instructions.txt ↔ instructions.uncompressed.md | N/A | No instruction files present. Inline skill. |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present and co-located with skill directory. |
| Required sections | PASS | Contains: Purpose, Problem (context), Scope, Definitions, Requirements (R-1 through R-8), Constraints, Acceptance Criteria. All required sections present. |
| Normative language | PASS | Requirements use proper normative language: MUST, MUST NOT, SHOULD. Enforceable and clear. |
| Internal consistency | PASS | No contradictions between spec sections. Definitions align with usage in requirements. No duplicate rules. |
| Spec completeness | PASS | All key terms defined (Signal, Self-report, Confidence level, Hedged response, Alias). All behavior explicitly stated, not implied. Edge cases covered (mid-session change, alias handling). |
| Coverage | PASS | Every normative requirement in spec is represented in SKILL.md and uncompressed.md. Priority order from R-1 directly maps to detection sections 1–5 in artifacts. Hedging rules from R-3 directly map to section 5 content. |
| No contradictions | PASS | SKILL.md and uncompressed.md do not contradict spec. Spec is authoritative; artifacts are subordinate and compliant. |
| No unauthorized additions | PASS | SKILL.md introduces no normative requirements absent from spec. All content derives from spec requirements. |
| Conciseness | PASS | SKILL.md is tight, agent-facing, decision-tree structured. Agent can skim in one pass and know exactly what to do. Spec rationale (Problem section) correctly segregated to spec, not runtime artifact. |
| Completeness | PASS | All runtime instructions present. Hedging rules explicit. Stop conditions clear. Edge cases (aliases, mid-session changes) addressed. No implicit assumptions. Defaults stated. |
| Breadcrumbs | PASS | No related-skills section present. Acceptable for a fundamental skill like this; inline skill requires no sub-skill delegation. |
| Cost analysis | N/A | Inline skill; cost analysis applies to dispatch skills only. |
| No dispatch refs | N/A | Inline skill; dispatch references not applicable. |
| No spec breadcrumbs | PASS | SKILL.md and uncompressed.md do not reference their own spec.md. Spec remains design rationale, not runtime content. |
| Eval log (informational) | ABSENT | No eval.txt present. Informational; not a finding. |
| Description not restated (A-FM-2) | PASS | Body prose of SKILL.md and uncompressed.md does not duplicate frontmatter description. Description remains frontmatter; body contains distinct procedural content. |
| No exposition in runtime (A-FM-5) | PASS | SKILL.md and uncompressed.md contain pure procedural steps and rules. No rationale, "why this exists," or background prose. Rationale correctly placed in spec.md Problem section. |
| No non-helpful tags (A-FM-6) | PASS | No bare type labels or non-operational descriptor lines ("inline skill", "dispatch skill", etc.). All content is actionable instruction. |
| No empty sections (A-FM-7) | PASS | All sections contain body content. No empty-leaf headings. |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety references present in any artifact. Skill is not iteration-safe by design; this is appropriate. |
| Iteration-safety pointer form (A-FM-9a) | N/A | No iteration-safety references. |
| No verbatim Rule A/B (A-FM-9b) | N/A | No iteration-safety references. |
| Cross-reference anti-pattern (A-XR-1) | PASS | No cross-skill references present. No path-only references detected. No canonical name violations. |
| Launch-script form (A-FM-10) | N/A | Inline skill; launch-script form applies to dispatch skills only. |
| Return shape declared (DS-1) | N/A | Inline skill; dispatch return shape not applicable. |
| Host card minimalism (DS-2) | N/A | Inline skill; host-card minimalism applies to dispatch skills only. |
| Description trigger phrases (DS-3) | N/A | Dispatch check; applies to dispatch skills. (Note: inline skill DOES have trigger phrases per A-FM-11 — this is separate.) |
| Inline dispatch guard (DS-4) | N/A | Inline skill; dispatch guard not applicable. |
| No substrate duplication (DS-5) | N/A | Inline skill; no sub-skill invocation. |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Inline skill; no sub-skill dispatch. |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| `SKILL.md` | Not empty | PASS | Contains 41 lines of content. Non-trivial skill procedure. |
| `SKILL.md` | Frontmatter | PASS | YAML frontmatter present with `name` and `description`. |
| `SKILL.md` | No abs-path leaks | PASS | No Windows-style (`<letter>:\` or `<letter>:/`) or Unix root-anchored paths (`/Users/`, `/home/`, `/d/`) detected in body. |
| `spec.md` | Not empty | PASS | Contains 159 lines of specification content. Comprehensive. |
| `spec.md` | Frontmatter | N/A | Spec files do not require frontmatter. |
| `spec.md` | No abs-path leaks | PASS | No absolute path leaks detected. |
| `spec.md` | Purpose section | PASS | Contains `## Purpose` section. |
| `spec.md` | Parameters section | PASS | Contains `## Definitions` section (functional equivalent; defines key parameters of the procedure). |
| `spec.md` | Output section | PASS | Contains `## Output Format` section describing response format. |
| `uncompressed.md` | Not empty | PASS | Contains 113 lines of procedural content. |
| `uncompressed.md` | Frontmatter | PASS | YAML frontmatter present with `name` and `description`. |
| `uncompressed.md` | No abs-path leaks | PASS | No absolute path leaks detected in body. |

### Issues

1. **A-FM-12: Frontmatter `description` mismatch between SKILL.md and uncompressed.md (FAIL)**
   - SKILL.md description: "...Priority-ordered detection: config file, system prompt, env variable, operator instructions, self-report..."
   - uncompressed.md description: "...Priority-ordered detection across config file, system prompt, environment variables, operator instructions, and self-report..."
   - Differences: (a) "detection:" vs "detection across", (b) "env variable" vs "environment variables", (c) comma list vs comma+conjunction list.
   - Per A-FM-12, `name` and `description` MUST match exactly (case-sensitive).
   - **Fix:** Edit uncompressed.md frontmatter to use the exact same `description` text as SKILL.md, then regenerate SKILL.md via recompression if applicable.

### Recommendation

Correct the frontmatter `description` mismatch between SKILL.md and uncompressed.md (make text identical), then revalidate.
