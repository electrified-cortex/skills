---
title: Test Input Spec - Elaborate Soufflé Recipe
type: test-input-spec
purpose: Compression benchmark — generate a maximally verbose recipe for compression testing
---

## What This Is

This spec defines the test input for the compression benchmark suite. An agent
or human should use this spec to **generate** a detailed, verbose recipe that
will then be compressed at all three tiers (lite, full, ultra) across multiple
models.

## Requirements

Generate a **grand chocolate soufflé recipe** that is intentionally elaborate,
detailed, and verbose. The recipe must include:

### Structure

1. **Introduction** — history of the soufflé, why it's considered difficult,
   what makes this version special
2. **Ingredients list** — with quantities, brand suggestions, and substitution
   notes for each ingredient
3. **Equipment** — every tool needed, with explanations of why each matters
4. **Technique sections** — step-by-step, with:
   - What to do
   - Why it matters (the science/technique behind it)
   - Common mistakes and how to avoid them
   - Visual/sensory cues for doneness
5. **Timing breakdown** — prep time, active time, resting time, bake time
6. **Serving instructions** — plating, accompaniments, timing (soufflés wait
   for no one)
7. **Troubleshooting** — "if your soufflé fell," "if the center is raw," etc.
8. **Chef's notes** — personal tips, variations, seasonal adaptations

### Style

- Write as if for an enthusiastic home cook who wants to understand *everything*
- Explain the "why" behind every step, not just the "what"
- Use descriptive language — textures, aromas, visual cues
- Include at least one anecdote or historical note
- Target: 800-1200 words (intentionally long for compression testing)

### What NOT to Do

- Don't pad with filler — every sentence should carry real information
- Don't repeat instructions — be verbose through depth, not repetition
- Don't use bullet points for the main recipe steps — use flowing paragraphs

## Validation

After generation, run the spec auditor against the output to verify it meets
all requirements above. The generated recipe should feel like a professional
cookbook entry, not AI slop.

## Usage

The generated recipe becomes `recipe.md` in `.tests/inputs/`. This spec becomes
`recipe.spec.md` alongside it. Both are inputs to the compression benchmark.
