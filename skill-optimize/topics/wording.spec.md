# WORDING

## Purpose

Assess the instruction phrasing, ordering, and structural patterns that
influence how a model interprets and executes the skill. This category
is empirical and judgment-based — different models respond differently,
and best practices here are informed by observed behavior rather than
deterministic rules.

**Guard clause ordering (fail-fast):**

Instructions with early termination conditions should state the stop
condition first, before the complex path. This mirrors programming
guard clauses: "if X, then done" before "if Y, then do complex thing."
Presenting the simple stop case first lets the model recognize it early
and avoid loading the rest of the procedure. Late guard clauses waste
context and can lead to models partially executing before realizing
they should have stopped.

**Instruction sequencing:**

The order instructions are given can affect which interpretation dominates.
Key heuristics:

- Guard clauses (stop conditions, early exits) come first — before the
  main action. This is not in tension with "main path first" below:
  guard clauses remove non-cases before the main path begins.
- State the main action before non-stopping caveats and qualifications.
  Caveats after the action are less likely to override it than caveats
  before. Caveats before the action can cause the model to hesitate.
- Put the most common path first; edge cases and exceptions last.
- Group related instructions together; interleaved concerns create
  ambiguity about what applies when.

**Phrasing for determinism:**

Imperative, present-tense commands ("Run X", "Check Y", "Return Z")
tend to produce more consistent behavior than hedged or conditional
prose ("You might want to run X if Y is present"). The more the
instruction reads like a program, the more deterministically it runs.
Prefer: short sentences, active verbs, explicit branches over implicit
judgment calls.

**Attention positioning (evidence):**

Model retrieval performance degrades for information positioned in the
middle of long inputs (Liu et al., 2023 — "lost in the middle"). Critical
instructions — especially stop conditions, error paths, and output
format requirements — should appear at the beginning or end of the
instruction file, not buried mid-document. Guard clauses placed at the
top are doubly effective: they are in the high-attention zone AND they
allow early exit before the model loads the rest.

Validation theater (IACDM antipattern 1): instructions that ask the
model to self-evaluate ("is this output good?", "verify your work")
without providing external observable criteria fall into this pattern.
A model can validate format, structural consistency, and constraint
satisfaction — but cannot determine semantic correctness or output
quality without external criteria (Moreira 2026, Section 2.1). Effective
verification criteria specify observable outputs — file presence, line
count, structured verdict format — not open-ended self-assessment prompts.

**Model-specific considerations:**

Note that instruction sensitivity varies by model. A pattern that helps
Haiku may be unnecessary for Opus. When a skill is designed for a
specific model tier, the wording recommendations should be calibrated
to that tier's known sensitivities. Evidence for specific patterns is
preferred over speculation — flag when a suggestion is unverified.

Produce a finding when:

- Guard clauses or stop conditions appear late in the instruction flow
  when they would be more effective early.
- Common paths are buried after extensive edge-case discussion.
- Instruction phrasing is hedged or narrative when imperative would serve.
- The ordering imposes unnecessary cognitive load (model must hold
  context from early instructions that could be local to their step).

Do not produce findings based on speculation alone. Label uncertain
recommendations as "empirical: unverified for this model tier."

## Parameters

- <skill-path> — path to the skill directory being analyzed (inherited from optimizer invocation)
- <skill-source-files> — all source files from the skill directory (inherited from Step 1)

## Output

Finding in standard format (### CATEGORY — HIGH | MEDIUM | LOW with **Reasoning:** and **Recommendation:**), or CLEAN if no issues apply.
