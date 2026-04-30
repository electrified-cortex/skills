# Skill Optimize — Execution Instructions

## What This Skill Does

Analyzes a single skill for architectural and structural improvement
opportunities. Produces findings organized by category. Never modifies
skill files. Records work in an optimize-log.

**Execution pattern:** Hybrid dispatch. The host agent handles routing,
log management, and output inline. Topic analysis (Step 4) is dispatched
to a Sonnet-class sub-agent to keep intermediate state out of the host
context. The Haiku qualifier (Step 3a) is dispatched for lightweight
topic selection.

**Iteration model:** One invocation = one topic analyzed. The caller
(operator or coordinator) decides whether to run again. This keeps each
pass focused and avoids spending context budget on topics that become
irrelevant after earlier changes are made.

---

## Inputs

Required:

- `<skill-path>` — path to the skill directory (contains SKILL.md,
  spec.md, uncompressed.md, etc.)

Optional:

- `<topic>` — specific topic category slug (e.g. `dispatch`, `caching`).
  If provided, skip the assessor and analyze that topic directly.
- `<mode>` — `assess-only` (pick next topic, no analysis) | default
  (assess then analyze)

---

## Step 1 — Read Skill Source Files

Read the following files from `<skill-path>` in order. Read all that exist
before forming any opinion. Do not analyze yet.

1. `spec.md` — purpose, requirements, contract
2. `uncompressed.md` — full instructions
3. `SKILL.md` — compressed runtime instructions
4. `instructions.txt` — if present
5. `instructions.uncompressed.md` — if present

If none of these exist, stop: `ERROR: no skill source files found at <skill-path>`.

---

## Step 2 — Check the Optimize Log

The optimize log is at `<skill-path>/optimize-log.md`.

If it exists, read it. The log records which topics have been analyzed,
when, and what was found. Use it to:

- Skip topics already marked `clean` or `rejected`
- Pick up from where the last session left off
- Avoid repeating analysis the owner already reviewed and decided on

If no log exists, proceed — this is the first pass.

**Log format:**

```markdown
# Optimize Log: <skill-name>

## Topics Analyzed

| Topic | Date | Model | Findings | Status |
| ----- | ---- | ----- | -------- | ------ |
| DISPATCH | 2026-04-29 | Sonnet | 1 | pending |
| CACHING  | 2026-04-29 | Sonnet | 0 | clean   |
```

Status values:

- `pending` — finding exists, not yet reviewed by owner
- `acted` — skill was changed based on this finding
- `deferred` — finding reviewed, owner chose not to act yet
- `rejected` — finding reviewed and does not apply
- `clean` — no findings for this topic

---

## Step 3 — Assessor Pass

Goal: pick the best topic to analyze next.

Skip this step if `<topic>` was explicitly provided — go to Step 4 with
that topic.

**Assessor model:** Sonnet-class (standard). The assessor makes the final
pick — it does not read topic specs itself. It reads qualifier signals and
decides.

### 3a — Qualifier Dispatch (Haiku-class, batched)

Dispatch one Haiku-class qualifier agent. Give it:

- All skill source files (from Step 1)
- The ordered candidate topic list — all unanalyzed topics not in the log
  as `clean`/`rejected`/`acted`, sorted by natural priority tier (see
  Topic Index below)
- One-line descriptions only — not full topic specs

Prompt:

```text
Read the skill files below.
Scan the following topic list in order.
Return the FIRST topic that applies to this skill.
Short-circuit: stop at the first match.

Format:
TOPIC: <SLUG>
APPLICABLE: yes | maybe
REASON: <one sentence>

If none apply: TOPIC: none
```

One dispatch call. One result. Move to 3b.

To find a second candidate (after acting on the first), run another
qualifier starting from the topic after the previously returned slug.

### 3b — Assessor Decision

Review qualifier results. From topics marked `yes` or `maybe`, pick the
single topic most likely to yield a HIGH finding.

Tie-breaking priority:

1. `yes` over `maybe`
2. Structural before stylistic (DISPATCH, CACHING, DETERMINISM before WORDING, COMPRESSIBILITY)
3. Shorter topic spec (faster analysis, same expected yield)
4. Default: DISPATCH → CACHING → DETERMINISM → INTERFACE CLARITY → LESS IS MORE

Emit: `Assessor selected: <TOPIC-SLUG> — <one-line reason>`

If in `assess-only` mode, stop here.

**Fallback — inline qualification (no dispatch available):**

Skip 3a. Read the skill and use these heuristics directly:

| Signal | First topic |
| ------ | ----------- |
| Expensive or repetitive work, no log/cache mechanism | HASH RECORD |
| Spawns sub-agents or calls external tools | DISPATCH |
| Steps that could be regex / file check / git command | DETERMINISM |
| Contract (inputs/outputs) not documented | INTERFACE CLARITY |
| Description is vague or similar to neighboring skills | TOOL SIGNATURES |
| Instructions are very long relative to task scope | LESS IS MORE |
| Makes judgment calls with no review step | SELF CRITIQUE |
| No output schema; output format varies | OUTPUT FORMAT |
| Iterates or loops with no hard cap | ITERATION SAFETY |
| External version references / model name pinned | TEMPORAL DECAY |
| Default | DISPATCH |

---

## Step 4 — Topic Analysis (Dispatched)

Dispatch a Sonnet-class topic analysis sub-agent. This step runs in an
isolated context — do not execute topic analysis inline in the host.

**Pass to the sub-agent:**

- All skill source files (from Step 1): spec.md, uncompressed.md, SKILL.md,
  instructions.txt, and any others that exist
- The selected topic spec file:
  `<skill-optimize-root>/topics/<topic-slug>.spec.md`
- The executable topic assessment file (if it exists):
  `<skill-optimize-root>/topics/<topic-slug>.md`
- Instruction: "Read the skill files and the topic spec. Apply the topic
  assessment. Return findings in the standard format, or confirm clean."

**Sub-agent prompt:**

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
```

**Collect the sub-agent's response.** If the response is CLEAN, record it
as `clean` in the log. If findings are returned, record them.

---

## Step 5 — Update the Optimize Log

Append one row to `<skill-path>/optimize-log.md`:

| `<TOPIC>` | `<today's date>` | `<model if known>` | `<N findings>` | `pending` or `clean` |

Also append a detail entry under `## <TOPIC> — <date>` with the full
finding text (or "CLEAN") and action taken.

If the log does not exist, create it using the header format from Step 2.

Set initial status:

- `clean` if N = 0
- `pending` if N > 0 (owner needs to review)

---

## Step 6 — Output

Emit a one-line summary as the final output:

```text
TOPIC: <TOPIC-SLUG> | FINDINGS: <N> | LOG: <repo-relative path to optimize-log.md>
```

Then stop. The caller decides whether to run again.

---

## Topic Index

| Topic slug | Category | Focus |
| ---------- | -------- | ----- |
| `dispatch` | DISPATCH | Dispatch vs. inline; sub-agent isolation decision |
| `caching` | HASH RECORD | Hash-record cache usage to avoid redundant work |
| `determinism` | DETERMINISM | Replace LLM steps with deterministic tools |
| `composition` | COMPOSITION | Decomposition, routing, context efficiency |
| `model-selection` | MODEL SELECTION | Tier calibration; instruction quality as cost lever |
| `compressability` | COMPRESSIBILITY | Token overhead in instruction and output files |
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

---

## Notes on Context Budget

If context budget is limited:

- Prefer shorter topic specs (DISPATCH, CACHING, DETERMINISM are lean)
- Stop after one topic rather than producing thin coverage on many
- The assessor's priority order is designed to ensure the highest-value
  topic is hit first even if you only get one pass

---

## Implementation Notes

**This spec is itself a candidate for optimization.** The intended
long-term architecture is:

- **Assessor** dispatched as a lightweight Haiku-class sub-agent — reads
  the skill and the index, returns a ranked topic list
- **Topic agents** dispatched in parallel once the order is known —
  each loads only one topic spec, isolated context, model-tier matched
- **Log maintenance** stays inline — the host agent writes the log
  after collecting sub-agent results

Start with everything inline. Extract to dispatch when you have evidence
that a step benefits from isolation (expensive, parallel-friendly, or
benefits from a different model tier).
