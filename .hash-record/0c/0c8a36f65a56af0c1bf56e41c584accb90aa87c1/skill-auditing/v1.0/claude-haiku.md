---
hash: 0c8a36f65a56af0c1bf56e41c584accb90aa87c1
file_paths:
  - .agents/skills/electrified-cortex/spec-auditing/instructions.uncompressed.md
  - .agents/skills/electrified-cortex/spec-auditing/spec.md
  - .agents/skills/electrified-cortex/spec-auditing/uncompressed.md
operation_kind: skill-auditing
model: claude-haiku
result: findings
---

# Result

NEEDS_REVISION

Skill Audit: spec-auditing

Verdict: NEEDS_REVISION
Mode: default (compressed artifacts)
Type: dispatch
Path: spec-auditing
Failed phase: 3

## Phase 1 — Spec Gate

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present and readable |
| Required sections | PASS | Purpose, Scope, Definitions, Inputs, Defaults, Required Audit Dimensions, Severity Levels, Pass/Fail Rules, Evidence Standard, Output Requirements, Required Auditor Behavior, Requirements, Constraints all present |
| Normative language | PASS | Must, shall, must not, required used consistently; enforceable terms throughout |
| Internal consistency | PASS | No contradictions; precedence rules clearly stated in §Precedence Rules |
| Completeness | PASS | All major terms defined; complete sections with no gaps |

## Phase 2 — Skill Smoke Check

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Dispatch skill (explicitly stated: "Do NOT attempt spec auditing inline") |
| Inline/dispatch consistency | PASS | Consistent with dispatch pattern; instructions.txt and instructions.uncompressed.md present |
| Structure | PASS | Proper dispatch structure with instruction files |
| Input/output double-spec (A-IS-1) | PASS | Output delegates to audit-reporting skill; no duplicate specs |
| Frontmatter | PASS | name: spec-auditing, description present in all artifacts |
| Name matches folder (A-FM-1) | PASS | "spec-auditing" matches directory exactly in uncompressed.md and SKILL.md |
| H1 per artifact (A-FM-3) | PASS | uncompressed.md has H1 "# Spec Auditing"; SKILL.md has no H1; instructions.uncompressed.md has H1 "# Spec Auditing Instructions"; instructions.txt has no H1 |
| No duplication | PASS | spec-auditing is unique; no capability duplication |

## Phase 3 — Spec Compliance

| Check | Result | Notes |
| --- | --- | --- |
| Coverage | PASS | All 11 audit dimensions from spec mapped to instructions; gates, stops, output format all represented |
| No contradictions | PASS | No semantic conflicts between spec and runtime artifacts |
| No unauthorized additions | PASS | "Dispatch-pattern exception" in instructions is valid clarification; iteration-safety reference is valid extension |
| Conciseness | PASS | SKILL.md and instructions.txt properly condensed; source files appropriately detailed |
| Completeness | PASS | All required operational information present |
| Breadcrumbs | PASS | uncompressed.md includes "Related: spec-writing, skill-auditing, compression" |
| Cost analysis | PASS | Instructions file length justified by complexity; dispatch agent handles full context |
| Markdown hygiene | PASS | No structural markdown violations visible |
| No dispatch refs | PASS | instructions.txt does not dispatch other skills; references are in uncompressed.md only |
| No spec breadcrumbs | PASS | No self-references to own spec.md in runtime artifacts |
| Description not restated (A-FM-2) | PASS | Description elaborated but not verbatim restated |
| Lint wins (A-FM-4) | PASS | Markdown structure clean; no violations detected |
| No exposition in runtime (A-FM-5) | PASS | No rationale, "why exists," or background prose in SKILL.md or instructions.txt |
| No non-helpful tags (A-FM-6) | PASS | No descriptor lines carrying no operational value |
| No empty sections (A-FM-7) | PASS | All sections have content before next heading or EOF |
| Iteration-safety placement (A-FM-8) | PASS | Pointer present in uncompressed.md under dedicated section; absent from instructions.uncompressed.md and instructions.txt |
| Iteration-safety pointer form (A-FM-9a) | PASS | Correct 2-line block: "Do not re-audit unchanged files." + "See ../iteration-safety/SKILL.md." Path depth correct (same level) |
| No verbatim Rule A/B (A-FM-9b) | PASS | Only the 2-line pointer present; no full rules copied verbatim |
| Cross-reference anti-pattern (A-XR-1) | PASS | "See ../iteration-safety/SKILL.md" and "follow the audit-reporting skill at ../audit-reporting/SKILL.md" use .md (correct form); skill names in Related section use name-only form (correct); no uncompressed.md or spec.md cross-references |
| Launch-script form (A-FM-10) | FAIL | **HIGH SEVERITY** |

## Issues

### Finding 1: A-FM-10 Launch-Script Form Violation (HIGH)

**Title:** uncompressed.md contains behavioral content outside launch-script scope

**Affected file:** spec-auditing/uncompressed.md

**Evidence:**
```
## Modes
- **Audit** (default) — read-only...
- **Fix** (`--fix`) — modifies target...
- **Spec-only** — used when...

## When to Use
- Before committing compressed files...
- Checking agent files...

## Errors / Stop Gates
- **Missing target** — STOP...

## Output
When producing file output: follow the `audit-reporting` skill...
```

**Explanation:**
The spec-auditing/uncompressed.md violates the launch-script form rule A-FM-10. According to the skill-auditing specification, `uncompressed.md` (the launch-script form for a dispatch skill) must contain ONLY:
1. Frontmatter (name, description)
2. Optional H1
3. Dispatch invocation + input signature
4. Return contract
5. Optional 2-line iteration-safety pointer

The current uncompressed.md includes additional sections:
- "Modes" (behavioral descriptions)
- "When to Use" (operational guidance)
- "Errors / Stop Gates" (behavior/output descriptions)
- "Output" (output specification)
- "Related" (breadcrumbs/related skills)

These sections belong in `instructions.uncompressed.md` or `spec.md`, not in the launch-script form. The uncompressed.md should serve as a minimal routing card for invoking the dispatch agent, while detailed procedures and context belong in the instruction file.

**Recommended fix:**
Remove the "Modes," "When to Use," "Errors / Stop Gates," "Output," and "Related" sections from uncompressed.md. The minimal form should be:

```markdown
---
name: spec-auditing
description: >-
  Audit a spec/companion pair or a spec alone. Dispatch instructions.txt —
  don't audit inline.
---

# Spec Auditing

Without reading `instructions.txt` yourself, use a Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory).
Input: `<target-path> [--spec <spec-path>] [--fix]`"

**Do NOT attempt spec auditing inline.** Inline attempts produce shallow, inconsistent audits. The dispatched agent runs in isolated context with its own strict disposition (defined in `instructions.txt`).

## Parameters

- `target-path` (string, required): path to spec file or companion file to audit
- `--spec <spec-path>` (string, optional): explicit path to spec file (pair-audit mode)
- `--fix` (flag, optional): enable fix mode — target must be git-tracked and clean; modifies target to match spec, up to 3 passes

**Returns:** Pass / Pass with Findings / Fail. Each finding includes: Finding ID, Severity, Title, Affected file(s), Evidence (with quote), Explanation, Recommended fix.

One skill per invocation. Chain multiple subjects as separate runs.

## Iteration Safety

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.
```

## Recommendation

Fix the launch-script form by removing sections 1–5 (Modes, When to Use, Errors/Stop Gates, Output, Related). All behavioral, procedural, and reference content belongs in instructions.uncompressed.md or spec.md. Re-audit after fix to confirm PASS.

## References

- spec-auditing/uncompressed.md — launch-script form violations (A-FM-10)
