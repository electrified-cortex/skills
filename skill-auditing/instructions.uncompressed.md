# Skill Auditor

Read the target skill, evaluate against the 8-point checklist, write verdict.

## Dispatch Parameters

- `skill_path` (required): Absolute path to SKILL.md to audit
- `result_file` (required): Absolute path to write the audit report
- `spec_path` (optional): Path to companion spec if not beside SKILL.md

## Procedure

1. Read the skill at `skill_path`
2. Determine type: inline or dispatch
3. Check for companion spec — ALWAYS check these paths in order:
   a. `spec_path` if provided
   b. `spec.md` in the same directory as `skill_path`
   c. `<skill-name>.spec.md` in the same directory
   If found, read it. If not found, note as N/A for simple inline skills (<30 lines) or FAIL for dispatch/complex inline.
4. Run the 8-point checklist (see below)
5. Assign verdict
6. Write report to `result_file`

## 8-Point Checklist

### 1. Classification

Apply: "Could someone with no context do this from just the inputs?"
- Yes → should be dispatch. No → should be inline.
- Flag misclassification.

### 2. Structure

**Inline:** frontmatter (`name`, `description`), direct instructions, self-contained.
**Dispatch:** SKILL.md ≤15 lines routing content. Instruction file exists. Params
typed with required/optional/defaults. Output format specified. Uses Dispatch agent
(isolated), not background agent with host context.

### 3. Companion Spec

- Required for dispatch and complex inline skills (>30 lines)
- May be absent for simple inline skills
- Must not contradict SKILL.md
- Named `spec.md` (no SKILL prefix)

### 4. Conciseness

- Every line affects runtime behavior
- No rationale in SKILL.md (belongs in spec)
- No redundant explanations
- Agent-facing density

### 5. Completeness

- All runtime instructions present
- No implicit assumptions
- Edge cases addressed or excluded
- Defaults stated

### 6. Breadcrumbs

- Ends with related skills/topics
- References are valid (targets exist)
- No stale references

### 7. Cost Analysis (dispatch only)

- Uses Dispatch agent (zero-context isolation)
- Instruction file right-sized (<500 lines)
- Sub-skills referenced by pointer, not inlined
- Single dispatch turn when possible

### 8. No Duplication

- Not duplicating existing capability
- If similar exists, recommend merge or distinguish

### 9. Markdown Hygiene

- All `.md` files in the skill folder should pass `npx markdownlint-cli2`
- Zero errors on uncompressed.md, spec.md, and instructions.uncompressed.md
- Compressed files (SKILL.md, instructions.txt) are exempt (may strip formatting)

## Verdict Rules

- **PASS**: All 9 checks pass
- **NEEDS_REVISION**: 1-2 non-critical issues. List fixes.
- **FAIL**: Classification error, missing instruction file, structural breakdown

## Report Format

```markdown
## Skill Audit: <skill-name>

**Verdict:** PASS | NEEDS_REVISION | FAIL
**Type:** inline | dispatch
**Path:** <path>

### Checklist

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS/FAIL | |
| Structure | PASS/FAIL | |
| Companion spec | PASS/FAIL/N/A | |
| Conciseness | PASS/FAIL | |
| Completeness | PASS/FAIL | |
| Breadcrumbs | PASS/FAIL | |
| Cost analysis | PASS/FAIL/N/A | |
| No duplication | PASS/FAIL | |

### Issues
- <issue and fix>

### Recommendation
<one line>
```

## Rules

- Read-only. Never modify the skill.
- One skill per dispatch.
- Evidence-based verdicts.
- When in doubt, NEEDS_REVISION over PASS.
