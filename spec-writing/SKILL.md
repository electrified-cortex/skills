---
name: spec-writing
description: Write precise, testable, auditable specification documents with explicit scope, stable terminology, and enforceable requirements.
---

Write specs: clear, complete, enforceable, internally consistent, externally auditable.

Purpose: define intent precisely, testably, auditably.

Scope: when writing spec or derived target doc governed by source spec. All scope must be explicitly declared.
Not for: non-spec docs (design notes, ADRs, READMEs), auditing (see spec-auditing), retroactive application without re-audit.

Definitions:
Spec: normative doc defining rules, requirements, constraints, expected behavior.
Atomic: requirement expressing exactly one testable condition; can't decompose further.
Testable: satisfaction verifiable from doc text alone without external judgment.
Normative: defines requirements/constraints/behavior; strictly enforceable.
Descriptive: explains context/intent; must not contradict normative content.
Exploratory: captures ideas, tradeoffs, open questions; may contain ambiguity.
Informational: notes, examples, references.
Mandatory language: must, shall, required.
Prohibited language: must not, shall not.
Guidance language: should, recommended.
Optional language: may, optional.

Content Modes: Classify every section as Normative (enforceable), Descriptive (context only, must not contradict normative), Exploratory (ideas/tradeoffs, may be ambiguous), or Informational (notes/examples). Only Normative is strictly enforceable. Behavior-affecting statements must be in Normative sections.

Requirements:
Define behavior or constraints. Use enforceable language. Internally consistent, structurally coherent, externally auditable. No implied intent. State all required behavior explicitly. Every requirement verifiable. Each in one canonical location. Define and use terms consistently. Clearly distinguish required, prohibited, guidance, optional behavior.
Required sections: Purpose (intent), Scope (boundaries), Definitions (key terms), Requirements (atomic rules), Constraints (limits/prohibitions), Behavior (edge cases), Defaults and Assumptions (explicit only), Error Handling (failure behavior), Precedence Rules (conflict resolution), Don'ts (explicit exclusions).
Each requirement: atomic (one testable condition), testable (verifiable from text alone), unambiguous.
Use subject-verb-object form: name actor, artifact, trigger condition.
Two clear sentences preferred over one dense clause.
Dense or compressed phrasing in any normative requirement is a defect. Reader must parse each requirement on first read without re-scanning.
Derived targets: map every normative requirement to source spec. Mappings one-to-one or one-to-many. Unmapped = Unauthorized Additions.

Constraints:
No vague terms; no implied behavior; no hidden requirements; no contradictions; no duplicated rules; no subjective language; no normative requirements in examples; no normative behavior implied in descriptive text; no normative requirements in exploratory sections.
Derived targets: no new requirements, no term redefinition, no scope expansion, no changed constraints/defaults, no new concepts.
If extension is allowed, the spec must define where extension is permitted and its constraints. Otherwise extension is prohibited.

Behavior:
Statement affects behavior → move to Normative section. Define behavior including edge cases. State defaults explicitly. Define failure behavior explicitly. Define conflict resolution explicitly. State explicit exclusions.
Derived targets, allowed transforms: reword for clarity, reorganize structure, aggregate related requirements, add descriptive explanations. Preserve meaning of all normative statements.
Validate before accepting: all required sections present, all requirements use normative language, no vague wording, all terms defined, no duplicates, no contradictions, no implicit assumptions.

Output Quality Gate:
Accept only if: all requirements testable, no critical ambiguity, terminology stable, no contradictions, no unauthorized scope expansion.

Defaults and Assumptions:
Only explicit defaults allowed. Ambiguity allowed only in non-normative sections. Assume every requirement will be challenged, every omission detected, every ambiguity flagged.

Error Handling:
Ambiguous normative statement → rewrite. Behavior-affecting statement outside Normative → move to Normative. Requirement not atomic, testable, or enforceable → rewrite before treating spec as valid.

Precedence:
Correctness and enforceability over readability. Normative content governs behavior. Non-normative must not introduce hidden requirements. Derived targets: source spec authoritative, target subordinate. Normative statement with multiple reasonable interpretations → invalid, must rewrite.

Derivation workflow:
1. Write spec.
2. Dispatch spec-auditor: Haiku first, Sonnet final pass.
3. Fix all findings.
4. Re-audit until PASS.
5. Write derived artifact only after PASS.
6. Dispatch artifact auditor (skill-auditor, agent-auditor, or tool-auditor) on derived artifact separately.
Skipping spec-auditor before derived artifacts is prohibited.

Don'ts:
Don't use descriptive, exploratory, or informational content as substitute for normative requirements. Don't use this skill to justify silent scope expansion. Don't hide requirements in examples, notes, or descriptive prose.

After writing any spec.md, run `markdown-hygiene` (dispatch) to ensure zero lint errors.

Footgun Convention:
Specs may include optional `Footguns` section. Format:
**F#: {title}** — failure mode description.
Why: why it's a footgun.
Mitigation: specific fix (parameter, phrasing, constraint).
Wrong-usage examples use `ANTI-PATTERN:` prefix.
Canonical reference: `dispatch-strategy` skill (F1–F5 with Mitigation: lines).

Related: `spec-auditing` (verify spec quality), `skill-writing` (write skills from specs), `skill-auditing` (verify skill quality), `markdown-hygiene` (zero-error lint gate)
