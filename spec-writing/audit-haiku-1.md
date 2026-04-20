## Skill Audit: spec-writing

**Verdict:** FAIL
**Type:** inline
**Path:** D:/Users/essence/Development/cortex.lan/.agents/skills/electrified-cortex/.worktrees/15-769/spec-writing/
**Failed phase:** 1

### Phase 1 — Spec Gate

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present and 361 lines |
| Required sections | FAIL | Critical: spec.md violates its own structural requirements |
| Normative language | FAIL | Multiple vague/weak formulations in normative content |
| Internal consistency | FAIL | Contradictions between stated requirements and spec structure |
| Completeness | FAIL | Scope of spec.md itself undefined; self-referential circular dependency |

### Phase 2 — Skill Smoke Check

| Check | Result | Notes |
| --- | --- | --- |
| Classification | N/A | Phase 1 failed; Phase 2 audit blocked |
| Inline/dispatch consistency | N/A | Phase 1 failed; Phase 2 audit blocked |
| Structure | N/A | Phase 1 failed; Phase 2 audit blocked |
| Frontmatter | N/A | Phase 1 failed; Phase 2 audit blocked |
| No duplication | N/A | Phase 1 failed; Phase 2 audit blocked |

### Phase 3 — Spec Compliance

| Check | Result | Notes |
| --- | --- | --- |
| Coverage | N/A | Phase 1 failed; Phase 3 audit blocked |
| No contradictions | N/A | Phase 1 failed; Phase 3 audit blocked |
| No unauthorized additions | N/A | Phase 1 failed; Phase 3 audit blocked |
| Conciseness | N/A | Phase 1 failed; Phase 3 audit blocked |
| Completeness | N/A | Phase 1 failed; Phase 3 audit blocked |
| Breadcrumbs | N/A | Phase 1 failed; Phase 3 audit blocked |
| Cost analysis | N/A | Phase 1 failed; Phase 3 audit blocked |
| Markdown hygiene | FAIL | spec.md has 10 lint errors (MD013 line length); uncompressed.md has 17 lint errors |
| No dispatch refs | N/A | Phase 1 failed; Phase 3 audit blocked |

### Issues

**1. CRITICAL: Spec violates its own required sections mandate**

The spec.md file defines at lines 198-209 that every spec must contain these top-level sections:
- **Purpose** ✓
- **Scope** ✓
- **Definitions** ✓
- **Requirements** ✓
- **Constraints** ✓
- **Behavior** ✗ (MISSING)
- **Defaults and Assumptions** ✗ (MISSING)
- **Error Handling** ✗ (MISSING)
- **Precedence Rules** ✗ (MISSING)
- **Don'ts** ✗ (MISSING)

The spec.md itself is a specification document (it defines rules, requirements, constraints, and expected behavior per line 5). By its own normative requirements, it must include all required sections. It currently lacks 5 of 10 required top-level sections. This is a fundamental violation — the spec is not self-consistent.

**Fix:** Add missing sections as top-level `##` headers: Behavior, Defaults and Assumptions, Error Handling, Precedence Rules, and Don'ts. Populate with normative requirements currently scattered through other sections or implicit.

**2. CRITICAL: Circular self-reference and undefined scope boundary**

The spec.md applies to "writing a new specification document" and "updating an existing specification document" (line 26-29), but spec.md itself is a specification document. This creates a self-referential requirement: spec.md must conform to spec.md's requirements.

The scope at lines 26-30 does not explicitly state whether the spec applies to itself. Is spec.md:
- A specification governed by itself?
- A meta-specification exempt from its own requirements?
- A template that other specs must follow but need not itself follow?

This ambiguity must be resolved in the spec before it can be audited. The scope section must explicitly state whether spec.md is self-governing.

**Fix:** Add explicit statement to Scope section: "This spec defines requirements for all specification documents, including this spec itself" OR "This spec provides a template; this meta-spec itself is exempt from the required sections mandate" (choose one, make it explicit and testable).

**3. FAIL: Vague normative language in Requirements section**

Line 115-137 (Requirements section) uses weak formulations that fail the "enforceable language" criterion:

- Line 115: "All required behavior must be explicitly stated." — What is "required behavior" vs. optional behavior? Undefined.
- Line 119: "Every requirement must be verifiable." — "Verifiable" by whom, using what criteria? Vague.
- Line 123: "Each requirement must exist in one canonical location." — What defines "canonical"? Who determines this?
- Line 129: "All scope must be explicitly declared." — What does "explicitly" mean operationally? How is explicit vs. implicit tested?
- Line 137: "Clearly distinguish required, prohibited, and optional behavior." — "Clearly" is subjective; who judges clarity? No pass/fail criterion.

Fix: Rewrite each with subject-verb-object form and testable criteria:
- Instead of "All required behavior must be explicitly stated," write "The Requirements section must include a statement for every behavior that affects runtime execution."
- Instead of "Every requirement must be verifiable," write "Every normative statement must include observable pass/fail criteria or must be rewritten."

**4. FAIL: Markdown hygiene violations block audit**

Per instructions line 68: "After writing any spec.md, run `markdown-hygiene` (dispatch) to ensure zero lint errors."

Current state:
- spec.md: 10 errors (all MD013 line-length)
- uncompressed.md: 17 errors (all MD013 line-length)

The auditing instructions state: "Markdown hygiene — all `.md` files in skill folder pass `npx markdownlint-cli2`; zero errors on uncompressed.md, spec.md."

Fix: Run markdownlint and fix all line-length violations to ≤80 characters.

**5. FAIL: Incomplete scope definition**

The spec does not explicitly define:
- Does the spec apply to domain-specific specs that extend this spec?
- Does the spec apply only to skill specs, or also to agent specs, tool specs, and arbitrary domain specs?
- Are there specs that are exempt from this spec?

Per line 38: "Silent scope expansion is prohibited." The spec must be explicit about what types of documents it governs.

Fix: Expand Scope section with explicit inclusions and exclusions (use "This skill applies when:" and "This skill does not apply to:" format from spec.md lines 26-36).

**6. FAIL: Multiple vague terms in normative sections**

- "Testable" (Definition, line 51) defined as "Satisfaction is verifiable from document text alone" — but "verifiable" is circular and vague.
- "Clear" / "Clearly" appears at lines 81, 137, 249 without definition of how clarity is measured.
- "Externally auditable" (line 109) is not defined; what makes something auditable vs. non-auditable?
- "Strictly enforceable" (line 82) — enforceable by whom? Using what enforcement mechanism?

Fix: Add precise definitions with testable criteria for each term used in normative requirements.

**7. FAIL: Contradictory section classification**

Section headers are not marked as Normative/Descriptive/Exploratory/Informational (per Content Modes, line 75-98). This makes it impossible to audit whether behavior-affecting statements are in normative sections or embedded in descriptive prose (which would violate line 37: "Non-normative sections must not introduce hidden requirements").

Example:
- "Final Rule" (line 358-360): Is this normative or informational? The content is clearly normative (defines an invalid spec), but the header doesn't signal content mode.
- "Relationship to Spec Auditor" (line 329-338): Mixes normative ("Assume: every requirement will be challenged") with exploratory/informational tone.

Fix: Add content-mode labels to all section headers: `## Definitions (Normative)`, `## Purpose (Descriptive)`, etc.

### Recommendation

STOP — do not proceed to skill audit until spec.md passes Phase 1. Recommend: (1) add missing 5 required sections, (2) resolve circular self-reference in scope, (3) fix vague normative language, (4) run markdownlint and fix all line-length errors, (5) define all vague terms, (6) mark section content modes explicitly, (7) re-audit until PASS.
