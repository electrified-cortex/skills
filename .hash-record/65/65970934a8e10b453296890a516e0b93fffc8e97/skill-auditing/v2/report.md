---
file_paths:
  - skill-auditing/SKILL.md
  - skill-auditing/eval.txt
  - skill-auditing/eval.uncompressed.md
  - skill-auditing/instructions.txt
  - skill-auditing/instructions.uncompressed.md
  - skill-auditing/spec.md
  - skill-auditing/uncompressed.md
operation_kind: skill-auditing/v2
model: sonnet-class
result: findings
---

# Result

NEEDS_REVISION

## Skill Audit: skill-auditing

**Verdict:** NEEDS_REVISION
**Type:** dispatch
**Path:** skill-auditing

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Context-independent audit procedure — correct as dispatch |
| Inline/dispatch consistency | PASS | `instructions.txt` present; SKILL.md is a routing card |
| Structure | PASS | Frontmatter present; dispatch invocation wired; `instructions.txt` reachable |
| Input/output double-spec (A-IS-1) | PASS | No double-specification found |
| Sub-skill input isolation (A-IS-2) | N/A | No sub-skills present |
| Frontmatter | PASS | `name` and `description` present and accurate |
| Name matches folder (A-FM-1) | PASS | `name: skill-auditing` matches folder name in both SKILL.md and uncompressed.md |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no H1; uncompressed.md has H1; instructions.uncompressed.md has H1; instructions.txt has no H1 |
| No duplication | PASS | No duplicate capability found |
| Orphan files (A-FS-1) | PASS | All files are well-known role files |
| Missing referenced files (A-FS-2) | PASS | result.sh, result.ps1, instructions.txt, ../dispatch/SKILL.md all exist on disk |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | PASS | SKILL.md faithfully compresses uncompressed.md with no loss of intent |
| instructions.txt ↔ instructions.uncompressed.md | PASS | instructions.txt faithfully compresses all checks, steps, and report format with no loss of intent |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present co-located with skill-auditing |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Requirements use must/shall throughout |
| Internal consistency | PASS | No contradictions or duplicate rules |
| Spec completeness | PASS | All terms defined; behavior explicitly stated |
| Coverage | PASS | All spec requirements represented in instructions.txt |
| No contradictions | PASS | SKILL.md and instructions.txt do not contradict spec |
| No unauthorized additions | PASS | No normative requirements added beyond spec |
| Conciseness | PASS | SKILL.md is a lean routing card; instructions.txt is dense and agent-facing |
| Completeness | PASS | All runtime instructions present; edge cases addressed |
| Breadcrumbs | PASS | Dispatch routing card; no Related section required |
| Cost analysis | PASS | Dispatch agent used; instructions.txt is 388 lines (under 500 limit); single dispatch turn |
| No dispatch refs | PASS | instructions.txt contains no directives to dispatch other skills |
| No spec breadcrumbs | PASS | SKILL.md and instructions.txt do not reference their own companion spec.md |
| Eval log (informational) | PRESENT | eval.txt and eval.uncompressed.md present |
| Description not restated (A-FM-2) | PASS | Description frontmatter not duplicated in artifact bodies |
| No exposition in runtime (A-FM-5) | FAIL | See Issues |
| No non-helpful tags (A-FM-6) | PASS | No bare descriptor labels found |
| No empty sections (A-FM-7) | PASS | All headings have body content |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety blurb in any runtime artifact |
| Iteration-safety pointer form (A-FM-9a) | N/A | No iteration-safety reference in runtime artifacts |
| No verbatim Rule A/B (A-FM-9b) | N/A | No iteration-safety reference in runtime artifacts |
| Cross-reference anti-pattern (A-XR-1) | PASS | References to uncompressed.md and spec.md in instructions.txt are subject-matter mentions — explicitly exempted |
| Launch-script form (A-FM-10) | PASS | uncompressed.md contains only permitted content: frontmatter, H1, input signature, inline result check sections, dispatch invocation |
| Return shape declared (DS-1) | PASS | Return shape declared in both SKILL.md and uncompressed.md |
| Host card minimalism (DS-2) | PASS | uncompressed.md has no forbidden content; inline result check sections are permitted per DS-2 exception |
| Description trigger phrases (DS-3) | PASS | Description follows action + Triggers pattern with 5 trigger phrases |
| Inline dispatch guard (DS-4) | PASS | NEVER READ guard present; Read and follow form used; Follow dispatch skill delegation present |
| No substrate duplication (DS-5) | PASS | Report frontmatter schema is this skill's own output format, not hash-record internal schema duplication |
| No overbuilt sub-skill dispatch (DS-6) | N/A | No sub-skill dispatches |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| `SKILL.md` | Not empty | PASS | |
| `SKILL.md` | Frontmatter | PASS | YAML frontmatter at line 1 |
| `SKILL.md` | No abs-path leaks | PASS | |
| `uncompressed.md` | Not empty | PASS | |
| `uncompressed.md` | Frontmatter | PASS | YAML frontmatter at line 1 |
| `uncompressed.md` | No abs-path leaks | PASS | |
| `instructions.txt` | Not empty | PASS | |
| `instructions.txt` | Frontmatter | N/A | Not SKILL.md or agent.md |
| `instructions.txt` | No abs-path leaks | PASS | Pattern examples are meta-references, not leaked paths |
| `instructions.uncompressed.md` | Not empty | PASS | |
| `instructions.uncompressed.md` | Frontmatter | N/A | Not SKILL.md or agent.md |
| `instructions.uncompressed.md` | No abs-path leaks | PASS | Pattern examples are meta-references, not leaked paths |
| `spec.md` | Not empty | PASS | |
| `spec.md` | Frontmatter | N/A | Not SKILL.md or agent.md |
| `spec.md` | No abs-path leaks | PASS | Pattern examples are meta-references, not leaked paths |
| `eval.txt` | Not empty | PASS | |
| `eval.txt` | No abs-path leaks | PASS | |
| `eval.uncompressed.md` | Not empty | PASS | |
| `eval.uncompressed.md` | No abs-path leaks | PASS | |
| `result.spec.md` | All checks | SKIPPED | Protected — cannot inspect per task constraints |
| `sealing-strategy.spec.md` | All checks | SKIPPED | Protected — cannot inspect per task constraints |

### Issues

- **[A-FM-5 HIGH]** `instructions.uncompressed.md` line 205 contains rationale embedded in the "No spec breadcrumbs in runtime" check body: "The compressed runtime is self-contained; nudging the agent toward the spec inflates context and defeats compression." This explains why the rule exists rather than stating it operationally. Rationale belongs exclusively in spec.md. Fix: remove that clause from `instructions.uncompressed.md`, then recompress to `instructions.txt`. The operative rule ("SKILL.md and instructions.txt must not reference the skill's own companion spec.md") stands without the explanatory clause.

### Recommendation

Remove the rationale clause ("The compressed runtime is self-contained; nudging the agent toward the spec inflates context and defeats compression.") from the "No spec breadcrumbs in runtime" section in `instructions.uncompressed.md` and recompress to `instructions.txt`.
