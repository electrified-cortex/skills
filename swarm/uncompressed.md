---
name: swarm
description: Multi-personality review infrastructure — selects personalities, gates availability, dispatches in parallel, arbitrates, and synthesizes a verdict. Triggers - swarm review, multi-reviewer, parallel personalities, run all reviewers, arbitrate findings.
---

# swarm — Uncompressed Reference

**Usage**: Never dispatch this skill as a sub-agent — it cannot orchestrate further dispatches from a leaf position.

## Key Terms

- **Artifact**: input content under review — conversation excerpt, file path, diff, plan, document, or structured description. Passed as `problem`.
- **Review packet**: self-contained brief assembled from the artifact. Fields: Goal, Approach, Key decisions, Artifacts (actual content), Files affected, Blast radius, Conventions. Omit fields not applicable to the artifact type.
- **Personality**: named reviewer role defined by a `reviewers/<name>.md` file with YAML frontmatter. Has trigger condition, suggested model list (preference-ordered), backend preference list, and scope limiter. Loaded lazily — full prompts not present at selection time.
- **Personality registry**: set of personalities discovered by crawling `reviewers/` at runtime. Not a static table. Extended per-invocation by caller-supplied custom menu.
- **Custom menu**: caller-supplied list of additional personalities appended to the registry for the current invocation only. Does not persist.
- **Selection**: filtering the combined registry against artifact problem traits to produce the active personality set.
- **Availability gate**: probe step confirming a personality's required backend is reachable before dispatch.
- **Swarm**: surviving personalities after selection and availability gating.
- **Dispatch skill**: the `dispatch` skill — runtime-specific how-to for launching sub-agents. Reference for the host agent executing this skill — not a delegation target. Host dispatches directly using its own runtime mechanism (runSubagent in VS Code Copilot, Task in Claude Code).
- **Disagree set**: subset of swarm findings where two or more personalities reached contradictory conclusions on the same point.
- **Confidence rating**: High / Medium / Low scalar attached to synthesis output. Reflects reviewer agreement, evidence quality, and scope coverage.
- **Model class**: abstract tier identifier — `haiku-class` (shallow/mechanical), `sonnet-class` (moderate reasoning, default), `opus-class` (heavy architectural reasoning), `gpt-class` (external OpenAI-hosted model). No bare model names anywhere.
- **Caller override**: caller-supplied `model_overrides` map pinning one or more personalities to a specific model class for the current invocation.
- **High-severity point**: finding that would block shipping or require architectural change. Used in confidence rating determination.
- **Availability probe**: lightweight shell command (e.g., `copilot --version`) or tool call confirming backend is live before including the personality.
- **Backend**: execution target for a personality. Values: `dispatch-sonnet`, `dispatch-haiku`, `dispatch-opus`, `copilot-cli`, `local-llm` (reserved, v1 out of scope).
- **Arbitrator**: single sonnet-class sub-agent dispatched after all swarm members complete. Receives full member outputs and review packet. Returns structured action list only. Not a reviewer. Not in the registry. Not subject to personality selection, availability gating, or `personality_filter`.
- **Generated persona**: reviewer personality manifested inline at runtime when the registry yields fewer than 3 suitable personalities for the artifact. Has a name, critique lens, and scope limiter — all specific to the artifact's domain. Exists for current invocation only; not cached; no `reviewers/` file.
- **Manifest hash**: SHA-256 of the canonical input manifest — sorted file paths concatenated with their content hashes. For non-file artifacts (text, conversation excerpts), the SHA-256 of the artifact content. Used as the cache key for all hash-record entries.

## Personality Registry

The registry is external to the skill. Built-in personality definitions live as separate files at `swarm/reviewers/<name>.md`. The registry is the directory listing — every `*.md` file present in `reviewers/` that passes the metadata-validation gate is a registered personality. Adding a personality requires only dropping a new file; no spec or SKILL.md edit required.

**Registry loading**: crawl `reviewers/` at runtime when a swarm invocation begins. Compile-time enumeration is not used. `reviewers/index.yaml` serves as the ordered manifest for the registry — it provides metadata and ordering for personalities discovered during the crawl.

**Metadata-validation gate**: any file in `reviewers/` is subject to automatic metadata-validation before registration. A file failing validation is silently skipped. No human approval required. Valid files are automatically registered.

**Built-in personalities (informative — not normative)**:

| # | Personality | Trigger | Suggested model class | Backend | Scope |
| --- | --- | --- | --- | --- | --- |
| 1 | Devil's Advocate | always | sonnet-class | dispatch-sonnet | Challenge assumptions; no constructive suggestions |
| 2 | Accessibility Officer | UI, web rendering, forms, interactive elements, color, user-facing text | sonnet-class | dispatch-sonnet | WCAG 2.2 AA only; no logic, security, or performance |
| 3 | Architect | system structure, new abstractions, service boundaries, shared infrastructure | sonnet-class | dispatch-sonnet | Structural concerns only; no implementation details |
| 4 | Designer | public interfaces, APIs, library surfaces, shared types, config contracts | sonnet-class | dispatch-sonnet | Public surface and caller experience only; no internals |
| 5 | Engineer | new logic, integrations, state mutation, error handling, partial failure | sonnet-class | dispatch-sonnet | Practical correctness only; no style or architecture |
| 6 | Linguist | code, docs, error messages, log strings, user-visible text, named abstractions | sonnet-class | dispatch-sonnet | Naming, clarity, communication only |
| 7 | Penny Pincher | API calls, DB queries, loops, caching, storage, cloud resource usage | sonnet-class | dispatch-sonnet | Cost and resource efficiency only |
| 8 | Privacy Advocate | user data, PII, analytics, logging, storage, data transmission, identity, consent | sonnet-class | dispatch-sonnet | Privacy and data handling only; no unrelated security |
| 9 | Security Auditor | auth, user input, API endpoints, data access, secrets, network calls, file system writes, process execution | sonnet-class | dispatch-sonnet | Find vulnerabilities only; no design advice |
| 10 | Copilot Reviewer | code + copilot-cli available | external | copilot-cli | Full code review via Copilot; availability-gated |
| 11 | Custom Specialist | caller supplies via custom menu | varies | varies | Defined by caller in custom menu entry |

The integer index is informative only. The stable runtime index is assigned by alphabetical crawl (1-based). Personality renames change the index; callers using `personality_filter` by name are not affected.

**Pre-implementation gate — entry 8**: before implementing entry 8 or any CLI-backed personality, verify that task 10-0845 (dispatch skill CLI-extension) has reached PASS. Entry 8 must not be implemented until that task is complete.

## Personality Metadata Schema

Each `reviewers/<name>.md` must begin with a YAML frontmatter block. Files missing required fields or with malformed frontmatter fail the validation gate and are silently skipped.

Required fields:

```yaml
---
name: <string>          # display name; unique across all files in reviewers/
trigger: <string>       # trigger condition; "always" for unconditional inclusion
required: <bool>        # true = always dispatched regardless of personality_filter (unless explicitly excluded)
suggested_models:       # preference-ordered list of model-class terms only
  - <model-class>       # first entry = most preferred
suggested_backends:     # preference-ordered list of backend identifiers
  - <backend>           # first entry = most preferred
scope: <string>         # what this personality reviews and what it ignores
---
```

Optional fields:

```yaml
vendor: <string>        # model vendor hint (e.g. anthropic, openai); used by diversity rule B8
```

**Model selection at dispatch**: see Step 2.

## Custom Personality Menu

Callers may supply additional personalities for a single invocation. Each entry must specify: name, trigger condition, model class (or inherit from caller override), backend, and scope limiter. Custom entries are appended after entry 9 in evaluation order. They do not mutate the built-in registry.

## Inputs

| Input | Required | Description |
| --- | --- | --- |
| `problem` | required | The content under review. |
| `personality_filter` | optional | List of personality names or indices. Named personalities dispatched regardless of trigger evaluation; triggers bypassed for named entries. Inclusion list only — not an exclusion gate. |
| `model_overrides` | optional | Map of personality name to model class. Overrides affect model class only, not backend type. |
| `arbitrator_model` | optional | Model class for the arbitrator dispatch. Defaults to `sonnet-class`. Use `opus-class` for high-stakes reviews where arbitrator judgment quality is critical. |

## Caller Tier

The host agent executing this skill must be **sonnet-class minimum**. Callers dispatching swarm via the `dispatch` skill must use `tier: standard` or higher. If no dispatch mechanism is available in the host runtime, return error: "Swarm requires dispatch capability; no dispatch mechanism available."

## Step Sequence

### Step 1 — Build the review packet

**Hash record check (early gate)**: before building the packet, extract the file list directly from `problem` (deterministic parse — no LLM required). Read file contents and compute the manifest hash (sorted paths + content hashes, SHA-256; or SHA-256 of artifact text for non-file inputs). Compute `filter_hash` = SHA-256 of the sorted `personality_filter` list (empty list if no filter supplied). Check `.hash-record/XX/HASH/swarm/v1/<filter_hash>/report.md` (where XX = first two hex chars of HASH, `v1` is the current skill version). Cache hit: return the cached result and skip Steps 2–8. Cache miss: before proceeding to Step 2, check `.hash-record/XX/HASH/swarm/v1/` for any existing per-persona results (B10 partial recovery). Treat any found result as complete; proceed with only the remaining personalities.

Continue to packet assembly on cache miss:

Construct a review packet from `problem`. The packet must be self-contained: a reader with zero prior context must understand what is being reviewed, why, and what the key decisions were.

Packet fields (omit if not applicable to artifact type):

- Goal: what problem is being solved or what output is being evaluated.
- Approach: what was proposed, implemented, or produced.
- Key decisions: why this approach over alternatives.
- Artifacts: actual content under review (diffs, text, config — not a description of it).
- Files affected: list with brief descriptions.
- Blast radius: downstream consumers, imports, integrations affected.
- Conventions: applicable project conventions.

Verify the packet before proceeding: Goal must name the artifact type and state what outcome is being evaluated (e.g., "evaluate diff for correctness and security"); Artifacts must include actual content, not just references. If either condition fails, attempt to resolve the gap from available context. Do not ask the caller to fill gaps. If the gap cannot be resolved, return error per B1 and halt.

### Step 2 — Select personalities

Build the combined registry by crawling `reviewers/` (applying the metadata-validation gate) and appending any caller-supplied custom menu entries.

If `personality_filter` is supplied: restrict candidate set to named personalities; dispatch those regardless of trigger evaluation (triggers bypassed for named entries). If no filter: evaluate trigger conditions against problem traits inferred from the review packet; exclude personalities whose trigger is not satisfied.

For each personality in the active set, read `suggested_models` from frontmatter and select the first available model. Caller `model_overrides` take precedence. If no `suggested_models` entry is available and no override applies, default to `sonnet-class`.

Selection logic must be inline within the skill.

Personalities with `required: true` must always be included regardless of trigger evaluation. `personality_filter` may exclude a required personality only when the caller explicitly names a subset that omits it. Devil's Advocate carries `required: true`.

**5-cap**: if more than 5 personalities pass trigger evaluation and availability gating, apply priority order: (1) Devil's Advocate always; (2) personalities with the most-specific trigger match (narrower/more-specific trigger = higher priority); (3) drop lowest-priority remaining until the count reaches 5.

**Manifest gap fill**: if selection yields fewer than 3 suitable personalities after filter and trigger evaluation, manifest one or more generated personas inline to reach at least 3. For each generated persona: invent a name relevant to the artifact's domain, a critique lens covering problem traits not already represented by selected personalities, and a scope limiter avoiding overlap. Dispatch the same as built-in; do not add to the registry; do not cache in the hash record.

### Step 3 — Availability gating

For each selected personality whose backend is not `dispatch-sonnet`, `dispatch-haiku`, or `dispatch-opus` (i.e., any external backend such as `copilot-cli`):

- Run the availability probe before including the personality.
- Probe succeeds: include the personality.
- Probe fails: drop the personality from the swarm for this invocation. Note the drop in synthesis output. Do not fail-stop or surface an error to the caller.

For `dispatch-*` backends, no probe is required; the dispatch skill handles errors internally.

### Step 4 — Load reviewer prompts

Only after the swarm is finalized (post-gating) load the prompt for each surviving personality. Reviewer prompts are stored as separate sub-skill files under `swarm/reviewers/<name>.md`. The filename is the personality name lowercased with spaces and apostrophes replaced by hyphens (e.g., `devils-advocate.md`, `security-auditor.md`). Load only files for dispatched personalities. Do not load files for non-dispatched personalities.

### Step 5 — Dispatch

Dispatch swarm personalities using your runtime dispatch mechanism, following the `dispatch` skill for implementation details. Maximum concurrency — dispatch up to 3 in parallel; as each completes, dispatch the next until all have run. Treat any personality that has not returned within a host-defined threshold (recommended: typical sonnet-class response time + 20%) as timed out per B4.

As each personality dispatch completes, immediately write its raw output to `.hash-record/XX/HASH/swarm/v1/<persona-name>/report.md` (built-in personas only — generated personas are never written). Do not wait for all dispatches to complete before writing per-persona results.

Each personality dispatch receives:

1. The full review packet from Step 1.
2. The personality's prompt loaded in Step 4.
3. An explicit read-only constraint — include verbatim in each prompt: "read-only review — analyze and report only, no file edits, no commits, no shell commands" (see Constraints C1–C3).

Apply `model_overrides` at dispatch time: if a caller override exists, use it; otherwise use first available entry from `suggested_models`; otherwise fall back to `sonnet-class`. Diversity check after model selection: if all selected personalities resolve to the same model family, apply resolution order before dispatching — (1) include any personality from the full candidate registry on a different model family; (2) re-assign Devil's Advocate to a different vendor via `vendor` override; (3) if neither resolves, proceed and set `homogeneity_warning`. (B8 governs this rule.)

Dispatch parameters:

- `<tier>` = `standard`
- `<description>` = `swarm-personality:<personality-name>`

Must return: a structured findings list. Each finding: description of the issue, evidence cite (snippet, line reference, scenario, or direct quote). Empty response or "No findings" is a valid return — treated as non-contributing (B4).

Structured-evidence requirement (high/critical findings): any finding marked HIGH or CRITICAL severity must include three fields: Source (where the vulnerability or bug enters), Sink (where it causes harm), and Missing guard (what defense is absent). Findings at HIGH or CRITICAL severity that lack this structure are automatically downgraded to MEDIUM.

### Step 6 — Arbitrator consolidation

File-existence filter (pre-arbitration): before forwarding member findings to the arbitrator, discard any finding that cites a file not present in the review packet's Files-affected list. Use deterministic string matching (exact path). Do not use LLM judgment for this filter — it is mechanical. If a finding does not cite a specific file, retain it.

After all swarm member outputs are collected, dispatch a single arbitrator sub-agent using `arbitrator_model` (default: `sonnet-class`). The arbitrator receives all raw member outputs and the original review packet. Per B4, non-contributing member outputs (empty/timeout) are excluded from the arbitrator's input set.

Dispatch parameters:

- `<tier>` = `standard`
- `<description>` = `swarm-arbitrator`

Must return: a structured two-section action list — Obvious actions and Critical actions — as specified in the Required arbitrator output format below. If no actionable findings: "No actionable findings" stated explicitly.

The arbitrator's sole job: produce a structured action list — not a narrative synthesis.

Required arbitrator output format (two sections):

- **Obvious actions**: items where two or more swarm members independently flagged the same concern, or where the concern is self-evident from the artifact. Each entry: action description + source personality names + evidence cite.
- **Critical actions**: items that, if unaddressed, would block shipping or require architectural change, regardless of reviewer agreement count. Each entry: action description + source personality names + evidence cite + severity rationale.

Authoritative format: `specs/arbitrator.md` — inline above is a summary only. On any amendment to the output structure, update both in the same commit.

The arbitrator must not include speculative, low-confidence, or duplicate items. Its output is the input to Step 7; the host synthesizes from this list only, not from raw member output.

Grounded-challenge requirement: before citing a member finding as incorrect, the arbitrator must quote the exact sentence from that finding it believes is wrong. Challenging an interpretation rather than an explicit claim is not permitted.

If the arbitrator produces an empty list, it must state "No actionable findings" explicitly. The host must still proceed to synthesis and note the clean result.

The arbitrator is structurally separate from the registry. It must not appear in the registry, must not be subject to personality selection, availability gating, or `personality_filter`.

### Step 7 — Aggregate findings and track disagreements

Collect findings from the arbitrator's structured action list. For each item, record: personality names cited, finding summary, cited evidence.

Identify the disagree set: items where the arbitrator flagged conflicting conclusions (source personality names from different members with contradictory claims on the same point). Each disagree entry records the personalities involved and the conflicting claims.

### Step 8 — Synthesize and return

Synthesize from the arbitrator's structured action list into a single host-voice output. Do not dump raw sub-agent output or raw arbitrator output to the caller. Speak as the host, presenting refined takeaways.

Required synthesis output fields:

- **Summary**: consolidated findings in host voice.
- **Disagreements**: explicit statement of each disagree-set item; state the tension and apply judgment.
- **Dropped personalities**: list of any personalities dropped by availability gate with reason.
- **Confidence rating**: High, Medium, or Low. Include rationale. If Low, state specifically what would raise it.

Synthesis output template (use this structure exactly):

```md
**Summary**: <consolidated findings in host voice>

**Disagreements**: <each disagree-set item with tension stated and judgment applied; "None" if disagree set is empty>

**Dropped personalities**: <name — reason for each dropped personality; "None" if none dropped>

**Confidence rating**: <High | Medium | Low> — <rationale; if Low, state what would raise it>

**Homogeneity warning** (omit if N/A): All personalities resolved to the same model family — result may exhibit sycophantic conformity. Re-run with cross-vendor overrides for higher confidence.
```

Synthesis output must not exceed 2000 words. If findings exceed this budget, prioritize high-severity and disagreement items. Note any truncation in output.

**Hash record write**: after synthesis completes, write the full result to `.hash-record/XX/HASH/swarm/v1/<filter_hash>/report.md`. Per-persona results were already written during Step 5. Generated personas are not written. If `v1/<filter_hash>/report.md` already exists, skip the write (idempotency guard — assumes a concurrent run completed first). Current skill version: `v1`. Bump to `v2` when persona prompts, selection criteria, arbitrator procedure, or hash algorithm changes in a way that could affect review quality. Wording and formatting changes do not require a bump.

## Constraints

C1. All dispatched sub-agents operate in read-only mode. Sub-agents must not edit files, run side-effecting commands, commit, or call any mutating tool. State this constraint explicitly in every personality's dispatch prompt.

C2. Include the literal phrase "read-only review — analyze and report only, no file edits, no commits, no shell commands" in each personality's dispatch prompt. For each finding, verify before including: (1) cited file path appears in the provided diff/artifact; (2) cited line is within a changed/relevant section or within 10 lines of one; (3) any verbatim code quotes appear in the artifact; (4) directional claims (added/removed/changed) match the artifact. Findings that fail any check must be omitted, not downgraded.

C3. The skill does not technically prevent a sub-agent from calling mutating tools; the constraint is behavioral, enforced by prompt instruction. If a sub-agent violates it, the violation is a prompt-design defect, not a dispatch-skill defect.

C4. Every finding must cite specific evidence: a snippet, line reference, scenario, or direct quote. Instruct each reviewer to either cite or retract.

C5. Must not invoke the `code-review` skill internally. The two are siblings with separate intent; neither is a dependency of the other.

C6. No bare model names may appear in the skill, reviewer files, or synthesis output. Use model class terms only: `haiku-class`, `sonnet-class`, `opus-class`, `gpt-class`.

C7. CLI-as-dispatch (e.g., `claude -p`, copilot CLI) is out of scope until task 10-0845 reaches PASS. Once 10-0845 lands, the Copilot Reviewer and any CLI-backed personalities may use the CLI dispatch pattern defined there.

C8. Do not expand the personality registry with new built-in entries without a spec amendment and audit pass.

## Behavior

B1. If `problem` is empty or cannot be resolved into a review packet with a non-empty Artifacts field, return error: "No reviewable artifact found." Do not dispatch any personalities.

B2. If the swarm is empty after availability gating, return error: "Swarm empty after gating — no personalities available." Do not attempt synthesis.

B3. If the swarm contains only Devil's Advocate, proceed with a single-personality swarm and note in synthesis that the review is adversarial only.

B4. If a dispatched personality returns no findings or times out, record it as non-contributing and exclude from synthesis. Note the dropped personality in synthesis output.

B5. If all dispatched personalities return no findings, synthesis must state "No findings from any reviewer" and assign confidence rating Low.

B6. Devil's Advocate must always be dispatched unless explicitly excluded by `personality_filter` with a named subset that omits it.

B7. Custom menu personalities are evaluated against their caller-supplied trigger condition. If trigger is "always", always include (subject to availability gating if backend is external).

B8. Cross-vendor diversity: if all finalized swarm personalities resolve to the same model family or vendor, attempt resolution before dispatching. Preferred resolution order:

1. Find any personality in the full candidate registry on a different model family — include it in the swarm.
2. Re-assign Devil's Advocate to a different vendor using the `vendor` frontmatter field.

If neither step resolves the monoculture, proceed with the homogeneous swarm and include a `homogeneity_warning` in the synthesis output. Do NOT degrade to `code-review`. Rationale: arxiv 2605.00914 documents 85.5% sycophantic conformity and 32.3 pp correct-answer loss in same-family debate.

B9. Generated persona dispatch: generated personas are dispatched in Step 5 the same way as built-in personalities. Each receives: the review packet, an inline system prompt synthesized from its name, critique lens, and scope limiter, and the explicit read-only constraint. Generated personas are not added to the registry and are never cached. They are always re-dispatched on any re-run.

B10. Hash record partial recovery: if a previous swarm run on the same manifest hash was interrupted before completion, check `.hash-record/XX/HASH/swarm/vN/` for existing per-persona results. Treat any cached built-in persona result as complete. Re-dispatch only missing built-in personas and all generated personas (which are never cached).

## Defaults

D1. Default `personality_filter`: none (all registry entries evaluated).
D2. Default model class: first available from `suggested_models` frontmatter; fallback `sonnet-class`. All built-in personalities default to sonnet-class — the hallucination filter (C2) requires evidence-cite self-checking that haiku-class handles unreliably. Callers may override individual personalities via `model_overrides` if they accept the tradeoff.
D3. Default dispatch: rolling window of 3. Never more than 3 personalities in flight at once.
D4. Default `model_overrides`: none.
D5. Custom menu entry with no model class and no caller override: default `sonnet-class`.
D6. Confidence rating default: Medium. Raised to High when all personalities agree and all findings cite evidence. Lowered to Low when disagree set is non-empty on a high-severity point, or when any personality returns no findings.

Calibration examples:

- **High**: Security Auditor, Code Quality Critic, and Devil's Advocate all flag the same SQL injection risk with evidence cites; no disagreements. → High.
- **Medium** (default): Reviewers agree on two findings but one personality returns "No findings." Wait — "any personality returns no findings" triggers Low, not Medium. → Low.
- **Medium** (true): Reviewers produce 3 findings with evidence; no high-severity disagreements; all personalities contributed. → Medium.
- **Low**: Devil's Advocate flags no concerns (returns "No findings"); or Security Auditor and Architect reach contradictory conclusions on a shipping-blocking concern. → Low; state what would raise it (e.g., "re-run with explicit security artifact to get Security Auditor finding").

## Error Handling

E1. Unavailable external backend (probe fails): drop personality, note in synthesis, continue. Do not fail-stop.
E2. Empty swarm after gating: return error (B2). Do not synthesize.
E3. Dispatch failure for individual personality (crash or incoherent output): treat as non-contributing (B4). Do not block synthesis.
E4. Review packet assembly fails (no artifact resolvable): return error (B1). Do not dispatch.
E5. Synthesis exceeds word budget: truncate at priority order — disagreements first, then high-severity, then medium, then low. Note truncation in output.
E6. Arbitrator dispatch fails or returns no structured output: return error to the caller with the per-personality summary from Step 7 (if any). Do not attempt synthesis from raw member outputs.

## Precedence

P1. `personality_filter` overrides trigger-condition evaluation; only named personalities are dispatched; triggers bypassed for named entries.
P2. `model_overrides` override registry defaults.
P3. Availability gate overrides selection: a personality that passes selection but fails the probe is dropped.
P4. Read-only constraint (C1) overrides any personality-specific instruction. No personality prompt may authorize editing, committing, or side-effecting commands.
P5. Synthesis word budget (2000-word cap) overrides completeness. Truncation required over exceeding the cap.

## Related

- `dispatch` — agent-launching skill; swarm delegates all sub-agent launches here.
- `compression` — compression skill used to produce the compressed form of this skill.
- `specs/arbitrator.md` — sub-specification for the arbitrator consolidation role.
- `specs/dispatch-integration.md` — sub-specification for dispatch integration patterns.
- `specs/glossary.md` — canonical term definitions for the swarm skill family.
- `specs/personality-file.md` — sub-specification for the reviewer personality file format.
- `specs/registry-format.md` — sub-specification for the personality registry format and crawl behavior.

