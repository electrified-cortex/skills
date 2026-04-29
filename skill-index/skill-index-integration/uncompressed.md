# Skill Index Integration — Uncompressed Reference

Requirements for how an agent discovers and uses skills via the skill-index cascade. Governs the integration layer only: how the index pointer enters the agent's context, what mandate drives the agent to consult it, and how discovery flows from task description to loaded skill content.

Does NOT govern: index construction (skill-index-building), structural validation (skill-index-auditing), or the crawl algorithm (skill-index-crawling).

## Core Concepts

- **Index pointer:** a reference in an agent's context identifying the path to the agent's root `skill.index` file.
- **Discovery mandate:** the imperative instruction that requires the agent to scan the index before responding to any task.
- **Agent configuration file:** platform-specific artifact guaranteed to be in the agent's context at all times, including after context-window resets. Examples: `CLAUDE.md` (Claude Code), `AGENTS.md` (OpenAI Codex), `GEMINI.md` (Gemini CLI).
- **Context injection:** making content available to an agent's active context window in a way that survives context-window resets.
- **Context-window reset:** any event that clears or compacts the agent's in-memory context — compaction, session restart, or token-limit truncation.
- **Demand loading:** skill content is NOT loaded at session start; it loads only when a keyword match identifies the skill as relevant.
- **Keyword match:** case-insensitive substring match between the task description and any keyword in a skill's index entry.
- **Index scope:** the set of skills enumerated in a particular agent's index — bounded to that agent's operational domain.
- **Stale index:** a `skill.index` file whose stamp is absent, invalid, or inconsistent with current content. May still be used for matching; note the stale condition.
- **Overlay (`skill.index.md`):** the human-readable trigger map loaded into agent context on every reset; the primary discovery surface. The raw `skill.index` is the substring-match fallback.

## Requirements

### Index Pointer Placement (R1-R4)

- R1: Agent's context must contain exactly one index pointer identifying the root `skill.index` path scoped to that agent.
- R2: The index pointer must be delivered via context injection that survives context-window resets. If the agent configuration file is re-read after every reset, placing the pointer there satisfies this. If not, a supplemental injection mechanism (hook output, system prompt, API field) is required.
- R3: The index pointer must be a resolvable file path. Relative paths resolve from the agent's working directory.
- R4: The index pointer must reference a `skill.index` file, not a `skill.index.md` overlay.

### Discovery Mandate (R5-R9)

- R5: Agent's context must contain a discovery mandate co-located with or preceding the index pointer in the same context injection.
- R6: The mandate must be imperative. Guidance language ("consider checking") is prohibited.
- R7: The mandate must apply to every task, including clarifying questions and small requests. No task category is exempt.
- R8: The mandate must explicitly state the consequence of a match: load the skill content before proceeding.
- R9: The mandate must be delivered via the same context injection mechanism as the index pointer.

Conformant mandate example: "Before responding to any task, scan your skill index for matching keywords. If a match is found, read the full skill content before proceeding."

Non-conformant: "Consider checking the skill index before responding." / "It may be helpful to look up skills."

### Keyword-Match Trigger (R10-R13)

- R10: On receiving any task, the agent must perform a keyword scan before producing any response or taking any action.
- R11: A keyword scan consists of: (a) reading the `skill.index` at the pointer location, (b) parsing entries per `skill-index-building` format, (c) applying case-insensitive substring matching between the task description and each entry's key and keywords, (d) selecting a match per `skill-index-crawling` resolution rules.
- R12: The agent must not skip the keyword scan because the task appears simple, familiar, or small.
- R13: If the `skill.index` is missing or unreadable, proceed without skill matching and note the missing index in output. Not a fatal error.

### Demand Loading (R14-R17)

- R14: Skill content (SKILL.md or equivalent) must NOT be loaded at context startup.
- R15: When a keyword match is found, the agent must read the full skill content before producing a response.
- R16: When no keyword match is found, proceed without loading any skill content.
- R17: When a match is found but the skill content file is missing or unreadable, proceed without the skill and note it in output.

### Index Scope (R18-R20)

- R18: An agent's skill index must enumerate only skills within that agent's operational domain.
- R19: Index scope is determined by the agent's role definition, not the full contents of the skills tree.
- R20: The index pointer must reference a scoped index file, not the root of the full skills tree.

### Keyword Quality (R21-R25)

- R21: Each entry must contain at least three keywords in addition to the entry key.
- R22: Keywords must be natural-language phrases — how an operator or user would describe the need, not the technical skill name.
- R23: Keywords must not duplicate the entry key verbatim.
- R24: At least one keyword per entry must be a multi-word phrase of two or more words.
- R25: Keyword quality is subject to audit by `skill-index-auditing`.

### Announcement (R26)

- R26: When a keyword match is found and skill content is loaded, the agent must announce the matched skill before taking action. Minimum form: "Using [skill name] to [brief description of action]."

### Overlay as Primary Discovery Surface (R27-R30)

- R27: The agent's context injection must include the overlay (`skill.index.md`) content — or a reference that causes it to be loaded on every reset — alongside the index pointer and discovery mandate.
- R28: The discovery mandate must instruct the agent to match its **current situation** (operator phrasing or self-observed state) to a section in the overlay, and load that section's skill. Keyword-substring matching against the raw index is a fallback when no overlay section matches.
- R29: Overlay sections in an agent's scoped index must be trigger-shaped per `skill-index-building` spec R22-R25. Description-shaped sections are non-conformant.
- R30: A preamble in the overlay (per `skill-index-building` spec R8, R24) may establish the routing convention once, so per-section prose does not repeat framing.

## Behavior Reference

| Situation | Required Action |
| --- | --- |
| Index present, keyword match found | Read full skill content; announce skill; then act |
| Index present, no keyword match | Proceed without loading any skill |
| Index pointer present, `skill.index` file missing | Proceed; note missing index in output; do not halt |
| Match found, skill content missing or unreadable | Proceed without skill; note in output; do not halt |
| Stale index (stamp absent or invalid) | May use for matching; note stale condition in output |
| Multiple matches at same subtree depth | Apply `skill-index-crawling` rules; if still ambiguous, load all candidates |

## Constraints

- C1: Index pointer must not reference a directory — must reference the `skill.index` file directly.
- C2: Discovery mandate may not be embedded only in prose documentation. Must appear in a context injection artifact active at the time the agent processes any task.
- C3: Skill content must not be pre-loaded into the context window to avoid future keyword scans.
- C4: The agent must not cache skill content across turns. Reload whenever a keyword match identifies the same skill as relevant to the current turn.

## Error Handling

- E1: Missing index — proceed, note in output, no halt.
- E2: Unreadable index — proceed, note in output, no halt.
- E3: Missing skill content after match — proceed without skill, note in output, no halt.
- E4: Multiple matches with ambiguous resolution — apply `skill-index-crawling` rules; if still ambiguous, load all candidates.
- E5: Discovery mandate absent from reset-surviving injection — integration is non-conformant; agent behavior is undefined.
- E6: Discovery mandate not found after context-window reset — attempt to reload from configured context injection artifact; if still absent, proceed without mandate and note "Discovery mandate not found; skill scanning disabled for this session"; do not halt.

## Conformance Checklist

An integration is conformant when:

- [ ] Exactly one scoped index pointer (R1-R4) delivered via reset-surviving injection (R2)
- [ ] Discovery mandate (R5-R9) delivered via the same injection
- [ ] Keyword scan performed before each task (R10-R12)
- [ ] Demand loading enforced: skill content loads only on keyword match (R14-R17)
- [ ] Matched skill announced before acting (R26)
- [ ] Index scoped to agent's operational domain (R18-R20)
- [ ] All index entries satisfy keyword quality requirements (R21-R24)

## Precedence

- P1: Operator-provided instructions take precedence over any skill content loaded via keyword matching.
- P2: This spec is subordinate to the `skill-index` root spec.
- P3: This spec governs the integration layer only; does not override `skill-index-crawling`, `skill-index-building`, or `skill-index-auditing`.

## Don'ts

- Don't place the discovery mandate only in an artifact that does not survive context-window resets.
- Don't pre-load all skill content at startup to shortcut keyword matching.
- Don't scope the agent's index to the full skills tree root.
- Don't treat a missing index as a fatal error.
- Don't skip the keyword scan for tasks that appear simple or familiar.
- Don't use guidance-language mandates ("consider using skills") — imperative only.

## Related

- `skill-index` — root spec; governs the full toolkit contract
- `skill-index-building` — how indexes are constructed
- `skill-index-auditing` — structural and quality validation; enforces R21-R24
- `skill-index-crawling` — keyword-match algorithm and crawl resolution
