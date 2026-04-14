---
name: compression
description: Compress .md files. Dispatch AGENT.md — don't compress inline.
---

# Compression

Dispatch `./AGENT.md` with the target file and optional `--tier <lite|full|ultra>`.
Default tier: ultra. The agent handles gates, tier selection, and post-flight verification.

**Do NOT attempt compression inline.** The agent runs in isolated context and produces
consistent, verified results. Reading tier skills directly leads to content loss.

## Surface → Tier Map

- Agent files, skills, agent DMs, reminders → Ultra
- Operator text, tasks, READMEs → Lite
- General docs → Full
- Spec files, audio, code → None (never compress)

## Tier Skills (reference only)

- `ultra/SKILL.md` — telegraphic, abbreviations, arrows
- `full/SKILL.md` — drop articles, fragments OK
- `lite/SKILL.md` — drop filler, keep grammar

Rationale: `SKILL.spec.md`
