# Spec-Only Audit Report: dispatch spec

**Mode:** spec-only (target ends with `.spec.md` — no companion present)  
**Audit Type:** Spec-only (6 checks: 1, 6, 7, 8, 9, 12 + internal consistency)  
**Severity Threshold:** Default  
**Result:** **Pass with Findings**

---

## Extract (Step 1)

**Scope:** Invocation contract for zero-context sub-agent dispatch via Claude Code `Agent` tool and VS Code `runSubagent`.

**In Scope:**
- Input parameters: `prompt`, `description`, `tier`, `model-override`
- Model derivation and concrete-model resolution
- Platform-specific tier-to-model tables (Claude Code and VS Code)
- Fallback behavior when Dispatch agent unavailable
- Return behavior (passthrough)
- Role-agnostic language
- Process note requirement for file-reading delegation

**Out of Scope (explicit):**
- Transport internals
- Sub-agent design or authoring
- Skill/spec authoring methodology
- Inter-agent Telegram/MCP communication
- Non-dispatch delegation patterns
- Workflow patterns for consuming skills

---

## Structural Integrity (Step 6)

✓ Proper markdown heading hierarchy: H1 title, H2 sections, H3 subsections.  
✓ No YAML frontmatter (clean).  
✓ Logical flow: Purpose → Scope → Definitions → Requirements → Constraints → Defaults → Precedence → Don'ts → Platform Gotchas → CLI Dispatch Mode.  
✓ Stable heading text (no redirects or reformatting).  
✓ Intentional gaps documented: "C3 and C6 were intentionally removed during trim. Numbering gaps are not missing content." (Constraints); "DN8 was intentionally removed" (Don'ts).  
✓ No duplicate rules or hidden requirements.  

**Finding (Low):** CDR numbering in CLI Dispatch Mode section references "CDR1–CDR4" in subsection title but only CDR1–CDR4 are visibly defined. Spec ends at CDR4 without explicit closure or note that CDR5–CDR7 are out of scope or trimmed. If CDR5–CDR7 exist elsewhere, linkage is missing; if not, subsection title could simply state "CLI Dispatch Mode" without the range hint. Not a defect (spec is self-contained), but minor clarity gap.

---

## Terminology (Step 7)

**Defined terms (14):**
- `prompt`, `description`, `tier`, `model-override`, `concrete-model`, `model`, `fast-cheap`, `standard`, `deep`, `fallback`, `passthrough`, `Calling agent`, `Dispatched agent` (also "host," "sub-agent").

**Consistency Check:**
- All defined terms are used consistently throughout.
- Synonymous terms (`Calling agent` ↔ `host`; `Dispatched agent` ↔ `sub-agent`) are introduced in Definitions but used interchangeably. No mapping table; readers must infer equivalence from context.
  
**Finding (Medium - Terminology):** Synonymous term pairs lack explicit mapping. Definitions section introduces both terms for each concept but does not state "also called X" or "equivalent to Y." Example: "Calling agent (or **host**): the agent currently executing..."; "Dispatched agent (or **sub-agent**)...". The parenthetical adds clarity but readers may miss the equivalence if skimming. Recommend: add one-sentence cross-reference table or explicit "also called" note in Definitions to improve readability for non-linear readers.

---

## Internal Consistency (Step 8)

**Contradiction Check:**

1. **D2 (Defaults) vs. R1 (Requirements):**  
   - D2: "Design principle: default model for a dispatch where the host has not specified one is the host's own model."
   - D2 (continued): "In practice, R1 defaults tier to `standard` (Sonnet-class) as a safe baseline."
   
   These are not contradictory; D2 explicitly documents that the design principle (match host model) deviates in practice (default to Sonnet for safety). D2 then says "callers seeking model-matching behavior should pass an explicit model-override parameter." This clarifies the deviation is intentional.
   
   ✓ **Consistent** (deviation documented and explained).

2. **D3 (Default foreground vs. background) vs. PG1 (VS Code no background):**
   - D3: "Default for foreground vs. background... is **background**."
   - PG1: "No background dispatch. VS Code has no background agent primitive... use foreground dispatch."
   
   ✓ **Consistent** (PG1 is labeled platform-specific gotcha; deviation from D3 is expected and documented).

3. **R9 (Cross-references one-way) vs. spec content:**
   - R9: "`dispatch` is referenced by authoring skills and callers; `dispatch` itself does not reference authoring skills."
   - Spec text mentions "authoring skills" and "skill-writing" in Scope (Out of Scope subsection) but does not reference specific authoring skills or their specs.
   
   ✓ **Consistent** (Scope mentions category "authoring skills" as out-of-scope; does not reference specific skill specs).

4. **C7 (Runtime card answerable end-to-end) vs. references to supplemental.md:**
   - C7: "Runtime card must remain answerable end-to-end for core dispatch invocation without reading any supplemental file."
   - Spec includes multiple "See also" references to `supplemental.md` (e.g., "Extended reference content... may reside in supplemental.md").
   
   ✓ **Consistent** (C7 permits "See also" pointers; supplemental is for nuance only, not core dispatch logic).

**Finding:** No contradictions detected. Internal consistency verified across constraints, defaults, precedence rules, platform gotchas, and cross-file references. All deviations from stated principles are documented as intentional (D2 practical default, PG1 platform gotcha).

---

## Economy (Step 9)

**Duplication Analysis:**

- **R5 and R6 (Model alias tables):** Duplicate structure (Tier / Class / model value columns) for two platforms. Duplication is necessary: Claude Code and VS Code use different model naming conventions (aliases vs. full names). **Necessary duplication, not waste.**

- **Requirements R1–R10:** Each requirement is distinct; no redundant restatement.

- **Constraints C1–C7 (intentional gaps):** Trimmed from ~9–10 items to 6. Numbering gaps are documented. No apparent duplication that would benefit from consolidation.

- **Don'ts DN1–DN13 (intentional gaps):** Trimmed similarly; no duplication.

- **Definitions section:** 13 terms, each distinct. No synonym collapsing; synonyms are introduced contextually (e.g., "Calling agent (or **host**)").

**Scope Creep:** Scope section explicitly lists what is NOT covered (transport internals, sub-agent design, skill/spec authoring, inter-agent communication, non-dispatch patterns). This is appropriately narrow and prevents scope bloat.

**Finding (Informational - Economy):** No unjustified duplication or removable scaffolding detected. Spec is economical. Potential minor optimization: Definitions section could condense synonymous term pairs into a single sentence per concept (e.g., "**Calling agent** (or **host**): ...") rather than introducing both terms separately. However, current approach is clear and acceptable. No remediation required.

---

## Compression Fidelity (Step 12)

**Question:** Can this spec be compressed (token reduction) while maintaining fidelity?

**Current Characteristics:**
- Formal structure: headings, numbered requirements, lettered constraints, tables.
- Verbose sections: Platform Gotchas (PG1–PG4), CLI Dispatch Mode (~200 lines), Definitions (~30 lines).
- Concise sections: Requirements (R1–R10), Constraints, Precedence, Don'ts.

**Potential Compression Opportunities:**
1. Definitions: Could remove semicolons and use compact phrasing. Example: "**prompt**: verbatim prompt sent to sub-agent" → "**prompt**: verbatim sub-agent prompt". **Fidelity loss: minimal; readability loss: low.**

2. Platform Gotchas: PG1–PG4 are explanatory and justification-heavy. Example: PG1 is ~50 words explaining VS Code has no background primitive. Could reduce to "VS Code has no background agent primitive; use foreground dispatch." **Fidelity loss: yes (context removed); readability loss: high.**

3. Examples and Explanations: Spec includes contextual explanation (e.g., "In practice, R1 defaults tier to `standard` (Sonnet-class) as a safe baseline"). Could be removed entirely. **Fidelity loss: yes (rationale removed); readability loss: medium.**

**Verdict on Compression:**
- **No loss:** All normative requirements present; spec is complete.
- **No unjustified gain:** No requirements added; scope is clean.
- **Acceptable bloat level:** Explanatory prose is justified. Spec is authoritative and meant for human readers (not just machine parsing). Current verbosity is appropriate for a spec that must be unambiguous and convincing.

**Finding (Informational):** Spec could be compressed by ~15–20% if aggressive token reduction were prioritized, but this would reduce clarity and remove rationale. Current compression level is appropriate for an authoritative spec. **No action required.** (Note: constraint C1 limits **SKILL.md** runtime card to ~3000 bytes; this spec is the normative source and may be more verbose. Trade-off is intentional and correct.)

---

## Overall Assessment

| Check | Status | Notes |
| --- | --- | --- |
| Extract (Step 1) | ✓ Clear | Scope, requirements, exclusions all explicit |
| Structural Integrity (Step 6) | ✓ Sound | Logical flow, proper hierarchy, gaps documented |
| Terminology (Step 7) | ⚠️ Minor | Synonym pairs lack explicit cross-reference table |
| Internal Consistency (Step 8) | ✓ Consistent | No contradictions; intentional deviations documented |
| Economy (Step 9) | ✓ Efficient | No unjustified duplication or bloat |
| Compression Fidelity (Step 12) | ✓ Appropriate | Current verbosity justified for authoritative spec |

---

## Findings Summary

**Critical:** None.

**High:** None.

**Medium (1):**
1. **Terminology Mapping** — Synonymous terms (`Calling agent` / `host`, `Dispatched agent` / `sub-agent`) lack explicit mapping table or one-sentence cross-reference. Impacts readability for skimming. Recommend: add "also called" or mapping note in Definitions section.

**Low (1):**
1. **CDR Numbering Range** — Subsection "When to Use CLI Dispatch (CDR1–CDR4)" suggests a range but spec ends at CDR4 without closure note. If CDR5–CDR7 exist, linkage missing; if not, title is slightly misleading. Clarify range or remove hint.

**Informational (1):**
1. **Compression Opportunity (Not Actionable)** — Spec could be compressed ~15–20% if verbosity reduced, but current level is appropriate for authoritative source. No action needed.

---

## Verdict

**PASS with Findings**

Spec is internally consistent, well-structured, and complete. Two minor findings do not block use; they are readability/clarity optimizations.

- **Threshold:** Default  
- **Fail Conditions:** None triggered (no Critical, no 2+ High)  
- **Pass Criteria:** Met (findings exist; no fail condition)

---

**Report Generated:** 2026-05-05  
**Audit Mode:** spec-only  
**Auditor:** Spec-Auditing Executor v1
