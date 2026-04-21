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

---

## Purpose

Define the requirements for how an agent discovers and uses skills via the skill-index cascade. This spec governs the integration layer: how the index pointer enters the agent's context, what mandate drives the agent to consult it, and how discovery flows from task description to loaded skill content.

This spec does not govern index construction (skill-index-building), structural validation (skill-index-auditing), or the crawl algorithm (skill-index-crawling). It governs the agent-side integration contract only.

---

## Scope

**In scope:**
- Index pointer placement in agent context (startup vs. recovery context)
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
- **Startup context**: context injected at fresh session start (e.g., CLAUDE.md, system prompt, --append-system-prompt). Survives compaction only if re-injected by a hook or equivalent mechanism.
- **Recovery context**: context injected after compaction (e.g., via SessionStart compact hook `additionalContext`). Guaranteed to be present post-compaction.
- **Demand loading**: the pattern in which skill content is NOT loaded at session start; it is loaded only when a keyword match identifies the skill as relevant.
- **Keyword match**: a case-insensitive substring match between the task description and any keyword in a skill's index entry.
- **Index scope**: the set of skills enumerated in a particular agent's index — a subset of the full skill tree bounded to that agent's operational domain.
- **Natural-language keyword**: a keyword expressed as a phrase a user or operator would naturally say when describing the task, not a technical identifier.
- **Task description**: the agent's interpretation of the current user or operator request, expressed as a short plain-language phrase, used as input to keyword matching.

---

## Requirements

### Index Pointer Placement

R1. An agent's context must contain exactly one index pointer identifying the root `skill.index` path scoped to that agent.

R2. The index pointer must appear in the recovery context at minimum. Presence in startup context alone is insufficient; agents lose startup context after compaction and must recover discovery capability.

R3. The index pointer must be a resolvable file path. Relative paths must resolve from the agent's working directory. Absolute paths are also permitted.

R4. The index pointer must reference a `skill.index` file, not a `skill.index.md` overlay. The raw index is the canonical lookup artifact.

### Discovery Mandate

R5. An agent's context must contain a discovery mandate co-located with or preceding the index pointer in the same context injection.

R6. The discovery mandate must be imperative in form. It must instruct the agent to scan the index before responding to any task. Guidance language ("consider checking") is prohibited in the mandate.

R7. The discovery mandate must apply to every task, including clarifying questions and small requests. No category of task is exempt from the mandate.

R8. The discovery mandate must explicitly state the consequence of a match: load the skill content before proceeding.

R9. The discovery mandate must be present in the recovery context. A mandate present only in CLAUDE.md or equivalent agent file is insufficient.

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

---

## Constraints

C1. The index pointer must not reference a directory; it must reference the `skill.index` file directly.

C2. The discovery mandate may not be embedded only in prose documentation (README, design notes). It must appear in an injected context artifact (recovery context, startup context, or system prompt) that the agent actively reads at session start or recovery.

C3. Skill content must not be pre-loaded into the agent's context window to avoid future keyword scans. Pre-loading bypasses the demand-loading requirement and wastes tokens.

C4. The agent may not maintain an in-session cache of skill content across turns for skills not actively in use. Skills loaded in prior turns are not exempt from reloading if the session context has been compacted.

---

## Behavior

**Index present, keyword match found:**
Agent reads skill content before responding. Agent announces which skill it is applying before taking action.

**Index present, no keyword match:**
Agent proceeds without loading any skill content. No announcement required.

**Index pointer present, `skill.index` file missing:**
Agent proceeds without skill matching. Agent notes the missing index in its output. Agent must not halt or treat this as a fatal condition.

**Index present, match found, skill content file missing or unreadable:**
Agent proceeds without the skill. Agent notes the unreadable skill in output. Agent must not halt.

**Index stamp mismatch (stale index):**
Agent may use the index for keyword matching. Agent should note the stale state (unaudited since last build) in output if the stale condition is detected.

**Multiple keyword matches at the same subtree depth:**
Agent loads all matched skills. Agent applies them in the order they appear in the index.

**Match found in descendant sub-node (crawl descent):**
Agent follows the `skill-index-crawling` resolution rules. Descent behavior is governed by that skill's spec; this spec does not override it.

---

## Defaults and Assumptions

D1. Default placement: recovery context is the canonical location for both the index pointer and the discovery mandate. Startup context placement is additive, not substitutive.

D2. Default scope: each agent type (Curator, Worker, Overseer, Sentinel) maintains its own scoped `skill.index`. There is no global agent index.

D3. Default mandate form: imperative, two sentences maximum. First sentence: instruct the scan. Second sentence: instruct the load on match.

D4. Keyword matching uses the `skill-index-crawling` procedure. This spec does not define an alternative matching algorithm.

---

## Error Handling

E1. Missing index: proceed, log, no halt.
E2. Unreadable index: proceed, log, no halt.
E3. Missing skill content after match: proceed without skill, log, no halt.
E4. Multiple matches with ambiguous resolution: apply `skill-index-crawling` ambiguity rules. If still ambiguous, load all candidates.
E5. Discovery mandate absent from recovery context: the integration is non-conformant. Agent behavior is undefined. Conformance requires the mandate be present.

---

## Precedence Rules

P1. Operator-provided instructions (CLAUDE.md, AGENTS.md, direct in-context instructions) take precedence over any skill content loaded via keyword matching. Skills may not override operator instructions.

P2. This spec is subordinate to the `skill-index` root spec. Any requirement in this spec that conflicts with the root spec is invalid. The root spec governs.

P3. This spec governs the integration layer. It does not override `skill-index-crawling` on crawl behavior, `skill-index-building` on index construction, or `skill-index-auditing` on structural validation. Conflicts in those areas default to the respective governing spec.

---

## Don'ts

- Don't place the discovery mandate only in CLAUDE.md without also placing it in recovery context.
- Don't pre-load all skill content at startup to shortcut keyword matching.
- Don't scope the agent's index to the full skills tree root.
- Don't treat a missing index as a fatal error.
- Don't skip the keyword scan for tasks that appear simple or familiar.
- Don't use descriptive-language mandates ("consider using skills") — imperative only.
- Don't define keyword matching logic in this spec; defer to `skill-index-crawling`.
- Don't define keyword quality as enforced by the builder; quality validation belongs to `skill-index-auditing` (per R25).

---

## Footguns

**F1: Mandate in CLAUDE.md only** — CLAUDE.md is not re-injected after compaction. Agent loses the mandate after context compaction and stops checking skills.
Why: Post-compaction sessions do not re-read CLAUDE.md unless a hook re-injects it.
Mitigation: Place mandate in recovery context (additionalContext from SessionStart compact hook). CLAUDE.md placement is additive only.

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
Mitigation: Mandate must be in startup context, recovery context, or system prompt — injected artifacts, not passive files.

---

## Related

- `skill-index` — root spec; governs the full toolkit contract
- `skill-index-building` — how indexes are constructed
- `skill-index-auditing` — structural and quality validation; enforces R21–R24
- `skill-index-crawling` — keyword-match algorithm and crawl resolution
- `spec-auditing` — validates this spec before derived artifacts are written
- `skill-writing` — how to write SKILL.md from a passing spec
