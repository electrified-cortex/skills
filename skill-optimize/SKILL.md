---
name: skill-optimize
description: Analyzes single skill for architectural and structural improvement. Dispatches topic analysis to sub-agents, records findings in optimize-log. NEVER modifies source files. Use when: optimize skill, skill review, architectural review, skill improvement, find skill issues, analyze skill structure.
---

Analyzes single skill for architectural/structural improvement. Produces findings by category. NEVER modifies skill files. Records work in optimize-log.

Execution: hybrid dispatch. Host handles routing, log mgmt, output inline. Topic analysis (Step 4) → Sonnet sub-agent. Haiku qualifier (Step 3a) → lightweight topic selection.

Iteration: one invocation = one topic. Caller decides whether to re-run. Keeps passes focused.

Autonomy: fully autonomous. Writes are new or append-only (log row, report file). Source modifications = caller's responsibility.

Inputs:

Required: `<skill-path>` — path to skill dir (SKILL.md, spec.md, uncompressed.md, etc.)

Optional:
`<topic>` — topic slug (e.g. `dispatch`, `caching`). Provided → skip assessor, analyze directly.
`<mode>` — `assess-only` (pick next topic, no analysis) | default (assess then analyze)

Step 1 — Read Skill Source Files:

Read all from `<skill-path>` in order. Don't analyze yet.

1. `spec.md` — purpose, requirements, contract
2. `uncompressed.md` — full instructions
3. `SKILL.md` — compressed runtime instructions
4. `instructions.txt` — if present
5. `instructions.uncompressed.md` — if present

None exist → `ERROR: no skill source files found at <skill-path>`.

Step 2 — Check Optimize Log:

Log at `<skill-path>/optimize-log.md`. Read if exists. Use to skip topics marked `clean`/`rejected`/`acted`, continue from last session, avoid repeat analysis.

No log → proceed (first pass).

Log format:

```markdown
# Optimize Log: <skill-name>

## Topics Analyzed

| Topic | Date | Model | Findings | Status |
| ----- | ---- | ----- | -------- | ------ |
| DISPATCH | 2026-04-29 | Sonnet | 1 | pending |
| CACHING  | 2026-04-29 | Sonnet | 0 | clean   |
```

Status: `pending` (not reviewed) | `acted` (skill changed) | `deferred` (not acting yet) | `rejected` (doesn't apply) | `clean` (no findings)

Step 3 — Assessor Pass:

Goal: pick best next topic.

Skip if `<topic>` provided — verify `<skill-path>/topics/<topic>.md` exists. Not found → `ERROR: topic file not found at topics/<topic>.md`. Go to Step 4.

Assessor model: Sonnet-class. Reads qualifier signals; doesn't read topic specs.

3a — Qualifier Dispatch (Haiku-class):

One call. Pass: all skill source files (Step 1), ordered candidate topics (unanalyzed, not logged as `clean`/`rejected`/`acted`, sorted by priority tier), one-line descriptions only.

Prompt:

```text
Read the skill files below.
Scan the following topic list in order.
Return the FIRST topic that applies to this skill.
Short-circuit: stop at first match.

Format:
TOPIC: <SLUG>
APPLICABLE: yes | maybe
REASON: <one sentence>

If none apply: TOPIC: none
```

One result → 3b.

Second candidate: one additional call starting after previously returned slug. Don't chain more calls in single invocation.

3b — Assessor Decision:

From `yes`/`maybe` topics, pick one most likely to yield HIGH finding.

`TOPIC: none` → `No applicable topics found — all topics already logged or none apply to this skill.`

Tie-breaking:
1. `yes` over `maybe`
2. Structural before stylistic (DISPATCH, CACHING, DETERMINISM before WORDING, COMPRESSIBILITY)
3. Shorter spec (faster, same yield)
4. Default: DISPATCH → CACHING → DETERMINISM → INTERFACE CLARITY → LESS IS MORE

Emit: `Assessor selected: <TOPIC-SLUG> — <one-line reason>`

`assess-only` → stop here.

Fallback (no dispatch): skip 3a, inline heuristics:

| Signal | First topic |
| ------ | ----------- |
| Expensive/repetitive work, no cache | HASH RECORD |
| Spawns sub-agents or external tools | DISPATCH |
| Steps replaceable with regex/file check/git cmd | DETERMINISM |
| Contract (inputs/outputs) undocumented | INTERFACE CLARITY |
| Description vague or similar to neighbors | TOOL SIGNATURES |
| Instructions very long relative to task scope | LESS IS MORE |
| Judgment calls with no review step | SELF CRITIQUE |
| No output schema; format varies | OUTPUT FORMAT |
| Iterates with no hard cap | ITERATION SAFETY |
| External version refs / model name pinned | TEMPORAL DECAY |
| Default | DISPATCH |

Step 4 — Topic Analysis (Dispatched):

Dispatch Sonnet-class sub-agent. NEVER inline. Pass:
All skill source files (Step 1)
Topic spec: `<skill-optimize-root>/topics/<topic-slug>.spec.md`
Topic assessment (if exists): `<skill-optimize-root>/topics/<topic-slug>.md`
Instruction: read skill files + topic spec, apply assessment, return findings or `CLEAN`

Sub-agent prompt:

```md
You are a skill optimizer running a focused topic analysis.

Topic: <SLUG>

Skill files:
<attach all source files>

Topic spec:
<attach topic spec>

<If executable topic .md exists:>
Topic assessment guide:
<attach topic .md>

Apply the topic assessment criteria to this skill.
Produce findings in this format, or confirm clean:

### <CATEGORY> — HIGH | MEDIUM | LOW

**Reasoning:** <grounded in specific content from the skill files>

**Recommendation:** <concrete, actionable>

Severity:
- HIGH: clear benefit, direct evidence, minimal downside
- MEDIUM: likely benefit, context-dependent
- LOW: minor or edge-case gain

If no finding applies, respond: CLEAN

Flag any finding that would apply universally (not just this skill) as:
audit-candidate: <description>

Before finalizing: review your finding. Does it hold under the evidence?
Is the severity calibrated correctly — not over- or under-rated? If the
verdict is CLEAN, confirm no signal was missed. Revise before outputting.
```

CLEAN → record `clean`. Findings → record them.

Response missing `### CATEGORY` or `**Reasoning:**` → record `ERROR: unexpected analysis format`, stop. NEVER parse malformed.

Step 5 — Record Results:

5a: Append row to `<skill-path>/optimize-log.md`:
| `<TOPIC>` | `<date>` | `<model>` | `<N findings>` | `<status>` | `<action summary>` |

Status: `acted` | `deferred` | `rejected` | `clean` | `audit-candidate`

No log → create using header from Step 2.

5b: Write report to `<skill-path>/.optimization/<topic-slug>.md`:

```md
# <TOPIC> — <date>

**Severity:** HIGH | MEDIUM | LOW

**Finding:** <what was observed>

**Action taken:** <what changed, or "No change.">
```

Clean → `CLEAN — no findings.`

Step 6 — Output:

Emit:

```text
TOPIC: <TOPIC-SLUG> | FINDINGS: <N> | LOG: <repo-relative path to optimize-log.md>
```

All tier-1+2 log topics show `clean`/`acted`/`deferred` → also emit:

```text
CONVERGENCE: tier-1+2 topics complete — <N acted>, <M clean>, <K deferred>
Next: re-run with higher model tier to verify.
```

Stop. Caller re-runs if needed.

Topic Index:

| Topic slug | Category | Focus |
| ---------- | -------- | ----- |
| `dispatch` | DISPATCH | Dispatch vs. inline; sub-agent isolation decision |
| `caching` | HASH RECORD | Hash-record cache; avoid redundant work |
| `determinism` | DETERMINISM | Replace LLM steps with deterministic tools |
| `composition` | COMPOSITION | Decomposition, routing, context efficiency |
| `model-selection` | MODEL SELECTION | Tier calibration; instruction quality as cost lever |
| `compressability` | COMPRESSIBILITY | Token overhead in instruction/output files |
| `wording` | WORDING | Guard clauses, ordering, attention positioning |
| `less-is-more` | LESS IS MORE | Subtraction pass; complexity inflation |
| `reuse` | REUSE | Shared procedures; tool conversion; dispatch adoption |
| `output-format` | OUTPUT FORMAT | Explicit output schema to reduce variance |
| `examples` | EXAMPLES | Few-shot examples for calibration |
| `chain-of-thought` | CHAIN OF THOUGHT | Reasoning scaffold for judgment tasks |
| `tool-signatures` | TOOL SIGNATURES | Tool/function description quality |
| `self-critique` | SELF CRITIQUE | Within-turn self-review for judgment outputs |
| `convergence` | CONVERGENCE | Multi-pass stop conditions; stabilization evidence |
| `iteration-safety` | ITERATION SAFETY | Loop design; hard caps; oscillation detection |
| `progressive-optimization` | PROGRESSIVE OPT | Impact tiers; per-topic tracking |
| `antipatterns` | ANTI-PATTERNS | Cross-topic tensions; per-category foot guns |
| `error-handling` | ERROR HANDLING | Error paths; fail-fast; silent failure |
| `interface-clarity` | INTERFACE CLARITY | Invocation contract; input/output documentation |
| `observability` | OBSERVABILITY | Decision transparency; audit trail quality |
| `temporal-decay` | TEMPORAL DECAY | Version-pinned references; staleness risk |
| `context-sensitivity` | CONTEXT SENSITIVITY | Parameterization; environment portability |
| `autonomy-level` | AUTONOMY LEVEL | Interactive vs. autonomous; confirmation calibration |
| `activation-discipline` | ACTIVATION DISCIPLINE | Trigger criteria; negative triggers; over-triggering |
| `context-budget` | CONTEXT BUDGET | Minimum viable context; pruning; handoff format |
| `failure-mode` | FAILURE MODE | Semantic failures; confidence labeling |
| `verification-strategy` | VERIFICATION STRATEGY | Evidentiary standard; primary source; acceptance criteria |
| `evaluation-harness` | EVALUATION HARNESS | Benchmark inputs; regression cases; before/after comparison |

Context budget:
Prefer shorter topic specs (DISPATCH, CACHING, DETERMINISM lean). Stop after one topic vs thin coverage. Assessor priority ensures highest-value topic hits first.

Impl notes:
Long-term arch: Assessor → lightweight Haiku sub-agent (reads skill + index, returns ranked list); topic agents → parallel after order known (one spec each, isolated, model-tier matched); log maintenance → inline.

Start inline. Extract to dispatch when step benefits from isolation (expensive, parallel, or needs different tier).
