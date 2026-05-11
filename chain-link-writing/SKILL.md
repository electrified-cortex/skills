---
name: chain-link-writing
description: Use when writing or refactoring a SKILL that participates in a chain (e.g. engineering/investigate, implement/plan, test/verify). Inherits from skill-writing. Adds the chain contract: manifest at chain root, inputs match upstream outputs, mode/tier/next-link declarations live in the manifest not the SKILL, brevity target one-sentence-to-one-paragraph. Triggers - write chain link, author chain skill, chain manifest, chain.md, refactor link to canon, chain-link contract, link inputs outputs, terminus link, first link, dispatch link, inline link.
---

A chain-link SKILL is a SKILL plus a chain contract. Inherit `skill-writing` first.

## Where the chain contract lives

`chain.md` at the chain root is the single source of truth. Required table columns: `id | link | mode | tier | prev | next-pass | next-fail | next-blocked | outputs`. Optional: `notes | tags`.

`tier` values: `fast-cheap` (haiku-class), `standard` (sonnet-class), `deep` (opus-class).

Exactly one row has `prev: —` (first link). At least one row has `next-pass: —` (terminus).

## SKILL body — what stays, what leaves

Stays in SKILL:
- inputs (names match what upstream link's `outputs` column declares)
- procedure (the work)
- evaluation (PASS / FAIL / BLOCKED rules)
- output contract (names match this link's `outputs` column in manifest)
- local constraints
- related skills

Leaves the SKILL (lives in `chain.md`):
- next-link decisions
- prev/next routing tables
- terminus/first declarations
- mode and tier declarations

## Brevity target

Pie-in-sky: SKILL describes the link in one sentence to one paragraph because everything else lives in the manifest.

Working budgets:
- pure-dispatch link: ≤ 40 lines (work lives in `instructions.txt`)
- pure-inline, no internal loop: ≤ 60 lines
- inline with cap-N audit/iterate loop: ≤ 100 lines

Over 120 lines = presumptively bloated. Justify or trim.

## Authoring workflow

1. Read `skill-writing`. Everything still applies.
2. Read or create `chain.md`. Confirm the link's row.
3. Write `spec.md` via `spec-writing`.
4. Write `uncompressed.md` (and `instructions.uncompressed.md` if dispatch).
5. Run `chain-link-auditing` — PASS before next step.
6. Run `skill-auditing` — PASS before shipping.
7. Compress to `SKILL.md` (+ `instructions.txt` if dispatch).

Chain-link-auditing FIRST, skill-auditing SECOND. Wrong contract makes hygiene moot.

## Contract rules (chain-link-auditing enforces)

- Outputs declared in SKILL MUST appear in the manifest `outputs` column for this link, and vice versa.
- Inputs the SKILL consumes MUST appear as outputs of some upstream link, OR as a chain entry-point input in the manifest's Acceptance paragraph.
- `mode: dispatch` link directory has `instructions.txt`; `mode: inline` does not.
- All paths repo-relative.
- Stack-specific assumptions (file extensions, language idioms) only in stack-specific chains; the chain manifest declares this.

## Related

`skill-writing` — read first; everything still applies
`chain-link-auditing` — verify the contract before skill-auditing
`spec-writing` — author link's spec.md
`skill-auditing` — general SKILL hygiene
`compression` — compress to runtime SKILL.md
`dispatch` — dispatch mechanics for `mode: dispatch` links
