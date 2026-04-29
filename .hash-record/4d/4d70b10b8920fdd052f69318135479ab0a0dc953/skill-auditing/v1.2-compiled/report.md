---
file_paths:
  - tool-auditing/SKILL.md
  - tool-auditing/instructions.txt
  - tool-auditing/spec.md
operation_kind: skill-auditing
model: haiku-class
result: fail
---

# Result

FAIL

## Skill Audit: tool-auditing

**Verdict:** FAIL
**Type:** dispatch
**Path:** tool-auditing
**Failed phase:** 2

### Phase 1 — Spec Gate

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Uses "must", "FAIL if", "WARN if", "PASS if" throughout |
| Internal consistency | PASS | No contradictions; scope clearly defined; requirements coherent |
| Completeness | PASS | All terms defined; all behavior explicit |

### Phase 2 — Skill Smoke Check

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Correctly identified as dispatch skill |
| Inline/dispatch consistency | PASS | Instruction file (instructions.txt) exists; SKILL.md is routing card |
| Structure | PASS | Dispatch skill structure sound; routing card references instructions |
| Input/output double-spec (A-IS-1) | PASS | No duplication with sub-skills |
| Frontmatter | PASS | name and description present and accurate |
| Name matches folder (A-FM-1) | PASS | name: "tool-auditing" matches folder name |
| H1 per artifact (A-FM-3) | FAIL | instructions.txt contains H1 heading (`# Tool Auditing`) but MUST NOT. SKILL.md correctly has no H1 |
| No duplication | PASS | No existing similar capability |

### Phase 3 — Spec Compliance

| Check | Result | Notes |
| --- | --- | --- |
| Coverage | PASS | All spec requirements represented in instructions.txt |
| No contradictions | PASS | instructions.txt aligns with spec |
| No unauthorized additions | PASS | No normative additions not in spec |
| Conciseness | PASS | Dense, agent-facing, no excessive rationale |
| Completeness | PASS | All checks described with levels (FAIL/WARN); edge cases covered |
| Breadcrumbs | PASS | Iteration-safety reference correct: "See ../iteration-safety/SKILL.md" |
| Cost analysis | PASS | Dispatch pattern appropriate; instructions right-sized |
| No dispatch refs | PASS | instructions.txt does not tell agent to dispatch other skills |
| No spec breadcrumbs | PASS | Neither SKILL.md nor instructions.txt reference own spec.md |
| Description not restated (A-FM-2) | PASS | No verbatim restatement of description in body |
| No exposition in runtime (A-FM-5) | PASS | instructions.txt is procedural; no rationale/why present |
| No non-helpful tags (A-FM-6) | PASS | No non-operational descriptor lines |
| No empty sections (A-FM-7) | PASS | All sections in all artifacts have content |
| Iteration-safety placement (A-FM-8) | PASS | Iteration safety correctly in spec.md, not in runtime |
| Iteration-safety pointer form (A-FM-9a) | PASS | Pointer form correct in spec.md |
| No verbatim Rule A/B (A-FM-9b) | PASS | No verbatim restatement of iteration-safety rules |
| Cross-reference anti-pattern (A-XR-1) | PASS | Reference is to SKILL.md (not uncompressed.md or spec.md); allowed |
| Launch-script form (A-FM-10) | N/A | N/A — not applicable for non-launch-script dispatch skills |
| Return shape declared (DS-1) | PASS | SKILL.md declares return shapes: PASS, PASS_WITH_FINDINGS, FAIL, ERROR |
| Host card minimalism (DS-2) | PASS | SKILL.md avoids cache mechanism descriptions and internal conditionals |
| Description trigger phrases (DS-3) | PASS | Description has 5 trigger phrases as required |
| Inline dispatch guard (DS-4) | FAIL | Missing canonical cross-platform dispatch pattern. SKILL.md references "../dispatch/SKILL.md" instead of embedding dispatch instructions. Must contain explicit Claude Code and VS Code dispatch blocks with model specification and NEVER READ reinforcement |
| No substrate duplication (DS-5) | PASS | No hash-record path schema or frontmatter shape duplication |
| No overbuilt sub-skill dispatch (DS-6) | PASS | No sub-skill usage for trivial work |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| tool-auditing/SKILL.md | Not empty | PASS | Contains routing instructions |
| tool-auditing/SKILL.md | Frontmatter | PASS | Has name and description frontmatter |
| tool-auditing/SKILL.md | No absolute-path leaks | PASS | No drive-letter or POSIX root paths |
| tool-auditing/instructions.txt | Not empty | PASS | Contains full procedure (approx 200 lines) |
| tool-auditing/instructions.txt | No absolute-path leaks | PASS | Uses placeholders; no absolute paths |
| tool-auditing/spec.md | Not empty | PASS | Contains full specification |
| tool-auditing/spec.md | No absolute-path leaks | PASS | No drive-letter or POSIX root paths |

## Findings

### A-FM-3 FAIL: H1 in instructions.txt

**Issue:** instructions.txt contains H1 heading (`# Tool Auditing`) on line 1.

**Rule:** `instructions.txt` (if present) MUST NOT contain H1. H1 is reserved for `SKILL.md` (which MUST NOT have it) and `uncompressed.md` (which MUST have it). This protects the artifact namespace and prevents title confusion in multi-file contexts.

**Fix:** Remove the H1 heading from line 1 of instructions.txt. The section headers (## Inputs, ## Procedure, etc.) are appropriate; the top-level H1 must go.

---

### DS-4 FAIL: Missing Canonical Dispatch Guard

**Issue:** SKILL.md (Inspect section) references "../dispatch/SKILL.md" instead of embedding the canonical cross-platform dispatch pattern inline.

**Rule:** Dispatch instruction MUST follow the canonical pattern with explicit platform-specific blocks (Claude Code + VS Code), model specification, and three reinforcements about NOT reading the instruction file directly.

**Current pattern (incomplete):**
```
Follow `dispatch` skill. See `../dispatch/SKILL.md`.
```

**Required pattern (full):**
```
Without reading `<instructions>` yourself, spawn a zero-context, <model>-class sub-agent:

**Claude Code:** `Agent` tool. Pass: `"Read and follow <instructions-abspath> here. Input: <input-args>"`

**VS Code / Copilot:** `runSubagent(model: "Claude Haiku 4.5", prompt: "Read and follow <instructions-abspath> in <skill_dir>. Input: <input-args>")`

Don't read `<instructions>` yourself.

Returns: <return contract>

NEVER READ OR INTERPRET <instructions> YOURSELF. Let the sub-agent do the work.
```

**Fix:** Inline the full canonical dispatch pattern in the SKILL.md Inspect section. Use `haiku-class` (matches spec requirement for "fast-cheap" model). Ensure three reinforcements present (opening "Without reading", mid-block "Don't read", closing "NEVER READ...UPPERCASE").

---

## Recommendation

Fix A-FM-3 (remove H1 from instructions.txt) and DS-4 (inline canonical dispatch pattern with full cross-platform form and reinforcements). Re-audit after changes.
