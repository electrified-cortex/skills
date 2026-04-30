# LESS IS MORE

Assess whether the skill's instructions have grown beyond what they need
to be. This is the final-pass mindset: after building up content, find
what can be removed. Perfection is not achieved by what you add — it is
achieved by what you remove.

**The over-elaboration problem:**

Models generating skills write tomes. Brainstorming sessions produce
rich context that accumulates into instruction files. This growth is
natural during design but harmful at runtime. Every sentence a model
does not need to read is a sentence that cannot cause an unexpected
detour, an over-interpretation, or a miskeyed behavior. The more you
give a model, the more surface area exists for it to latch onto the
wrong thing.

**Specs are not instructions:**

Spec files are for humans — they may be verbose, richly contextual, and
explanatory. Instruction files are for models — they must be lean. If
rationale, background, or design history has leaked from a spec into an
instruction file, remove it. Models do not need to know why; they need
to know what and how.

**The subtraction check:**

For every sentence in the instruction file, ask: if this sentence were
absent, would a capable model still execute the skill correctly? If yes,
it is a candidate for removal. This applies to:

- Explanatory prose (why a step exists, what the skill is for)
- Redundant restatements (the same instruction said twice with different words)
- Edge cases already handled by the model's base behavior
- Motivational or cautionary language that adds length without adding constraint

**The growth signal:**

If a skill's instruction file has grown after recent edits — more
content was added but nothing removed — this category should produce a
finding. Every addition should trigger a corresponding subtraction review.
The size of an instruction file is not a measure of its quality; it is
often inversely related to it.

**Complexity inflation (evidence):**

IAICDM names "complexity inflation" as a primary antipattern: when
critique reveals fragility, the instinct is to add components or
caveats rather than simplify. The correct response is simplification.
Growth in component count (or instruction count) without corresponding
growth in required new behaviors is a signal of design failure, not
progress. Each revision of a skill should maintain or reduce instruction
complexity relative to the previous version; growth is only justified
when a genuinely new behavioral requirement has been added. (IACDM,
Moreira 2026, Section 9, antipattern 2)

Produce a finding when:

- Instruction content is explanatory or contextual rather than procedural
- Spec-level rationale is present inside the instruction file
- The same constraint is stated more than once in slightly different words
- The instruction file has grown significantly without a documented
  subtraction review

Do not produce a finding when every sentence is load-bearing — present
because without it the model would produce meaningfully wrong output.