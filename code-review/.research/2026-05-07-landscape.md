# Code Review Skill Landscape Research

Date: 2026-05-07
Status: complete
Scope: public agent skill repos, academic papers (May 2026 arxiv RSS), tooling integrations, severity conventions

---

## TL;DR

- **Adversarial framing beats neutral framing** - MOSAIC-Bench (arxiv 2605.03952) shows a pentester-framed reviewer detects 88.4% of adversarially injected vulnerabilities (4.6% FP rate on 608 real GitHub PRs) vs. 25.8% approval rate for neutral reviewers on confirmed-vulnerable diffs. Single-prompt framing change; no fine-tuning needed.
- **Homogeneous swarms are actively harmful** - arxiv 2605.00914 measures sycophantic conformity up to 85.5% and correct-answer loss up to 32.3 percentage points in same-model debate; 2.1-3.4x token cost for equal or lower accuracy. Cross-family diversity (different vendor/model) is the structural fix, not more rounds.
- **Hallucination filter before arbitration is load-bearing** - CodeAgora (github.com/bssm-oss/CodeAgora) shows baseline precision of 20% / recall 62.5% without a filter; after 4-check hallucination filter + structured debate it reaches 100%/100%/100% F1 on a 12-fixture golden-bug suite. The filter is implementable as reviewer-prompt instructions, no external tool needed.
- **SARIF is the CI integration standard; markdown is the authoring format** - SARIF 2.1.0 levels are error/warning/note; tools add a proprietary severity layer above that. The pattern: author findings in structured markdown, emit SARIF for CI gates, keep markdown for human output.
- **Hash-based skip is already production-validated** - code-review-graph (github.com/tirth8205/code-review-graph, 15.6k stars) incremental-updates a 2900-file project in under 2 seconds using SHA-256 hash checks on git-tracked files, skipping unchanged nodes. Pattern is directly analogous to our hash-record skill.

---

## Per-Pattern Review

### Tiered Review (fast-cheap pass + standard sign-off)

The two-pass tiered pattern is the most common practitioner pattern across all surveyed tools. AI Review (github.com/Nikita-Filonov/ai-review, 407 stars) formalizes three independent modes: run-inline (per-line, narrow context), run-context (cross-file, broader), and run-summary (high-level verdict), with an optional agent mode that adds a ReAct-style codebase exploration loop before the review call. The Productivity-Reliability Paradox paper (arxiv 2605.01160, multivocal review of 67 sources 2022-2026) documents the observable cost of skipping tiering: AI-assisted development produces 98% more PRs but 91% longer review times with flat delivery metrics, attributed to insufficient context discipline rather than model quality. A cheap smoke pass that catches obvious issues early reduces the review bottleneck identified as a primary PRP amplifier. Microsoft CodeReviewer (arxiv 2203.09095) provides the most rigorous pre-LLM baseline: three-task framing (quality estimation, comment generation, code refinement) on a 130k PR dataset, with quality estimation as the gating step - directly analogous to our smoke/substantive split. No post-2024 tiered-LLM eval papers were found with published precision/recall numbers; practitioner implementations agree on the pattern but publish anecdotal evidence only.

### Adversarial Review (one model attacks, another defends)

MOSAIC-Bench (arxiv 2605.03952, Steinberg & Gal, May 2026) is the most precisely measured adversarial review study found. It constructs 199 three-stage attack chains across 31 CWE classes and 5 languages, then measures downstream reviewer agent behavior. Standard reviewer agents approved 25.8% of confirmed-vulnerable cumulative diffs as routine PRs. Full-context provision closed only 50% of that gap, ruling out context fragmentation as the sole cause. Reframing the reviewer as an adversarial pentester drops evasion to 3.0%-17.6% across evaluated reviewer models. An open-weight Gemma-4-E4B-it reviewer under pentester framing detects 88.4% of attacks with a 4.6% false-positive rate on 608 real-world GitHub PRs - a remarkable result for a small open-weight model. The ARIS harness paper (arxiv 2605.03042, Yang et al., May 2026) independently validates the cross-model adversarial principle: "using Claude Code subagents for both execution and review tends to fall into local minima - the same model reviewing its own patterns creates blind spots." ARIS defaults to a different model family for the reviewer role and documents this as the single most important design decision. Practical guidance from both sources: (1) explicitly frame the reviewer as adversary/pentester in the system prompt, (2) use a different model vendor/family from the code author when possible.

### Swarm Review (multiple models in parallel, consensus)

Three production implementations exist with distinct consensus mechanics: Dissent (github.com/itsarbit/dissent), CodeAgora (github.com/bssm-oss/CodeAgora), and opencode-swarm (github.com/zaxbysauce/opencode-swarm). Dissent uses two phases: independent parallel review then structured debate where agents endorse, challenge (with grounded-quotation requirement to prevent hallucinated challenges), or withdraw findings. Consensus score = (1 + endorsements - challenges) x severity weight; findings classify as consensus (2+ endorsers, 0 challenges), split (contested), or emergent (surfaced only during debate). CodeAgora is more elaborate: L0 uses Thompson Sampling bandit selection to route to models with better quality history; L1 is parallel specialist reviewers; a 4-check hallucination filter removes fabricated file/line references before L2; L2 is a moderator-controlled supporter/devil-advocate debate; L3 is a head agent that runs `tsc` transpile on CRITICAL+ suggestions before emitting a verdict. The CodeAgora benchmark shows the baseline 3-reviewer config at precision 20.0%, recall 62.5%, F1 30.3% before calibration; after tuning it reaches 100%/100%/100% on 12 fixtures (small fixture set - proof-of-concept, not production evidence). Critical academic warning: arxiv 2605.00914 (Bertalanic & Fortuna, May 2026) shows homogeneous debate (same model family, no structured roles) produces sycophantic conformity up to 85.5%, correct-answer loss up to 32.3 pp, and 2.1-3.4x token overhead vs. self-correction for equal or lower accuracy. The fix is heterogeneous models + structured roles (moderator, devil's advocate), not more rounds.

### Single-Adversary Mode

Sarix (github.com/AvixoSec/sarix) implements the cleanest single-adversary pattern: it ingests an existing SARIF file from Semgrep/CodeQL, then runs a judge-and-skeptic two-agent loop. The judge promotes/downgrades/dismisses scanner alerts by attaching source context (input source, sink, missing guard); the skeptic re-checks high-confidence verdicts before CI trusts them. Output vocabulary: exploitable | likely_exploitable | uncertain | probably_false_positive | not_exploitable. The "no evidence, no confident verdict" principle is explicit: the system refuses to emit "exploitable" without a full evidence path (source -> sink -> missing guard). This is the most rigorous false-positive control mechanism found in the survey. No published precision/recall numbers for Sarix at time of writing. MOSAIC-Bench pentester-framing result (88.4% detection, 4.6% FP on real PRs) is the best published single-adversary number but applies specifically to security vulnerability detection under adversarial framing.

---

## Tooling + Integration Patterns Worth Borrowing

**Blast-radius-first context selection.** code-review-graph uses Tree-sitter ASTs stored in SQLite to compute which files are actually affected by a change (callers, dependents, tests) before handing context to the LLM reviewer. In a 2900-file project, a change to one file results in approximately 5-15 files read, not 2900. Result: 6.8x average token reduction on review tasks, 49x on full codebase tasks. The analogous pattern for e-cortex: before dispatching a code-review agent on a git range, compute blast radius from `git diff --name-only` + dependency analysis, pass only the affected-file set as context rather than the full repo diff.

**Pre-analysis enrichment layer.** CodeAgora runs 5 pre-analysis steps before L1 review: semantic diff classification, TypeScript diagnostics (`tsc` on changed files), change impact analysis, external AI rule detection (auto-injects `.cursorrules`, `CLAUDE.md`, `copilot-instructions.md`), and build artifact exclusion. The external-AI-rule detection is directly applicable: auto-detect the repo's `CLAUDE.md` or style guide and inject as context_pointer if the caller did not specify one. The build artifact exclusion (`dist/`, lock files, `*.min.js`) is also directly implementable as a pre-dispatch filter on the file list.

**Hallucination filter as mandatory pre-arbitration gate.** CodeAgora's 4-check filter is prompt-engineering level; no external tooling required. The file-existence and line-range checks are deterministic against the diff hunk list. The code-quote fabrication check (does the quoted snippet actually appear in the diff?) is a string match. The self-contradiction check (claims "added" but only removals exist) is also deterministic. All four can be expressed as reviewer-prompt instructions. CodeAgora's evidence shows these filters drove precision from 20% to 100% on its fixture set - the single highest-leverage intervention found in this survey.

**GitHub Actions + SARIF.** CodeAgora, Sarix, and AI Review all emit SARIF 2.1.0 for GitHub Code Scanning integration and post inline PR comments via the GitHub Review API. Pattern: review output -> SARIF file -> upload-sarif action -> code scanning alerts, plus a separate step posting inline comments. This is the production-ready CI integration path for any skill that gains a CI integration use case.

**Thompson Sampling for model selection.** CodeAgora's L0 uses a bandit algorithm that tracks per-model quality history and routes future reviews to higher-performing models. Too complex for current stage but the principle (track per-model quality signals and prefer higher-signal models over time) is worth noting as a future direction for capability-cache evolution.

**Session storage for audit trail.** CodeAgora stores per-run artifacts: raw L1 outputs, L2 debate transcripts, unconfirmed issues, moderator report, head verdict, all under `.ca/sessions/YYYY-MM-DD/NNN/`. This is the hash-record pattern applied to review runs rather than individual files - an audit trail for review results, not just file hashes.

---

## Severity + Format Conventions

**SARIF 2.1.0 canonical levels:** error | warning | note | none. These map to GitHub Code Scanning alert severity. Mapping used by CodeAgora and Sarix:

| Tool internal | SARIF level | GitHub severity |
| --- | --- | --- |
| HARSHLY_CRITICAL / exploitable | error | Critical / Error |
| CRITICAL / likely_exploitable | error | Error |
| WARNING / uncertain | warning | Warning |
| SUGGESTION / probably_false_positive | note | Note |

**Emerging practitioner vocabulary (non-SARIF):** Dissent uses high | medium | low with no nit/info tier. CodeAgora uses HARSHLY_CRITICAL | CRITICAL | WARNING | SUGGESTION. Sarix uses exploitability-framed verdicts. Our existing code-review skill uses two separate vocabularies (blocker/major/minor/nit in tiered mode; critical/high/medium/low/info in single-adversary mode) - the only surveyed tool with a split vocabulary across modes, which creates caller confusion and complicates SARIF mapping.

**Markdown-first, JSON-structured:** All production tools author findings in structured markdown and generate SARIF as a downstream artifact, not as the primary authoring format. The finding structure that appears most consistently across tools:

```json
{
  "severity": "high|medium|low",
  "file": "path/to/file",
  "line": <int or null>,
  "title": "Specific short title naming the exact problem",
  "detail": "Concrete scenario: what input/condition triggers it, what breaks, why it matters",
  "suggestion": "Code-level fix: name the specific function/pattern/change"
}
```

Dissent's prompt engineering guidance for title/detail/suggestion is worth adopting verbatim: "Title must be specific. Bad: 'Cache issue'. Good: 'required_capability missing from cache key'. Detail must include a concrete scenario showing when the bug triggers. Suggestion must be actionable at the code level." This guidance reduces the hallucination rate for low-signal findings and measurably improves reviewer output quality.

---

## Specific Recommendations for electrified-cortex

### For code-review skill

**R1. Unify severity vocabulary.** Current split (blocker/major/minor/nit vs critical/high/medium/low/info) is non-standard and creates caller confusion. Proposal: adopt critical | high | medium | low | info as the single vocabulary across all modes. Map to SARIF on output: critical/high -> error, medium -> warning, low/info -> note. Aligns with the emerging industry standard and enables future SARIF output.

**R2. Add adversarial framing to the smoke-pass instruction.** Based on MOSAIC-Bench findings, the smoke-pass (haiku-class) should include an explicit adversarial frame in instructions.txt: "Assume the author made at least one mistake. Your job is to find it." For security focus: "Frame yourself as a pentester looking for exploitable paths, not a colleague doing a courtesy review." This is a prompt-level change with no architectural cost and a documented 3x+ detection improvement for security findings.

**R3. Add hallucination filter criteria to both passes.** Add to the reviewer agent prompt: "For every finding you emit: (1) the file path must appear in the provided diff, (2) the line number must be within a changed hunk or within 10 lines of one, (3) any code you quote verbatim must appear in the diff. Omit findings that fail any check." This is CodeAgora's 4-check filter expressed as reviewer instructions. No external tooling needed.

**R4. Auto-detect context_pointer.** Before dispatching either pass, check for `CLAUDE.md`, `README.md`, `.cursorrules`, or `copilot-instructions.md` in the repo root and inject as context_pointer if the caller did not specify one. Reduces caller friction and improves reviewer calibration.

**R5. Consider a pre-dispatch blast-radius step.** When `change_set` is a git range/ref (not an inline diff), add an optional step that uses `git diff --name-only` to restrict the context to affected files before constructing the diff payload. Mirrors code-review-graph approach; can reduce token cost substantially on large PRs.

### For swarm skill

**R6. Strengthen the heterogeneity mandate (B8).** Current B8 is best-effort. The homogeneous-debate failure paper (85.5% conformity, 32.3 pp accuracy loss) shows same-family swarms are actively harmful, not just suboptimal. Upgrade B8 to: "If all available personalities resolve to the same model family, dispatch Devil's Advocate on a different family or degrade to single-adversary mode rather than running a homogeneous swarm." Behavior change, not architectural change.

**R7. Add grounded-challenge requirement to S6 arbitrator prompt.** Dissent's grounded-challenge check (a challenge must quote text actually present in the finding) prevents hallucinated challenges from polluting arbitration. Add to the arbitrator prompt: "Before citing a member finding as incorrect, quote the exact sentence from that finding you believe is wrong. Do not challenge your interpretation of the finding - only challenge what the finding explicitly states."

**R8. Add pre-arbitration file-existence filter to S5.** Before sending member outputs to S6, instruct the host to filter any finding where the cited file is not in the review packet Files-affected list. Deterministic string match, done in the synthesis prompt without an extra dispatch: "Discard any finding that references a file not in this list: [files]."

**R9. Add structured-evidence requirement for high+ findings in S5 reviewer prompt.** Sarix principle - no evidence, no confident verdict - applied to swarm: "For each HIGH or CRITICAL finding, include: Source (where the input comes from), Sink (where the risk lands), Missing guard (what check is absent). Findings at high+ severity without this evidence structure will be treated as medium." Raises signal-to-noise on the most actionable findings.

**R10. Note SARIF output mode as a future extension.** None of our skills currently emit SARIF. If code-review and swarm gain CI integration use cases, a thin SARIF emitter (error/warning/note levels, ruleId from severity, physicalLocation from file/line) would unlock GitHub Code Scanning integration. Defer until concrete CI demand exists.

---

## Source List

- [CodeAgora - multi-model debate review](https://github.com/bssm-oss/CodeAgora) - L1/L2/L3 pipeline, hallucination filter, Thompson Sampling, benchmark data
- [CodeAgora benchmark report 2026-04-27](https://github.com/bssm-oss/CodeAgora/blob/main/docs/golden-bug-benchmark-report-2026-04-27.md) - 12-fixture golden-bug suite, baseline (P=20%, R=62.5%) vs tuned (P=100%, R=100%)
- [Dissent - swarm debate with endorsement/challenge/withdrawal](https://github.com/itsarbit/dissent) - consensus scoring formula, grounded-challenge anti-hallucination, YAML persona system
- [code-review-graph - SHA-256 incremental hash skip + blast radius](https://github.com/tirth8205/code-review-graph) - 6.8x token reduction, 2s re-index on 2900-file project, MCP integration
- [AI Review - multi-provider, multi-mode, CI integration](https://github.com/Nikita-Filonov/ai-review) - inline/context/summary modes, agent mode with ReAct codebase exploration
- [Sarix - judge+skeptic SARIF verifier](https://github.com/AvixoSec/sarix) - input-to-sink evidence requirement, exploitability vocabulary
- [opencode-swarm - gated architect-led pipeline](https://github.com/zaxbysauce/opencode-swarm) - hallucination verifier agent, placeholder scan, SAST/secrets gates
- [ARIS - cross-model adversarial research harness](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep) - 65+ Markdown skills, cross-family reviewer recommendation, arxiv paper 2605.03042
- [ARIS technical report - arxiv 2605.03042](https://arxiv.org/abs/2605.03042) - Yang et al., May 2026; cross-model adversarial collaboration architecture; "same model self-reviewing creates local minima"
- [MOSAIC-Bench - arxiv 2605.03952](https://arxiv.org/abs/2605.03952) - Steinberg & Gal, May 2026; 199-chain attack benchmark; neutral reviewer 25.8% approval of vulnerable PRs; pentester-framed reviewer 88.4% detection, 4.6% FP on 608 real GitHub PRs; evasion 3.0%-17.6% under adversarial framing
- [Homogeneous debate failures - arxiv 2605.00914](https://arxiv.org/abs/2605.00914) - Bertalanic & Fortuna, May 2026; 85.5% sycophantic conformity, 32.3 pp oracle gap, 2.1-3.4x token overhead vs self-correction for equal or lower accuracy
- [Multiagent debate improves factuality - arxiv 2305.14325](https://arxiv.org/abs/2305.14325) - Du et al., 2023; foundational "society of minds" paper; cited by CodeAgora as design basis
- [Productivity-Reliability Paradox - arxiv 2605.01160](https://arxiv.org/abs/2605.01160) - Farrag, May 2026; 67-source multivocal review 2022-2026; 98% more PRs + 91% longer review times + flat delivery metrics; code review bottleneck as primary PRP amplifier
- [Microsoft CodeReviewer - arxiv 2203.09095](https://arxiv.org/abs/2203.09095) - Zhipeng Gao et al., 2022; quality estimation / comment generation / code refinement on 130k PRs; pre-LLM tiered baseline
- [SARIF 2.1.0 specification](https://docs.oasis-open.org/sarif/sarif/v2.1.0/sarif-v2.1.0.html) - OASIS; canonical error/warning/note/none level vocabulary
