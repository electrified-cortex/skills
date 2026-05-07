---
file_paths:
  - code-review/SKILL.md
  - code-review/instructions.txt
  - code-review/instructions.uncompressed.md
  - code-review/spec.md
  - code-review/uncompressed.md
operation_kind: skill-auditing/v2
model: sonnet-class
result: fail
---

# Result

FAIL

## Skill Audit: code-review

**Verdict:** FAIL
**Type:** dispatch
**Path:** code-review/

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | `instructions.txt` present → dispatch |
| Inline/dispatch consistency | PASS | SKILL.md contains dispatch invocations referencing `instructions.txt` |
| Structure | FAIL | SKILL.md is not a minimal routing card — contains `## Goal`, `## When to Use`, full `## Review Modes` table, complete tiered and single-adversary procedure blocks, and output schemas. Dispatch SKILL.md must contain only dispatch invocation, input signature, and return contract. |
| Input/output double-spec (A-IS-1) | PASS | No input overriding sub-skill output path |
| Sub-skill input isolation (A-IS-2) | N/A | No sibling sub-skill output consumed as input |
| Frontmatter | PASS | `name` and `description` present |
| Name matches folder (A-FM-1) | PASS | `name: code-review` matches folder `code-review` |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no real H1; `uncompressed.md` has `# Code Review`; `instructions.uncompressed.md` has `# Code Review Pass` |
| No duplication | PASS | Skill is distinct from `spec-auditing` and `skill-auditing` |
| Orphan files (A-FS-1) | FAIL | `eval.md`, `skill.index`, `skill.index.md` are not well-known role files and are unreferenced by SKILL.md, uncompressed.md, spec.md, or instructions.uncompressed.md → LOW orphans (×3) |
| Missing referenced files (A-FS-2) | PASS | `instructions.txt` exists; no other sibling file pointers |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | FAIL | SKILL.md contains content absent from uncompressed.md: Swarm mode row in `## Review Modes` table, full Single-Adversary mode section (separate input interface: `file_path`/`pr_number`/`model`, distinct output contract). SKILL.md is more detailed than its declared source — inverted parity. Fix: edit `uncompressed.md` to align, then recompress. Or remove unauthorized content from SKILL.md. |
| instructions.txt ↔ instructions.uncompressed.md | FAIL | Hallucination Filter section present in `instructions.uncompressed.md` but absent from `instructions.txt`. Parity failure — compiled artifact is missing normative executor behavior. Fix: edit `instructions.uncompressed.md`, then recompress to `instructions.txt`. |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | `spec.md` co-located |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Uses `must`, `shall`, `required` throughout |
| Internal consistency | PASS | No contradictions between spec sections |
| Spec completeness | PASS | All terms defined; behavior explicitly stated |
| Coverage | FAIL | Hallucination Filter is normative in spec (`Behavior > Hallucination filter`) but absent from `instructions.txt` (executor artifact). Dispatched agents won't apply the filter. |
| No contradictions | FAIL | Single-Adversary mode in SKILL.md uses a conflicting input interface (`file_path` or `pr_number` + `model`) vs spec's defined inputs (`change_set`, `tier`, `prior_findings`, `focus`, `context_pointer`). Single-adversary is also a single-pass mode, contradicting spec's two-pass requirement (Requirements > Procedure items 1–7). |
| No unauthorized additions | FAIL | SKILL.md introduces Swarm mode and Single-Adversary mode — neither appears in spec. Both modes define behavior and input interfaces absent from the spec. Spec is authoritative; SKILL.md is subordinate. |
| Conciseness | FAIL | SKILL.md reads as documentation, not a routing card. Named patterns: `too much why — move rationale to spec.md` (`## Goal`, `## When to Use`); `exposition where a decision tree would serve` (modes table, extensive procedure blocks). |
| Completeness | PASS | All runtime instructions present in instructions.txt for the two-pass procedure |
| Breadcrumbs | PASS | `uncompressed.md` Related line references valid canonical names |
| Cost analysis | PASS | Uses dispatch skill (zero-context isolation); `instructions.txt` is right-sized |
| No dispatch refs | PASS | `instructions.txt` contains no dispatch instructions |
| No spec breadcrumbs | PASS | SKILL.md and `instructions.txt` do not reference own `spec.md` |
| Eval log (informational) | PRESENT | `eval.md` present |
| Description not restated (A-FM-2) | FAIL | Phrase "Read-only — never modifies code" appears in both description frontmatter and SKILL.md `## Goal` body. LOW (closely similar, not verbatim). |
| No exposition in runtime (A-FM-5) | FAIL | SKILL.md: `## Goal` (background) and `## When to Use` (usage rationale) are exposition — move rationale to `spec.md`. `instructions.uncompressed.md`: `## When to Use` section (usage rationale); Steps 6–7 describe calling-agent orchestration behavior, not executor behavior; `## Calling Agent Rules` and `## Aggregated Result (calling agent assembles after all passes)` are host-facing content misplaced in executor instructions. |
| No non-helpful tags (A-FM-6) | PASS | No bare type labels found |
| No empty sections (A-FM-7) | PASS | All sections have body content |
| Iteration-safety placement (A-FM-8) | FAIL | Iteration Safety 2-line block present in `instructions.uncompressed.md`. Must be absent from executor instructions — its only valid placement is SKILL.md or uncompressed.md. |
| Iteration-safety pointer form (A-FM-9a) | FAIL | `instructions.uncompressed.md` wraps the iteration-safety 2-line block under `## Iteration Safety` heading. Exact sanctioned form requires only 2 bare lines with no heading. Remove the heading. |
| No verbatim Rule A/B (A-FM-9b) | N/A | Covered by A-FM-8 (block must not exist in executor instructions) |
| Cross-reference anti-pattern (A-XR-1) | FAIL | `See ../iteration-safety/SKILL.md` in `instructions.uncompressed.md` is a path-only reference with no canonical name preceding it. LOW (also subsumed by A-FM-8). |
| Launch-script form (A-FM-10) | FAIL | `uncompressed.md` contains content prohibited for dispatch host cards: (1) `## Orchestration` — output format description and phase descriptions not allowed; (2) `## Caller obligations` — behavior section not allowed; (3) `Related:` line — related breadcrumbs not allowed. |
| Return shape declared (DS-1) | PASS | Aggregated result shape declared in `uncompressed.md`; skill returns inline JSON, not file artifact |
| Host card minimalism (DS-2) | FAIL | `uncompressed.md` (host card) contains: `## Orchestration` prose describing multi-pass behavior; `## Caller obligations` behavior section. Neither belongs in the host card. |
| Description trigger phrases (DS-3) | FAIL | Trigger separator in description is em-dash (`—`) where spec pattern requires hyphen (`-`). `Triggers -` literal not present. LOW. |
| Inline dispatch guard (DS-4) | FAIL | `uncompressed.md` is missing required canonical dispatch pattern: (1) no `<instructions>` variable binding with `NEVER READ` guard on same line; (2) no `Follow dispatch skill. See .../dispatch/SKILL.md` delegation line. SKILL.md has the canonical pattern; `uncompressed.md` does not — additional parity failure. |
| No substrate duplication (DS-5) | N/A | No hash-record schema inlined |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Sub-skill dispatches are substantive review passes, not trivial |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| `SKILL.md` | Not empty | PASS | |
| `SKILL.md` | Frontmatter required | PASS | YAML block at line 1 |
| `SKILL.md` | No abs-path leaks | PASS | Template placeholder `<instructions-abspath>` is not a path literal |
| `uncompressed.md` | Not empty | PASS | |
| `uncompressed.md` | Frontmatter required | PASS | |
| `uncompressed.md` | No abs-path leaks | PASS | |
| `instructions.uncompressed.md` | Not empty | PASS | |
| `instructions.uncompressed.md` | Frontmatter required | N/A | Not SKILL.md or agent.md |
| `instructions.uncompressed.md` | No abs-path leaks | PASS | |
| `spec.md` | Not empty | PASS | |
| `spec.md` | Frontmatter required | N/A | Not SKILL.md or agent.md |
| `spec.md` | No abs-path leaks | PASS | |
| `instructions.txt` | No abs-path leaks | PASS | .txt — md checks not applicable |

### Issues

- **Structure (FAIL):** SKILL.md is not a minimal routing card. Sections `## Goal`, `## When to Use`, `## Review Modes` (modes table), and the full `## Procedure` including Single-Adversary mode are not routing-card content. Fix: strip SKILL.md to dispatch invocation signature, parameters, and return contract only. Move any modes rationale to `spec.md`.

- **Parity SKILL.md ↔ uncompressed.md (FAIL):** SKILL.md adds Swarm mode and Single-Adversary mode that do not exist in `uncompressed.md`. The compiled artifact is more expansive than its source — inverted direction. Fix: align `uncompressed.md` with SKILL.md if these modes are intentional, then recompress. If unauthorized (see below), remove from SKILL.md first.

- **Parity instructions.txt ↔ instructions.uncompressed.md (FAIL):** Hallucination Filter is in `instructions.uncompressed.md` but absent from `instructions.txt`. Dispatched agents won't apply it. Fix: edit `instructions.uncompressed.md` as source of truth, then recompress to `instructions.txt`.

- **Coverage (FAIL):** Hallucination Filter is normative in spec (`Behavior > Hallucination filter`) but absent from `instructions.txt`. Fix: recompress `instructions.uncompressed.md` to produce `instructions.txt` that includes the filter.

- **No contradictions (FAIL):** Single-Adversary mode in SKILL.md uses a different input surface (`file_path` or `pr_number`, `model`) than spec's defined inputs. It also permits a single-pass review, contradicting spec's two-pass requirement. Fix: remove Single-Adversary mode from SKILL.md, or update spec to authorize it.

- **No unauthorized additions (FAIL):** Swarm mode and Single-Adversary mode are absent from spec. Fix: remove from SKILL.md, or raise a spec change to authorize them.

- **Conciseness (FAIL):** `## Goal` and `## When to Use` in SKILL.md are rationale (`too much why`). The modes table and extensive procedure blocks make SKILL.md an essay rather than a reference card. Fix: move rationale to `spec.md`; reduce SKILL.md to dispatch invocation signature only.

- **A-FM-5 SKILL.md (FAIL):** `## Goal` and `## When to Use` are exposition. Fix: delete both sections; rationale belongs in `spec.md`.

- **A-FM-5 instructions.uncompressed.md (FAIL):** `## When to Use` section, Steps 6–7 (describing calling-agent orchestration), `## Calling Agent Rules`, and `## Aggregated Result (calling agent assembles after all passes)` are host-facing content in executor instructions. Fix: remove all host-facing content from executor instructions. Move calling-agent rules to `uncompressed.md` (host card). The Aggregated Result shape already appears in `uncompressed.md`.

- **A-FM-8 (FAIL):** Iteration Safety block present in `instructions.uncompressed.md`. Fix: delete it from `instructions.uncompressed.md`; it belongs only in `uncompressed.md` or `SKILL.md`.

- **A-FM-9a (FAIL):** `## Iteration Safety` heading precedes the 2-line pointer block in `instructions.uncompressed.md`. The sanctioned form is exactly 2 bare lines with no heading. Fix: delete the heading. (Moot once A-FM-8 fix is applied.)

- **A-FM-10 (FAIL):** `uncompressed.md` `## Orchestration` (output format description + phase descriptions), `## Caller obligations` (behavior section), and `Related:` line (related breadcrumbs) are prohibited in the host card. Fix: (1) Move orchestration step list to SKILL.md compressed card as inline dispatch steps; (2) Retain return contract (aggregated result fields) but restructure as a `Returns:` block; (3) Move caller obligations to a compressed form in SKILL.md; (4) Delete `Related:` line.

- **DS-2 (FAIL):** `uncompressed.md` `## Orchestration` is prose describing how the skill works internally. `## Caller obligations` is a behavior section. Both belong in `spec.md` (rationale) or compressed into the SKILL.md routing card (operational obligations). Fix: see A-FM-10 fix above.

- **DS-4 (FAIL):** `uncompressed.md` uses platform-specific invocation patterns (Claude Code / VS Code) without the canonical `<instructions>` binding with `NEVER READ` guard, and without a `Follow dispatch skill. See .../dispatch/SKILL.md` delegation line. SKILL.md has the canonical pattern but `uncompressed.md` does not — parity gap. Fix: update `uncompressed.md` to use canonical dispatch pattern per `dispatch/dispatch-pattern.md`, then recompress SKILL.md.

- **A-FS-1 LOW:** `eval.md`, `skill.index`, `skill.index.md` are not referenced by any skill source file. Fix: reference from SKILL.md or `spec.md`, or remove if stale.

- **A-FM-2 LOW:** "Read-only — never modifies code" appears in both the frontmatter description and SKILL.md `## Goal` body. Fix: remove from `## Goal` body (or delete `## Goal` entirely per A-FM-5 fix).

- **DS-3 LOW:** Description separator is em-dash (`—`) in `Triggers —`. The canonical pattern requires hyphen-minus (`-`): `Triggers - <phrases>`. Fix: change `Triggers —` to `Triggers -` in both SKILL.md and `uncompressed.md` frontmatter.

- **A-XR-1 LOW:** `See ../iteration-safety/SKILL.md` in `instructions.uncompressed.md` is a path-only reference with no canonical name prefix. Fix: prefix with `the \`iteration-safety\` skill` — but moot once A-FM-8 fix removes this block.

### Recommendation

Remove Single-Adversary and Swarm modes from SKILL.md or update spec to authorize them; strip SKILL.md to a minimal routing card; fix `uncompressed.md` to use canonical DS-4 dispatch pattern; recompress `instructions.txt` to include Hallucination Filter; purge A-FM-5 exposition and A-FM-8/A-FM-10 violations.
