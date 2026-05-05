---
file_paths:
  - skill-auditing/spec.md
operation_kind: spec-auditing/v1
model: claude-sonnet-4-6
result: pass_with_findings
---

# Audit Result

Pass with Findings

# Executive Summary

Spec-only mode — target ends in `spec.md`, no `--spec` flag supplied; caller explicitly requested spec-only audit. No companion present; companion-dependent steps skipped.

The `skill-auditing/spec.md` is structurally complete: all five required sections (Purpose, Scope, Definitions, Requirements, Constraints) are present. Normative language is consistently applied throughout. The spec is comprehensive and detailed. However, the audit found several internal consistency defects, enforceability gaps, and redundancy issues that create ambiguity or drift risk for implementers.

The most significant issue is a contradiction in the cache-miss / MISS-token model: Requirements R10 places `MISS: <abs-path>` in the executor's return-token vocabulary, while the Behavior section makes clear the executor is only ever dispatched on a cache miss — meaning the executor would never have occasion to emit MISS. This creates conflicting guidance for any implementer reading both sections.

A secondary concern is that two defined terms (HIT, MISS) are defined in Definitions but are not operationalized by any normative requirement — HIT has no requirement at all, and MISS is contradicted by the architecture described in Behavior.

Several structural redundancies across Constraints / Auditing Constraints / Don'ts create drift risk.

# Findings

## F-01
**Finding ID:** F-01
**Severity:** High
**Title:** MISS token defined as executor return but executor is never dispatched on a hit — contradiction
**Affected file:** skill-auditing/spec.md
**Evidence (direct):**
- Requirements R10: "Valid return tokens: `CLEAN: <abs-path>` | `PASS: <abs-path>` | `NEEDS_REVISION: <abs-path>` | `FAIL: <abs-path>` on verdict; `MISS: <abs-path>` on cache miss (triggers full audit run)."
- Behavior section: "On a miss, the host dispatches the executor with `--report-path <abs-path>` and the executor runs the full audit."
- Definitions: "MISS: return token emitted when no cache record exists for the manifest hash; the full audit must run."
- Output/Return Contract (Behavior subsection): "`Right: CLEAN: <abs-path> | PASS: <abs-path> | NEEDS_REVISION: <abs-path> | FAIL: <abs-path>`" — MISS absent from the Right column.

**Explanation:** R10 places MISS in the executor's return-token vocabulary. However, the Behavior section states the executor is only dispatched on a cache miss, meaning the executor always runs the full audit when invoked and would never emit MISS — it has no occasion to do so. The Output/Return Contract confirms this by listing only the four verdict tokens as correct executor output. The definition of MISS says it is "emitted when no cache record exists" without specifying the emitter. These three statements are mutually inconsistent: R10 says executor emits MISS; Behavior says executor is only dispatched on miss (so executor always runs full audit, never emits MISS); Return Contract omits MISS from correct output. An implementer cannot reconcile all three.

**Recommended fix:** Clarify that MISS is a host-level signal (not an executor return token). Remove MISS from R10's valid executor return-token list. If MISS is a host-internal signal, define it in the host's operation, not in the executor's return contract. Update Definitions to identify the emitter explicitly.

---

## F-02
**Finding ID:** F-02
**Severity:** Medium
**Title:** HIT token defined but never operationalized by any normative requirement
**Affected file:** skill-auditing/spec.md
**Evidence (direct):**
- Definitions: "HIT: return token emitted when a cache record is found; verdict not re-computed."
- No normative requirement (must/shall/required) anywhere in the spec instructs the executor or host to emit HIT. The Behavior section says on a hit the host "re-emits the cached verdict token and stops" — there is no mention of a HIT token being emitted.

**Explanation:** HIT is defined but has no associated requirement. If HIT is a host-internal signal, it needs a normative statement in the host's procedure. If it is unused, its definition is dead. A dangling definition creates confusion for implementers who may attempt to implement it or attempt to parse it from output.

**Recommended fix:** Either add a normative requirement that specifies when and by whom HIT is emitted, or remove HIT from Definitions if it has no operational role.

---

## F-03
**Finding ID:** F-03
**Severity:** Medium
**Title:** Per-file Basic Checks verdict contribution is undefined — HIGH findings from this section have no stated verdict impact
**Affected file:** skill-auditing/spec.md
**Evidence (direct):**
- Audit Steps / Per-file Basic Checks: "Findings accumulate into a separate Per-file section of the report; they do NOT block Steps 1–3."
- Verdict Rules: "FAIL: Any FAIL finding, or 3+ HIGH findings. NEEDS_REVISION: No FAIL findings, but HIGH or multiple LOW findings present."
- The Verdict Rules do not distinguish findings by origin (Per-file vs Steps 1–3).

**Explanation:** The Per-file section states its findings "do NOT block Steps 1–3," which an implementer could read as meaning Per-file findings are informational-only and do not affect the verdict. However, the Verdict Rules count HIGH findings generically — if a Per-file check produces a HIGH (e.g., empty file, missing frontmatter, absolute path leak), the verdict rules would trigger NEEDS_REVISION or FAIL. The phrase "do NOT block Steps 1–3" is ambiguous: does it mean (a) findings don't halt steps 1–3 (they run regardless), or (b) findings from this section are excluded from verdict computation? If (b), the Verdict Rules must say so. If (a), the phrasing is misleading because it implies exclusion.

**Recommended fix:** Clarify whether Per-file findings contribute to the verdict or are informational only. If they contribute, remove the potentially misleading "do NOT block Steps 1–3" language or replace it with "findings are collected in parallel and contribute to the verdict per normal severity mapping." If they are truly informational-only, add a statement to that effect in both Per-file Basic Checks and Verdict Rules.

---

## F-04
**Finding ID:** F-04
**Severity:** Medium
**Title:** Dispatch Skill Audit Criteria verdict threshold uses vague "depending on count" without specifying the count
**Affected file:** skill-auditing/spec.md
**Evidence (direct):**
- Dispatch Skill Audit Criteria closing paragraph: "Violations are recorded in the Step 3 findings table under a 'Dispatch Skill Checks' group and contribute to the verdict per the normal severity mapping (HIGH → NEEDS_REVISION or FAIL depending on count; LOW → NEEDS_REVISION)."
- Verdict Rules: "FAIL: Any FAIL finding, or 3+ HIGH findings."

**Explanation:** The phrase "depending on count" is vague. The Verdict Rules already define the count threshold (3+ HIGH = FAIL), so "depending on count" is a non-specific paraphrase that could be read as a different or overriding threshold. An implementer unfamiliar with the Verdict Rules might not know what count is meant. This is an enforceability issue.

**Recommended fix:** Replace "HIGH → NEEDS_REVISION or FAIL depending on count" with a pointer to the Verdict Rules threshold: "HIGH → NEEDS_REVISION (1–2 HIGHs) or FAIL (3+ HIGHs) per Verdict Rules."

---

## F-05
**Finding ID:** F-05
**Severity:** Low
**Title:** Redundant constraint sections — Constraints, Auditing Constraints, and Don'ts overlap materially
**Affected file:** skill-auditing/spec.md
**Evidence (direct):**
- Constraints: "One skill per invocation"; "Compiled artifacts immutable: SKILL.md, instructions.txt, spec.md, and README.md must never be modified by the auditor in any mode."
- Auditing Constraints: "Auditor is read-only. The companion spec.md and all compiled runtime files (SKILL.md, instructions.txt) are immutable." and "One skill per dispatch — don't batch audit multiple skills in one run."
- Don'ts: "Do not modify any file in skill_dir — auditor is read-only." and "Do not batch-audit multiple skills in a single dispatch invocation."

**Explanation:** The read-only constraint and one-skill-per-invocation constraint each appear in three separate sections under slightly different wording. This triplication creates drift risk: a future edit to one section may not be replicated to the others, leading to inconsistencies. The "Auditing Constraints" section appears redundant with both "Constraints" and "Don'ts."

**Recommended fix:** Consolidate. Keep the normative constraints in the "Constraints" section. Move operational prohibitions to "Don'ts." Remove "Auditing Constraints" as a separate section or clearly distinguish what it adds beyond the other two.

---

## F-06
**Finding ID:** F-06
**Severity:** Low
**Title:** Core sweep rule (single pass, collect all findings) repeated in three locations
**Affected file:** skill-auditing/spec.md
**Evidence (direct):**
- Requirements R1: "The auditor must execute the audit as a single sweep in order: compiled artifacts → parity check → spec alignment."
- Requirements R2: "All findings must be collected across the full sweep before assigning a verdict; the sweep does not stop on the first finding."
- Behavior section intro: "The audit executes as a single sweep in three ordered steps. All findings are collected before a verdict is assigned — the sweep does not stop on the first finding."
- Audit Steps intro: "The audit executes three steps in order. All findings are collected before a verdict is assigned."

**Explanation:** The same two rules (ordered single sweep; collect all findings before verdict) appear in Requirements, Behavior section, and Audit Steps section. Triplication creates drift risk without adding clarity.

**Recommended fix:** State the rule once in Requirements. Reference it by requirement number in Behavior and Audit Steps if needed ("per R1 and R2"). Remove the prose restatements.

---

## F-07
**Finding ID:** F-07
**Severity:** Low
**Title:** Classification criterion depends on externally-referenced decision tree not reproduced in this spec
**Affected file:** skill-auditing/spec.md
**Evidence (direct):**
- Audit Steps, Step 1.1: "apply the decision tree from the skill-writing spec: 'Could someone with no context do this from just the inputs?' Yes → should be dispatch. No → should be inline."

**Explanation:** The classification rule quotes a single heuristic question from the skill-writing spec but does not reproduce the full decision tree. An auditor without access to skill-writing/spec.md cannot reliably apply the full classification logic. This creates a completeness gap for the procedure as a standalone document.

**Recommended fix:** Either reproduce the relevant portion of the decision tree inline, or add an explicit cross-reference requirement that the auditor must load skill-writing/spec.md before performing Step 1 classification.

---

## F-08
**Finding ID:** F-08
**Severity:** Low
**Title:** "companion spec" used normatively but not formally defined in Definitions
**Affected file:** skill-auditing/spec.md
**Evidence (direct):**
- Defaults and Assumptions: "Spec location: companion spec is spec.md co-located with skill_dir."
- Used throughout Audit Steps and Requirements (e.g., R15: "If no companion spec exists...").
- Definitions section does not contain an entry for "companion spec."

**Explanation:** "companion spec" is an operationally significant term used in multiple requirements. Its meaning is described informally in Defaults but not formally defined. A formal definition in Definitions would resolve any ambiguity about what qualifies as a companion spec and when the companion relationship applies.

**Recommended fix:** Add "companion spec" to the Definitions section: "The spec.md file co-located with a skill's folder (skill_dir). Provides the authoritative behavioral contract for the skill."

---

## F-09
**Finding ID:** F-09
**Severity:** Low
**Title:** "manifest hash" used extensively but not defined in Definitions
**Affected file:** skill-auditing/spec.md
**Evidence (direct):**
- Requirements R10: "The auditor must compute a manifest hash from the skill's source files..."
- Behavior section: "the host ... computes a manifest hash from the semantic-content whitelist..."
- Audit Report Format: references hash-record path encoding the manifest hash.
- Definitions section: no entry for "manifest hash."

**Explanation:** "manifest hash" is a critical operational term used in the cache-check mechanism, report path, and frontmatter. It is not defined in Definitions. The procedure for computing it references "the hash-record manifest procedure" (an external procedure) without defining what inputs and algorithm produce it. An executor reading this spec cannot compute a manifest hash from this spec alone.

**Recommended fix:** Add "manifest hash" to Definitions with a description of inputs (the whitelist of files in specified order) and a pointer to the hash-record skill's manifest procedure.

---

## F-10
**Finding ID:** F-10
**Severity:** Informational
**Title:** "host" and "executor" are operationally critical roles not defined in Definitions
**Affected file:** skill-auditing/spec.md
**Evidence (direct):**
- Behavior section uses "host (via result.sh / result.ps1)" and "executor" throughout.
- Requirements R10 distinguishes between host and executor behavior implicitly.
- Definitions section: no entry for "host" or "executor."

**Explanation:** The distinction between host (the calling agent that invokes result.sh/ps1 and handles the cache check) and executor (the dispatched agent that runs the full audit) is architecturally fundamental but undefined. The Behavior section makes the distinction clear enough for experienced readers, but formal definitions would make the spec self-contained and reduce onboarding cost.

**Recommended fix:** Add "host" and "executor" to Definitions: "Host — the orchestrating agent that computes the manifest hash, checks the cache, and dispatches the executor on a miss. Executor — the dispatched agent that performs the full audit and writes the report to the hash-record path."

---

## F-11
**Finding ID:** F-11
**Severity:** Informational
**Title:** Tiered Model Strategy section contains rationale prose — belongs in spec but creates length
**Affected file:** skill-auditing/spec.md
**Evidence (direct):**
- Tiered Model Strategy: "Rationale: the iterate tier catches structural and obvious issues cheaply; the sign-off tier catches subtle compliance gaps. Running the sign-off tier on every iteration wastes tokens on issues the iterate tier already found."

**Explanation:** The rationale paragraph is clearly labeled as such and is appropriate in a spec. This is an informational observation only — rationale is permitted in spec.md. The paragraph is not present in runtime artifacts.

**Recommended fix:** No action required. Observation noted for completeness.

# Coverage Summary

N/A — spec-only mode, no companion present.

Internal consistency check performed as substitute for cross-file checks. See Findings F-01 through F-04 for contradictions and gaps within the spec itself.

Well-covered areas:
- Verdict vocabulary (CLEAN/PASS/NEEDS_REVISION/FAIL) and mapping to record result values
- Audit sweep order and step definitions
- Per-file checks and dispatch skill checks
- Frontmatter anti-patterns (A-FM-1 through A-FM-10)
- Cross-reference anti-pattern (A-XR-1)
- Banned terminology (non-goals)
- Error handling (target not found, spec not found, report path not writable)
- Precedence rules

Weak or missing coverage:
- MISS/HIT token emitter identity (see F-01, F-02)
- Per-file findings verdict contribution (see F-03)
- Dispatch section verdict threshold precision (see F-04)
- "companion spec," "manifest hash," "host," "executor" formal definitions (see F-08, F-09, F-10)

# Drift and Risk Notes

1. **Three-way rule triplication** (F-05, F-06): The read-only constraint and the single-sweep rule each appear in three separate sections. Future edits that update one location but not others will produce silent inconsistencies. Highest drift risk in the spec.

2. **MISS/HIT definition drift** (F-01, F-02): MISS and HIT are defined in Definitions but their operational roles are contradicted or absent in Requirements and Behavior. As the spec evolves (e.g., if the cache mechanism changes), these definitions will drift further from reality.

3. **External dependency on skill-writing/spec.md** (F-07): The classification procedure depends on a decision tree defined in a separate spec. If skill-writing/spec.md changes its classification heuristic, this spec is silently broken. A local reproduction or a versioned reference would reduce this risk.

4. **Per-file findings isolation** (F-03): The ambiguous "do NOT block Steps 1–3" phrasing may cause different implementers to treat Per-file findings differently — some including them in the verdict, some treating them as informational. This is a behavioral inconsistency risk.

# Repair Priorities

1. **F-01 (High)** — Resolve the MISS-token contradiction between R10 and the Behavior section. This is the highest-risk defect: an implementer may implement a MISS return from the executor that the architecture never triggers, or may misunderstand the cache-miss flow entirely.

2. **F-03 (Medium)** — Clarify Per-file findings verdict contribution. The ambiguity could cause an executor to omit HIGH findings from the verdict computation.

3. **F-02 (Medium)** — Operationalize or remove the HIT definition. A dangling definition in a normative spec creates unnecessary noise.

4. **F-04 (Medium)** — Replace "depending on count" with the precise threshold from Verdict Rules.

5. **F-05 (Low)** — Consolidate Constraints / Auditing Constraints / Don'ts to eliminate triplication.

6. **F-06 (Low)** — Remove sweep-rule restatements in Behavior and Audit Steps; reference Requirements instead.

7. **F-07 (Low)** — Reproduce or fully reference the classification decision tree.

8. **F-08 (Low)** — Add "companion spec" to Definitions.

9. **F-09 (Low)** — Add "manifest hash" to Definitions with computation pointer.

10. **F-10 (Informational)** — Add "host" and "executor" to Definitions.
