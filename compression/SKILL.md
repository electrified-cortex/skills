---
name: compression
description: Compress .md agent-context files. Tiers: Lite, Full, Ultra. Load one.
---

Target: reduce `.md` token cost in agent ctx.

Tier map:
- Lite: human-facing. Drop filler, keep articles + grammar.
- Full: general docs. Drop articles, fragments OK.
- Ultra: agent files, skills. Telegraphic, abbreviations, arrows.
- None: specs, audio, code. Never compress.

Surface map:
- Agent files (`.agent.md`, `CLAUDE.md`), skills, agent DMs, reminders → Ultra.
- Operator text, tasks, READMEs → Lite.
- General docs → Full.
- Spec files (`.spec.md`), audio, code blocks → None.

Usage: `lite/SKILL.md`, `full/SKILL.md`, `ultra/SKILL.md`.

Rules: meaning-preserving intent — reduce tokens, not meaning. Never compress specs, code,
audio. Security warnings: full clarity. Full/Ultra strip non-structural markdown.
Lite keeps meaningful markdown.

Preserve: terms, paths, URLs, commands, proper nouns, dates, versions, env vars.
Logic words (not/never/only/unless/must/may/required/optional). Actors +
permission boundaries. Ordered steps, counts, thresholds, priorities.
Exact-match strings (labels, branch names, config keys, frontmatter values,
CLI flags, error text).

Ambiguity stop: if compression adds ambiguity, keep original.

Pass order: preserve scan, remove, transform, ambiguity check.

Abbreviations: one per concept per file. Standard or introduced once in full.
