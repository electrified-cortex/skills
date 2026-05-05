---
file_paths:
  - tool-auditing/instructions.uncompressed.md
  - tool-auditing/SKILL.md
  - tool-auditing/spec.md
operation_kind: skill-auditing/v2
model: sonnet-class
result: findings
---

# Result

NEEDS_REVISION

## Per-file Basic Checks

| File | Check | Status | Notes |
| --- | --- | --- | --- |
| SKILL.md | Not empty | PASS | Has content |
| SKILL.md | Frontmatter required | PASS | `name` + `description` present |
| SKILL.md | No absolute-path leaks | PASS | No absolute paths found |
| spec.md | Not empty | PASS | Has content |
| spec.md | No absolute-path leaks | PASS | No absolute paths found |
| instructions.uncompressed.md | Not empty | PASS | Has content |
| instructions.uncompressed.md | No absolute-path leaks | PASS | Pattern references in backticks only; no real file-system paths |

## Step 1 — Compiled Artifacts

| Check | Status | Notes |
| --- | --- | --- |
| Classification | PASS | `instructions.txt` present; SKILL.md is a minimal routing card — correctly dispatch |
| A-FM-1: Name matches folder | PASS | `name: tool-auditing` matches folder name |
| A-FM-3: H1 in SKILL.md | PASS | No real H1; starts with frontmatter then `## Input` |
| A-FM-3: H1 in instructions.uncompressed.md | PASS | Starts with `# Tool Auditing` |
| A-IS-1: No input/output double-specification | PASS | No sub-skill output re-passed as input |
| A-IS-2: Sub-skill input isolation | PASS | No cross-sub-skill data flow |
| A-FS-1: Orphan files | PASS | All files are well-known role files; no orphans |
| A-FS-2: Missing referenced files | PASS | `instructions.txt`, `result.sh`, `result.ps1` all present |
| A-FM-5: No exposition in runtime artifacts | PASS | SKILL.md is a clean routing card; instructions.uncompressed.md is fully procedural |
| A-FM-6: No non-helpful tags | PASS | No non-operational descriptor lines found |
| A-FM-7: No empty leaves | PASS | All headings have body content |
| A-FM-8: Iteration-safety placement | PASS | No iteration-safety blurb in instructions.uncompressed.md |
| A-XR-1: Cross-reference anti-pattern | PASS | No pointers to other skills' uncompressed.md or spec.md |

## Step 2 — Parity Check

| Pair | Status | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | N/A | No `uncompressed.md` present |
| instructions.txt ↔ instructions.uncompressed.md | N/A | `instructions.txt` is dispatch-only; treated as opaque |

## Step 3 — Spec Alignment

| Check | Status | Notes |
| --- | --- | --- |
| spec.md exists | PASS | Present in tool-auditing/ |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Uses FAIL/WARN with clear, testable conditions |
| Internal consistency | PASS | No contradictions between sections |
| Spec completeness | FINDINGS | Missing trio concept and Check 2 (see F1, F2) |
| Coverage | FINDINGS | Check 2 and trio scope in instructions.uncompressed.md not covered by spec.md |
| No contradictions | PASS | No direct conflicts found |
| No unauthorized additions | FINDINGS | instructions.uncompressed.md adds Check 2 and trio scope not present in spec.md |

## Findings

### F1 — Spec missing trio concept (NEEDS_REVISION)

spec.md describes a single-script audit (7 checks; "Tool script: a PowerShell or Bash script") but
instructions.uncompressed.md implements a trio audit: `<stem>.sh` + `<stem>.ps1` + `<stem>.spec.md`
all required (Check 1). The spec scope does not define the trio and does not cover Check 1.

Fix: update `tool-auditing/spec.md` — add "tool trio" to `## Definitions`; expand `## Requirements`
to cover Check 1 (trio completeness); remove the `tools/` directory restriction from the Tool script
definition.

### F2 — Unauthorized addition: Check 2 not in spec (NEEDS_REVISION)

instructions.uncompressed.md implements "Check 2 — Spec describes THIS tool and intent aligns with
implementation" as a normative FAIL-level check. This check is absent from spec.md `## Requirements`.
The spec must be updated to declare this check, or the check must be removed from the instructions.

Fix: add Check 2 to `tool-auditing/spec.md` `## Requirements` with FAIL condition and fix guidance.

### F3 — Scope definition restricts to tools/ directory (LOW)

spec.md `## Definitions` defines "Tool script" as "a PowerShell or Bash script in the `tools/`
directory." instructions.uncompressed.md applies the audit to any trio in any directory without this
restriction. The definition does not reflect actual behavior.

Fix: remove the `tools/` restriction from the Tool script definition in `tool-auditing/spec.md`.
