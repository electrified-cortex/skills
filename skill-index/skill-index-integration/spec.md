---
name: skill-index-integration
description: >-
  Specification for wiring a skill-index cascade into an agent's context: index
  pointer placement, discovery mandate, keyword-match flow, and demand loading.
type: spec
status: draft
version: 1
parent-spec: skill-index
---

# Skill Index Integration Specification

## Changelog

- v1: Initial draft. Covers integration contract between agent context and the skill-index toolkit.
- v1.1: Removed platform-specific terms (Claude Code hooks, startup/recovery context). Replaced with platform-agnostic abstractions: agent configuration file, context-reset recovery.
- v1.2: Fixed audit findings (Haiku pass): defined "operational domain," "index stamp," "stale index"; clarified task description extraction; added R26 (announcement); clarified multi-skill resolution in Behavior; added E6 (mandate-loss recovery); added D3 mandate examples; added D2 single-domain scope note; linked Don'ts to Footguns; noted deliberate omission of platform table.

---

## Purpose

Define the requirements for how an agent discovers and uses skills via the skill-index cascade. This spec governs the integration layer: how the index pointer enters the agent's context, what mandate drives the agent to consult it, and how discovery flows from task description to loaded skill content.

This spec does not govern index construction (skill-index-building), structural validation (skill-index-auditing), or the crawl algorithm (skill-index-crawling). It governs the agent-side integration contract only.

---

## Scope

**In scope:**

- Index pointer placement in agent context (agent configuration file, context injection)
- Discovery mandate: the instruction that compels the agent to check the index
- Keyword-match trigger: when and how the agent scans for matches
- Demand loading: the rule that skill content loads only on match, not at startup
- Index scope bounds: which skills belong in an agent's index
- Keyword quality requirements: what constitutes a valid keyword set per entry

**Out of scope:**

- How indexes are built — see `skill-index-building`
- How indexes are structurally validated — see `skill-index-auditing`
- The crawl algorithm and match resolution logic — see `skill-index-crawling`
- Skill content quality — see `skill-writing`
- How operators author index entries — see `skill-index-building` (shortcut entries)

---

## Definitions

- **Index pointer**: a reference in an agent's context that identifies the path to the agent's root `skill.index` file.
- **Discovery mandate**: the imperative instruction in an agent's context that requires the agent to scan the index before responding to a task.
- **Agent configuration file**: the platform-specific artifact that is guaranteed to be in the agent's context at all times, including after a context-window reset. Examples: `CLAUDE.md` (Claude Code), `AGENTS.md` (OpenAI Codex), `GEMINI.md` (Gemini CLI), system prompt or instructions file (VS Code Copilot), or any equivalent. Implementations vary; the requirement is platform-agnostic.
- **Context injection**: the act of making content available to an agent's active context window. May occur via the agent configuration file, a hook mechanism, an API system prompt field, or any platform-supported mechanism. Must guarantee content presence after context-window resets.
- **Context-window reset**: any event that clears or compacts the agent's in-memory context — including context compaction, session restart, or token-limit truncation. After a reset, only content that is re-injected by the platform's context injection mechanism remains active.
- **Demand loading**: the pattern in which skill content is NOT loaded at session start; it is loaded only when a keyword match identifies the skill as relevant.
- **Keyword match**: a case-insensitive substring match between the task description and any keyword in a skill's index entry.
- **Index scope**: the set of skills enumerated in a particular agent's index — a subset of the full skill tree bounded to that agent's operational domain.
- **Operational domain**: the set of tasks an agent may be assigned or asked to perform, as defined by that agent's role. An agent's index must be scoped to skills relevant within this boundary. Skills outside the agent's operational domain must not appear in its index. Role definitions are maintained by each agent's configuration artifacts (e.g., `CLAUDE.md`, `AGENTS.md`). This spec does not define role boundaries; it only requires that index scope not exceed them.
- **Index stamp**: a content hash or equivalent integrity marker attached to a `skill.index` file by the `skill-index-auditing` process after a validation PASS. Presence of a valid stamp indicates the index has been audited. Absence or mismatch indicates the index is unaudited since last build. See `skill-index-auditing` for stamp format and validation procedure.
- **Stale index**: a `skill.index` file whose stamp is absent, invalid, or inconsistent with current index content. A stale index may still be used for keyword matching; the agent must note the stale condition.
- **Natural-language keyword**: a keyword expressed as a phrase a user or operator would naturally say when describing the task, not a technical identifier.
- **Task description**: the agent's interpretation of the current user or operator request, expressed as a short plain-language phrase, used as input to keyword matching. The agent extracts the task description by identifying the primary action or intent in the request. When a request contains multiple actions, the primary (first or highest-priority) action governs the task description. Precise extraction procedure is left to the agent's judgment; the requirement is that it be consistent for the same input.

---

## Requirements

### Index Pointer Placement

R1. An agent's context must contain exactly one index pointer identifying the root `skill.index` path scoped to that agent.

R2. The index pointer must be delivered via context injection that survives context-window resets. If the platform re-reads its agent configuration file at every session start and after every reset, placing the pointer there satisfies this requirement. If the agent configuration file is read only once at initial load and is not re-injected after resets, the pointer must be delivered via a supplemental injection mechanism (hook output, system prompt, API field) that the platform guarantees survives resets.

R3. The index pointer must be a resolvable file path. Relative paths must resolve from the agent's working directory. Absolute paths are also permitted.

R4. The index pointer must reference a `skill.index` file, not a `skill.index.md` overlay. The raw index is the canonical lookup artifact.

### Discovery Mandate

R5. An agent's context must contain a discovery mandate co-located with or preceding the index pointer in the same context injection.

R6. The discovery mandate must be imperative in form. It must instruct the agent to scan the index before responding to any task. Guidance language ("consider checking") is prohibited in the mandate.

R7. The discovery mandate must apply to every task, including clarifying questions and small requests. No category of task is exempt from the mandate.

R8. The discovery mandate must explicitly state the consequence of a match: load the skill content before proceeding.

R9. The discovery mandate must be delivered via the same context injection mechanism as the index pointer (R2). A mandate present only in a context artifact that does not survive context-window resets is non-conformant.

### Keyword-Match Trigger

R10. On receiving any task, the agent must perform a keyword scan against the index before producing any response or taking any action.

R11. A keyword scan consists of: (a) reading the `skill.index` at the pointer location, (b) parsing entries in the format defined by `skill-index-building`, (c) applying case-insensitive substring matching between the task description and each entry's key and keywords, and (d) selecting a match per the `skill-index-crawling` resolution rules.

R12. The agent must not skip the keyword scan on the basis that the task appears simple, familiar, or small. This reasoning is a rationalization; the scan must run regardless.

R13. If the `skill.index` is missing or unreadable, the agent must proceed without skill matching and must note the missing index in its output. The agent must not treat a missing index as a fatal error.

### Demand Loading

R14. Skill content (SKILL.md or equivalent) must not be loaded at context startup. Skill content must load only when a keyword match identifies the skill as relevant to the current task.

R15. When a keyword match is found, the agent must read the full skill content before producing a response or taking action on the matched task.

R16. When no keyword match is found, the agent must proceed without loading any skill content.

R17. When a keyword match is found but the skill content file is missing or unreadable, the agent must proceed without the skill and must note the unreadable skill in its output.

### Index Scope

R18. An agent's skill index must enumerate only skills within that agent's operational domain. Skills irrelevant to the agent's role must not appear in its index.

R19. Index scope is determined by the agent's role definition, not by the full contents of the skills tree. Enumeration of all available skills in every agent's index is prohibited.

R20. The index pointer for a specific agent must reference a scoped index file, not the root of the full skills tree. An agent-level `skill.index` is the correct pointer target; the workspace-level skills root is not a valid pointer target for a single-role agent.

### Keyword Quality

R21. Each entry in an agent's index must contain at least three keywords in addition to the entry key.

R22. Keywords must be natural-language phrases. A keyword must represent how an operator or user would describe the need — not the technical skill name. The entry key itself is the technical name; keywords are its natural-language surface forms.

R23. Keywords must not duplicate the entry key verbatim. Paraphrases, synonyms, and related phrases are required; exact repetition of the key is prohibited.

R24. At least one keyword per entry must be a multi-word phrase of two or more words. Single-word keywords alone are insufficient to distinguish between overlapping skills.

R25. Keyword quality for entries in agents' indexes is subject to audit by `skill-index-auditing`. This spec's keyword requirements (R21–R24) are the normative standard the auditor must enforce. Any conflict between this spec and the auditor's keyword quality checks must be resolved by updating the auditor to match this spec.

R26. When a keyword match is found and the skill content is loaded, the agent must announce the matched skill before taking action on the matched task. Minimum form: "Using [skill name] to [brief description of action]." The announcement must be visible to the user or operator.

---

## Constraints

C1. The index pointer must not reference a directory; it must reference the `skill.index` file directly.

C2. The discovery mandate may not be embedded only in prose documentation (README, design notes). It must appear in a context injection artifact that the platform guarantees is active at the time the agent processes any task — not merely on initial load.

C3. Skill content must not be pre-loaded into the agent's context window to avoid future keyword scans. Pre-loading bypasses the demand-loading requirement and wastes tokens.

C4. The agent may not maintain an in-session cache of skill content across turns for skills not actively in use. Skills loaded in prior turns are not exempt from reloading if the session context has been compacted.

---

## Behavior

**Index present, keyword match found:**
Agent reads the full skill content before responding. Agent must announce which skill it is loading before taking action (see R26). Minimum form: "Using [skill name] to [primary action]."

**Index present, no keyword match:**
Agent proceeds without loading any skill content. No announcement required.

**Index pointer present, `skill.index` file missing:**
Agent proceeds without skill matching. Agent notes the missing index in its output. Agent must not halt or treat this as a fatal condition.

**Index present, match found, skill content file missing or unreadable:**
Agent proceeds without the skill. Agent notes the unreadable skill in output. Agent must not halt.

**Index stamp mismatch (stale index):**
A stale index is one whose integrity stamp is absent, invalid, or inconsistent with current index content (see Definitions: "Index stamp," "Stale index"). Agent may use a stale index for keyword matching. Agent must note the stale state in output when detected: "Skill index may be outdated (stamp absent or invalid)."

**Multiple keyword matches at the same subtree depth:**
Agent loads the full content of each matched skill. Agent applies them sequentially in the order they appear in the index. Each skill operates independently; the output of one skill is not passed as input to the next. The agent presents each skill's contribution in sequence.

**Match found in descendant sub-node (crawl descent):**
Agent follows the `skill-index-crawling` resolution rules. Descent behavior is governed by that skill's spec; this spec does not override it.

---

## Defaults and Assumptions

D1. Default placement: the index pointer and discovery mandate must be in a context artifact the platform guarantees survives context-window resets. On platforms that re-read the agent configuration file after every reset, the configuration file is the default location. On platforms that do not, a hook or system-prompt injection is required in addition.

D2. Default scope: each agent type (Curator, Worker, Overseer, Sentinel) maintains its own scoped `skill.index`. There is no global agent index. This spec assumes each agent has a single operational domain. Multi-domain agent support — agents that require multiple independent skill index pointers — is out of scope for this version.

D3. Default mandate form: imperative, two sentences maximum. First sentence: instruct the scan. Second sentence: instruct the load on match.

Conformant example: "Before responding to any task, scan your skill index for matching keywords. If a match is found, read the full skill content before proceeding."

Non-conformant examples (guidance language, not imperative): "Consider checking the skill index before responding." / "It may be helpful to look up skills in your index." / "You should probably check the skill index."

D4. Keyword matching uses the `skill-index-crawling` procedure. This spec does not define an alternative matching algorithm.

---

## Error Handling

E1. Missing index: proceed, log, no halt.
E2. Unreadable index: proceed, log, no halt.
E3. Missing skill content after match: proceed without skill, log, no halt.
E4. Multiple matches with ambiguous resolution: apply `skill-index-crawling` ambiguity rules. If still ambiguous, load all candidates.
E5. Discovery mandate absent from a context injection that survives context-window resets: the integration is non-conformant. Agent behavior is undefined. Conformance requires the mandate be present in a reset-surviving injection.

E6. Discovery mandate not found after a context-window reset: the agent must attempt to reload the mandate from its configured context injection artifact. If the mandate is still absent after the reload attempt, the agent must proceed without the discovery mandate, must log the absence ("Discovery mandate not found; skill scanning disabled for this session"), and must not halt. Conformance is compromised but agent operation continues.

---

## Precedence Rules

P1. Operator-provided instructions (CLAUDE.md, AGENTS.md, direct in-context instructions) take precedence over any skill content loaded via keyword matching. Skills may not override operator instructions.

P2. This spec is subordinate to the `skill-index` root spec. Any requirement in this spec that conflicts with the root spec is invalid. The root spec governs.

P3. This spec governs the integration layer. It does not override `skill-index-crawling` on crawl behavior, `skill-index-building` on index construction, or `skill-index-auditing` on structural validation. Conflicts in those areas default to the respective governing spec.

---

## Don'ts

The items below are brief prohibitions. Extended explanations, rationale, and mitigations are in the Footguns section below.

- Don't place the discovery mandate only in an artifact that does not survive context-window resets.
- Don't pre-load all skill content at startup to shortcut keyword matching.
- Don't scope the agent's index to the full skills tree root.
- Don't treat a missing index as a fatal error.
- Don't skip the keyword scan for tasks that appear simple or familiar.
- Don't use descriptive-language mandates ("consider using skills") — imperative only.
- Don't define keyword matching logic in this spec; defer to `skill-index-crawling`.
- Don't define keyword quality as enforced by the builder; quality validation belongs to `skill-index-auditing` (per R25).

---

## Footguns

**F1: Mandate only in an artifact that does not survive context-window resets** — Agent loses the mandate after compaction or session restart and stops checking skills.
Why: Some agent configuration files are read only at initial load and are not re-injected after context resets. On those platforms, a mandate placed exclusively in that file becomes inactive after the first reset.
Mitigation: Confirm whether the platform re-reads the agent configuration file after every reset. If not, also place the mandate in a supplemental injection mechanism (hook output, system prompt, API field) that the platform guarantees survives resets. Example: Claude Code's SessionStart compact hook `additionalContext`; VS Code Copilot's persistent instructions file; an API system-prompt field injected on every request.

**F2: Index pointer scoped to full skills tree** — Agent's index lists hundreds of skills across all domains, making keyword matching noisy and slow.
Why: The full skills tree root contains skills for all agent types; most are irrelevant to any specific agent.
Mitigation: Create a per-agent scoped `skill.index` that enumerates only skills relevant to that agent's role. Reference this scoped file in the pointer.

**F3: Keywords that duplicate the key** — Entry has `skill-writing: skill-writing, write skill` — the first keyword is the key verbatim. Banned by R23.
Why: Verbatim repetition adds no surface coverage. The key is already matched as a first-class field.
Mitigation: Keywords must be synonyms, paraphrases, or related phrases. Remove any keyword that exactly matches the key.

**F4: Pre-loaded skill content** — Agent reads all SKILL.md files at startup to avoid running the index scan.
Why: Violates demand-loading (R14), wastes tokens on skills that will never be used in the session, bloats the context window.
Mitigation: Read `skill.index` only. Load SKILL.md only when a keyword match is found.

**F5: Mandate in exploratory or descriptive context** — Discovery mandate embedded in a README or design doc rather than an injected context artifact.
Why: Agents do not actively read documentation in their skills library at every turn.
Mitigation: Mandate must be in an injected context artifact (agent configuration file, system prompt, hook output) — not in passive documentation.

---

## Related

- `skill-index` — root spec; governs the full toolkit contract
- `skill-index-building` — how indexes are constructed
- `skill-index-auditing` — structural and quality validation; enforces R21–R24
- `skill-index-crawling` — keyword-match algorithm and crawl resolution
- `spec-auditing` — validates this spec before derived artifacts are written
- `skill-writing` — how to write SKILL.md from a passing spec
