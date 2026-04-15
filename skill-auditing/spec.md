---
name: skill-auditing
description: >-
  Specification for auditing skills — the quality rules, compliance checks,
  and cost analysis that govern skill quality in the workspace.
type: spec
---

# Skill Auditing Specification

## Purpose

Define the rules and procedures for auditing skills. The skill auditor is
the source of truth for skill quality. Skill writers conform to the
auditor's rules. The auditor can verify its own skill for compliance
(dogfooding).

## Scope

Applies when auditing an existing skill for quality, compliance, or
optimization. Covers classification verification, structural checks,
cost analysis, and breadcrumb validation.

This is a **dispatch skill** — the audit procedure is context-independent
and should run in an isolated agent via the Dispatch agent pattern.

## Definitions

- **Audit**: Systematic verification of a skill against the skill-writing
  spec and this auditing spec's quality rules.
- **Verdict**: The outcome of an audit — PASS, NEEDS_REVISION, or FAIL.
- **Classification error**: A skill using the wrong execution pattern
  (inline when it should dispatch, or vice versa).
- **Context overhead**: The cost of loading unnecessary context (system
  prompt, conversation history) into a dispatched agent's turns.
- **Routing depth**: How many sub-skills a skill references. Deeper =
  more modular but harder to trace.

## Audit Checklist

### 1. Classification (inline vs dispatch)

Apply the decision tree from the skill-writing spec:

> "Could someone with no context do this from just the inputs?"
> Yes → should be dispatch. No → should be inline.

- If classified as inline but task is mechanical → flag as NEEDS_REVISION
- If classified as dispatch but task needs caller context → flag

### 2. Structure

**For inline skills:**
- Has frontmatter with `name` and `description`
- Instructions are direct and actionable
- Self-contained (no dependency on companion spec at runtime)

**For dispatch skills (routing cards):**
- SKILL.md is ≤15 lines of routing content
- Dispatch instruction file exists and is reachable
- Parameters documented with types, required/optional, and defaults
- Output format specified
- Uses Dispatch agent (isolated) — not background agent with host context

### 3. Companion Spec

- Required for dispatch skills and complex inline skills
- May be absent only for simple inline skills (under ~30 lines, no
  design decisions worth recording)
- If present, must not contradict the SKILL.md
- Must be clearly separated: spec holds rationale, SKILL.md holds runtime
  instructions

### 4. Conciseness

- Every line must affect runtime behavior
- No design rationale in SKILL.md (belongs in spec)
- No redundant explanations of the same rule
- No prose that could be fragments
- Agent-facing density, not human-facing readability

### 5. Completeness

- All runtime-relevant instructions present
- No implicit assumptions — state everything explicitly
- Edge cases addressed or explicitly excluded
- Defaults stated, not assumed

### 6. Breadcrumbs

- Ends with related skills or help topics
- References are valid (pointed-to resources exist)
- No stale references to renamed/moved resources

### 7. Cost Analysis (dispatch skills only)

- Uses Dispatch agent (zero-context isolation) — not background agent
  with host context
- Instruction file is right-sized — not loading unnecessary content
- References sub-skills by pointer, not by inlining their content
- Single dispatch turn when possible (agent reads file once, processes,
  returns)
- Flag skills where instruction file is >500 lines — may need splitting

### 8. No Duplication

- Skill does not duplicate an existing capability
- If similar skill exists, recommend merge or distinguish clearly

## Verdict Rules

- **PASS**: All 8 checks pass. Skill is production-ready.
- **NEEDS_REVISION**: 1-2 non-critical issues. Skill works but has quality
  gaps. List specific fixes.
- **FAIL**: Classification error, missing instruction file, or structural
  breakdown. Skill cannot be used reliably until fixed.

## Audit Report Format

```markdown
## Skill Audit: <skill-name>

**Verdict:** PASS | NEEDS_REVISION | FAIL
**Type:** inline | dispatch
**Path:** <path-to-skill>

### Checklist

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS/FAIL | <notes> |
| Structure | PASS/FAIL | <notes> |
| Companion spec | PASS/FAIL/N/A | <notes> |
| Conciseness | PASS/FAIL | <notes> |
| Completeness | PASS/FAIL | <notes> |
| Breadcrumbs | PASS/FAIL | <notes> |
| Cost analysis | PASS/FAIL/N/A | <notes> |
| No duplication | PASS/FAIL | <notes> |

### Issues
- <specific issue and fix>

### Recommendation
<one-line summary>
```

## Dispatch Parameters (for the auditor agent)

- `skill_path` (string, required): Absolute path to the SKILL.md to audit
- `result_file` (string, required): Absolute path to write the audit report
- `spec_path` (string, optional): Path to companion spec if not co-located

## Self-Audit

This skill can and should be audited by its own agent. The skill-auditor
dispatch instruction file reads the skill-writing spec as its rule set
and applies this auditing spec's checklist to any skill — including
itself. If the auditor fails its own audit, fix it before auditing others.

## Relationship to Other Skills

- **skill-writing** — the spec this auditor enforces
- **spec-auditing** — audits companion specs (complementary, not overlapping)
- **compression** — exemplar dispatch pattern to compare against
- **task-verification** — exemplar audit dispatch pattern

## Constraints

- Auditor is read-only — never modifies the skill being audited
- One skill per dispatch — don't batch audit multiple skills in one run
- Verdict must be justified with evidence from the skill file
- When in doubt, NEEDS_REVISION over PASS — be adversarial
