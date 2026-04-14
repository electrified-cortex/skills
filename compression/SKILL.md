---
name: compression
description: Compress .md files via subagent dispatch.
---

# Compression

Dispatch `./AGENT.md` as subagent with:
`<file-path> [--tier <lite|full|ultra>]` (default: ultra)

Agent handles safety gates (clean baseline, spec companion), tier resolution, post-flight verification.

Tiers:
`ultra/rules.txt` — telegraphic, abbreviations, arrows
`full/rules.txt` — drop articles, fragments OK
`lite/rules.txt` — drop filler, keep grammar
