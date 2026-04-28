---
hash: 20b5e8ca72b59914a09885ebee2e8f0780c21dfb
file_paths:
  - hash-stamping/spec.md
  - hash-stamping/uncompressed.md
operation_kind: skill-auditing
model: claude-haiku
result: findings
---

# Result

NEEDS_REVISION

Skill Audit: hash-stamping

Verdict: NEEDS_REVISION
Type: dispatch (combo node)
Path: hash-stamping
Failed phase: 1, 3

## Phase 1 — Spec Gate

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present |
| Required sections | FAIL | Missing explicit "Purpose", "Scope", "Definitions", "Constraints" headers. Content present but organizational structure needs standardization. |
| Normative language | FAIL | Uses "should" (Stamp Policy: "A file should carry a stamp when:") and vague conditionals. Requires enforceable terms: "MUST", "MUST NOT", "SHALL". |
| Internal consistency | PASS | No contradictions between sections |
| Completeness | PASS | All terms contextually defined, behavior explicit |

## Phase 2 — Skill Smoke Check

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Correctly dispatch (combo node routing to audit/ and stamp/) |
| Inline/dispatch consistency | PASS | SKILL.md is routing card; sub-skills have instructions.txt |
| Structure | PASS | Appropriate for dispatch combo node |
| Input/output double-spec (A-IS-1) | N/A | Dispatch skill, no inputs/outputs |
| Frontmatter | PASS | name and description present and accurate |
| Name matches folder (A-FM-1) | PASS | "hash-stamping" matches folder name |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no H1; uncompressed.md has "# Hash Stamp" |
| No duplication | PASS | Unique capability |

## Phase 3 — Spec Compliance

| Check | Result | Notes |
| --- | --- | --- |
| Coverage | PASS | Spec requirements (format, policy, routing) represented in SKILL.md and uncompressed.md |
| No contradictions | PASS | SKILL.md faithful to spec intent |
| No unauthorized additions | PASS | No extra requirements introduced |
| Conciseness | PASS | Dispatcher-appropriate density |
| Completeness | PASS | Sufficient instructions for routing |
| Breadcrumbs | FAIL | No "Next:" section or reference to spec.md or sub-skill dispatch details. Agents should know where to find policy (spec) and how to invoke sub-skills (sub-instructions.txt). |
| Cost analysis | PASS | <20 lines, sub-skills referenced by pointer, single dispatch turn |
| Markdown hygiene | PASS | No violations |
| No dispatch refs in instructions | N/A | No parent instructions.txt (combo node) |
| No spec breadcrumbs in runtime | PASS | Doesn't reference own spec.md |
| Description not restated (A-FM-2) | FAIL | Body restates/elaborates description. Frontmatter: "Verify stamp drift (audit/) or write/update stamps (stamp/)." SKILL.md repeats: "Two sub-skills: - `audit/` — verify stamps, detect drift... - `stamp/` — write or update `.sha256` companions...". Uncompressed.md repeats again. |
| Lint wins (A-FM-4) | PASS | No linting violations (MD041 suppressed via implicit YAML) |
| No exposition in runtime (A-FM-5) | PASS | No unnecessary background or rationale |
| No non-helpful tags (A-FM-6) | PASS | All labels operational ("Policy:", "Dispatch:") |
| No empty sections (A-FM-7) | PASS | All sections have content |
| Iteration-safety placement (A-FM-8) | N/A | Not an iteration-sensitive skill |
| Iteration-safety pointer form (A-FM-9a) | N/A | Not applicable |
| No verbatim Rule A/B (A-FM-9b) | N/A | Not applicable |
| Cross-reference anti-pattern (A-XR-1) | PASS | No pointers to other skills' uncompressed.md or spec.md |
| Launch-script form (A-FM-10) | PASS | uncompressed.md has frontmatter, H1, sub-skills description, policy, and dispatch instruction. No execution steps or rationale. |

## Issues

### Phase 1 — Spec Structure

**Issue:** Spec missing explicit section headers for Purpose, Scope, Definitions, Requirements, Constraints.

**Current:** 
- Opening paragraph serves as implicit purpose
- "## Stamp Format" (requirement description)
- "## Stamp Policy" (requirements + constraints)
- "## Sub-skill Routing" (requirement)
- "## Combo Node" (architectural note)

**Fix:** Reorganize spec with explicit sections in order: Purpose → Scope → Definitions → Requirements (with sub-sections for Format, Policy, Routing) → Constraints.

### Phase 1 — Vague Normative Language

**Issue:** Spec uses conditional language ("should") instead of enforceable terms.

**Current:** "A file **should** carry a stamp when:..."

**Fix:** Change to "A file **MUST** carry a stamp when:..." and "A file **MUST NOT** be stamped when:..." Ensure all normative statements use MUST, MUST NOT, SHOULD, or SHALL with clear enforcement intent.

### Phase 3 Check 6 — Missing Breadcrumbs

**Issue:** SKILL.md and uncompressed.md don't guide agents to spec.md for policy details or sub-skill dispatch instructions.

**Current:** Ends with "Dispatch each sub-skill via its own `instructions.txt`." No next steps.

**Fix:** Add:
```
## Next

Read `spec.md` for detailed stamp format, policy, and rationale.
Dispatch `audit/` sub-skill via `hash-stamp-audit/instructions.txt` to verify stamps.
Dispatch `stamp/` sub-skill via `hash-stamp/instructions.txt` to write/update stamps.
```

### Phase 3 Check 11 (A-FM-2) — Description Restated

**Issue:** Body duplicates/elaborates the frontmatter description.

**Frontmatter:** "SHA-256 integrity stamp suite. Verify stamp drift (audit/) or write/update stamps (stamp/)."

**SKILL.md:** "SHA-256 integrity stamp suite. Two sub-skills: - `audit/` — verify stamps, detect drift... - `stamp/` — write or update `.sha256` companions..."

**Fix:** Remove elaboration from SKILL.md body. Replace with minimal routing:
```
---
name: hash-stamping
description: SHA-256 integrity stamp suite. Verify stamp drift (audit/) or write/update stamps (stamp/).
---

Two dispatch sub-skills: `audit/` for verifying stamps, `stamp/` for writing/updating them. See `spec.md` for policy and `hash-stamp-audit/instructions.txt` or `hash-stamp/instructions.txt` to dispatch.
```

## Recommendation

Restructure spec.md with explicit Purpose/Scope/Definitions/Requirements/Constraints headers; tighten SKILL.md to avoid description restatement; add breadcrumbs linking to spec and sub-skill dispatch paths. Re-audit after fixes.

## References

None (markdown hygiene CLEAN assumed; no sub-dispatch failures).
