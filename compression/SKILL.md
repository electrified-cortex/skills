---
name: compression
description: Compress .md files via subagent dispatch. Supports in-place, source→target, and untracked fallback modes.
---

# Compression

Dispatch background agent (Sonnet-class or lower subagent without your full context): "Read and follow `compress.md` (in this directory). Input: `<file-path> [--tier <lite|full|ultra>] [--source <src> --target <dst>]`" (default: ultra)

Modes:
- `--source X --target Y` → read X, compress to Y. No git check. Primary workflow for skill development.
- Default → in-place if tracked+clean; creates `.compressed` alongside if untracked/dirty.

Tiers: `ultra/rules.txt` — telegraphic, abbreviations, arrows; `full/rules.txt` — drop articles, fragments OK; `lite/rules.txt` — drop filler, keep grammar
