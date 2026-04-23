---
name: skill-writing
description: >-
  How to write skills — decision tree for inline vs dispatch, structure,
  quality criteria.
---

# Skill Writing

Create skills agents can discover, invoke, rely on.
Never reference `spec.md` at runtime. Minimize tokens.

Workflow:

New skill — follow order. Never skip steps.

1. Spec first — write `spec.md` via `spec-writing`. Defines requirements, constraints, acceptance criteria.
2. Write `uncompressed.md` from spec. Human-readable baseline.
3. Markdown hygiene — run `markdown-hygiene` skill on `uncompressed.md`. Zero errors required before proceeding.
4. Intermediate audit — dispatch `skill-auditing --uncompressed` on the skill. FAIL → fix → re-audit until PASS. Never compress a failing `uncompressed.md`.
5. Compress via `compression` skill (`--source uncompressed.md --target SKILL.md`). SKILL.md = compressed runtime.
6. Final audit via `skill-auditing` (standard mode) on `SKILL.md`. FAIL → fix source → recompress → re-audit until PASS.

Dispatch skills: also write companion instruction source file (see Dispatch Skill).

Completion Gate:
NOT done until both audits return PASS. Intermediate gate (step 4): PASS required before compression. Final gate (step 6): PASS required before declaring complete. No exceptions. Receiving FAIL and stopping is a workflow violation.

Revising: update spec first. Exception: non-normative changes (README, examples, typo fixes) → skip to step 2. Update `uncompressed.md` → hygiene → intermediate audit (`--uncompressed`) → compress → final audit. Never modify SKILL.md directly — compiled artifact.

Decision: Inline or Dispatch?

"Could someone with no context do this from just inputs?" Yes → dispatch. No → inline.

Inline = needs caller's context, judgment, creative intent. Inline skills don't need dispatch mechanics.
Dispatch = mechanical processing against rules. Use Dispatch agent (zero context).
This skill: decides whether a skill dispatches + how to structure it. Dispatch mechanics (decision tree, model tiers, prompt construction, footguns) → read the `dispatch` skill.

Skill Folder Convention:

```text
skill-name/
├── SKILL.md            ← compressed runtime (what agents load)
├── instructions.txt    ← dispatch procedure (dispatch skills only)
├── uncompressed.md     ← human-readable baseline
└── spec.md             ← normative spec (never at runtime)
```

`instructions.txt` present = dispatch skill. Absent = inline.

Inline Skill:

SKILL.md IS the full instruction set. Agent reads and applies directly.

Dispatch Skill (Routing Card):

SKILL.md = minimal routing card. `instructions.txt` holds procedure.
Dispatch via Dispatch agent: "Read and follow `instructions.txt`. Input: `<params>`"
Parameters: types, required/optional, defaults. Output format specified.

Dispatch-time constraints caller must know before invocation go in routing card (`uncompressed.md` / `SKILL.md`), not only `instructions.txt`. Examples: required model tier for `--fix`, required tool class, refusal conditions. `instructions.txt` may enforce defensively — secondary.

Don't rely on repo-local fallback filenames — those belong in skill-specific auditors, not universal spec-auditing rules.

Dispatch instruction file must be in same dir or known path.
Compressed `instructions.txt`: only instructions — no title headers, no descriptions, no preamble. `instructions.uncompressed.md` MAY include H1 title for markdown-hygiene (MD041); strip after compression.

Requirements:

Naming:

Dir name = kebab-case, equal to `name` frontmatter. Mismatch → skill unreachable.
Nested sub-skills must use fully-qualified names including parent prefix. Example: under `electrified-cortex/skill-index/`, children are `skill-index-auditing/`, `skill-index-building/` — not bare `auditing/`, `building/`. Ref: `electrified-cortex/gh-cli/` (`gh-cli-actions`, `gh-cli-api`). Bare unqualified names don't resolve.
Never use "SKILL" in any filename except `SKILL.md`.

Content:

Frontmatter: `name` + `description`
Self-contained: no spec dependency at runtime
Concise: agent-facing, every line earns place
Token-efficient: no prose, no rationale, no redundancy
Breadcrumbs: end with related skills (verified, not stale)
No secrets

Verify with `skill-auditing`. Flags markdown issues.

Footgun Mirroring:

If companion spec has `Footguns` section, mirror it in `uncompressed.md`/`SKILL.md`:
Preserve all F#: entries, Mitigation: lines, ANTI-PATTERN: examples.
Canonical ref: `dispatch` skill.

Related:

`spec-writing` — write spec first (step 1)
`compression` — compress `uncompressed.md` → SKILL.md (step 4)
`skill-auditing` — verify quality (step 5, dispatch)
`dispatch` — dispatch mechanics; read before writing any dispatch skill
