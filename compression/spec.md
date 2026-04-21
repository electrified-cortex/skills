---
name: compression
description: >-
  Spec for the compression skill — design rationale, tier philosophy,
  credits, gate justifications, and displaced commentary.
---

# Compression — Spec

Design rationale and reference for the compression skill. This file is the
spec companion — it contains everything that was stripped from the lean
`SKILL.md` and everything that explains *why* the skill works the way it does.

## Credit

Inspired by [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) (MIT).
The caveman approach showed that LLMs can read and produce telegraphic text
with negligible loss of comprehension in practice. We adopted this insight
and extended it with safety gates, tier differentiation, and integration
into an audit pipeline.

## Purpose

Every file loaded into an AI agent's context window costs tokens. Some files
are loaded on every session start (agent definitions, instructions). Others are
loaded on every skill invocation. The cost compounds: a 10KB agent file loaded
200 times costs 2MB of context window across sessions. Reducing that file to
6KB saves 800KB — real capacity that could hold actual work products instead.

Compression isn't about readability for humans. It's about density for machines.
In practice, LLMs parse compressed text with negligible loss of understanding —
though results vary by model, task, and compression tier. Verify via audit.
The spec (this file) preserves the human-readable version.

## Why Markdown Only

The skill targets `.md` files that are loaded into agent context: agent files,
skills, instructions. These are the highest-volume, highest-frequency files in
the workspace. Code files have their own density — they're already compressed
by necessity. General text files (READMEs, docs) are human-facing and use Lite
compression by convention, not this skill.

## Skill vs Agent Separation

The skill is pure technique — what to remove, transform, and preserve. It has
no opinions about *when* or *whether* compression should happen.

Process gates live in the **compression dispatch** — see `compress.spec.md`
(in this directory) for full gate design and rationale. The skill's
`instructions.txt` is the executable companion; the spec here defines what
compression is.

This separation means: if someone invokes the skill directly, they get raw
compression with no safety net. That's by design — the skill is a tool, not
a workflow.

## Tier Philosophy

The workspace uses four compression tiers:

| Tier | Description | Applied by |
| --- | --- | --- |
| **None** | Full natural language, no compression | Audio, specs, code |
| **Lite** | Drop filler/hedging, keep articles and grammar | Human-facing text, operator messages |
| **Full** | Drop articles, fragments OK, short synonyms | General documentation |
| **Ultra** | Abbreviate, telegraphic, arrows for causality | Agent-to-agent, agent files, skills |

The compression skill implements all three tiers as self-contained sub-skills:

- `lite/rules.txt` — Lite rules, human-facing content
- `full/rules.txt` — Full rules, general documentation
- `ultra/rules.txt` — Ultra rules, agent-facing files

Each tier is standalone — loading `ultra/rules.txt` gives an agent everything
needed to apply Ultra compression without reading the parent or other tiers.
The top-level `SKILL.md` serves as a concept overview and tier index.

The key insight: Ultra is for machines reading instructions. Lite is for humans
reading updates. They serve different audiences and should never be mixed.
A message to a human should be Lite. A direct message to an agent should be Ultra.
The transport (Telegram, Signal, Teams, whatever) doesn't matter — the audience does.

**Gold standard:** `ultra/rules.txt` is the benchmark for how agent-facing files
should be structured — minimal frontmatter, label: format, zero fluff, self-referential
stamp. All agent-facing files should aspire to this density.

## Why Specs Are Never Compressed

Specs exist for human readability. They contain the *why* behind decisions,
incident history, design rationale, gotchas, and credits. Compressing a spec
defeats its purpose — it's the one place where verbose explanation is not only
acceptable but required.

Specs are also comparatively low-frequency reads. An agent file might be loaded
200 times; its spec might be read 5 times. The token savings from compressing
specs are negligible compared to the information loss.

## The Preserve List — Why Each Item

- **Code blocks** — Semantic meaning depends on exact syntax. Even whitespace matters.
- **Inline code** — Same as code blocks but inline. Identifiers, commands, paths.
- **URLs/links/file paths** — Changing a single character breaks them.
- **Technical terms** — "AppArmor" ≠ "app armor". "SSRF" ≠ "server-side request forgery" (in compressed context).
- **Proper nouns** — Names of people, projects, companies. Identity matters.
- **Dates/versions/numbers** — Factual data that cannot be approximated.
- **Environment variables** — Exact case and spelling required.
- **Headings** — Structural anchors. Compressing heading text breaks navigation and cross-references.
- **Bullet/list structure** — Hierarchy carries meaning. Flattening loses relationships.
- **Tables** — Cell text can be compressed but structure (columns, rows) must stay.
- **Frontmatter** — Machine-parsed metadata. Exact keys and values required.

### Semantic Preserve Additions (GPT 5.4 Review, 2026-04-12)

External review identified silent failure modes where compression can destroy
meaning without obvious breakage:

- **Logic/modality words** (not, never, only, unless, must, may) — Removing "not" or
  "only" inverts meaning. "Must" vs "may" is the difference between a requirement and
  a suggestion. These are load-bearing words that compression must never touch.
- **Actors + permissions** (who does what) — "Curator commits" ≠ "Workers commit."
  Stripping the actor makes the sentence ambiguous about who has permission.
- **Ordered steps, counts, thresholds** — "Run A then B" ≠ "Run A and B." Sequence
  matters. "Max 3 retries" cannot be approximated.
- **Exact-match strings** (labels, branch names, config keys, frontmatter values) —
  These are machine-parsed identifiers. Synonyms break them.

These rules apply at all tiers — even Lite must preserve logic words and actors.

### Process Additions

- **Ambiguity stop** — If compression produces a sentence that could be read two ways,
  keep the original. This is the final safety net. Better to waste tokens than create
  a misunderstanding that causes wrong behavior.
- **Pass order** (preserve scan → remove → transform → ambiguity check) — Scanning for
  preserved content first prevents accidental removal. The ambiguity check at the end
  catches any meaning drift introduced by transforms.
- **Abbreviation discipline** (one per concept per file, standard or introduced once in
  full) — Prevents abbreviation collisions and ensures a reader encountering an
  abbreviation can find its expansion nearby.
- **Contractions at all tiers** (don't, mustn't, won't over expanded multi-word forms) —
  "Don't" is 1 BPE token vs "Do not" at 2 tokens. Contractions carry identical meaning
  with lower cost. Applies to Lite, Full, and Ultra. "Cannot" is preferred over "can't"
  for two reasons: (1) it's a single word typically 1 token in common BPE tokenizers — the apostrophe in
  "can't" might split on some tokenizers, and (2) "cannot" carries stronger imperative
  weight in English — "you cannot do this" is a prohibition/command, while "can't" reads
  as a softer capability statement. In normative contexts (constraints, rules, skill
  directives), "cannot" is semantically more precise.
  
  **Normative strength hierarchy:** "must not" / "mustn't" is the strongest prohibition —
  spec-like, expressing a hard requirement ("this must not break"). "Cannot" is a strong
  imperative command. "Can't" / "shouldn't" are softer, conveying capability or suggestion.
  Unlike cannot→can't, the contraction "mustn't" preserves the full normative weight of
  "must not" — both are equally spec-like. Prefer "mustn't" freely; prefer "cannot" over
  "can't" in normative contexts.

## Integration Points

The compression skill is invoked by:

1. **Compression dispatch** (`compress.spec.md` + `instructions.txt`) — the
   primary consumer. Enforces gates, applies the skill, reports results.
2. **Dispatch agents** — invoked via this skill's `instructions.txt` during
   the audit → compress → re-audit cycle.
3. **File audit skill** (`auditing/file-audit/`) — dispatches compression
   via this skill when a target needs to be reduced.
4. **Copilot caveman-compress** (`cortex.lan/.github/skills/caveman-compress/`) —
   Copilot-specific wrapper that references this as the canonical source.

## Example — Before and After

Before compression (original prose):
> You should always make sure to run the test suite before pushing any changes
> to the main branch. This is important because it helps catch bugs early and
> prevents broken builds from being deployed to production.

After Ultra compression:
> Run tests before push to main. Catches bugs early, prevents broken prod deploys.

Removed: "You should always make sure to" (imperative softener), "This is
important because" (connective fluff), "any changes to the" (articles + padding),
"from being deployed to" (wordier than needed).

Preserved: "test suite" → "tests" (acceptable synonym), "main branch" → "main"
(context makes "branch" implicit), all technical meaning intact.

## One Example Per Pattern

The skill limits Transform to "one example per pattern." Multiple examples
consume tokens without adding instruction value — an LLM grasps the pattern
from a single instance. Additional examples belong in the spec (like the one
above), not in the lean skill file.

## Operating Modes

The compression skill supports three operating modes based on the caller's
intent and the file's git tracking state.

### Mode 1: Source→Target (`--source X --target Y`)

Read the source file, compress it, write to the target path. The source file
is never modified. No git status check is required — the caller explicitly
controls input and output. This is the primary workflow for skill development:

- `uncompressed.md` → `SKILL.md`
- `instructions.uncompressed.md` → `instructions.txt`

**Rationale:** Separating source and target eliminates friction from git guards.
The uncompressed file is the authoritative source; the compressed file is a
derived artifact that can always be regenerated.

### Mode 2: In-place (default, tracked+clean)

Compress the file directly. Requires the file to be tracked by git with no
uncommitted changes (`git status --porcelain` returns empty,
or the first character is `M` and the second character is a
space — meaning staged only, working tree clean).
This is the original behavior and remains the default when no `--source` or
`--target` flags are provided.

### Mode 3: Fallback (untracked/dirty)

When no `--source`/`--target` is provided and the file is untracked or has
uncommitted changes, create a `<filename>.compressed` version alongside it.
The original file is never modified. This prevents accidental overwrites of
work-in-progress files.

**Decision tree:**
1. `--source` + `--target` provided → Mode 1 (no git check)
2. No flags, file tracked+clean → Mode 2 (in-place)
3. No flags, file untracked/dirty → Mode 3 (alongside)

## Future Considerations

- Help topics in TMCP: `compression` (overview), `compression/lite`,
  `compression/full`, `compression/ultra` — derived from this skill and the
  tier system. Part of the guide spec implementation.
- Publishing to electrified cortex as a reusable community skill.
- Automated compression pipeline: commit hook that flags files over a size
  threshold and suggests compression.

Credit: Inspired by [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) (MIT).
