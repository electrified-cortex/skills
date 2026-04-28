# swarm-protocol spec

## Purpose

Define the `swarm-protocol` skill: a generic multi-personality review and analysis infrastructure skill. Given any input artifact, the skill selects applicable reviewer personalities from a registry, gates each on availability, dispatches the surviving set in parallel, aggregates their findings, tracks disagreements, and returns a synthesized verdict with a confidence rating.

`swarm-protocol` is infrastructure. It does not perform reviews itself. Consumer skills (e.g., `code-review`) call into it with a problem and an optional personality filter. The skill is not a code-review skill; the two have a strict consumer-service relationship.

## Scope

Applies to any calling agent or skill that needs multi-perspective review of a problem artifact (conversation context, file, diff, plan, document, or other structured input).

Does NOT cover:

- The `code-review` consumer skill or any other consumer skill's internal logic.
- How to write reviewer prompts (that is a data concern, not a behavioral requirement of this skill).
- Non-review dispatch use cases (search, generation, transformation).
- Any side-effecting operation by a dispatched personality; all personalities are strictly read-only.
- CLI-as-dispatch patterns for environments where the `dispatch` skill's Agent tool is unavailable. That extension is tracked in task 10-0845 and must be specified there before CLI dispatch is added here.

## Definitions

**Artifact**: the input content under review. May be a conversation excerpt, file path, diff, plan, document, or structured description. Passed as the `problem` input.

**Review packet**: a self-contained brief assembled from the artifact. Contains Goal, Approach, Key decisions, Artifacts (actual content), Files affected (when relevant), Blast radius (when relevant), and applicable Conventions (when relevant). Fields that do not apply to a given artifact type are omitted.

**Personality**: a named reviewer role with a defined trigger condition, preferred model class, backend type, and scope limiter. Personalities are loaded lazily; their full prompts are not present at selection time.

**Personality registry**: the built-in ordered table of personalities defined in this skill. Extended at call time by a caller-supplied custom menu.

**Custom menu**: a caller-supplied list of additional personalities appended to the registry for the current invocation only. Does not persist between invocations.

**Selection**: the process of filtering the combined registry against the artifact's problem traits to produce the active personality set.

**Availability gate**: a probe step for each selected personality that confirms the required backend is reachable before dispatch.

**Swarm**: the surviving set of personalities after selection and availability gating.

**Dispatch skill**: `electrified-cortex/dispatch` — the authoritative agent-launching mechanism. `swarm-protocol` delegates all sub-agent launches to this skill; it must not reinvent the launch primitive.

**Disagree set**: the subset of swarm findings where two or more personalities reached contradictory conclusions on the same point.

**Confidence rating**: a three-value scalar (High / Medium / Low) attached to the synthesis output. Reflects reviewer agreement, evidence quality, and scope coverage.

**model class**: an abstract tier identifier: `haiku-class` (shallow, mechanical), `sonnet-class` (moderate reasoning, default for most personalities), `opus-class` (heavy architectural reasoning). No bare model names may appear anywhere in the skill.

**Caller override**: a caller-supplied `model_overrides` map that pins one or more personalities to a specific model class for the current invocation.

**Availability probe**: a lightweight shell command (e.g., `copilot --version`) or tool call used to confirm a backend is live before including the personality in the swarm.

**Backend**: the execution target for a personality. One of: `dispatch-sonnet` (Agent tool dispatch at sonnet-class), `dispatch-haiku` (Agent tool dispatch at haiku-class), `dispatch-opus` (Agent tool dispatch at opus-class), or `copilot-cli` (external `copilot` CLI process).

## Personality Registry

The registry is normative. All built-in personalities must appear in this table. Trigger conditions are evaluated against problem traits. Multiple triggers may be satisfied; all matching personalities are included unless filtered by `personality_filter`.

| # | Personality | Trigger condition | Default model class | Backend | Scope limiter |
| --- | --- | --- | --- | --- | --- |
| 1 | Devil's Advocate | always | sonnet-class | dispatch-sonnet | Challenge assumptions; no constructive suggestions |
| 2 | Security Auditor | problem touches auth, user input, API endpoints, data access, secrets, or network calls | sonnet-class | dispatch-sonnet | Find vulnerabilities only; no design advice |
| 3 | Code Quality Critic | problem includes code (new or modified) | sonnet-class | dispatch-sonnet | Code conventions, readability, duplication; no security or arch |
| 4 | Test Reviewer | problem includes new or modified logic requiring test coverage | sonnet-class | dispatch-sonnet | Test coverage and quality only |
| 5 | Architect | problem affects system structure, introduces new abstractions, crosses service boundaries, or modifies shared infrastructure | sonnet-class | dispatch-sonnet | Structural and interface concerns only |
| 6 | Operational Readiness | problem introduces new failure modes, external dependencies, error handling paths, or production-facing behavior | sonnet-class | dispatch-sonnet | Observability, recovery, degraded-mode behavior |
| 7 | Performance Reviewer | problem involves data access, loops, serialization, caching, or computationally significant logic | sonnet-class | dispatch-sonnet | Throughput, latency, resource use only |
| 8 | Copilot Reviewer | problem includes code and copilot-cli is available | external | copilot-cli | Full code review via Copilot; availability-gated |
| 9 | Custom Specialist | caller explicitly supplies via custom menu | varies | varies | Defined by caller in custom menu entry |

Registry entries must not be re-ordered; the integer index is stable across invocations and used in disagreement tracking.

## Custom Personality Menu

Callers may supply additional personalities that extend the registry for a single invocation. Each custom entry must specify: name, trigger condition, model class (or inherit from caller override), backend, and scope limiter. Custom entries are appended after entry 9 in evaluation order. They do not mutate the built-in registry.

## Inputs

| Input | Required | Type | Description |
| --- | --- | --- | --- |
| `problem` | required | artifact | The content under review. |
| `personality_filter` | optional | list of personality names or indices | If supplied, restricts the candidate set to the named personalities (from built-in registry + custom menu). Personalities not in the filter are not evaluated against trigger conditions and are not dispatched. |
| `model_overrides` | optional | map of personality name → model class | Pins the given personalities to the specified model class for this invocation. Overrides the default model class in the registry. |

## Step Sequence

### Step 1 — Build the review packet

The skill constructs a review packet from `problem`. The packet must be self-contained: a reader with zero prior context must understand what is being reviewed, why, and what the key decisions were.

Required packet fields (omit if not applicable to the artifact type):

- Goal: what problem is being solved or what output is being evaluated.
- Approach: what was proposed, implemented, or produced.
- Key decisions: why this approach over alternatives.
- Artifacts: the actual content under review (diffs, text, config — not a description of it).
- Files affected: list with brief descriptions (for code or config artifacts).
- Blast radius: downstream consumers, imports, integrations affected.
- Conventions: applicable project conventions (for code artifacts).

The skill must verify the packet before proceeding: Goal must be specific enough to evaluate; Artifacts must include actual content, not just references. If either condition fails, the skill must attempt to resolve the gap from available context before proceeding. The skill must not ask the caller to fill gaps.

### Step 2 — Select personalities

The skill reads the combined registry (built-in + custom menu). If `personality_filter` is supplied, the candidate set is restricted to named personalities. Trigger conditions are evaluated against the problem traits inferred from the review packet. Personalities whose trigger condition is not satisfied are excluded from the active set.

Selection logic must be inline within the skill. A separate dispatch for personality selection is not used. Rationale: the token cost of a selection dispatch exceeds the cost of inline evaluation for registries of the current scale (under 12 entries). This decision should be revisited if the registry grows beyond approximately 20 entries.

Devil's Advocate (entry 1) must always be included regardless of trigger evaluation. The `personality_filter` may exclude Devil's Advocate only when the caller explicitly names an explicit subset that omits it.

### Step 3 — Availability gating

For each selected personality whose backend is not `dispatch-sonnet` or `dispatch-haiku` or `dispatch-opus` (i.e., for any external backend such as `copilot-cli`), the skill must run the availability probe before including that personality in the swarm.

- If the probe succeeds, the personality is included.
- If the probe fails, the personality is dropped from the swarm for this invocation. The drop must be noted in the synthesis output. The skill must not fail-stop or surface an error to the caller.
- For `dispatch-*` backends, no probe is required; the dispatch skill handles errors internally.

### Step 4 — Load reviewer prompts

Only after the swarm is finalized (post-gating) does the skill load the prompt for each surviving personality. Reviewer prompts are stored as separate sub-skill files under `swarm-protocol/reviewers/<name>.md`. The skill loads only the files corresponding to dispatched personalities. Files for non-dispatched personalities must not be loaded.

Rationale for sub-skill files over inline data: inline prompts bloat the context regardless of which personalities are selected, defeating lazy loading. Dynamic data loading at dispatch time keeps the skill's base context minimal. This is a normative decision; implementors must not revert to inline prompts.

### Step 5 — Dispatch

The skill dispatches all swarm personalities in parallel using the `dispatch` skill. All dispatches in a single swarm invocation must be issued as a single batch; the skill must not issue them sequentially.

Each personality dispatch receives: (1) the full review packet from Step 1, (2) the personality's prompt loaded in Step 4, (3) an explicit read-only constraint (see Constraints section C1–C3).

The skill applies `model_overrides` at dispatch time: if a caller override exists for a personality, the override model class is used; otherwise the registry default applies.

### Step 6 — Aggregate findings and track disagreements

The skill collects findings from all dispatched personalities. For each finding, the skill records: personality index, finding summary, cited evidence.

The skill identifies the disagree set: findings where two or more personalities reached contradictory conclusions on the same point. Each disagree entry records the personalities involved and the conflicting claims.

### Step 7 — Synthesize and return

The skill synthesizes findings into a single host-voice output. It must not dump raw sub-agent output to the caller. It speaks as the host, presenting refined takeaways.

Required synthesis output fields:

- Summary: consolidated findings in host voice.
- Disagreements: explicit statement of each disagree-set item; the skill states the tension and applies judgment.
- Dropped personalities: list of any personalities dropped by availability gate with reason.
- Confidence rating: High, Medium, or Low. Rationale for the rating must be included. If Low, the output must state specifically what would raise it.

Synthesis output must not exceed 2000 words. If findings exceed this budget, the skill must prioritize high-severity and disagreement items.

## Constraints

C1. All dispatched sub-agents operate in read-only mode. Sub-agents must not edit files, run side-effecting commands, commit, or call any tool that mutates state. This constraint must be stated explicitly in every personality's dispatch prompt.

C2. Enforcing the read-only constraint is the responsibility of the dispatch prompt, not the dispatch infrastructure. The skill must include the literal phrase "read-only review — analyze and report only, no file edits, no commits, no shell commands" in each personality's dispatch prompt.

C3. The skill does not technically prevent a sub-agent from calling mutating tools; the constraint is behavioral, enforced by prompt instruction. If a sub-agent violates it, the violation is a prompt-design defect, not a dispatch-skill defect. The spec flags this as a known limitation (see Footguns, F3).

C4. Every finding in the aggregated output must cite specific evidence: a snippet, line reference, scenario, or direct quote. Unsupported assertions are not findings. The skill must instruct each reviewer to either cite or retract.

C5. The skill must not merge or replace the `code-review` skill. `swarm-protocol` is infrastructure; `code-review` is a consumer. The two must remain separate with a defined consumer-service boundary.

C6. No bare model names (e.g., specific version strings) may appear in the skill, its reviewer files, or its synthesis output. Use model class terms only: `haiku-class`, `sonnet-class`, `opus-class`.

C7. CLI-as-dispatch (e.g., `claude -p`, generic CLI invocations) is out of scope for this skill until task 10-0845 (dispatch skill CLI-extension) reaches PASS. Once 10-0845 lands, the Copilot Reviewer entry and any new CLI-backed personalities may use the CLI dispatch pattern defined there.

## Behavior

B1. If `problem` is empty or cannot be resolved into a review packet with a non-empty Artifacts field, the skill must return an error to the caller: "No reviewable artifact found." It must not dispatch any personalities.

B2. If the swarm is empty after availability gating (all personalities dropped), the skill must return an error to the caller: "Swarm empty after gating — no personalities available." It must not attempt synthesis.

B3. If the swarm contains only Devil's Advocate (all others filtered or gated out), the skill must proceed with a single-personality swarm and note in the synthesis that the review is adversarial only.

B4. If a dispatched personality returns no findings or times out, the skill records it as non-contributing and excludes it from synthesis. The dropped personality is noted in the synthesis output.

B5. If all dispatched personalities return no findings, the synthesis must state "No findings from any reviewer" and assign confidence rating Low.

B6. Devil's Advocate must always be dispatched unless explicitly excluded by `personality_filter` with a named subset that omits it.

B7. Custom menu personalities are evaluated against their caller-supplied trigger condition. If the trigger is "always", they are always included (subject to availability gating if their backend is external).

## Defaults and Assumptions

D1. Default `personality_filter`: none (all registry entries evaluated).

D2. Default model class for each personality: as listed in the Personality Registry table.

D3. Default for parallel vs sequential dispatch: parallel (all at once, single batch).

D4. Default `model_overrides`: none.

D5. If a custom menu entry does not specify a model class and no caller override applies, the skill defaults to `sonnet-class`.

D6. Confidence rating defaults to Medium. It is raised to High when all personalities agree and all findings cite evidence. It is lowered to Low when the disagree set is non-empty on a high-severity point, or when any personality returns no findings.

## Error Handling

E1. Unavailable external backend (availability probe fails): drop personality from swarm, note in synthesis, continue. Must not fail-stop.

E2. Empty swarm after gating: return error to caller (see B2). Must not synthesize.

E3. Dispatch failure for an individual personality (sub-agent crashes or returns incoherent output): treat as non-contributing (see B4). Must not block synthesis.

E4. Review packet assembly fails (no artifact resolvable): return error to caller (see B1). Must not dispatch.

E5. Synthesis exceeds word budget: truncate at priority order — disagreements first, then high-severity findings, then medium, then low. Note the truncation in output.

## Precedence Rules

P1. Caller-supplied `personality_filter` takes precedence over trigger-condition evaluation, except that an explicit filter that includes a personality whose trigger is not met still dispatches that personality (the filter is additive, not a gate).

P2. Caller-supplied `model_overrides` take precedence over registry defaults.

P3. Availability gate result takes precedence over selection result: a personality that passes selection but fails its availability probe is dropped.

P4. Read-only constraint (C1) takes precedence over any personality-specific instruction. No personality prompt may authorize a sub-agent to edit, commit, or run side-effecting commands.

P5. Synthesis word budget (C5 2000-word cap) takes precedence over completeness. Truncation is required over exceeding the cap.

## Don'ts

DN1. Must not load reviewer prompts for personalities that will not be dispatched.

DN2. Must not use a fixed roster; selection must evaluate trigger conditions against the artifact.

DN3. Must not fail-stop when a personality is unavailable; drop and continue.

DN4. Must not dump raw sub-agent output to the caller; synthesize and speak as the host.

DN5. Must not merge with or replace the `code-review` skill.

DN6. Must not dispatch personalities sequentially when parallel dispatch is available.

DN7. Must not include bare model names; use model class terminology only.

DN8. Must not perform CLI-as-dispatch (`claude -p`, copilot CLI) until task 10-0845 lands and is referenced here.

DN9. Must not expand the registry with personalities not in this spec without a spec amendment and audit pass.

DN10. Must not allow `model_overrides` to specify a backend change; overrides affect model class only, not backend type.

DN11. Must not allow a custom menu personality to override or replace a built-in registry entry; custom entries are additive only.

DN12. Must not apply the `personality_filter` as an exclusion list; it is an inclusion constraint (only named personalities are considered).

## Footguns

**F1: Loading all reviewer prompts at start** — the full prompt library arrives in context before selection, defeating lazy loading and bloating every invocation.
Why: the naive implementation reads all reviewer files during setup.
Mitigation: load reviewer files only after the swarm is finalized in Step 3.

**F2: Silent availability-gate fail-stop** — a missing `copilot` binary causes the entire skill to error rather than drop the Copilot Reviewer and proceed.
Why: error propagation defaults treat probe failure as fatal.
Mitigation: probe failures must set personality status to dropped, not error; swarm continues.

**F3: Read-only constraint not in dispatch prompt** — sub-agent has no instruction preventing file edits; caller assumes the skill enforces it structurally.
Why: constraint lives only in this spec, not in the per-personality dispatch prompt.
Mitigation: include the literal read-only phrase (C2) in every personality dispatch.

**F4: Swarm dispatch issued sequentially** — personalities are dispatched one by one, multiplying total latency by personality count.
Why: default coding pattern loops and awaits each dispatch.
Mitigation: issue all dispatches as a single parallel batch per Step 5.

**F5: Synthesis dumps reviewer names** — output exposes the internal review machinery ("Devil's Advocate said...") breaking the host-voice requirement.
Why: synthesizing from structured output naturally includes provenance.
Mitigation: strip reviewer attribution before synthesis output; speak in host voice only.

`ANTI-PATTERN:` Caller passes `personality_filter: ["Security Auditor"]` expecting that only Security Auditor runs. But the implementation also runs Devil's Advocate because it is "always" included, and the filter is interpreted as additive. Result: caller gets two reviewers when it expected one. Correct approach: `personality_filter` is an inclusion list; Devil's Advocate is always added unless the caller explicitly excludes it by name.

## Section Classification

| Section | Type | Required |
| --- | --- | --- |
| Purpose | Descriptive | Yes |
| Scope | Normative | Yes |
| Definitions | Normative | Yes |
| Personality Registry | Normative | Yes |
| Custom Personality Menu | Normative | Yes |
| Inputs | Normative | Yes |
| Step Sequence | Normative | Yes |
| Constraints | Normative | Yes |
| Behavior | Normative | Yes |
| Defaults and Assumptions | Normative | Yes |
| Error Handling | Normative | Yes |
| Precedence Rules | Normative | Yes |
| Don'ts | Normative | Yes |
| Footguns | Informational | No |
| Section Classification | Structural | Yes |

## Open Questions

OQ1. Skill name: the queued task notes the operator may prefer `swarm-review` over `swarm-protocol`. This spec uses `swarm-protocol` (the infrastructure name). Auditor should confirm the name with the operator before the uncompressed/SKILL compilation step.

OQ2. CLI dispatch: `claude -p` and copilot CLI as parallel dispatch backends are explicitly deferred to task 10-0845. The Copilot Reviewer (registry entry 8) currently uses `copilot-cli` as its backend. Once 10-0845 defines the CLI dispatch contract, this spec must be amended to reference it and remove the scope exclusion in C7.

OQ3. Selection-as-dispatch: inline selection is specified (see Step 2 rationale). If the registry grows past approximately 20 entries, revisit whether a haiku-class meta-personality dispatch is more token-efficient than inline evaluation.
