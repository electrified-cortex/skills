# Compression Benchmark Suite

Test the compression skill across multiple models and all three tiers using a
purpose-built recipe input. Results demonstrate skill portability, model
sensitivity, and inform default model recommendations.

## Directory Structure

```text
.tests/
├── inputs/
│   ├── recipe.spec.md        ← spec for generating the test input
│   └── recipe.md             ← full uncompressed recipe (generated from spec)
├── lite/
│   ├── sonnet.md
│   ├── haiku.md
│   ├── gpt54.md
│   ├── qwen-14b.md
│   └── qwen-1.7b.md
├── full/
│   └── (same model files)
├── ultra/
│   └── (same model files)
├── PLAN.md                   ← this file — test procedure
└── RESULTS.md                ← summary matrix, findings, recommendations
```

## Test Procedure

### Phase 1 — Input Generation

1. Generate `recipe.md` from `recipe.spec.md` using a frontier model (Sonnet or
   GPT 5.4). The generated recipe is the uncompressed baseline.
2. Run the Spec Auditor on `recipe.md` against `recipe.spec.md` to verify the
   input meets all spec requirements before proceeding.

### Phase 2 — Compression Runs

For each model in the matrix, compress `recipe.md` at each tier:

| Step | Input | Tier | Model | Output |
| --- | --- | --- | --- | --- |
| 2a | `recipe.md` | Lite | Sonnet | `lite/sonnet.md` |
| 2b | `recipe.md` | Full | Sonnet | `full/sonnet.md` |
| 2c | `recipe.md` | Ultra | Sonnet | `ultra/sonnet.md` |
| 2d | `recipe.md` | Lite | Haiku | `lite/haiku.md` |
| 2e | `recipe.md` | Full | Haiku | `full/haiku.md` |
| 2f | `recipe.md` | Ultra | Haiku | `ultra/haiku.md` |
| 2g | `recipe.md` | Lite | GPT 5.4 | `lite/gpt54.md` |
| 2h | `recipe.md` | Full | GPT 5.4 | `full/gpt54.md` |
| 2i | `recipe.md` | Ultra | GPT 5.4 | `ultra/gpt54.md` |
| 2j | `recipe.md` | Lite | Qwen 14B | `lite/qwen-14b.md` |
| 2k | `recipe.md` | Full | Qwen 14B | `full/qwen-14b.md` |
| 2l | `recipe.md` | Ultra | Qwen 14B | `ultra/qwen-14b.md` |
| 2m | `recipe.md` | Lite | Qwen 1.7B | `lite/qwen-1.7b.md` |
| 2n | `recipe.md` | Full | Qwen 1.7B | `full/qwen-1.7b.md` |
| 2o | `recipe.md` | Ultra | Qwen 1.7B | `ultra/qwen-1.7b.md` |

Each compression run uses the skill's standard prompt with the appropriate tier
instructions. No manual intervention — the model receives the skill prompt and
the input file.

### Phase 3 — Audit

Run the Spec Auditor on each output against `compression/SKILL.spec.md` to
verify tier compliance:

- **Lite outputs:** preserve rules respected, filler dropped, grammar intact
- **Full outputs:** shorter synonyms, fragments allowed, preserve rules intact
- **Ultra outputs:** telegraphic, abbreviations used, preserve rules intact

Record audit verdicts per output file.

### Phase 4 — Analysis

Populate `RESULTS.md` with:

1. **Size matrix** — word count and line count for each output vs baseline
2. **Compression ratio** — percentage reduction per tier per model
3. **Audit verdicts** — pass/fail per output
4. **Quality notes** — any meaning loss, preserve rule violations, or style drift
5. **Model comparison** — rank models by compression quality at each tier
6. **Recommendations:**
   - If Haiku ≈ Sonnet → recommend Haiku as default (cost savings)
   - If local models follow rules → note local-dispatch viability
   - Flag any model that consistently fails preserve rules

## Model Matrix

| Model | Type | Access | Priority |
| --- | --- | --- | --- |
| Claude Sonnet 4 | Frontier | API | P1 — baseline |
| Claude Haiku 4 | Frontier (small) | API | P1 — cost comparison |
| GPT 5.4 | Frontier (external) | API | P2 — cross-vendor |
| Qwen 2.5 14B Instruct | Local | Ollama (local) | P3 — local validation |
| Qwen 3 1.7B | Local | Ollama (local) | P4 — small model floor |

## Success Criteria

- [ ] Sonnet + Haiku complete at all 3 tiers (6 outputs minimum)
- [ ] GPT 5.4 at all 3 tiers if accessible (3 more)
- [ ] At least one local model attempt (Qwen 14B)
- [ ] All outputs pass Spec Auditor preserve rule check
- [ ] RESULTS.md populated with full comparison matrix
- [ ] Recommendation on default model documented
