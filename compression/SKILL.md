---
name: compression
description: Compress .md files via subagent dispatch.
---

# Compression

Dispatch `./AGENT.md` as a subagent with:
`<file-path> [--tier <lite|full|ultra>]` (default: ultra)

The agent handles safety gates (clean baseline, spec companion), tier resolution,
and post-flight verification.

## Tiers

- `ultra/SKILL.md` — telegraphic, abbreviations, arrows
- `full/SKILL.md` — drop articles, fragments OK
- `lite/SKILL.md` — drop filler, keep grammar
