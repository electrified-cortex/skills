---
file_path: spec-auditing/spec.md
operation_kind: spec-auditing/v1
model: sonnet-class
result: pass_with_findings
---

# Audit Result

Pass with Findings

---

# Executive Summary

**Mode:** Spec-only (caller explicitly requested spec-only mode; no companion file).

`spec-auditing/spec.md` is a mature, comprehensive spec. All required sections are present. Normative language is consistent and enforceable. Internal consistency is sound across the 33 named sections. Structural ordering is logical. Defined terms are used consistently throughout.

One Medium finding exists: the spec's manifest hash computation excludes the effective `--kind` flag, which creates a potential stale cache hit when the same files are audited with different `--kind` values. The spec's own determinism claim is inconsistent with this gap.

One Low finding exists: minor structural duplication between the `## Requirements` section and `## Constraints` section (Requirement 5 restates Constraint 1 verbatim). This is low-impact but creates a maintenance surface.

---

# Findings

## F-01

**Severity:** Medium
**Title:** Manifest hash excludes `--kind` flag; determinism claim is not fully correct
**Affected file:** spec-auditing/spec.md
**Evidence (direct):**

- `## Hash-Record Cache / Overview`: "spec-auditing is a deterministic, read-only operation. Given the same set of input files and the same audit logic version, the result is identical."
- `## Hash-Record Cache / Manifest Hash`: "Compute from all input files (target spec and companion, if present)." No mention of including the effective audit kind.
- `## Inputs`: "`--kind meta|domain` — force audit kind; default auto-detects from path." Different `--kind` values for the same input files produce different audit results.
- `optimize-log.md` (informational context): records pending finding "audit-kind flag not in manifest hash; stale cache hit when same files audited with different --kind."

**Explanation:** The manifest hash is computed from input file blobs only. Two invocations with identical input files but different effective `--kind` values (e.g., `--kind meta` then `--kind domain`) hash identically, so the second invocation would return the first result from cache — a stale hit with a wrong audit kind. The determinism claim in the Overview is incorrect in this scenario: the result is NOT identical given the same files when `--kind` differs.

The `optimize-log.md` entry corroborates this as a known open concern.

**Recommended fix:** Either (a) include the effective audit kind (auto-detected or explicit) as a component of the manifest hash computation, or (b) qualify the determinism claim: "Given the same set of input files, the same audit logic version, and the same effective audit kind, the result is identical."

---

## F-02

**Severity:** Low
**Title:** Requirement 5 duplicates Constraint 1 verbatim
**Affected file:** spec-auditing/spec.md
**Evidence (direct):**

- `## Requirements`, item 5: "The auditor must never modify the spec file under any circumstances."
- `## Constraints`, item 1: "The auditor must never modify the spec file. The executor is single-pass read-only; fix iteration is caller-driven."

**Explanation:** These two entries express the same prohibition. The Constraints entry includes additional context ("The executor is single-pass read-only; fix iteration is caller-driven") that is absent from Requirements item 5. The duplication creates a maintenance hazard: if one is updated, the other may drift. The Constraints section's version is more complete.

This duplication is Informational for consolidation purposes, but the asymmetry (Constraints has more detail) elevates it to Low because a reader of Requirements only would have a weaker understanding of the constraint than a reader of Constraints only.

**Recommended fix:** Either remove item 5 from Requirements (trusting Constraints as the authoritative statement) or expand item 5 to include "The executor is single-pass read-only; fix iteration is caller-driven" for parity.

---

# Coverage Summary

N/A — spec-only mode, no companion present.

---

# Drift and Risk Notes

Internal consistency is sound. The following structural observations apply to the spec in isolation:

1. The prohibition against modifying the spec appears in four locations: `## Required Auditor Behavior`, `## Requirements` (item 5), `## Constraints` (item 1), and `## Error Handling` ("`--fix` passed in any mode" row). This is intentional multi-context redundancy (behavioral disposition, machine-readable requirements, hard prohibition, error table). The duplication is load-bearing in each context. No consolidation recommended beyond the F-02 asymmetry fix.

2. The `## Don'ts` section and `## Constraints` section overlap substantially. The Don'ts section frames scope in negative terms; Constraints adds detail to some items. These serve different reading purposes (narrative vs normative list). The overlap is acceptable and low-risk.

3. The `optimize-log.md` entry for the manifest hash issue (F-01 above) has been pending since 2026-05-03 with status "maybe." This spec audit formalizes it as a confirmed Medium finding.

---

# Repair Priorities

1. **F-01 (Medium):** Fix the manifest hash computation or qualify the determinism claim. Prevents real stale cache bugs when `--kind` is used explicitly.
2. **F-02 (Low):** Align Requirements item 5 with Constraints item 1 (add missing context, or remove the duplicate). Low effort, reduces future drift risk.
