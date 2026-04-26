---
name: swarm
description: Multi-personality review infrastructure. Selects reviewer personalities from a runtime registry, gates availability, dispatches in parallel via the dispatch skill, arbitrates, synthesizes verdict with confidence rating. Model selection is automatic. Infrastructure only — consumer skills (e.g. code-review) call in; swarm doesn't review itself.
---

Inputs: `problem` (required artifact), `additional_personalities` (inclusion list of personality names or indices, bypasses triggers — not exclusion gate; code-domain personalities like Code Quality Critic/Architect/Test Reviewer/Operational Readiness/Performance Reviewer/Copilot Reviewer are caller-supplied here, not built-in), `disable_inline_personality_generation` (optional bool, default false — set true for strict registry-only, no on-the-fly Custom Specialist). Model selection is automatic — no caller override. Key terms/glossary: `specs/glossary.md`. Sub-specs: `specs/registry-format.md`, `specs/personality-file.md`, `specs/arbitrator.md`, `specs/dispatch-integration.md`.

## Step Sequence

S1. Build review packet from `problem`. Fields (omit if N/A): Goal, Approach, Key decisions, Artifacts (actual content — not references), Files affected, Blast radius, Conventions. Must be self-contained. Verify Goal evaluable + Artifacts contain real content; resolve gaps from context — don't ask caller.

S2. Select personalities. Read index from `reviewers/` — ONE file. Build in-memory: name, trigger, required, suggested_models, suggested_backends, scope, vendor. Skip invalid entries; verify `reviewers/<name>.md` exists and non-empty; missing/empty → drop with warning. Append caller custom-menu entries. If `additional_personalities`: dispatch named only, triggers bypassed. Else: evaluate triggers against packet. `required: true` personalities are always dispatched regardless of `additional_personalities` content. Devil's Advocate carries `required: true`. Selection inline.

S3. Availability gate. Non-`dispatch-*` backends: run probe. Pass → include. Fail → drop, note in synthesis, continue — don't fail-stop. `dispatch-*` backends: no probe needed.

S4. Load reviewer prompts — ONLY after swarm finalized (post-S3). Load `reviewers/<kebab-name>.md` for dispatched personalities only. Strip YAML frontmatter if present. Body IS the system prompt verbatim — no scaffolding. Don't load non-dispatched files.

S5. Dispatch. Single parallel batch via `electrified-cortex/dispatch`. Never sequential. Each dispatch receives: review packet + personality prompt + read-only phrase ("read-only review — analyze and report only, no file edits, no commits, no shell commands") + evidence rule ("cite specific evidence (snippet/line/scenario) per finding, or retract"). Model: `suggested_models` first available → `sonnet-class`. Apply B8 diversity after all selections.

S6. Arbitrator. After all outputs collected, dispatch single sonnet-class arbitrator (not in registry; not gated). Input: non-empty/non-timeout member outputs + review packet. Output: structured action list — (1) Obvious actions: 2+ members agreed or self-evident; description + source indices + evidence. (2) Critical actions: blocks shipping or requires arch change; description + source indices + evidence + severity rationale. No speculative/low-confidence/duplicate items. Empty → "No actionable findings".

S7. Aggregate. Collect from arbitrator's action list. Record per item: personality indices, summary, evidence. Identify disagree set: contradictory conclusions from different members on same point.

S8. Synthesize. Host voice only — don't dump raw output. From arbitrator list only. Required: Summary, Disagreements (tension + judgment), Dropped personalities (reason), Confidence (High/Medium/Low + rationale; if Low, state what raises it). Cap 2000 words; truncate — disagreements → high → medium → low; note truncation.

## Behaviors

B1. Empty/unresolvable `problem` → "No reviewable artifact found." No dispatch. B2. Empty swarm after gating → "Swarm empty after gating." No synthesis. B3. Single personality → proceed; note limited scope. B4. No findings or timeout → non-contributing; note in output. B5. All return no findings → "No findings from any reviewer"; Low confidence. B6. Devil's Advocate is always dispatched. There is no exclusion path. B7. Custom entries: "always" trigger = include (subject to gating). B8. Cross-vendor diversity best-effort; if unavailable, proceed + note monoculture. B9. Selection reads index only — not body files; body loaded S4 for selected only. B10. When no built-in or caller-supplied personality covers the domain and `disable_inline_personality_generation` isn't true, generate Custom Specialist inline: infer role from problem, author brief system-prompt, dispatch with same constraints. One-shot — not persisted.

## Precedence

P1. `additional_personalities` overrides triggers. P2. Availability gate overrides selection. P3. Read-only constraint overrides personality instruction. P4. 2000-word cap overrides completeness.

## Don'ts

Don't load prompts before swarm finalized. Don't use fixed roster. Don't fail-stop on unavailable personality. Don't dump raw output. Don't merge with/replace code-review. Don't dispatch sequentially. Don't use bare model names. Don't CLI-as-dispatch until 10-0845 lands. Don't let custom entries replace built-ins. Don't treat `additional_personalities` as exclusion list. Don't have host parse raw member output. Don't add arbitrator to registry. Don't implement `local-llm` in v1. Don't embed normative registry as static table. Don't fail swarm on monoculture. Don't dispatch personality with missing/empty body. Don't read body files at S2. Don't add scaffolding to body files. Don't expand registry without spec amendment + audit. Don't include code-domain personalities in the built-in registry — Code Quality Critic, Test Reviewer, Architect, Operational Readiness, Performance Reviewer, Copilot Reviewer are caller-supplied via `additional_personalities`.

## Footguns

F1. Loading all prompts before selection → load post-S3 only. F2. Probe fail treated as fatal → drop, don't error. F3. Read-only phrase missing → include literal phrase every dispatch. F4. Sequential dispatch → single parallel batch. F5. Synthesis names reviewers → host voice only. F6. Host synthesizes from raw output → arbitrator list only at S8. F7. Monoculture → Devil's Advocate carries `vendor: openai`. F8. Informative table treated as normative → index file is truth. F9. Body files read at S2 → index only at S2; bodies at S4.

Anti-pattern: `additional_personalities: ["Security Auditor"]` — bypasses triggers for the named entry only. Devil's Advocate is still dispatched along with Security Auditor (plus any other required personalities from the registry). The inclusion list does not suppress Devil's Advocate.

## Two-Level / Fractal Use

- Single-level: caller → swarm → personalities → arbitrator → synthesis.
- Two-level: swarm dispatched as sub-agent; returns rolled-up synthesis; outer host aggregates N syntheses.
- Output contract identical in both modes.
- Depth: two levels supported (deeper nesting out of scope).

Related: `dispatch` — agent-launching mechanics
