# swarm spec

<!-- TODO REMOVE BEFORE FINAL COMMIT — dev-only reference pointer; operator-confirmed 2026-04-26 PM -->
> Reference (not checked in): `.reference/source-prompt.md` carries the original VS Code prompt that inspired this skill. Open side-by-side during development. Committed historical record at `.agents/tasks/00-ideas/swarm-review-source.md`.

## Purpose

The `swarm` skill is a generic multi-personality review and analysis infrastructure. Given any input artifact, it selects applicable reviewer personalities from a runtime registry, gates each on availability, dispatches the surviving set in parallel, aggregates findings via an arbitrator, and returns a synthesized verdict with a confidence rating.

`swarm` is infrastructure only. Consumer skills (e.g., `code-review`) call into it. The two have a strict consumer-service relationship; `swarm` must not merge with or replace any consumer skill.

## Definitions

| Term | Meaning |
| --- | --- |
| host | The swarm orchestrator agent. Runs selection, dispatches personalities, receives arbitrator output, and produces the final synthesis in host voice. |
| availability gate | A per-personality probe that determines whether a personality's required backend or model class is reachable at dispatch time. Personalities that fail the probe are dropped, not error-stopped. |
| arbitrator | A dedicated sub-agent that receives raw personality outputs, identifies disagreements, consolidates findings, and returns a structured action list to the host. The arbitrator is never a personality and is never subject to selection or gating. |

## Inputs / Outputs

### Inputs

| Input | Required | Description |
| --- | --- | --- |
| `problem` | required | The artifact under review. May be a conversation excerpt, file path, diff, plan, document, or structured description. |
| `additional_personalities` | optional | Inclusion list of personality names or indices. Named personalities are dispatched regardless of trigger evaluation; triggers are bypassed for named entries. Not an exclusion gate. Code-domain personalities (e.g. Code Quality Critic, Architect) are supplied here by consumer skills such as `code-review`; they are not built-in. |
| `disable_inline_personality_generation` | optional | When `true`, suppresses Custom Specialist on-the-fly generation. Swarm evaluates only registered built-ins and caller-supplied personalities. Default: `false` (generation is ON). |

### Output

A single host-voice synthesis containing:

- **Summary** — consolidated findings in host voice.
- **Disagreements** — each disagree-set item with stated tension and applied judgment.
- **Dropped personalities** — any personalities dropped at availability gate, with reason.
- **Confidence rating** — High, Medium, or Low with rationale. If Low, what would raise it must be stated.

Output cap: 2000 words. If findings exceed this budget, truncate at priority order: disagreements first, then high-severity, then medium, then low; note the truncation.

## Behavior (B-rules)

B1. If `problem` is empty or cannot be resolved into a reviewable artifact, return error: "No reviewable artifact found." Do not dispatch any personalities.

B2. If the swarm is empty after availability gating, return error: "Swarm empty after gating — no personalities available." Do not attempt synthesis.

B3. If the swarm contains only one personality, proceed and note the limited review scope in synthesis.

B4. If a dispatched personality returns no findings or times out, record it as non-contributing and exclude it from synthesis. Note the dropped personality in synthesis output.

B5. If all dispatched personalities return no findings, synthesis must state "No findings from any reviewer" and assign confidence rating Low.

B6. The Devil's Advocate personality must always be dispatched. There is no exclusion path.

B7. Custom menu personalities are evaluated against their caller-supplied trigger condition. If the trigger is "always", include them subject to availability gating.

B8. Cross-vendor diversity is best-effort: the swarm should include at least one personality running on a different model family or vendor than the host whenever possible. If unavailable after gating, proceed and note monoculture in synthesis output. Devil's Advocate is the natural diversity carrier.

B9. Selection reads only the personality registry index file — not body files. Body files are loaded at dispatch time for selected personalities only.

B10. When no built-in or caller-supplied personality covers the problem domain, and `disable_inline_personality_generation` is not `true`, swarm generates a Custom Specialist inline: (1) infers the appropriate role from the problem, (2) authors a brief system-prompt body for that role, (3) dispatches it with the same read-only and evidence-citation constraints as any registered personality. The generated personality is one-shot — not persisted to the registry.

B11. Devil's Advocate model-class preference: for problems classified as "conceptual" (big overarching ideas, design decisions, architecture choices, plans), prefer running Devil's Advocate on `gpt-class` (via `copilot-cli` backend) when available. Falls back to the host's Anthropic model class if `gpt-class` is unavailable. For code/file-level problems, default model class applies. This rule is best-effort and availability-gated — it is not a hard requirement.

## Constraints (C-rules)

C1. All dispatched sub-agents operate in read-only mode. Sub-agents must not edit files, run side-effecting commands, commit, or call any mutating tool. This constraint must be stated explicitly in every personality's dispatch prompt.

C2. Every dispatch prompt must include the literal phrase: "read-only review — analyze and report only, no file edits, no commits, no shell commands".

C3. The read-only constraint is behavioral, enforced by prompt instruction only. A sub-agent violation is a prompt-design defect, not a dispatch-skill defect.

C4. Every finding must cite specific evidence: a snippet, line reference, scenario, or direct quote. Each reviewer must be instructed to cite or retract.

C5. No bare model names may appear in the skill, reviewer files, or synthesis output. Use model class terms only (`haiku-class`, `sonnet-class`, `opus-class`).

C6. CLI-as-dispatch (e.g., `claude -p`, copilot CLI) is out of scope until task 10-0845 (dispatch skill CLI-extension) reaches PASS.

C7. All sub-agent launches are delegated to the `electrified-cortex/dispatch` skill. The swarm must not reinvent the launch primitive. See `specs/dispatch-integration.md`.

## Don'ts (DN-rules)

DN1. Must not load reviewer prompts for personalities that will not be dispatched.

DN2. Must not use a fixed roster; selection must evaluate trigger conditions against the artifact.

DN3. Must not fail-stop when a personality is unavailable; drop and continue.

DN4. Must not dump raw sub-agent output or raw arbitrator output to the caller; synthesize in host voice.

DN5. Must not merge with or replace the `code-review` skill.

DN6. Must not dispatch personalities sequentially when parallel dispatch is available.

DN7. Must not perform CLI-as-dispatch until task 10-0845 lands and is referenced here.

DN8. Must not allow custom menu entries to override or replace built-in registry entries; custom is additive only.

DN9. Must not treat `additional_personalities` as an exclusion list; it is an inclusion constraint. Omitting Devil's Advocate from `additional_personalities` does not exclude it — Devil's Advocate is always dispatched (see B6).

DN10. Must not have the host parse raw member output; that is the arbitrator's job.

DN11. Must not add the arbitrator to the personality registry or subject it to selection, gating, or filtering.

DN12. Must not implement `local-llm` backend routing in v1; the type is reserved only.

DN13. Must not embed a normative personality registry as a static table in this spec or in SKILL.md; the registry lives in `reviewers/index.md`.

DN14. Must not fail the swarm if cross-vendor diversity cannot be achieved; diversity is best-effort.

DN15. Must not dispatch a personality whose body file is missing or empty; drop with a warning.

DN16. Must not read body files during selection; this defeats the lazy-load architecture.

DN17. Must not add swarm scaffolding or exposition to a personality body file.

DN18. Must not expand the personality registry without a spec amendment and audit pass.

DN19. Must not include code-domain personalities (Code Quality Critic, Test Reviewer, Architect, Operational Readiness, Performance Reviewer, Copilot Reviewer) in the built-in registry. These are caller-supplied via `additional_personalities` by consumer skills such as `code-review`.

## Footguns

**F1: Loading all reviewer prompts at start** — bloats every invocation before selection runs. Load only after the swarm is finalized (post availability gate).

**F2: Silent availability-gate fail-stop** — a missing backend binary causes the entire skill to error. Probe failures must set personality status to dropped, not error.

**F3: Read-only constraint missing from dispatch prompt** — sub-agent has no instruction preventing file edits. Include the literal phrase from C2 in every personality dispatch.

**F4: Sequential dispatch** — personalities dispatched one by one, multiplying total latency. Issue all dispatches as a single parallel batch.

**F5: Synthesis dumps reviewer names** — exposes internal review machinery, breaking the host-voice requirement. Strip reviewer attribution before synthesis output.

**F6: Host bypasses arbitrator** — host synthesizes from raw member output, defeating arbitrator consolidation. Synthesis must receive only the arbitrator's structured action list.

**F7: Monoculture swarm** — all personalities resolve to the same model family as the host. Devil's Advocate should carry a non-Anthropic vendor preference (see B8, B11, and `specs/arbitrator.md`).

**F8: Informative registry table treated as normative** — personality list derived from a table in the spec instead of reading the index at runtime. `reviewers/index.md` is the only source of truth.

**F9: Reading body files at selection time** — loads all system prompts into context before selection, defeating lazy load. Read the index only at selection; load body files at dispatch time.

**Anti-pattern:** `additional_personalities: ["Security Auditor"]` — falsely assumes the inclusion list can suppress unwanted personalities or that omitting Devil's Advocate from this list excludes it. The inclusion list bypasses triggers unconditionally but does not exclude. Devil's Advocate is always dispatched regardless (see B6/DN10); omitting it from this list has no effect.

## Sub-Specs

Detail for each concern lives in the `specs/` directory. This spec references them normatively; their contents are not reproduced here.

| Sub-spec | Covers |
| --- | --- |
| `specs/registry-format.md` | Index file format options, validation rules, body-file naming convention |
| `specs/personality-file.md` | Body-file structure, frontmatter handling, system-prompt extraction rule |
| `specs/arbitrator.md` | Arbitrator role, output structure, exclusions, confidence rating logic |
| `specs/dispatch-integration.md` | How swarm uses the `electrified-cortex/dispatch` skill, model-class routing, parallelism |

## Recursive / Two-Level Use

`swarm` is designed to be dispatched as a sub-agent itself (two-level fractal). An outer host dispatches one swarm host per artifact; each dispatched swarm runs its own personalities and returns a single rolled-up synthesis. The outer host aggregates the syntheses.

Output contract is identical in both modes (Summary, Disagreements, Dropped personalities, Confidence rating). Two levels (caller → swarm host → personalities) are specified. Deeper nesting is not prohibited but is outside this spec's scope.

## Precedence Rules

P1. `additional_personalities` overrides trigger-condition evaluation for named entries.

P2. Availability gate overrides selection; a personality that passes selection but fails its probe is dropped.

P3. Read-only constraint (C1/C2) overrides any personality-specific instruction.

P4. Synthesis word budget (2000-word cap) overrides completeness; truncation is required over exceeding the cap.

## Open Questions

OQ1. CLI dispatch: `claude -p` and copilot CLI backends are explicitly deferred to task 10-0845. Once 10-0845 defines the CLI dispatch contract, this spec must be amended to reference it and remove the scope exclusion in C6.

OQ2. Selection-as-dispatch: inline selection is specified (Step 2 of execution). If the registry grows past approximately 20 entries, revisit whether a haiku-class meta-personality dispatch is more token-efficient than inline evaluation.

OQ3. Local-LLM discovery: the `local-llm` backend type is reserved; concrete availability probe, endpoint contract, and dispatch protocol are out of scope for v1 and must be specified before any `local-llm` registry entry is implemented.

## Section Classification

| Section | Type | Required |
| --- | --- | --- |
| Purpose | Descriptive | Yes |
| Definitions | Normative | Yes |
| Inputs / Outputs | Normative | Yes |
| Behavior (B-rules) | Normative | Yes |
| Constraints (C-rules) | Normative | Yes |
| Don'ts (DN-rules) | Normative | Yes |
| Footguns | Informational | No |
| Sub-Specs | Structural | Yes |
| Recursive / Two-Level | Normative | Yes |
| Precedence Rules | Normative | Yes |
| Open Questions | Deferred | No |
| Section Classification | Structural | Yes |
