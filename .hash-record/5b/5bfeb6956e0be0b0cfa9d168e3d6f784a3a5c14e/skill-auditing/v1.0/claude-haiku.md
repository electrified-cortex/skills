---
hash: 5bfeb6956e0be0b0cfa9d168e3d6f784a3a5c14e
file_paths:
  - skill-writing/spec.md
  - skill-writing/uncompressed.md
operation_kind: skill-auditing
model: claude-haiku
result: findings
---

# Result

NEEDS_REVISION

Skill Audit: skill-writing

Verdict: NEEDS_REVISION
Type: inline
Path: skill-writing/SKILL.md
Failed phase: Phase 3

## Phase 1 — Spec Gate

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present and well-formed |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Properly uses must/shall/required throughout |
| Internal consistency | PASS | No contradictions or duplicate rules |
| Completeness | PASS | All terms defined, behavior explicit |

## Phase 2 — Skill Smoke Check

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Correctly classified as inline (requires caller context/judgment) |
| Inline/dispatch consistency | PASS | No instructions.txt present; SKILL.md is full instruction set |
| Structure | PASS | Frontmatter + direct instructions |
| Frontmatter | PASS | name="skill-writing", description present |
| Name matches folder (A-FM-1) | PASS | Folder "skill-writing" = frontmatter name |
| H1 per artifact (A-FM-3) | PASS | spec.md H1=YES, uncompressed.md H1=YES, SKILL.md H1=NO (all correct) |
| No duplication | PASS | Not duplicating existing capabilities |

## Phase 3 — Spec Compliance

| Check | Result | Notes |
| --- | --- | --- |
| Coverage | FAIL | Constraints section not included in SKILL.md (see Issues below) |
| No contradictions | PASS | SKILL.md does not contradict spec |
| No unauthorized additions | PASS | No new normative requirements introduced |
| Conciseness | PASS | Agent-facing, every line earns place |
| Completeness | FAIL | Missing Constraints section; error handling/defaults not represented |
| Breadcrumbs | PASS | Related section present with skill references |
| Markdown hygiene | PASS | Proper H1 structure, no violations |
| Description not restated (A-FM-2) | PASS | Description not duplicated in body prose |
| Lint wins (A-FM-4) | PASS | No markdown lint violations |
| No exposition in runtime (A-FM-5) | PASS | No rationale/background prose in SKILL.md |
| No non-helpful tags (A-FM-6) | PASS | No descriptor lines without operational value |
| No empty sections (A-FM-7) | PASS | All headings have body content |
| Cross-reference anti-pattern (A-XR-1) | PASS | Only skill NAME references used (not file paths) |

## Issues

**SPEC COMPLIANCE GAP — Constraints Section Missing**

The spec defines a "Constraints" section with normative requirements governing skill creation:
- Don't create dispatch skills for tasks that need caller context
- Don't create skills that duplicate existing ones
- Never modify SKILL.md directly
- Never restate description frontmatter
- Never put H1 in SKILL.md/instructions.txt
- Never put rationale in runtime artifacts
- And 6 more explicit constraints

SKILL.md addresses some of these indirectly (e.g., "Never modify SKILL.md directly — compiled artifact") but omits a Constraints section that would explicitly guide agents on what NOT to do. Per the spec's own principle: "Self-containment wins over aggressive compression."

An agent following SKILL.md could unknowingly violate constraints like "Don't create skills that duplicate existing ones" because the constraint is not mentioned.

**Fix**: Add a "Constraints" or "Don'ts" section to SKILL.md (compressed form) listing the key normative constraints from spec. Reference spec for full detail if compression limits text.

---

## Recommendation

Add mandatory Constraints section to SKILL.md covering key "Don't" rules from spec; compress per existing SKILL.md style; re-audit.

## References

- Coverage gap: spec-writing/spec.md Constraints section
