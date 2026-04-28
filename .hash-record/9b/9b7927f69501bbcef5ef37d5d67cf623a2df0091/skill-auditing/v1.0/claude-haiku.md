---
hash: 9b7927f69501bbcef5ef37d5d67cf623a2df0091
file_paths:
  - gh-cli/spec.md
  - gh-cli/uncompressed.md
operation_kind: skill-auditing
model: claude-haiku
result: fail
---

# Result

Skill Audit: gh-cli

Verdict: FAIL
Type: dispatch
gh-cli\SKILL.md
Failed phase: 3

## Phase 1 — Spec Gate

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present and well-formed |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Behavior, Error Handling, Precedence Rules, Constraints all present |
| Normative language | PASS | Uses "must", "shall", "may", "required" correctly; no vague language |
| Internal consistency | PASS | No contradictions; all requirements align with behavior section |
| Completeness | PASS | All terms defined; all behavior explicit and testable |

**Phase 1 Verdict: PASS** — Spec is authoritative and well-formed. Proceed to Phase 2.

## Phase 2 — Skill Smoke Check

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Correctly classified as dispatch (routes to sub-skills) |
| Inline/dispatch consistency | PASS | SKILL.md is routing card; instructions.txt exists; consistent |
| Structure | PASS | Dispatch structure sound: minimal SKILL.md + detailed instructions.txt |
| Input/output (A-IS-1) | PASS | No double-spec violations |
| Frontmatter | PASS | name: "gh-cli"; description accurate |
| Name matches folder (A-FM-1) | PASS | folder "gh-cli" = name "gh-cli" |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no H1 (correct); uncompressed.md has H1 "# GH CLI Router" (correct) |
| No duplication | PASS | No duplicate capabilities |

**Phase 2 Verdict: PASS** — Smoke check passes. Proceed to Phase 3.

## Phase 3 — Spec Compliance Audit

| Check | Result | Notes |
| --- | --- | --- |
| Coverage | PASS | All spec requirements represented in skill |
| No contradictions | PASS | SKILL.md/instructions.txt align with spec |
| No unauthorized additions | PASS | All content is spec-authorized |
| Conciseness | PASS | SKILL.md ~50 lines, instructions.txt ~50 lines; agent-facing density appropriate |
| Skill completeness | PASS | All runtime instructions present; edge cases handled (multi-domain, ambiguous) |
| Breadcrumbs (A-BR-1) | PASS | Related skills listed; all targets exist |
| Cost analysis | PASS | instructions.txt <500 lines; single dispatch viable |
| Markdown hygiene | PASS | No obvious violations; proper tables and formatting |
| No dispatch refs in instructions (A-DI-1) | PASS | No "dispatch X" directives in instructions.txt |
| No spec breadcrumbs (A-SB-1) | PASS | No references to spec.md in runtime |
| Description not restated (A-FM-2) | PASS | Description paraphrased naturally, not verbatim restated |
| Lint wins (A-FM-4) | PASS | Manual markdown check clean |
| No exposition in runtime (A-FM-5) | PASS | No rationale, "why exists," or historical prose |
| No non-helpful tags (A-FM-6) | PASS | No bare type labels or meta-architectural tags |
| No empty sections (A-FM-7) | PASS | All sections have content |
| Iteration-safety placement (A-FM-8) | N/A | Not applicable; doesn't call iteration-safety-dependent skill |
| Iteration-safety pointer form (A-FM-9a) | N/A | Not applicable |
| No verbatim Rule A/B (A-FM-9b) | N/A | Not applicable |
| Cross-reference anti-pattern (A-XR-1) | PASS | Breadcrumbs use skill names only; no cross-file pointers to uncompressed.md or spec.md |
| Launch-script form (A-FM-10) | FAIL | uncompressed.md contains executor steps, behavior tables, and breadcrumbs that violate dispatch launch-script form |

**Phase 3 Verdict: FAIL** — Critical violation of A-FM-10.

## Issues

### A-FM-10: uncompressed.md violates launch-script form (HIGH)

**Issue:** For dispatch skills, `uncompressed.md` must use launch-script form: frontmatter, optional H1, input signature, return contract, optional iteration-safety pointer only.

Current uncompressed.md contains:
- "How It Works" section with 5 executor steps (numbered list)
- Large "Domain Routing" table with behavioral examples
- "PR Sub-skills" section with detailed sub-skill breakdown
- "Rules" section with operational constraints
- "Related" section with breadcrumbs

**Correct pattern (per compression/ skill):**
- Launch-script form in uncompressed.md: brief intro + input/output signature only
- Create instructions.uncompressed.md with: "How It Works" steps, Domain Routing table, PR Sub-skills, Rules
- instructions.txt: compressed version of instructions.uncompressed.md

**Fix required:** Restructure gh-cli skill:
1. Trim uncompressed.md to launch-script form (frontmatter, H1, brief intro, input signature, modes/tiers if applicable, iteration-safety pointer, related)
2. Create instructions.uncompressed.md with: "How It Works" (5 steps), Domain Routing (full table), PR Sub-skills section, Rules section
3. Recompress: compression skill → instructions.txt from instructions.uncompressed.md
4. Recompress: compression skill → SKILL.md from uncompressed.md

## Recommendation

Restructure to follow dispatch launch-script form. Create instructions.uncompressed.md with executor steps and behavioral details moved from uncompressed.md. Re-audit after restructuring.

## References

- **Phase 3 Check 20 (A-FM-10):** Launch-script form violation — uncompressed.md contains executor steps, behavior descriptions, and breadcrumbs beyond minimal signature form
