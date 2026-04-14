---
name: agent-optimizer
description: Audit and optimize agent files for token efficiency, routing clarity, and retrieval-first design.
---

# Agent Optimizer

Dispatch `./AGENT.md` as a subagent with:
`<file-path>` — the always-on agent file to audit and optimize.

The agent classifies every section (keep / move to skill / move to doc / remove),
proposes target structure, and reports savings projection. Read-only by default.
Avoids loading procedural and domain-heavy material by default.
Makes it easier to retrieve specialized instructions only when needed.

Compression Interoperation:
Optimization (moving content between layers) and compression (reducing tokens within layer) are distinct.
Recommended workflow:
1. Optimize first — tier placement.
2. Compress each layer independently using `compression` skill.
3. Layer 1 = Ultra compression (highest density, per-turn).
4. Manifests = Full compression.
5. Skills = per skill convention.
Skill recommends placement. Compression skill handles token reduction.

Advanced: Hook-Based Context Injection:
Platforms with lifecycle hooks can automate context loading entirely, making agent file even smaller.
SessionStart hooks read manifest files and inject as `additionalContext` — agent arrives with full operating context loaded, zero file reads needed. Same hook with `compact` matcher re-injects context after compaction automatically.
Reminders inject periodic context (fleet status, pending tasks, blocked items) on schedule rather than baking into always-on cost.
Subagent folders give specialized work its own context window, keeping main agent's context clean.
When hook-based injection available, agent file shrinks further:
No "read manifest on startup" instruction needed — hooks handle it.
No "re-read after compaction" instruction needed — hooks handle it.
Agent file becomes pure kernel: identity, invariants, routing index.
Target: ~200-300 tokens.
Most aggressive optimization tier. Mention as bonus recommendation when platform supports hooks.

Precedence:
Safety placement (Layer 1) > token savings.
Post-compaction recovery > structural elegance.
Behavioral fidelity > compression targets.
Spec (`spec.md`) governs this file.
