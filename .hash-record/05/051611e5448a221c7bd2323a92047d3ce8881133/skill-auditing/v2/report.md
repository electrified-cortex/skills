---
file_paths:
  - copilot-cli/SKILL.md
  - copilot-cli/spec.md
  - copilot-cli/uncompressed.md
  - copilot-cli/eval.md
operation_kind: skill-auditing/v2
model: haiku-class
result: findings
---

# Result

NEEDS_REVISION

## Skill Audit: copilot-cli

**Verdict:** NEEDS_REVISION
**Type:** dispatch
**Path:** copilot-cli/

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Dispatch skill (has uncompressed.md host card and sub-skills in copilot-cli-ask/, copilot-cli-explain/, copilot-cli-review/) |
| Inline/dispatch consistency | PASS | Dispatch file present (uncompressed.md); SKILL.md is minimal routing card |
| Structure | PASS | Frontmatter present with name and description; routing table clear |
| Input/output double-spec (A-IS-1) | N/A | Router does not consume overlapping inputs from sub-skills |
| Sub-skill input isolation (A-IS-2) | N/A | Sub-skills are independent; router does not pass sibling sub-skill outputs as inputs |
| Frontmatter | PASS | SKILL.md has required frontmatter (name: copilot-cli, description present) |
| Name matches folder (A-FM-1) | PASS | name: copilot-cli matches folder name exactly |
| H1 per artifact (A-FM-3) | FAIL | SKILL.md contains real H1 marker on line 7 (`# copilot-cli`). SKILL.md (compiled artifact) MUST NOT contain H1. Violation. |
| No duplication | PASS | Skill not duplicating existing capability; routing is orthogonal pattern |
| Orphan files (A-FS-1) | PASS | skill.index and skill.index.md are referenced in SKILL.md; eval.md is present and valid |
| Missing referenced files (A-FS-2) | PASS | All sub-skills referenced (copilot-cli-ask, copilot-cli-explain, copilot-cli-review) exist |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | PASS | Content faithful; uncompressed adds full Behavior and Requirements detail; SKILL.md compresses to routing table + rules. No contradiction. |
| instructions.txt ↔ instructions.uncompressed.md | N/A | No instructions.txt present; routing is embedded in uncompressed.md |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md co-located with skill_dir |
| Required sections | PASS | spec.md contains Purpose, Scope, Definitions, Intent, Operation Routing Table, Requirements, Behavior, Error Handling, Precedence Rules, Constraints, Don'ts, Lessons |
| Normative language | PASS | Uses "must", "must not", "required", "shall" throughout; enforceable |
| Internal consistency | PASS | No contradictions between Scope (routing only), Intent (host doesn't know flag details), and Requirements (router doesn't execute commands) |
| Spec completeness | PASS | All terms defined; behavior explicitly stated; operation routing table complete with three operations |
| Coverage | PASS | Every normative requirement in spec is represented in SKILL.md and uncompressed.md |
| No contradictions | PASS | SKILL.md and uncompressed.md align with spec requirements |
| No unauthorized additions | PASS | No normative requirements in SKILL.md/uncompressed.md absent from spec |
| Conciseness | PASS | SKILL.md is agent-facing reference card; agent can skim routing table and rules in one pass |
| Completeness | PASS | All runtime instructions present; edge cases addressed (ambiguous operation → ask; sub-skill missing → report and stop; copilot unavailable → surface error) |
| Breadcrumbs | PASS | Related section lists sub-skills (copilot-cli-review, copilot-cli-ask, copilot-cli-explain); targets valid |
| Cost analysis | PASS | Single dispatch turn; no inline operation logic; sub-skills own execution |
| No dispatch refs | N/A | No instructions.txt present; instructions embedded in uncompressed.md are not dispatch-step descriptions but host-facing behavior contract |
| No spec breadcrumbs | PASS | Neither SKILL.md nor uncompressed.md references spec.md; spec is design document |
| Eval log (informational) | PRESENT | eval.md documents effectiveness evaluation of copilot-cli-review sub-skill; findings logged |
| Description not restated (A-FM-2) | PASS | Description (router, dispatch) is not verbatim repeated in body prose |
| No exposition in runtime (A-FM-5) | PASS | No rationale, threat-model narrative, or background prose in SKILL.md or uncompressed.md |
| No non-helpful tags (A-FM-6) | PASS | No bare type labels or descriptor lines with no operational value |
| No empty sections (A-FM-7) | PASS | All headings have body content or subsections |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety guard present (N/A for non-auditing skills) |
| Iteration-safety pointer form (A-FM-9a) | N/A | Not applicable |
| No verbatim Rule A/B (A-FM-9b) | N/A | Not applicable |
| Cross-reference anti-pattern (A-XR-1) | PASS | No cross-reference to spec.md or uncompressed.md in runtime artifacts |
| Launch-script form (A-FM-10) | PASS | uncompressed.md serves as host card; contains frontmatter, H1, operation routing table, behavior, requirements; does NOT contain executor procedure (belongs in instructions.uncompressed.md) or rationale (belongs in spec.md) |
| Return shape declared (DS-1) | PASS | Host card implicitly declares return contract: "pass the full task to the correct sub-skill; return the sub-skill's structured result unchanged" |
| Host card minimalism (DS-2) | PASS | uncompressed.md does not contain cache mechanism descriptions, tool-fallback hints, subjective qualifiers, or implementation details; clean invocation contract |
| Description trigger phrases (DS-3) | PASS | Description has trigger phrases: "use copilot CLI, copilot command, run copilot, ask copilot, explain with copilot, copilot review" |
| Inline dispatch guard (DS-4) | N/A | Not using the inline dispatch pattern (no variable bindings) |
| No substrate duplication (DS-5) | PASS | No inlining of hash-record or substrate skill details |
| No overbuilt sub-skill dispatch (DS-6) | PASS | Each sub-skill handles legitimate operation scope (review, ask, explain); not trivial 2-3-step operations |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| SKILL.md | Not empty | PASS | Contains routing table and rules |
| SKILL.md | Frontmatter (required) | PASS | YAML frontmatter with name, description present |
| SKILL.md | No abs-path leaks | PASS | No drive-letter or root-anchored paths detected |
| uncompressed.md | Not empty | PASS | Contains purpose, routing table, behavior, requirements, definitions, error handling, constraints, lessons |
| uncompressed.md | Frontmatter (not required for .md) | N/A | Not required for uncompressed.md |
| uncompressed.md | No abs-path leaks | PASS | No path leaks detected |
| spec.md | Not empty | PASS | Full specification document |
| spec.md | Frontmatter (not required) | N/A | Not required for spec.md |
| spec.md | No abs-path leaks | PASS | No path leaks detected |
| spec.md | Purpose section | PASS | `## Purpose` present |
| spec.md | Parameters section | PASS | Implicit in Operation Routing Table and Requirements |
| spec.md | Output section | PASS | Output contract implicit in routing ("return the sub-skill's structured result unchanged") |
| eval.md | Not empty | PASS | Contains evaluation round with findings |

### Issues

1. **A-FM-3 (HIGH):** SKILL.md contains a real H1 marker (`# copilot-cli` on line 7). Per H1 artifact rule, SKILL.md (compiled artifact) MUST NOT have H1. H1 markers are only allowed in uncompressed.md. Fix: Remove the H1 from SKILL.md; replace with a comment or leave as content under frontmatter.

### Recommendation

Remove the H1 marker from SKILL.md line 7. The frontmatter `name:` and `description:` provide sufficient context; the H1 is redundant and violates the compiled-artifact rule. Consider recompressing from uncompressed.md if available (strip the H1 during compression).
