# Anti-Patterns and Foot Guns

## Purpose

> **Activation:** This topic fires only when a *systemic* failure is
> present — one that no primary topic fully owns, or one that emerges from
> topic interaction. The cross-topic tensions and per-topic foot guns below
> are **reference material** — they inform other topic analyses but do not
> generate findings on their own. Findings come exclusively from the
> **Systemic anti-patterns** section.
>
> **Required context before running:**
>
> - Topic set being applied to this skill
> - Prior findings or changelog entries (to assess duplication rate)
> - Any prior optimize log
>
> **Do not fire when:** a primary topic (LESS IS MORE, DISPATCH, EXAMPLES,
> etc.) already owns the issue. This topic picks up only what falls through.

Cross-cutting anti-patterns and tug-of-war tensions between optimization
topics. Each topic file should also flag its own foot guns in context —
this file collects the cross-topic ones and the most common per-topic
mistakes for quick reference.

## Parameters

- <skill-path> — path to the skill directory being analyzed (inherited from optimizer invocation)
- <skill-source-files> — all source files from the skill directory (inherited from Step 1)

## Output

Finding in standard format (### CATEGORY — HIGH | MEDIUM | LOW with **Reasoning:** and **Recommendation:**), or CLEAN if no issues apply.

## Cross-topic tug-of-war tensions

These pairs pull in opposite directions. Understanding the resolution
prevents over-applying one topic at the expense of another.

**LESS IS MORE vs. EXAMPLES**
Tension: LESS IS MORE wants to shrink the instruction file; EXAMPLES adds
tokens (possibly many) to anchor behavior. Resolution: examples are
load-bearing if and only if prose description alone fails to calibrate the
model. Run LESS IS MORE first; only add examples where prose genuinely
doesn't work. Don't add examples just because they feel clarifying.

**LESS IS MORE vs. CHAIN OF THOUGHT**
Tension: LESS IS MORE removes non-load-bearing sentences; CoT adds explicit
reasoning steps ("First, identify X. Then, assess Y..."). Resolution: CoT
steps ARE load-bearing on judgment tasks — the reasoning scaffolding
changes the model's behavior in a measurable way. Applying LESS IS MORE
to a CoT skill and removing the reasoning steps is the foot gun here, not
adding them.

**COMPRESSIBILITY vs. OUTPUT FORMAT**
Tension: explicit output format adds tokens; COMPRESSIBILITY wants to
reduce them. Resolution: output format is load-bearing — it anchors model
behavior and reduces variance. Do not sacrifice format specification for
compression. Compress the surrounding prose, not the format spec.

**DETERMINISM vs. CHAIN OF THOUGHT**
Tension: DETERMINISM replaces LLM steps with deterministic tools;
CHAIN OF THOUGHT adds explicit reasoning steps. They seem opposed.
Resolution: CoT applies to genuinely uncertain judgment; DETERMINISM
applies to certifiable facts. A file hash is deterministic — CoT on it
is wasted tokens. "Is this skill architecturally over-loaded?" is
judgment — CoT helps here. The test: would two experts examining the same
inputs always agree? If yes, it's deterministic. If no, CoT applies.

**REUSE vs. LESS IS MORE**
Tension: REUSE extracts repeated blocks into a shared tool; LESS IS MORE
prefers not to add architecture. Resolution: extract only when the block
repeats 3+ times across the skill or across multiple skills. A single
repeat is not REUSE; it might just be emphasis (see "intentional repetition"
in less-is-more.spec.md).

**EXAMPLES vs. COMPRESSIBILITY**
Tension: examples add tokens to every invocation; COMPRESSIBILITY wants
to reduce per-invocation token cost. Resolution: if examples are in the
instructions file, they cost tokens on every invocation. Consider whether
examples can be moved to a companion file and loaded only when the skill
indicates it needs calibration (lazy loading). This is an advanced pattern
and not always worth the complexity.

**DISPATCH vs. SELF CRITIQUE**
Tension: dispatch adds a round-trip overhead; self-critique adds an extra
reasoning pass. Both cost. Resolution: if SELF CRITIQUE is warranted, run
it within the same dispatch context (appended to the dispatcher's
instructions), not as a separate dispatch. Never dispatch a sub-agent just
for self-critique.

---

## Per-topic foot guns

### DISPATCH

- **Dispatching a tiny inline skill** — If the skill is 5 steps and the
  procedure fits in 10 lines, dispatch overhead (round-trip, context
  switch, schema) dominates the work. Inline it.
- **Not dispatching a context polluter** — Long procedures left inline
  accumulate intermediate state in the host context. Every token of
  intermediate state is permanently in the host's window. The cost
  compounds.

### HASH RECORD

- **Hashing a skill with always-different inputs** — If the skill's
  inputs are parameterized by a timestamp, a random ID, or any value that
  changes every run, the manifest hash will always miss. The overhead is
  pure waste.
- **Over-including in the manifest** — including config files or
  environment-specific files in the hash manifest means any environment
  change invalidates all cached records. Include only the files that
  actually determine the output.

### DETERMINISM

- **Determinizing a judgment that needs nuance** — replacing LLM judgment
  with a rigid rule when the edge cases genuinely vary by context. The
  tool will be correct on the common case and wrong on the edges.
- **Leaving a deterministic step as LLM** — The model "decides" something
  that is actually computable from the inputs. Costs tokens. Can produce
  wrong results when the model drifts.

### MODEL SELECTION

- **Haiku for judgment + elaborate compensation instructions** — Writing
  a 500-word instruction file to make a cheap model "smart enough" for a
  judgment task. The extra tokens often cost more than just using Sonnet,
  and reliability is still lower. Right-size the tier first, then
  simplify instructions.
- **Opus by default** — Treating Opus as a safe default ("it can always
  handle it"). Opus costs 5-15x more than Sonnet. Unless the task
  genuinely requires deep multi-constraint reasoning, Sonnet is sufficient.

### WORDING

- **Emphatic repetition as a crutch** — Repeating a constraint three
  times to make it feel more binding ("always X", "remember: always X",
  "important: always X"). The model's attention budget is finite; three
  instances dilute each other. State it once, at the point where it
  first matters.
- **Guard clauses for things the model naturally does** — Adding a guard
  clause for behavior the model exhibits without instruction. These add
  tokens with no behavioral change and contribute to complexity inflation.

### LESS IS MORE

- **Removing load-bearing context disguised as preamble** — A sentence
  that looks like context-setting ("you are analyzing a skill that may
  be called in isolation or as part of a pipeline") might be providing
  real behavioral guidance. Always run the subtraction test, don't just
  trim by feel.
- **Trimming until the model guesses** — Taking LESS IS MORE too far
  leaves implicit the things the model must infer. If the model starts
  making wrong inferences, you've removed too much. Find the floor.

### CHAIN OF THOUGHT

- **CoT on deterministic lookups** — Telling the model to "think through"
  a file hash, a format check, or a rule lookup. These are not judgment
  tasks; CoT adds tokens and can introduce drift by giving the model
  space to second-guess a mechanically correct answer.
- **CoT without structure** — "Think step by step" without defining what
  the steps are. Unstructured CoT is less reliable than structured CoT
  ("First assess X, then evaluate Y, then conclude Z").

### EXAMPLES

- **Outlier examples** — Teaching the model an exceptional case instead
  of the representative case. The model anchors on the example. If the
  example is rare, normal inputs will be handled like the rare case.
- **Stale examples** — Examples that demonstrate the old output format
  after the format was updated. The model will produce the stale format
  unless examples are updated in sync.

### OUTPUT FORMAT

- **Implicit "you'll know it when you see it" format** — Describing the
  output in prose without a template. The model produces different
  structures across runs. Even a simple markdown template anchors
  behavior more than 100 words of description.

### SELF CRITIQUE

- **Self-critique on deterministic steps** — Asking the model to "verify
  your work" on a file hash, a line count, or a regex result. Use a tool
  for verification; self-critique is for judgment.
- **Infinite loop risk** — If self-critique produces findings, does the
  model try to fix them? If so, does it re-critique? Without an explicit
  stop condition, self-critique can loop. Always specify: "review once,
  note issues, do not recurse."

### TOOL SIGNATURES

- **Generic tool names in a large registry** — A tool named "process" or
  "analyze" in a registry of 30 tools will be called randomly. Specific,
  action-verb names ("hash_manifest", "compare_versions") are selected
  reliably.
- **Mismatch between name and behavior** — A tool named "validate_format"
  that also modifies the file. The model's intent when calling it is
  read-only verification; the side effect is invisible and unexpected.

### REUSE

- **Premature extraction** — Extracting a block that appears once into a
  shared tool "for future reuse." If it never gets reused, you've added
  architecture with no payoff and made the original skill harder to read.
  Extract when you have the second use, not in anticipation of it.
- **Extraction that breaks context** — Some blocks depend on surrounding
  context to make sense. Extracting them into a standalone tool loses that
  context, requiring extra parameter documentation to compensate.

---

## Systemic anti-patterns

**Optimization theater** — running skill-optimize repeatedly with no
changelog, producing the same findings each time, acknowledging them, and
not applying them. The optimization record grows; the skill doesn't improve.
Track finding resolution, not just finding production.

**Category sprawl** — adding a new topic for every single nuance until
the optimizer has 40 topics, each of which fires rarely. Diminishing
returns. Prefer adding nuance to existing topics over creating new ones
unless the new topic is structurally distinct and commonly applicable.

**Over-optimization** — A skill that has been optimized so many times
it is now fragile — every sentence is precision-tuned, no slack remains,
and any context shift breaks it. Leave deliberate slack in skills that
operate in variable contexts. Not everything needs to be maximally tight.
