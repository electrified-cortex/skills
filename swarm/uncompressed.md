# swarm — Uncompressed Reference

Every invocation begins with Step 1: assemble a self-contained review packet from the problem input. Without this packet, swarm cannot evaluate triggers or select personalities. Packet-first requirement ensures all reviewers operate from the same artifact context with zero prior knowledge gaps.

Key terms: see `specs/glossary.md`.

## Personality Registry

External to the skill. Index at `reviewers/index.md` (or format of implementor's choice). Body files at `reviewers/<name>.md` — system-prompt body only, no scaffolding.

Adding a personality: (1) add entry to the index file, (2) drop body at `reviewers/<name>.md`. No spec or SKILL.md edit required.

Full format spec, validation rules, YAML schema: see `specs/registry-format.md`.
Body file rules: see `specs/personality-file.md`.

## Inputs

| Input                                   | Required | Description                                                                                                                                                                                                        |
| --------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `problem`                               | required | The artifact under review.                                                                                                                                                                                         |
| `additional_personalities`              | optional | Inclusion list of personality names. Named personalities dispatched regardless of trigger evaluation; triggers bypassed for named entries. Not an exclusion gate. Code-domain personalities are supplied here by consumer skills (e.g. `code-review`); they are not built-in. |
| `disable_inline_personality_generation` | optional | When `true`, suppresses Custom Specialist on-the-fly generation; swarm evaluates only registered built-ins and caller-supplied personalities. Default: `false`.                                                     |

## Step Sequence

### Step 1 — Build the review packet

Construct a review packet from `problem`. Must be self-contained: a reader with zero prior context must understand what is being reviewed, why, and what the key decisions were.

Packet fields (omit if not applicable): Goal, Approach, Key decisions, Artifacts (actual content — not a description), Files affected, Blast radius, Conventions.

Verify before proceeding: Goal must be evaluable; Artifacts must include actual content. If either fails, resolve from available context — do not ask caller.

### Step 2 — Select personalities

Read the index file from `reviewers/` — one file read, full metadata. No directory crawl. Build in-memory index: name, trigger, `required`, `suggested_models`, `suggested_backends`, `scope`, optional `vendor`.

Validation gate: entries with missing required fields or malformed data silently skipped. For each valid entry, verify `reviewers/<name>.md` exists and non-empty; missing or empty body → drop with warning (not fatal). Append caller custom-menu entries.

If `additional_personalities` supplied: dispatch named personalities only; triggers bypassed for named entries.
If no list: evaluate trigger conditions against packet traits; exclude non-matching.

`required: true` personalities always included unless explicitly omitted by a named `additional_personalities` list. Devil's Advocate carries `required: true`.

Selection is inline — no separate dispatch. Revisit if registry exceeds ~20 entries (see `specs/dispatch-integration.md`).

For each active personality, read `suggested_models` from in-memory index, pick first available. Fallback: `sonnet-class`. Apply diversity rule B8 after all selections (see `specs/dispatch-integration.md`).

### Step 3 — Availability gating

For each selected personality with a non-`dispatch-*` backend (e.g., `copilot-cli`): run availability probe.

- Pass: include.
- Fail: drop from swarm, note in synthesis, continue. Do not fail-stop.

For `dispatch-*` backends: no probe required.

### Step 4 — Load reviewer prompts

Only after swarm is finalized (post-gating). Load `reviewers/<kebab-name>.md` for dispatched personalities only. If body file begins with YAML frontmatter, exclude it; use only content after closing `---`. The body is the complete, literal system prompt — insert verbatim. Do not load files for non-dispatched personalities.

### Step 5 — Dispatch

Issue all swarm personalities as a single parallel batch via the `dispatch` skill. Never sequential when parallel is available.

Each dispatch receives:

1. Full review packet (Step 1).
2. Personality prompt (Step 4).
3. Literal read-only constraint: "read-only review — analyze and report only, no file edits, no commits, no shell commands".
4. Evidence citation rule: "cite specific evidence (snippet/line/scenario) per finding, or retract".

Model selection: first available from `suggested_models`, then `sonnet-class`. Selection is fully automatic. Apply diversity rule B8 after all selections. See `specs/dispatch-integration.md`.

### Step 6 — Arbitrator consolidation

After all member outputs collected, dispatch single sonnet-class arbitrator (not in registry; not subject to filter/gating). Input: all non-empty, non-timeout member outputs + review packet.

Arbitrator output: structured action list only. Two sections:

- **Obvious actions**: 2+ members flagged same concern, or self-evident. Each entry: description + source personality indices + evidence cite.
- **Critical actions**: would block shipping or require architectural change regardless of agreement count. Each entry: description + source personality indices + evidence cite + severity rationale.

No speculative, low-confidence, or duplicate items. If empty: "No actionable findings".

Full specification: see `specs/arbitrator.md`.

### Step 7 — Aggregate findings and track disagreements

Collect findings from arbitrator's action list. Record per item: personality indices, finding summary, evidence cite.

Identify disagree set: items where arbitrator flagged contradictory conclusions from different members on the same point. Each disagree entry records personalities involved and conflicting claims.

### Step 8 — Synthesize and return

Speak as host only. Synthesize from arbitrator's action list — do not dump raw member or arbitrator output.

Required output:

- **Summary**: consolidated findings in host voice.
- **Disagreements**: each disagree-set item; state the tension and apply judgment.
- **Dropped personalities**: list with reason.
- **Confidence rating**: High / Medium / Low + rationale. If Low, state what would raise it.

Cap: 2000 words. If over, truncate at priority order: disagreements, then high-severity, then medium, then low. Note the truncation.

## Confidence Rating

Default: Medium. High: all personalities agree + all findings cite evidence. Low: disagree set has a high-severity point, or any personality returned no findings. Full logic: `specs/arbitrator.md`.

## Behaviors

B1. `problem` empty or no resolvable artifact → return "No reviewable artifact found." Do not dispatch.

B2. Swarm empty after gating → return "Swarm empty after gating — no personalities available." Do not synthesize.

B3. Single personality in swarm → proceed; note limited review scope in synthesis.

B4. Personality returns no findings or times out → non-contributing; exclude from synthesis; note in output.

B5. All personalities return no findings → state "No findings from any reviewer"; confidence Low.

B6. Devil's Advocate dispatched unless explicitly omitted by named `additional_personalities` list.

B7. Custom menu entries evaluated against caller-supplied trigger; "always" = include (subject to gating if external backend).

B8. Cross-vendor diversity best-effort: prefer at least one personality on different model family/vendor than host. If unavailable, proceed + note monoculture. Devil's Advocate is natural diversity carrier.

B10. When no built-in or caller-supplied personality covers the problem domain and `disable_inline_personality_generation` is not `true`, swarm generates a Custom Specialist inline: (1) infer role from problem domain, (2) author brief system-prompt body for that role, (3) dispatch with same read-only and evidence constraints as any registered personality. Generated personality is one-shot — not persisted.

B9. Selection reads only the registry index — not body files. Body files loaded at Step 4 for selected personalities only. Reading body files at Step 2 violates this rule.

## Precedence

P1. `additional_personalities` overrides trigger evaluation for named entries.
P2. Availability gate overrides selection; failed probe = drop.
P3. Read-only constraint overrides any personality-specific instruction.
P4. 2000-word cap overrides completeness; truncation required.

## Defaults

| Default                          | Value                                                            |
| -------------------------------- | ---------------------------------------------------------------- |
| `additional_personalities`       | None (all registry entries evaluated)                            |
| Model class per personality      | First available from `suggested_models`; fallback `sonnet-class` |
| Dispatch mode                    | Parallel (single batch)                                          |
| Custom entry with no model class | `sonnet-class`                                                   |
| Confidence rating                | Medium                                                           |

## Error Handling

E1. External backend unavailable (probe fails): drop personality, note in synthesis, continue.
E2. Empty swarm after gating: return error (B2).
E3. Dispatch failure for individual personality: treat as non-contributing (B4).
E4. Review packet assembly fails: return error (B1).
E5. Synthesis exceeds word budget: truncate at priority order — disagreements, high-severity, medium, low. Note truncation.

## Don'ts

- Don't load reviewer prompts before the swarm is finalized.
- Don't use a fixed roster; evaluate trigger conditions against the artifact.
- Don't fail-stop on unavailable personality; drop and continue.
- Don't dump raw output; synthesize in host voice.
- Don't merge with or replace the `code-review` skill.
- Don't dispatch personalities sequentially when parallel is available.
- Don't use bare model names; use model class terms only.
- Don't perform CLI-as-dispatch until task 10-0845 lands.
- Don't allow custom entries to replace built-in entries; custom is additive only.
- Don't treat `additional_personalities` as an exclusion list; it is an inclusion constraint.
- Don't include code-domain personalities (Code Quality Critic, Test Reviewer, Architect, Operational Readiness, Performance Reviewer, Copilot Reviewer) in the built-in registry; these are caller-supplied via `additional_personalities`.
- Don't have the host parse raw member output; that is the arbitrator's job.
- Don't add the arbitrator to the registry or subject it to selection/gating/filter.
- Don't implement `local-llm` backend routing in v1; type is reserved only.
- Don't embed a normative personality registry as a static table in the spec or SKILL.md.
- Don't fail the swarm if cross-vendor diversity can't be achieved; best-effort only.
- Don't dispatch a personality whose body file is missing or empty; drop with warning.
- Don't read body files during selection; read the index only at Step 2.
- Don't add scaffolding to personality body files; body is the system prompt verbatim.
- Don't expand the registry without a spec amendment and audit pass.

## Footguns

F1. Loading all prompts before selection — bloats every invocation. Load only post-gate (Step 4).
F2. Probe fail treated as fatal error — drop personality, do not error the whole swarm.
F3. Read-only phrase missing from dispatch prompt — include literal C2 phrase in every dispatch.
F4. Sequential dispatch — issue all dispatches as a single parallel batch.
F5. Synthesis names reviewers — host voice only; strip attribution.
F6. Host synthesizes from raw member output, bypassing arbitrator — Step 8 receives arbitrator list only.
F7. Monoculture swarm — Devil's Advocate carries `vendor: openai`; check synthesis for monoculture notice.
F8. Informative registry table treated as normative — `reviewers/index.md` is the only source of truth.
F9. Reading body files at Step 2 — index only at Step 2; bodies at Step 4 for selected personalities only.

Anti-pattern: `additional_personalities: ["Security Auditor"]` — bypasses triggers AND suppresses Devil's Advocate. Name Devil's Advocate explicitly if needed.

## Two-Level / Fractal Use

- Single-level: caller invokes swarm directly → personalities → arbitrator → synthesis → return.
- Two-level: swarm dispatched as sub-agent; runs in isolation, returns rolled-up synthesis; outer host aggregates N syntheses.
- Output contract identical in both modes.
- Depth limit: two levels. Deeper nesting out of scope.

## Sub-Spec Reference

| Sub-spec                        | Covers                                                             |
| ------------------------------- | ------------------------------------------------------------------ |
| `specs/glossary.md`             | Key term definitions                                               |
| `specs/registry-format.md`      | Index format, validation rules, YAML schema, naming convention     |
| `specs/personality-file.md`     | Body-file structure, frontmatter handling, loading timing          |
| `specs/arbitrator.md`           | Arbitrator role, output structure, confidence rating logic         |
| `specs/dispatch-integration.md` | Dispatch skill integration, model-class routing, parallelism rules |
