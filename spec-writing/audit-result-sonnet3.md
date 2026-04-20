## Skill Audit: spec-writing

**Verdict:** NEEDS_REVISION
**Type:** inline
**Path:** D:/Users/essence/Development/cortex.lan/.agents/skills/electrified-cortex/.worktrees/15-769/spec-writing/SKILL.md
**Failed phase:** none

### Phase 1 — Spec Gate

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present and readable |
| Required sections | PASS | All 10 required sections present: Purpose, Scope, Definitions, Requirements, Constraints, Behavior, Defaults and Assumptions, Error Handling, Precedence Rules, Don'ts |
| Normative language | PASS | Requirements use must/shall/required/must not throughout; normative intent is clear |
| Internal consistency | PASS | No contradictions between sections; no duplicate rules; normative content is not introduced in descriptive sections |
| Completeness | PASS | All terms defined in Definitions; all behavior-affecting statements appear in normative sections |

### Phase 2 — Skill Smoke Check

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Spec writing requires contextual judgment; not mechanically dispatchable from inputs alone; inline is correct |
| Inline/dispatch consistency | PASS | No instructions.txt or separate instruction file found; SKILL.md contains full procedure — correctly inline |
| Structure | PASS | Frontmatter present; full procedure embedded; self-contained; 79 lines appropriate for inline |
| Frontmatter | PASS | name=spec-writing; description present, accurate, and matches behavior |
| No duplication | PASS | spec-auditing is a separate skill; no capability overlap |

### Phase 3 — Spec Compliance

| Check | Result | Notes |
| --- | --- | --- |
| Coverage | NEEDS_REVISION | Negative scope exclusions from spec (non-spec docs, auditing, retroactive application) omitted in SKILL.md; Output Quality Criteria (5 explicit criteria) not represented as a distinct block; see Issues |
| No contradictions | PASS | SKILL.md does not contradict spec on any normative point |
| No unauthorized additions | PASS | No normative requirements in SKILL.md without a source in spec |
| Conciseness | PASS | All lines affect runtime behavior; no rationale padding; appropriately dense for inline skill |
| Completeness | PASS | All workflow steps present; Haiku-first/Sonnet-final derivation workflow captured; markdown-hygiene dispatch included |
| Breadcrumbs | PASS | Related skills listed at end: spec-auditing, skill-writing, skill-auditing, markdown-hygiene — all confirmed to exist |
| Cost analysis | N/A | Inline skill; no dispatch cost analysis required |
| Markdown hygiene | FAIL | spec.md: 9 MD013 line-length errors; uncompressed.md: 17 MD013 line-length errors (compressed SKILL.md exempt per rules) |
| No dispatch refs | N/A | No instructions.txt; dispatch refs in SKILL.md itself are acceptable (host agent context) |

### Issues

1. **Negative scope omitted (Coverage — non-critical).**
   The spec's Scope section explicitly states this skill does NOT apply to non-specification documents, auditing specs, or retroactive application without re-audit. SKILL.md compresses scope to "when writing spec or derived target doc" only. The exclusions are normative (they prohibit misuse) and must be present.
   Fix: Add explicit negative scope to SKILL.md Scope line, e.g.: "Not for: non-spec docs (design notes, ADRs, READMEs), auditing (see spec-auditing), or retroactive application without re-audit."

2. **Output Quality Criteria not represented (Coverage — non-critical).**
   The spec (lines 338-345) states a spec is acceptable only if: all requirements testable, no critical ambiguity, terminology stable, no contradictions, no unauthorized scope expansion. These 5 acceptance criteria are normative (uses "only if") and define a distinct validation gate. SKILL.md omits this gate entirely.
   Fix: Add an "Accept only if:" block after the Validate step in the Behavior section or inline after the self-validation content.

3. **Markdown hygiene failures (Phase 3 Check 8 — critical for spec.md and uncompressed.md).**
   `npx markdownlint-cli2 spec.md uncompressed.md` reports 26 total MD013 line-length errors: 9 in spec.md, 17 in uncompressed.md. Per rules, compressed files (SKILL.md, instructions.txt) are exempt, but spec.md and uncompressed.md are not.
   Notable violations:
   - spec.md:5 — 168 chars (intro paragraph)
   - spec.md:244 — 242 chars (Footguns section)
   - uncompressed.md:41 — 379 chars (Requirements prose block)
   - uncompressed.md:88 — 242 chars (Behavior block)
   - uncompressed.md:110 — 300 chars (Precedence block)
   Fix: Run `markdown-hygiene` dispatch on spec.md and uncompressed.md; wrap long lines at 80 chars.

### Recommendation

Address 3 non-critical issues: add negative scope exclusions to SKILL.md, add the "Accept only if" acceptance gate, and fix MD013 line-length errors in spec.md and uncompressed.md via `markdown-hygiene` dispatch.
