---
name: skill-writing
description: >-
  How to write skills — decision tree for inline vs dispatch, structure,
  quality criteria.
---

# Skill Writing

Create skills agents can discover, invoke, rely on.
Never reference `spec.md` at runtime. Minimize tokens.

## Workflow

When creating a new skill, follow this order. Never skip steps.

1. **Spec first** — write `spec.md` using the `spec-writing` skill. The
   spec defines what the skill does, its requirements, constraints, and
   acceptance criteria.
2. **Write uncompressed** — write `uncompressed.md` derived from the
   spec. This is the human-readable baseline.
3. **Markdown hygiene** — run the `markdown-hygiene` skill on
   `uncompressed.md`. Zero errors required before proceeding.
4. **Compress** — use the `compression` skill (source→target mode:
   `--source uncompressed.md --target SKILL.md`). The SKILL.md is the
   compressed runtime agents load.
5. **Audit** — use the `skill-auditing` skill to verify. Fix findings,
   recompress, re-audit until PASS.

For dispatch skills, also write the companion instruction source file (see
Dispatch Skill section).

When revising an existing skill: always update the spec first. The only
exception is changes limited to non-normative content (README, examples,
typo fixes in informational sections) — in that case skip to step 2.
Then update `uncompressed.md` → hygiene → recompress → re-audit. Never modify
SKILL.md directly — it is a compiled artifact.

## Decision: Inline or Dispatch?

> "Could someone with no context do this from just the inputs?"
> **Yes** → dispatch. **No** → inline.

**Inline** = needs caller's context, judgment, creative intent. Inline skills don't need to understand dispatch mechanics.
**Dispatch** = mechanical processing against rules. Use Dispatch agent (zero context).

This skill decides *whether* a skill dispatches and *how to structure it*. For dispatch mechanics (decision tree, model tiers, prompt construction, footguns) read the `dispatch` skill.

## Skill Folder Convention

```text
skill-name/
├── SKILL.md            ← compressed runtime (what agents load)
├── instructions.txt    ← dispatch procedure (dispatch skills only)
├── uncompressed.md     ← human-readable baseline
└── spec.md             ← normative spec (never at runtime)
```

`instructions.txt` present = dispatch skill. Absent = inline.

## Inline Skill

SKILL.md IS the full instruction set. Agent reads and applies directly.

## Dispatch Skill (Routing Card)

SKILL.md = ~10-15 line routing card. `instructions.txt` holds procedure.

Dispatch via Dispatch agent: "Read and follow `instructions.txt`.
Input: `<params>`"

Parameters: types, required/optional, defaults. Output format specified.

Routing card = invocation signature + output format. Stop gates (refusal
conditions, git-clean checks, path escape guards, eligibility rules) belong in
`instructions.txt` only — not the routing card. The dispatched agent enforces
them; the host doesn't need to know them before dispatch.

Do not rely on repo-local fallback filenames — those belong in skill-specific
auditors, not in universal spec-auditing rules.

Dispatch instruction file must be in the same directory or a known path.
Compressed `instructions.txt` contains only instructions — no title
headers, no descriptions, no preamble. The uncompressed baseline
`instructions.uncompressed.md` MAY include an H1 title so markdown-hygiene
passes (MD041); strip the title after compression.

## Requirements

### Naming

- Skill directory name = kebab-case and **equal to the `name` frontmatter
  field**. Discovery matches folder name to frontmatter name; a mismatch
  makes the skill unreachable.
- **Nested sub-skills** under a parent skill folder must use
  fully-qualified names that include the parent as a prefix. Example:
  under `electrified-cortex/skill-index/`, children are
  `skill-index-auditing/`, `skill-index-building/` — not bare
  `auditing/`, `building/`. Canonical reference: `electrified-cortex/gh-cli/`
  (`gh-cli-actions`, `gh-cli-api`, etc.). Bare unqualified names inside a
  parent folder do not resolve.
- Never use "SKILL" in any filename except `SKILL.md`.

### Content

- Frontmatter: `name` + `description`
- Self-contained: no spec dependency at runtime
- Concise: agent-facing, every line earns its place
- Token-efficient: no prose, no rationale, no redundancy
- No "why": rationale belongs in `spec.md`; skills state *what*, not *why*
- Decision trees not prose: conditional logic uses tables or decision trees, not paragraphs
- Breadcrumbs: end with related skills (verified, not stale)
- No secrets

Verify completed skills with `skill-auditing`. The audit flags any
markdown issues.

## Footgun Mirroring

If the companion spec has a `Footguns` section, mirror it in uncompressed.md/SKILL.md:

- Preserve all F#: entries, Mitigation: lines, and any ANTI-PATTERN: examples
- Canonical reference: `dispatch` skill

## Related

- `spec-writing` — write the spec first (step 1 of workflow)
- `compression` — compress uncompressed.md to SKILL.md (step 3)
- `skill-auditing` — verify skill quality (step 4, dispatch)
- `dispatch` — dispatch mechanics (decision tree, model tiers, prompt construction); read before writing any dispatch skill
