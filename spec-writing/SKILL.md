---
name: spec-writing
description: Write precise, testable, auditable specification documents with explicit scope, stable terminology, and enforceable requirements.
---

Write specs: clear, complete, enforceable, internally consistent, externally auditable.

Purpose: define intent precisely, testably, auditably.

Scope: when writing spec or derived target doc governed by source spec. All scope must be explicitly declared.

Definitions:
Spec: normative doc defining rules, requirements, constraints, expected behavior.
Atomic: requirement expressing exactly one testable condition; can't decompose further.
Testable: satisfaction verifiable from doc text alone without external judgment.
Normative: defines requirements/constraints/behavior; strictly enforceable.
Descriptive: explains context/intent; mustn't contradict normative content.
Exploratory: captures ideas, tradeoffs, open questions; may contain ambiguity.
Informational: notes, examples, references.
Mandatory language: must, shall, required.
Prohibited language: mustn't, shall not.
Guidance language: should, recommended.
Optional language: may, optional.

Requirements:
Define behavior or constraints. Use enforceable language. Internally consistent, structurally coherent, externally auditable. No implied intent. State all required behavior explicitly. Every requirement verifiable. Each requirement in one canonical location. Define and use terms consistently. Clearly distinguish required, prohibited, guidance, optional behavior.
Include sections: Purpose, Scope, Definitions, Requirements, Constraints, Behavior, Defaults and Assumptions, Error Handling, Precedence Rules, Don'ts.
Each requirement atomic, testable, unambiguous. Use subject-verb-object form; name the actor, the artifact acted upon, and the trigger condition. Two clear sentences preferred over one dense clause. Dense or compressed phrasing in a normative requirement is a defect. A reader must be able to parse any single requirement on first read without re-scanning surrounding text.
Derived targets: map every normative requirement to source spec. Mappings one-to-one or one-to-many. Unmapped = Unauthorized Additions.

Constraints:
No vague terms; no implied behavior; no hidden requirements; no contradictions; no duplicated rules; no subjective language; no normative requirements in examples; no normative behavior implied in descriptive text; no normative requirements in exploratory sections.
Derived targets: no new requirements, no term redefinition, no scope expansion, no changed constraints/defaults, no new concepts.
If extension allowed, define where and constraints on extension. Otherwise extension prohibited.

Behavior:
Classify each section: Normative, Descriptive, Exploratory, or Informational. Only Normative sections strictly enforceable. Statement affects behavior → move to Normative. Define behavior including edge cases. State defaults explicitly. Define failure behavior explicitly. Define conflict resolution explicitly. State explicit exclusions.
Derived targets, allowed transforms: reword for clarity, reorganize structure, aggregate related requirements, add descriptive explanations. Preserve meaning of all normative statements.
Validate before accepting: all required sections present, all requirements use normative language, no vague wording, all terms defined, no duplicates, no contradictions, no implicit assumptions.
Accept only if: all requirements testable, no critical ambiguity, terminology stable, no contradictions, no unauthorized scope expansion.

Defaults and Assumptions:
Only explicit defaults allowed. Ambiguity allowed only in non-normative sections. Assume every requirement will be challenged, every omission detected, every ambiguity flagged.

Error Handling:
Ambiguous normative statement → rewrite. Behavior-affecting statement outside Normative → move to Normative. Requirement not atomic, testable, or enforceable → rewrite before treating spec as valid.

Precedence:
Correctness and enforceability over readability. Normative content governs behavior. Non-normative content mustn't introduce hidden requirements. Derived targets: source spec authoritative, target subordinate. Normative statement with multiple reasonable interpretations → invalid, must rewrite.

Derivation workflow:
Write spec → spec-auditor (Haiku iterations first, Sonnet final pass) → fix findings → re-audit until PASS → only then write derived artifact. Dispatch artifact auditor (skill-auditor, agent-auditor, or tool-auditor) on derived artifact separately. Skipping spec-auditor before writing derivative artifacts is prohibited.

Don'ts:
Don't use descriptive, exploratory, or informational content as substitute for normative requirements. Don't use this skill to justify silent scope expansion. Don't hide requirements in examples, notes, or descriptive prose.

Related: `spec-auditing` (verify spec quality), `skill-writing` (write skills from specs), `skill-auditing` (verify skill quality)
