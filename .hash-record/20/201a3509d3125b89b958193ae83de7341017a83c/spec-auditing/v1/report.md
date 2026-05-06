---
operation_kind: spec-auditing/v1
result: pass_with_findings
timestamp: 2026-05-05T00:00:00Z
---

## Audit Result

**Pass with Findings**

---

## Executive Summary

Spec-only audit of copilot-cli/spec.md. The spec is well-structured, internally consistent, and defines the router's responsibility boundaries clearly. Normative language is appropriately deployed; precedence rules are stated. No structural defects detected.

However, several key concepts lack formal definitions in the Definitions section, and the matching logic for operation classification is unspecified, creating implementation ambiguity. The spec is fit for purpose as a high-level design document but requires clarification for implementation, particularly around: (1) what constitutes "context" passed to sub-skills, (2) the algorithm for matching tasks to operations when ambiguity exists, and (3) the full error taxonomy beyond the three cases mentioned in Error Handling.

No Critical or High-severity findings. Six Medium findings address definitional gaps and enforceability weaknesses.

---

## Findings

### Finding 1

**Severity:** Medium  
**Title:** Missing definition for "primary operation"  
**Affected file(s):** copilot-cli/spec.md  
**Evidence:**
- Requirements section: "One operation is handled per invocation. Multi-operation tasks are split: **primary operation runs**, remaining operations are reported to the caller."
- Behavior section: "If the task spans multiple operations, the router executes the **primary operation** and reports the remaining operations to the caller."

**Explanation:** The term "primary operation" is used normatively (directs execution priority) but is not defined in the Definitions section. This creates ambiguity: Is primary operation determined by order of appearance in the task? By operation precedence? By caller designation? Implementation without this definition risks incorrect behavior on multi-operation tasks.

**Recommended fix:** Add to Definitions section: "**Primary operation**: the operation within a multi-operation task that the router selects for execution. If the task maps to multiple operations without explicit caller designation, the primary operation is the first mentioned in the task description. The router must report remaining operations without executing them."

---

### Finding 2

**Severity:** Medium  
**Title:** Undefined "context" parameter in Behavior  
**Affected file(s):** copilot-cli/spec.md  
**Evidence:**
- Behavior section: "forwards the full task plus **any context the caller provided**."

**Explanation:** The term "context" is mentioned but never defined. What constitutes context? Is it file paths, git diffs, environment variables, model preferences? Without definition, a caller cannot know what to pass, and the router cannot reliably know what to forward to sub-skills.

**Recommended fix:** Add to Behavior section clarification: "Context includes caller-supplied structured arguments such as file paths, model preferences, or parsing hints relevant to the target operation. The router does not interpret context; it forwards the full task and context arguments unchanged to the dispatched sub-skill for validation and use."

---

### Finding 3

**Severity:** Medium  
**Title:** Operation matching algorithm unspecified  
**Affected file(s):** copilot-cli/spec.md  
**Evidence:**
- Behavior section: "identifies the target operation by **matching the task** to the Operation Routing Table."
- Requirements section: "Operation ambiguity must be resolved by asking the caller — never assume."

**Explanation:** The phrase "identifies the target operation by matching" is procedurally vague. The spec does not specify the matching algorithm: keyword detection, LLM classification, fuzzy matching, or explicit operation selection. This is a critical implementation detail for the router. Without it, two implementations might use different approaches, leading to inconsistent behavior on edge cases.

**Recommended fix:** Add to Behavior section: "The router performs keyword-based matching against the Operation Routing Table's operation names and sub-skill descriptions. If the task text includes an unambiguous operation name (e.g. 'do a **review**'), that operation is selected. If the task is ambiguous (e.g. 'analyze this code' maps to both 'explain' and 'review'), the router asks the caller for clarification before dispatching."

---

### Finding 4

**Severity:** Medium  
**Title:** Incomplete error taxonomy in Error Handling  
**Affected file(s):** copilot-cli/spec.md  
**Evidence:**
- Error Handling section covers only three error cases:
  1. Operation cannot be determined → ask clarification
  2. Copilot not installed or auth failed → surface error unchanged
  3. (Implicit: sub-skill reports error) → surface unchanged

**Explanation:** The spec does not cover: What if the targeted sub-skill does not exist? What if the sub-skill fails during execution? What if the sub-skill returns malformed output? What if the router itself encounters a runtime error? The current Error Handling is incomplete and may force implementation choices not grounded in spec intent.

**Recommended fix:** Expand Error Handling section:
- "**Sub-skill not found:** If the targeted sub-skill folder is missing or inaccessible, the router must report 'Sub-skill [operation] not available' and stop without attempting fallback."
- "**Sub-skill execution error:** If the dispatched sub-skill reports failure (e.g. unable to parse CLI output, sub-skill internal error), the router surfaces that result unchanged to the caller."
- "**Multi-part task with no matchable primary operation:** Router reports the ambiguity and asks caller to clarify or revise."

---

### Finding 5

**Severity:** Low  
**Title:** Redundancy between Constraints and Don'ts sections  
**Affected file(s):** copilot-cli/spec.md  
**Evidence:**
- Constraints: "Does not pass through caller-supplied free-form CLI flags. Sub-skills construct flags from structured task arguments only..."
- Don'ts: "Do not pass through caller-supplied free-form CLI flags. Sub-skills construct flags from structured task arguments only — direct flag pass-through is a security regression..."
- Constraints: "Does not couple this skill to `code-review` or any orchestrator."
- Don'ts: "Do not couple this skill to `code-review` or any orchestrator."

**Explanation:** Several Constraints are restated verbatim (or near-verbatim) in the Don'ts section. This increases maintenance burden and creates a consistency risk if one is updated without the other.

**Recommended fix:** Consolidate by removing duplicate statements from Don'ts. Keep Constraints as normative (applies to all implementations). Rename Don'ts to "Anti-Patterns to Avoid" and populate it only with guidance that extends or emphasizes the Constraints section. For example, retain the threat-model context on `--allow-all-tools` but trim the redundancy.

---

### Finding 6

**Severity:** Low  
**Title:** Section heading "Lessons / Don'ts" conflates two concepts  
**Affected file(s):** copilot-cli/spec.md  
**Evidence:**
- Section title: "Lessons / Don'ts (carry-forward from prior draft)"
- Content: "Lessons" are historical design insights; "Don'ts" are prescriptive constraints.

**Explanation:** The heading mixes terminology. Lessons are descriptive (lessons learned); Don'ts are prescriptive (constraints). Conflating them in the heading creates ambiguity about whether this section is informational or normative.

**Recommended fix:** Rename to "Lessons and Constraints — Carry-forward" or split into two sections: "Lessons from Prior Design" (informational) and "Carry-forward Constraints" (normative). Clarify that both sections are part of the spec and are binding for implementations.

---

## Coverage Summary

**N/A — spec-only mode, no companion present.**

---

## Drift and Risk Notes

### Internal Consistency: No Contradictions Detected

The spec's stated requirements, constraints, and behaviors do not contradict each other. Key examples:
- Scope states "operations require new sub-skill folders" → Constraints forbid extending with inline logic: **Consistent.**
- Requirements state "no injected defaults" → Don'ts emphasize security on `--allow-all-tools`: **Consistent.**
- Error Handling defers to sub-skill for Copilot availability check → Constraints show router is dispatch-only: **Consistent.**

### Maintenance Hotspots

1. **Reference to Curator-only documentation:** Lessons section cites "notes/copilot-review-skill-direction-2026-04-25.md (Curator-only)." If that file is deleted or moved, this spec reference becomes orphaned. Consider archiving the reference in a separate Curator handoff doc or removing it if no longer relevant.

2. **Operation Routing Table stability:** The table is the canonical source for operations. Any new operation requires synchronous updates to this table, the Behavior section's description, and the sub-skill availability check. Codify as a maintenance requirement in the Constraints or add a note.

3. **Ambiguity in "matching":** The spec uses "matching the task to the Operation Routing Table" but leaves the algorithm open. Implementation will lock in a choice (keyword, LLM, regex, etc.). Future maintainers should document the chosen algorithm in the runtime card to prevent silent divergence.

---

## Repair Priorities

1. **High value, High effort:** Add complete definitions for "primary operation" and operation matching algorithm (Findings 1, 3). These unlock implementation and prevent costly rework.

2. **Medium value, Low effort:** Define "context" and expand Error Handling (Findings 2, 4). Quick wins with meaningful impact on spec precision.

3. **Low value, Low effort:** Consolidate redundancy (Finding 5) and fix section heading (Finding 6). Maintainability improvements, not blocking.

---

Pass with Findings: d:\Users\essence\Development\cortex.lan\electrified-cortex\skills\.hash-record\20\201a3509d3125b89b958193ae83de7341017a83c\spec-auditing\v1\report.md
