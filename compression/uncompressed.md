---
name: compression
description: Compress .md files via subagent dispatch. Supports in-place, source→target, and untracked fallback modes.
---

# Compression

Without reading `instructions.txt` yourself, use a Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory).
Input: `<file-path> [--tier <lite|full|ultra>] [--source <src> --target <dst>]`" (default: ultra)

Modes:

- `--source X --target Y` → read X, compress to Y. No git check. Primary workflow for skill development.
- Default → in-place if tracked+clean; creates `.compressed` alongside if untracked/dirty.

Tiers: `ultra/rules.txt` — telegraphic, abbreviations, arrows; `full/rules.txt` — drop articles, fragments OK; `lite/rules.txt` — drop filler, keep grammar

For `.md` targets: after compression, runs a markdown-hygiene pass on the result. Fixes lint issues in-place; remaining unfixable issues reported as warnings, never rejected. Output always states hygiene outcome so callers know no further pass is needed.

## Iteration Safety

Root cause: repeated compress → audit → recompress cycles against an unchanged source produce identical artifacts — deterministic verdicts, wasted work.

**Rule A — Land fixes before recompressing.** When an audit of the compressed output returns NEEDS_REVISION or FAIL, you must resolve those findings in the authoritative source file (`uncompressed.md` or `instructions.uncompressed.md`) before recompressing. Recompressing an unchanged source produces an identical artifact. The audit verdict doesn't change; the compress pass is pure waste.

**Rule B — Never re-audit unchanged content.** "Never re-audit a file that has not been modified since the previous audit, period, full stop." If the source file hasn't changed since the prior compression pass, the compressed output is identical and the audit verdict is deterministic. Re-dispatching the audit without first modifying the source is forbidden.

Before dispatching any follow-up compress → audit cycle, verify that at least one authoritative source file has changed since the previous cycle completed. If no source file has changed, the prior verdict stands and re-dispatch is forbidden.

Related: `skill-writing` (skills workflow), `spec-auditing` (post-compression verification)
