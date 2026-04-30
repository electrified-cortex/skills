# Less Is More

Assess whether the skill's instruction file contains content that is not
pulling its weight — instructions the model doesn't need to produce correct
output, or that exist to patch symptoms of a deeper wording problem.

## The subtraction test

For every sentence in the instruction file, ask: if this sentence were
removed, would the model produce meaningfully wrong output?

- **Yes** — the sentence is load-bearing. Keep it.
- **No** — the sentence is overhead. Remove it.

Sentences that fail this test include: restating the obvious ("you are
analyzing a skill file"), hedging language ("try to ensure that..."),
motivational framing ("this is important because..."), and meta-commentary
that doesn't change behavior ("note: the following section is critical").

Produce a finding when a significant portion of the instruction file is
non-load-bearing — not for single-sentence cases.

## Complexity inflation antipattern

A skill accumulates rules over time to handle edge cases and model
misbehaviors. Each rule addresses a real problem. But cumulatively, the
instruction file becomes a negotiation — long enough that the model must
prioritize some rules over others, and important early rules get diluted
by volume.

The fix is not to add more rules at the end. The fix is to address the
root cause: often a few earlier instructions are underspecified, causing
downstream confusion that generates corrective rules. Rewriting the root
cause can collapse a chain of corrective rules into a single clear
instruction.

Signal: a skill has 3+ rules that are all corrections of the same model
behavior (e.g., "don't output paths," "remember not to use absolute paths,"
"always use repo-relative paths" — three instructions doing one job).
These should be one instruction, placed where the behavior first matters.

(IACDM, Moreira 2026: "complexity inflation" — adding rules to fix
symptoms of an unclear original instruction.)

## Specs vs. instructions

A spec file defines what good output looks like — written for humans to
review and approve. It describes requirements, criteria, and intent.

An instructions file tells the model what to do — step by step, with
explicit branches, stop conditions, and output format. It's a program,
not a policy document.

The two are not interchangeable. A model running an instructions file
should follow the steps, not read the spec and infer the steps. A
reviewer reading a spec should be able to evaluate conformance without
running the model.

Signal for a finding: the instructions file contains spec-style content
(requirements rationale, design discussion, "why" explanations) mixed
with procedural instructions. The procedural parts should stand alone,
with rationale either removed or moved to a companion spec.

Conversely: a spec file that doubles as an instructions file (models are
told to "follow this spec") is over-loaded. The instructions layer should
be thin and procedural; the spec should be authoritative but non-operational.

## Repetition within a skill

If a constraint or rule appears multiple times in the skill, one instance
is overhead. The rule's authority does not increase with repetition; the
model's attention budget does. Choose the one placement that matters most
(typically: where the first opportunity to violate the rule occurs), and
state it once.

## Preambles and conclusions

Many skills open with context-setting ("You are a skill optimizer analyzing
a skill file to find improvement opportunities. The following is the skill
content...") and close with summary framing ("Return your findings in the
format above."). These are often pure overhead — the model receives the
skill content and the output schema and can infer the task without
narration.

Check whether the skill's preamble and conclusion are load-bearing. If
removing them would leave the instructions unambiguous, they are candidates
for removal.

## When NOT to apply less-is-more

Do not produce a finding when every sentence is load-bearing. A dense,
tight instruction file with no waste is correctly structured — suggesting
it be shortened when it can't be shortened without loss is a false positive.

Also: do not flag necessary repetition. If a constraint appears in both
the "entry check" and the "output format" sections because it's easy to
violate in both contexts, that repetition is intentional and load-bearing.
Use judgment: is the second instance doing different work than the first?
If yes, keep it.
