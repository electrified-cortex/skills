# Skill Optimize Specification

## Purpose

Define the rules and procedures for optimizing skills via LLM-intelligence
analysis. Where skill-auditing enforces conformance to structural rules
(verifiable by Haiku), skill-optimize performs higher-order assessments that
require judgment — asking "given what this skill is trying to do, is it
structured optimally?" This is Sonnet-class work and cannot be reduced to
a deterministic checklist.

**Skills are engineered, not written.** A writer asks "what should I say?"
An engineer asks "what contract am I fulfilling, and what is the minimum
that satisfies it?" The optimizer applies that engineering lens: contract
first, failure paths before the happy path, complexity as a smell, and
proof that the change was worth it. If a skill was written but not
engineered, the optimizer finds where that distinction shows.

## Design Goal — Intelligence Over Rules

Skill auditing finds rule violations. Skill optimize finds missed
opportunities. The optimizer reads the skill holistically and asks these
(but not limited to) structural questions:

1. Is the execution pattern (dispatch vs inline) the right choice?
2. Should this skill use a hash record to avoid redundant work?
3. Can any LLM-dependent step be replaced with a deterministic tool?

Each finding must be grounded in the skill's actual content and purpose —
not applied mechanically. A suggestion without a clear reason tied to the
skill's intent is not a valid finding.

**Stable audit sequence (orientation):** A useful mental model for
approaching any skill, before diving into the per-topic checklist:

1. Should this skill exist at all?
2. When should it activate?
3. What contract does it fulfill?
4. What context does it require?
5. What failure modes and variance must it control?
6. How do we prove the optimized version is better?

These are not additional topics — they are the framing questions that
prevent the topic checklist from becoming a taste test. If the answers
are unclear, the findings will be shallow regardless of how many topics
are evaluated.

**The auditing/optimizing boundary:**

When a specific, deterministic technique is identified (e.g., "trigger
words in the description field improve skill invocation reliability"),
that technique belongs in **skill-auditing** — a checklist check that
Haiku can verify on every skill. Skill-optimize is for broader, harder-to-
decipher assessments: architectural patterns, structural tradeoffs, and
judgment calls that require understanding what a skill is trying to do.
The test: if the check can be expressed as a rule with a binary pass/fail
and Haiku can apply it without judgment, it belongs in auditing. If it
requires weighing tradeoffs specific to the skill's purpose, it belongs
here.

## Scope

Applies when analyzing an existing skill for architectural and structural
improvement. The optimizer reads, reasons, and recommends — it does not
modify files and does not gate on pass/fail. Every invocation produces
findings (which may be empty if no improvements apply).

## Architecture Direction (Planned)

This spec is itself a candidate for the COMPOSITION pattern it defines.
As the category set grows, the optimal structure is:

1. **This file** becomes a routing index — a table of categories with
   one-line descriptions and links to per-category sub-specs.
2. **Per-category sub-specs** (e.g., `dispatch.spec.md`,
   `composition.spec.md`) contain the detailed analysis instructions.
   An invocation that only needs to evaluate DISPATCH loads only
   `dispatch.spec.md` — not this entire file.
3. **Per-category agents** may be dispatched to different models. Some
   analysis types are better on specific models (GPT 5.4 for certain
   reasoning patterns, Claude Opus for deep structural analysis). The
   routing layer checks what's available and falls back gracefully if
   a preferred model or agent is unavailable.
4. **Swarm mode**: for high-thoroughness optimization runs, all topic
   categories can be dispatched in parallel to specialized agents and
   results merged — similar to the swarm skill pattern.

This spec dogfoods itself: its final architecture should demonstrate
COMPOSITION (routing + sub-skills), DISPATCH (isolated category agents),
MODEL SELECTION (per-category tier calibration), LESS IS MORE (index
stays lean; detail is in sub-files), and CHAIN OF THOUGHT (analysis
sub-agents reason before finding). When that refactor happens, this
spec becomes a live example of the principles it defines.

This is a **hybrid skill** — the host agent handles routing, log management, and
output inline. Topic analysis (Step 4) dispatches to a Sonnet-class sub-agent.
Sonnet-class or higher is required for standard passes; the topic assessments
require judgment. Haiku-class may be used for initial qualifier passes only.

## Parameters

- `<skill-path>` — absolute path to the skill directory to analyze (required).
- `<topic>` — topic slug (e.g. `dispatch`, `caching`). Optional. If provided,
  skips the assessor phase and analyzes the named topic directly.
- `<mode>` — `assess-only` (select topic but do not analyze) | default (assess
  then analyze).

## Version

1.0

Bump when optimization categories, output schema, or assessment logic
change in a way that invalidates prior records.

## Definitions

- **Optimization finding**: A concrete, reasoned suggestion to improve the
  skill's architecture or structure. Each finding belongs to exactly one
  category.
- **Category**: Any topic defined in `./topics/`. The canonical category
  set is the set of `.spec.md` files in that directory. Each topic file
  defines the signals, finding criteria, and when-not-to-apply guidance
  for its category. New categories are added by adding a topic file.
- **Dispatch skill**: A skill that invokes a sub-agent (Dispatch pattern)
  to perform its work in an isolated context.
- **Inline skill**: A skill whose instructions execute directly in the
  host agent's context without spawning a sub-agent.
- **Routing skill**: A parent skill that only indexes and routes to
  sub-skills — no execution logic, no `instructions.txt`. Its SKILL.md
  is a minimal sub-skill table or index. It is neither dispatch nor
  inline: it is a navigation hub.
- **Hash record**: A content-addressed cache (`.hash-record/`) used to
  avoid re-running expensive operations on unchanged inputs.
- **Deterministic step**: A step whose output is fully determined by its
  inputs with no LLM reasoning required — e.g., file hashing, regex
  extraction, git commands, file presence checks.
- **Severity**: Confidence-weighted impact of the finding —
  HIGH (strong signal, clear benefit), MEDIUM (likely benefit, context
  dependent), or LOW (minor or edge-case benefit).

## Requirements

1. The optimizer **must** read all available skill source files before
   producing any finding: `spec.md`, `uncompressed.md`, `SKILL.md`,
   `instructions.txt`, and `instructions.uncompressed.md` if present.
2. The optimizer **must** track all optimization categories defined in
   `./topics/` across invocations using the optimize log, and **must not**
   skip categories without logging a status (`clean`, `rejected`, `acted`,
   or `deferred`). Each `.spec.md` file in that directory is a required
   analysis category. Full coverage is achieved across multiple invocations,
   not in a single pass.
3. Each finding **must** include: category, severity, reasoning (grounded
   in the skill's content), and a concrete recommendation.
4. The optimizer **must** produce no finding for a category when no
   meaningful improvement applies — empty categories are valid and
   preferred over low-confidence suggestions.
5. The optimizer **must** track progress using an optimize log at
   `<skill-path>/.optimization/.log.md`. On entry, read the log and exclude
   topics with status `clean`, `rejected`, or `acted` from the active
   candidate set. Append a row on completion of each topic pass.
   Optionally, a content-addressed hash record (`.hash-record/`) may be
   used by callers as a full-skip cache for unchanged inputs — but this
   is caller-controlled, not optimizer-internal. The log is the primary
   iteration state.
6. The optimizer **must** return exactly one final stdout line in the
   form `TOPIC: <slug> | FINDINGS: <N> | LOG: <path>` on success or
   `ERROR: <reason>` on failure. This line **must** be last, at column 0,
   with no indentation, quoting, or list-marker prefix.
7. Findings **must** be grounded in evidence from the skill files.
   Assertions not traceable to specific content in the files are not
   valid findings.
8. The optimizer **must not** modify any skill file. It is strictly
   read-only.
9. Severity **must** be assigned honestly: HIGH requires a clear,
   direct benefit with minimal downside; MEDIUM requires a likely but
   context-dependent benefit; LOW is reserved for edge cases or minor
   gains.
10. The optimizer **must** operate within the scope of the provided
    skill path — it must not traverse sibling skills or other worktrees.
    The optimize log at `<skill-path>/.optimization/.log.md` is local to the
    target skill.
11. The record body **must not** contain absolute filesystem paths.
    All paths in the body **must** be repo-relative.

12. The optimizer **must** support multi-pass convergence. The recommended
    execution pattern is: run lightweight (Haiku-class) passes repeatedly
    until no new findings are produced — then escalate to a standard
    (Sonnet-class) pass for a deeper review, and optionally to a deep
    (Opus-class) pass for final refinement. Convergence is when a full
    pass produces zero net-new findings. Each pass must cache its own
    result. The caller controls how many passes to run; the optimizer
    does not self-iterate — it is stateless per invocation.

13. **Pre-flight audit probe**: Before deep analysis, the optimizer
    **should** probe the current audit verdict (via `skill-auditing/result.ps1`)
    and note it as context. The optimizer **must** proceed regardless —
    a failing audit is not a gate. Audit is a sealing step, not an entry
    requirement. Optimization findings are valid and useful on structurally
    unsound skills.

14. **Audit-candidate findings**: When the optimizer identifies a pattern
    that is deterministic and universally applicable (not specific to this
    skill), it **should** flag it as an audit-candidate. These are findings
    that, once validated, could be promoted to skill-auditing as a
    deterministic rule — widening the auditing net. Label them:
    `audit-candidate: <description>` in the finding body.

## Constraints

- **One skill per invocation**: each invocation optimizes exactly one
  skill; multi-skill runs are separate invocations.
- **Read-only**: the optimizer never writes to skill source files. Write
  targets are: `<skill-path>/.optimization/.log.md` (log rows) and
  `<skill-path>/.optimization/<topic-slug>.md` (per-topic reports). Hash-record
  writes (`.hash-record/`) are caller-controlled, not optimizer-internal.
- **Convergence-based multi-pass**: the optimizer may run in multiple
  passes across escalating model tiers (see R12). A single pass is valid;
  multi-pass until convergence is the optimal pattern.
- **Seal sequence (post-convergence, caller responsibility)**: once all
  topics converge, the caller **must** run the seal sequence before
  distributing the skill: skill-auditing → compression pass (if
  `uncompressed.md` exists) → markdown-hygiene. The optimizer itself
  does not trigger these — it emits a `CONVERGED` signal and stops.
- **Minimum Sonnet for standard pass**: Haiku may be used for initial fast
  passes; Sonnet is required for the standard pass; Opus is recommended
  for deep or final refinement passes. The caller is responsible for tier
  selection.
- **No fabrication**: findings must be grounded in the actual skill
  content. Generic suggestions not tied to the specific skill are not
  permitted.
- **No absolute paths in record body**: paths in the findings record must
  be repo-relative.

## Behavior

The optimizer executes as a single-pass analysis per invocation. Each
invocation covers one topic. Multi-pass coverage (running until all
relevant topics are addressed) is owned by the caller or a coordinator
agent.

### Entry and Optimize Log Check

On entry, identify the skill source files (`spec.md`, `uncompressed.md`,
`SKILL.md`, `instructions.txt`, `instructions.uncompressed.md`) and read
all that exist.

Check for an optimize log at `<skill-path>/.optimization/.log.md`. If present,
read it. Topics with status `clean`, `rejected`, or `acted` can be
excluded from the active candidate set — they have already been handled.

### Assessor Pass

The assessor selects the next topic to analyze. The assessor runs at
Sonnet-class minimum — it requires judgment to weigh signals across the
topic set.

#### Qualifier Dispatch (Haiku-class, batched)

Before the assessor decides, dispatch one Haiku-class qualifier agent with
a *batch* of candidate topics — all unanalyzed / non-excluded topics,
ordered by natural priority. The qualifier scans the list in order and
returns the first topic it determines to be applicable.

Each qualifier receives:

- All skill source files
- The ordered topic list (slugs + one-line descriptions, not full specs)

The qualifier returns:

```text
TOPIC: <SLUG>
APPLICABLE: yes | maybe
REASON: <one sentence>
```

The qualifier short-circuits: it returns as soon as it finds the first
applicable topic. If none apply in the batch, it returns `TOPIC: none`.

This batched approach is preferred over per-topic dispatch — it uses one
call instead of N, and the natural priority order ensures the highest-value
topic is found first.

For a second opinion or to find the next candidate after acting on the
first, run another batch qualifier starting from the topic after the
previously returned one.

**Fallback:** When qualifier dispatch is unavailable, the assessor applies
the inline heuristics in the topic priority table (see below) directly
from its reading of the skill.

#### Assessor Decision

The assessor builds the candidate topic list by reading the optimize log,
excluding topics already marked `clean`, `rejected`, or `acted`, and
ordering the remainder by natural priority (Tier 1 first — see table).

That ordered list goes to the qualifier. The qualifier returns the first
applicable topic. The assessor accepts the result and proceeds to Topic
Analysis.

If the qualifier returns `TOPIC: none`, there are no remaining applicable
topics. The assessor reports completion and stops.

**Natural priority order** — the ordering the assessor applies to the
candidate list before passing it to the qualifier:

| Tier | Topics | Rationale |
| ---- | ------ | --------- |
| 1 — Structural | DISPATCH, HASH RECORD, DETERMINISM | Wrong architectural pattern invalidates downstream topics |
| 2 — Contract | INTERFACE CLARITY, TOOL SIGNATURES, OUTPUT FORMAT | Contract problems block useful invocation |
| 3 — Efficiency | LESS IS MORE, COMPRESSIBILITY, COMPOSITION | Reduce waste once structure is sound |
| 4 — Quality | SELF CRITIQUE, CHAIN OF THOUGHT, EXAMPLES, WORDING | Judgment and calibration improvements |
| 5 — Safety | ITERATION SAFETY, ERROR HANDLING, FAILURE MODE, AUTONOMY LEVEL | Bounded, predictable behavior |
| 6 — Lifecycle | TEMPORAL DECAY, CONVERGENCE, EVALUATION HARNESS, ACTIVATION DISCIPLINE | Long-term maintainability |
| 7 — Context | CONTEXT BUDGET, CONTEXT SENSITIVITY, VERIFICATION STRATEGY | Portability and evidence |
| 8 — Meta | REUSE, PROGRESSIVE OPT, OBSERVABILITY, ANTI-PATTERNS | Cross-cutting concerns last |

### Topic Analysis

Load the selected topic spec. Analyze the skill against its criteria.
Produce findings or confirm clean. Update the optimize log.

See `uncompressed.md` for the full execution procedure.

## Topics

Each topic is a `.spec.md` file in `./topics/`. Topics define the
analysis criteria for one optimization category. See a topic file to
understand its signals, when-not-to-apply guidance, and finding criteria.

### Topic Quality Standards

Every topic spec must meet these three bars to be considered complete.
Topics that fail these standards produce low-quality findings — too vague
to act on, missing the context needed to apply them, or unprovable.

**1. Operational trigger conditions**

Silence and fire conditions must be specific enough to act on without
judgment. Vague thresholds — "materially improved," "significant,"
"likely," "when it seems warranted" — are not operational. Replace with
observable signals: "fire when the instructions file has grown by more
than 20% since the last subtraction review" or "fire when no `REASON:`
justification is present on a finding." If you cannot write a test case
for the trigger, it is not operational.

**2. Required evaluator context declared**

Each topic must state what context it needs to produce valid findings.
Examples: "requires the caller invocation pattern," "requires prior
findings or changelog to assess duplication rate," "requires the runtime
environment to assess portability." Topics that silently assume context
they are not given will produce incorrect or inapplicable findings.

**3. Success criteria**

Findings must be falsifiable. A finding that cannot be disproved after
it is acted on is not useful. Each topic's finding section must describe
what "acting on this finding" looks like and how you would verify it
helped — even informally. Example: "acting means removing N sentences;
verify by re-running the skill and checking output quality holds."

| Topic | Category | Focus |
| --- | --- | --- |
| `dispatch.spec.md` | DISPATCH | Dispatch vs. inline execution pattern; tool call vs. text substitution |
| `caching.spec.md` | HASH RECORD | Hash-record cache usage to avoid redundant work |
| `determinism.spec.md` | DETERMINISM | Replacing LLM steps with deterministic tools |
| `composition.spec.md` | COMPOSITION | Skill decomposition, routing, context efficiency |
| `model-selection.spec.md` | MODEL SELECTION | Tier calibration; instruction quality as cost lever |
| `compressability.spec.md` | COMPRESSIBILITY | Token overhead in instruction and output files |
| `wording.spec.md` | WORDING | Guard clauses, ordering, attention positioning |
| `less-is-more.spec.md` | LESS IS MORE | Subtraction pass; complexity inflation; specs vs. instructions |
| `reuse.spec.md` | REUSE | Shared procedures; tool conversion; dispatch adoption |
| `output-format.spec.md` | OUTPUT FORMAT | Explicit output schema to reduce variance |
| `examples.spec.md` | EXAMPLES | Few-shot examples for calibration |
| `chain-of-thought.spec.md` | CHAIN OF THOUGHT | Reasoning elicitation for judgment tasks |
| `tool-signatures.spec.md` | TOOL SIGNATURES | Tool/function description quality |
| `self-critique.spec.md` | SELF CRITIQUE | Within-turn self-review for judgment outputs |
| `convergence.spec.md` | CONVERGENCE | Multi-pass convergence; adversarial review loops |
| `iteration-safety.spec.md` | ITERATION SAFETY | Loop design; hard caps; oscillation detection |
| `progressive-optimization.spec.md` | PROGRESSIVE OPT | Impact tiers; per-topic tracking; menu mode |
| `antipatterns.spec.md` | ANTI-PATTERNS | Cross-topic tensions; per-category foot guns |
| `error-handling.spec.md` | ERROR HANDLING | Error paths; fail-fast; silent failure |
| `interface-clarity.spec.md` | INTERFACE CLARITY | Invocation contract; input/output documentation |
| `observability.spec.md` | OBSERVABILITY | Decision transparency; audit trail quality |
| `temporal-decay.spec.md` | TEMPORAL DECAY | Version-pinned references; staleness risk |
| `context-sensitivity.spec.md` | CONTEXT SENSITIVITY | Parameterization; environment portability |
| `autonomy-level.spec.md` | AUTONOMY LEVEL | Interactive vs. autonomous; confirmation calibration |
| `activation-discipline.spec.md` | ACTIVATION DISCIPLINE | Trigger criteria; negative triggers; over-triggering |
| `context-budget.spec.md` | CONTEXT BUDGET | Minimum viable context; pruning; handoff format |
| `failure-mode.spec.md` | FAILURE MODE | Semantic failures; confidence labeling; must-stop vs. degrade |
| `verification-strategy.spec.md` | VERIFICATION STRATEGY | Evidentiary standard; primary source; acceptance criteria |
| `evaluation-harness.spec.md` | EVALUATION HARNESS | Benchmark inputs; regression cases; before/after comparison |

## Output

The optimizer produces two outputs per invocation:

**1. Primary return line** — emitted as the final stdout line:

```
TOPIC: <TOPIC-SLUG> | FINDINGS: <N> | LOG: <repo-relative path to .optimization/.log.md>
```

`N` is the count of findings (0 if clean). This line must be last, at
column 0, with no indentation, quoting, or list-marker prefix.

On failure: `ERROR: <reason>` as the final line instead.

**2. Optimize log entry** — the optimizer appends one row to
`<skill-path>/.optimization/.log.md`:

```
| TOPIC | date | model | N findings | status | one-line action summary |
```

Status values: `acted`, `deferred`, `rejected`, `clean`, `audit-candidate`.

**3. Report file** — the optimizer writes the full finding to
`<skill-path>/.optimization/<slug>.md`:

- Severity, signal, reasoning, recommendation
- Action taken (what changed, or "none")

The optimize log is the scan surface — read it to build the candidate list.
The `.optimization/` reports are the detail layer — read a specific report
only when you need to understand a prior finding.

**Finding format** (in log and in sub-agent response):

```md
### <CATEGORY> — HIGH | MEDIUM | LOW

**Signal:** <what was observed in the skill>

**Reasoning:** <grounded in specific content from the skill files>

**Recommendation:** <concrete, actionable>
```

Severity:

- HIGH — clear benefit, direct evidence, minimal downside
- MEDIUM — likely benefit, context-dependent
- LOW — minor or edge-case gain; or audit-candidate for future promotion

## Evidence Base

The optimization categories in this spec are grounded in the following
research and operational references:

- **Reflexion / Self-Refine** — Shinn, N. et al. (2023). *Reflexion: Language
  Agents with Verbal Reinforcement Learning.* arXiv:2303.11366.
  Madaan, A. et al. (2023). *Self-Refine: Iterative Refinement with
  Self-Feedback.* arXiv:2303.17651. Basis for SELF CRITIQUE category.

- **Function calling / tool description quality** — Patil, S. et al. (2024).
  *Gorilla: Large Language Model Connected with Massive APIs.* arXiv:2305.15334.
  Empirical basis for TOOL SIGNATURES category.

- **IACDM** — Moreira, J. (2026). *IACDM: Interactive Adversarial Convergence
  Development Methodology.* arXiv:2604.16399.
  Repository: <https://github.com/jasminemoreira/Versus>
  Key contributions: context efficiency model (E = I₀/C), complexity
  inflation antipattern, cost-tier switch point, granularization principle,
  validation theater, convergence-loop stopping criteria.

- **"Lost in the middle"** — Liu, N.F. et al. (2023). *Lost in the Middle:
  How Language Models Use Long Contexts.* arXiv:2307.03172.
  Establishes that model retrieval performance degrades for content
  positioned mid-context. Used in COMPOSITION (partitioning) and WORDING
  (attention positioning).

- **Chain-of-Thought Prompting** — Wei, J. et al. (2022). *Chain-of-Thought
  Prompting Elicits Reasoning in Large Language Models.* arXiv:2201.11903.
  Establishes that reasoning elicitation (step-by-step) produces 5–20%
  accuracy improvement on reasoning tasks. Basis for CHAIN OF THOUGHT category.

- **In-context learning / few-shot** — Brown, T. et al. (2020). *Language
  Models are Few-Shot Learners.* arXiv:2005.14165.
  Establishes that including labeled examples in the prompt (few-shot)
  dramatically anchors model output behavior. Basis for EXAMPLES category.

- **Dispatch pattern** — Internal. `dispatch/dispatch-pattern.md`.
  Foundational rationale for scope isolation via dispatch as a
  context-saving primitive. Used in DISPATCH and REUSE.

- **Compression tiers** — Internal. `docs/compression-tiers.md`.
  Governs text brevity conventions. Informs COMPRESSIBILITY targets.

Empirical claims marked "(author calibration, N=1)" or "empirical: unverified"
are pending broader external measurement. Flag all unverified recommendations
with that label when producing findings.
