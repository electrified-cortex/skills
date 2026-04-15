---
name: compression
description: Compress .md files via subagent dispatch.
---

# Compression

Dispatch background agent (Sonnet-class or lower subagent without your full context): "Read and follow `compress.md` (in this directory). Input: `<file-path> [--tier <lite|full|ultra>]`" (default: ultra)

Tiers: `ultra/rules.txt` — telegraphic, abbreviations, arrows; `full/rules.txt` — drop articles, fragments OK; `lite/rules.txt` — drop filler, keep grammar
