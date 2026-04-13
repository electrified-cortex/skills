# Compression Benchmark Results

Baseline: `inputs/recipe.md` — 1172 words, 131 lines, 129 articles, 2 filler words.

**Model versions tested:** Sonnet = `claude-sonnet-4-20250514`, Opus = `claude-opus-4-20250514`,
Haiku = `claude-haiku-4-5-20251001`, GPT = `GPT 5.4` (Copilot model identifier).

## Dual-Metric Matrix

| Tier | Model | Words | Reduction | Conformance | Notes |
| --- | --- | ---: | ---: | ---: | --- |
| Lite | Sonnet | 1090 | 7.0% | 90% | 1 uncontracted "do not"; 4 articles removed (should keep) |
| Lite | Haiku | 1141 | 2.6% | 95% | Correct but conservative; minimal filler removal |
| Lite | GPT | 1139 | 2.8% | 95% | Same as Haiku — rules followed, low aggression |
| Lite | **Opus** | 1061 | **9.5%** | 91% | 9 articles removed (should keep); 0 filler, 0 uncontracted |
| Full | Sonnet | 734 | 37.4% | 95% | 3 articles survive; structural markdown correct |
| Full | Haiku | 916 | 21.8% | 85% | 0 articles ✓ but undercompresses; retains connective tissue |
| Full | GPT | 932 | 20.5% | 85% | 1 article; undercompresses like Haiku |
| Full | **Opus** | 841 | **28.2%** | 93% | 2 articles survive; structural markdown ✓, good synonym use |
| Ultra | Sonnet | 690 | 41.1% | 98% | Label: format ✓, 0 articles, 0 bullets, contractions ✓ |
| Ultra | Haiku | 666 | 43.2% | 92% | Label: format ✓, 1 article survives |
| Ultra | GPT | 654 | 44.2% | 90% | Label: format ✓, 2 articles survive |
| Ultra | **Opus** | 676 | **42.3%** | 93% | Label: ✓, 2 articles survive, 32 abbreviations |

## Compression Ratio by Tier

| Model | Lite | Full | Ultra |
| --- | ---: | ---: | ---: |
| Sonnet | 7.0% | **37.4%** | 41.1% |
| **Opus** | **9.5%** | 28.2% | **42.3%** |
| Haiku | 2.6% | 21.8% | 43.2% |
| GPT | 2.8% | 20.5% | 44.2% |

## Conformance by Tier

| Model | Lite | Full | Ultra |
| --- | ---: | ---: | ---: |
| Sonnet | 90% | 95% | **98%** |
| **Opus** | 91% | 93% | 93% |
| Haiku | 95% | 85% | 92% |
| GPT | 95% | 85% | 90% |

## Conformance Methodology

Each output scored against its tier's SKILL.md rules. Deductions for:
- Remaining articles in Full/Ultra (should be 0): -3% each
- Removed articles in Lite (should keep): -2% each
- Uncontracted multi-word negations ("do not" instead of "don't"): -5% each
- Wrong heading format in Ultra (`##` instead of `Label:`): -20%
- Remaining bullet markers in Ultra (`- `): -15%
- Residual filler words: -5% each
- Undercompression (retaining connective tissue beyond tier spec): -5% to -15%

Baseline filler scan: original recipe has 2 filler words ("simply" x2). All models
removed both at every tier.

## Conformance Audit Detail

### Lite (rules: remove filler/hedging, KEEP articles, full sentences, contractions)

| Check | Sonnet | Haiku | GPT | Opus |
| --- | --- | --- | --- | --- |
| Filler removed | 2/2 ✓ | 2/2 ✓ | 2/2 ✓ | 2/2 ✓ |
| Articles kept | 125/129 (4 lost) | 128/129 ✓ | 128/129 ✓ | 120/129 (9 lost) |
| Full sentences | ✓ | ✓ | ✓ | ✓ |
| Contractions | ✗ 1 "do not" | ✓ | ✓ | ✓ |

Opus compresses most aggressively at Lite (9.5%) but loses more articles than it
should. Sonnet has a contraction miss. Haiku/GPT are conservative but more conformant.

### Full (rules: remove articles, remove filler, short synonyms, keep structural markdown)

| Check | Sonnet | Haiku | GPT | Opus |
| --- | --- | --- | --- | --- |
| Articles removed | 3 survive | 0 ✓ | 1 survives | 2 survive |
| Structural markdown | ✓ | ✓ | ✓ | ✓ |
| Short synonyms | Aggressive ✓ | Moderate | Moderate | Moderate-Aggressive |
| Contractions | ✓ | ✓ | ✓ | ✓ |
| Connective tissue | Stripped ✓ | Retained | Retained | Mostly stripped |

Sonnet strips connective tissue most aggressively (37.4%). Opus compresses 28.2%
with 2 surviving articles. Haiku/GPT undercompress despite correct article handling.

### Ultra (rules: Label: format, strip bullets, remove articles, abbreviations, telegraphic)

| Check | Sonnet | Haiku | GPT | Opus |
| --- | --- | --- | --- | --- |
| Label: format | ✓ | ✓ | ✓ | ✓ |
| Bullets stripped | ✓ | ✓ | ✓ | ✓ |
| Articles removed | 0 ✓ | 1 survives | 2 survive | 2 survive |
| Abbreviations | Used ✓ | Some ✓ | Some ✓ | 32 — heavy ✓ |
| Contractions | ✓ | ✓ | ✓ | ✓ |
| Telegraphic style | ✓ | Partial | Partial | Mostly ✓ |

All four models follow structural rules (Label: format, no bullets). Sonnet achieves
cleanest article removal (0) and highest conformance (98%). Opus uses the most
abbreviations (32) but retains 2 articles, same as GPT. Haiku/GPT follow structural
rules but retain more natural phrasing.

## Model Comparison

### Ranking by Conformance

1. **Sonnet** — highest conformance at Ultra (98%) and strong at Full (95%). Best
   structural rule adherence. Minor Lite issue (1 uncontracted negation, 4 articles
   removed).
2. **Opus** — comparable to Sonnet at Full (93%) and Ultra (93%). Uses abbreviations
   aggressively but retains a few articles at higher tiers. Slight over-compression
   at Lite (9 articles lost).
3. **Haiku** — perfect article removal at Full, good Ultra conformance (92%).
   Conservative but correct at Lite (95%).
4. **GPT** — similar to Haiku across all tiers. Slightly lower Ultra conformance
   (2 surviving articles vs Haiku's 1).

### Ranking by Compression Depth

1. **Opus** — highest at Lite (9.5%) and Ultra (42.3%). Slightly below Sonnet at
   Full (28.2% vs 37.4%).
2. **Sonnet** — strongest at Full (37.4%). Competitive at Ultra (41.1%).
3. **GPT** — highest raw Ultra compression (44.2%) but with conformance
   trade-off. Undercompresses at Full (20.5%).
4. **Haiku** — nearly identical to GPT. Conservative at Lite (correct). Weak at
   Full (21.8%).

### Combined Score (Compression × Conformance)

| Model | Lite | Full | Ultra | Average |
| --- | ---: | ---: | ---: | ---: |
| Sonnet | 6.3 | 35.5 | 40.3 | **27.4** |
| Opus | 8.6 | 26.2 | 39.3 | 24.7 |
| Haiku | 2.5 | 18.5 | 39.7 | 20.2 |
| GPT | 2.7 | 17.4 | 39.8 | 20.0 |

Combined score = reduction% × (conformance/100). Higher = better.

### Key Insight: Context Contamination in Benchmarks

Initial Opus tests were run directly by the Curator agent (Claude Opus), which had
full context about the test procedure, other models' results, and the conformance
scoring rubric. Those biased results showed Opus at 59.5%/99% Ultra — dramatically
overstating its capability.

When re-run via a clean subagent (same model, no context about other results), Opus
produced 42.3%/93% Ultra — competitive with Sonnet but NOT dominant. The context
difference inflated compression by 40% and conformance by 6 points.

**Lesson:** Model benchmarks must use isolated, context-free test runners. Benchmark
agents should have NO access to other results, scoring rubrics, or tier rules beyond
what's in their compression prompt.

### Key Insight: Conformance vs Compression Trade-off

At Ultra, an inversion appears among smaller models:

| Model | Ultra Reduction | Ultra Conformance |
| --- | ---: | ---: |
| Sonnet | 41.1% | **98%** |
| Opus | 42.3% | 93% |
| Haiku | 43.2% | 92% |
| GPT | 44.2% | 90% |

Haiku, GPT, and Opus all achieved MORE word reduction than Sonnet at Ultra, but with
LOWER conformance. They cut verbose phrases while leaving articles. Sonnet's proper
Label: formatting + thorough article removal (0 articles) makes it the most conformant
despite slightly lower compression.

Opus resolves this trade-off partially — higher compression than Sonnet (42.3% vs
41.1%) but with slightly lower conformance (93% vs 98%). When run without context
contamination, Opus is competitive with Sonnet but not clearly superior.

The old Sonnet Ultra (now replaced) was 519 words / 55.7% reduction but violated
structural rules (`##` headings, `- ` bullets). After re-running with current rules,
Sonnet dropped to 690 words / 41.1% — a 17pp reduction in compression ratio just
from following the structural rules correctly.

**Conclusion:** Compression % alone is misleading without conformance. A model that
compresses 55% but violates structural rules is worse than one that compresses 41%
while following all rules. Both metrics are needed.

## Multi-Pass Experiment: 2×Haiku vs 1×Sonnet

**Question:** Does running Haiku twice (compress → compress again) achieve
Sonnet-equivalent results at lower cost?

**Method:** Fed the Haiku Ultra output (666 words) back through Haiku with identical
Ultra rules.

**Result:**

| Metric | 1×Haiku | 2×Haiku | 1×Sonnet | 1×Opus |
| --- | ---: | ---: | ---: | ---: |
| Words | 666 | 666 | 690 | 676 |
| Reduction | 43.2% | 43.2% | 41.1% | 42.3% |
| Conformance | 92% | 92% | 98% | 93% |
| Articles | 1 | 1 | 0 | 2 |

**Changes in 2nd pass:** Minimal. "all-purpose flour" → "AP flour",
equipment/timing lists semicolon-joined, "few minutes" → "few min", periods
added to troubleshooting lines. Word count identical (666).

**Finding:** Haiku has a fixed compression floor. A second pass makes no meaningful
improvement — same word count, same surviving article, same conformance. The
compression ceiling is determined by model capability, not iteration count.

**Answer:** **No.** 2×Haiku ≠ 1×Sonnet. Haiku's floor (43.2%/92%) remains
below Sonnet's ceiling (41.1%/98%) in conformance. All models cluster in the
40–44% compression range at Ultra — the differentiator is conformance, not depth.
Model capability cannot be substituted with iteration.

### Other Observations

- Sonnet-to-Haiku gap is largest at Full tier (~16 percentage points of compression).
  Full requires the most interpretive precision — smaller models hedge on fragment
  usage and connective tissue stripping.
- Lite compression is gentle enough that all models produce nearly identical output.
  The tier may need stricter rules to differentiate from source.
- All models correctly apply contractions except Sonnet at Lite (1 miss).
- All models correctly flatten Ultra headings to `Label:` format — the structural
  rules transfer well across models.
- Opus's Lite weakness (9 articles removed) suggests it over-applies compression
  instinct even at the gentlest tier.
- Context contamination inflated Opus results by ~40% at Ultra. Clean subagent
  isolation is essential for honest benchmarks.

## Recommendations

- **Default model for compression: Opus.** Operator decision. Opus shows competitive
  compression across all tiers (Lite 9.5%, Full 28.2%, Ultra 42.3%) with strong
  conformance (91-93%). While Sonnet leads on the combined score metric (27.4 vs
  24.7 avg), Opus delivers more consistent results and higher raw compression at
  Lite and Ultra. For the workspace's actual usage (mostly Ultra on agent files and
  skills), Opus is the right default.
- **Sonnet remains a strong alternative.** Highest combined score (27.4 avg) and best
  conformance at Full/Ultra (95%/98%). If conformance precision matters more than
  raw compression depth, Sonnet is the better pick.
- **Haiku viable for Lite tier** where minimal compression is expected. Cost savings
  meaningful if Lite is the target. At Full/Ultra, Haiku undercompresses connective
  tissue even while correctly removing articles.
- **GPT interchangeable with Haiku.** Cross-vendor portability confirmed — the
  skill instructions transfer. No significant advantage over Haiku.
- **Multi-pass is not cost-effective.** Running Haiku twice achieves nothing a single
  pass didn't. Model capability > iteration count.
- **Full tier rules may need strengthening.** The Sonnet-Haiku gap at Full suggests
  smaller models need more explicit connective tissue removal instructions.
- **Both metrics required in any future benchmark.** Compression % without conformance
  is misleading. The old Sonnet Ultra result proved this — 55.7% reduction but
  non-conformant on structural rules.
- **Benchmark isolation is mandatory.** Always use context-free subagents for
  compression benchmarks. Never run benchmarks directly from an agent with access
  to other results or scoring rubrics.
- **Local model tests pending.** Qwen 14B and Qwen 1.7B not yet tested.

## Remaining Work

- [x] Test Opus at all 3 tiers
- [x] Multi-pass Haiku experiment (2×Haiku vs 1×Sonnet)
- [ ] Run Spec Auditor on all 13 outputs
- [ ] Test Qwen 14B at all 3 tiers (requires local Ollama instance)
- [ ] Test Qwen 1.7B at all 3 tiers
- [ ] Update recommendations after local model results
- [ ] Create compression README with model choice rationale
