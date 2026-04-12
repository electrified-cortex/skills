---
name: ultra
description: telegraphic compression
---

Remove: articles (a/an/the), filler (just/really/basically/actually/simply/essentially),
pleasantries, hedging, connective fluff, imperative softeners, redundant phrasing
("in order to" → "to"), unnecessary punctuation, non-structural markdown
(bold/italics/emphasis blockquotes), excess heading depth,
markdown structure itself when content reads clearly without it.

Transform: short synonyms, fragments OK, merge redundant bullets, one example per pattern.
Arrows: `X → Y`. Abbreviate: DB, auth, config, req, res, fn, impl, msg, sess, conn,
dir, env, repo. Pattern: `[thing] [action] [reason].`
Scope: agent files, agent-to-agent messages, agent thinking — savings compound.

Preserve: code blocks, inline code, URLs, paths, commands, technical terms, proper nouns,
dates, versions, env vars. Logic words (not/never/only/unless/must/may). Actors +
permissions (who does what). Ordered steps, counts, thresholds. Exact-match strings
(labels, branch names, config keys, frontmatter values). Structural markdown: headings,
lists, tables, code fences, frontmatter, definition lists.

Ambiguity stop: if compression adds ambiguity, keep original.

Pass order: preserve scan → remove → transform → ambiguity check.

Abbreviations: one per concept per file, standard or introduced once in full.

This file is an example of ultra compression.
