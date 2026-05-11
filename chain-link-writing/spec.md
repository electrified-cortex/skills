# chain-link-writing — Specification

## Purpose

Define the contract for a chain-link SKILL: a SKILL that participates in a
multi-step workflow chain (e.g. `engineering/investigate` →
`engineering/implement/plan` → `engineering/implement/execute` → …). This skill
guides an author to write or refactor a chain-link SKILL so that:

1. The SKILL body stays maximum-compressed (procedure + evaluation rules only).
2. The chain-orchestration concerns (inputs from previous link, outputs to
   next, terminus/first-link, dispatch-vs-inline, model tier, audit events)
   live in the chain manifest, not in the SKILL body.
3. The chain-link-auditing skill can verify the SKILL against the manifest
   mechanically.

This skill **inherits** from `skill-writing`. A chain-link IS a SKILL, just one
with extra contract obligations. Read `skill-writing` first; everything in it
still applies. This skill adds the chain-specific layer on top: chain manifest,
inputs/outputs alignment with neighbouring links, mode declaration,
terminus/first-link constraints. Companion is `chain-link-auditing`
(verification).

## Scope

Applies when authoring or refactoring any SKILL that is one link in a chain.
Covers: chain manifest format, per-link metadata, SKILL-body permitted content,
and the boundary between chain orchestration (manifest) and link execution
(SKILL).

Does not cover: general SKILL hygiene (see `skill-writing`), spec authoring
(see `spec-writing`), or chain construction strategy (see `chain-builder` when
authored).

## Definitions

- **Chain**: An ordered, named sequence of links that implements a workflow.
  Identified by the directory that contains the chain manifest (e.g.
  `workflows/engineering/`).
- **Link**: A single step in a chain. Implemented as a chain-link SKILL in its
  own subdirectory (e.g. `workflows/engineering/investigate/`).
- **Chain manifest**: A Markdown file named `chain.md` at the chain root.
  Declares every link with its contract metadata. Single source of truth for
  chain orchestration. Required.
- **Chain-link SKILL**: A SKILL whose folder appears as a link row in a chain
  manifest. May be inline or dispatch. MUST satisfy R-CLW-3 through R-CLW-7.
- **First link**: The first row in the manifest. Has no `prev` and is the
  entry point invoked when the chain runs.
- **Terminus link**: A link whose row has empty `next-pass` and `next-fail`
  fields. Returns control to the chain's caller (Foreman, Worker pod, etc.)
  with the final outcome.
- **Linear link**: A link with exactly one `next-pass`. Non-PASS outcomes route
  per the routing table on the manifest row.
- **Branching link**: A link whose `next-pass` and `next-fail` (and/or
  `next-blocked`) point to different downstream links.
- **Inline link**: The SKILL runs in the executing agent's context. No
  sub-agent dispatched for the work; sub-agents only optional for parts of the
  procedure.
- **Dispatch link**: The SKILL runs entirely in a dispatched sub-agent
  (typically with `instructions.txt`). The executing agent stays at the
  routing layer.
- **Chain orchestration**: The act of moving from one link to the next based
  on outcome. Lives in the manifest; never in the SKILL body.
- **Link execution**: The act of doing the link's work. Lives in the SKILL
  body; never in the manifest.

## Chain Manifest Format

A chain manifest is a Markdown file at the chain root. Required sections in
order:

### Section 1 — Header

```
# <Chain Name> chain

<one-sentence purpose>
```

### Section 2 — Links table

Required columns (left to right):

| `id` | `link` | `mode` | `tier` | `prev` | `next-pass` | `next-fail` | `next-blocked` | `outputs` |

- `id`: short kebab identifier; unique within the manifest.
- `link`: repo-relative path to the link folder (e.g. `investigate`,
  `implement/plan`).
- `mode`: `inline` or `dispatch`.
- `tier`: model class — `fast-cheap` (haiku-class), `standard` (sonnet-class),
  or `deep` (opus-class). For dispatch links the sub-agent tier; for inline
  links the minimum executing-agent tier.
- `prev`: link id of the previous link, or `—` for the first link.
- `next-pass`: link id invoked on PASS outcome; or `—` for terminus.
- `next-fail`: link id invoked on FAIL outcome; or `—` if FAIL exits the
  chain.
- `next-blocked`: link id on BLOCKED outcome; or `—` to exit the chain.
- `outputs`: comma-separated names of values the link writes for downstream
  consumption (e.g. `findings_path`, `plan_path`, `report_path`).

Optional columns: `notes`, `tags`.

### Section 3 — Acceptance

A short paragraph stating what "the chain ran to completion" means for this
chain. Used by chain-link-auditing to verify each link's outputs are consumed
downstream and the chain has a defined terminus.

## Requirements

### R-CLW-1 — Chain manifest is mandatory and authoritative

Every chain MUST have a `chain.md` at the chain root. The manifest is the
single source of truth for chain orchestration. Authoring or refactoring any
link MUST start by reading the manifest. If the manifest does not exist, the
author MUST create it before writing the link SKILL.

### R-CLW-2 — One link per directory

Each link MUST live in its own directory immediately under (or in a stable
sub-path of) the chain root. The directory name MUST equal the link's `id`
column in the manifest. Multiple SKILLs in one link directory are prohibited.

### R-CLW-3 — SKILL body content boundary

A chain-link SKILL.md MUST NOT contain:

- Chain orchestration metadata (the next-link decisions, `prev`/`next` lists,
  manifest-style routing tables). These live in `chain.md`.
- Spec-level rationale, narrative prose, or background discussion. These live
  in `spec.md`.
- Stack-specific assumptions (file extensions, language idioms, framework
  names) unless the chain is itself stack-specific and the chain manifest
  declares this.
- Duplicate restatements of cross-skill conventions (dispatch mechanics,
  markdown-hygiene, hash-record semantics). Reference the sibling skill by
  name instead.

A chain-link SKILL.md MAY contain:

- Inputs (the values the link consumes; names MUST match what an upstream
  link's `outputs` column declares).
- Procedure (the steps the link performs).
- Evaluation rules (how the link decides PASS / FAIL / BLOCKED).
- Output contract (the values the link emits; names MUST match the link's own
  `outputs` column in the manifest).
- Constraints local to this link's execution.
- Related skills (the dispatch skill, hash-record, etc.).

### R-CLW-4 — Outputs match manifest

Every value name the SKILL declares it emits MUST appear in the link's
`outputs` column in the chain manifest, and vice versa. A SKILL that emits an
undeclared value or omits a declared one is a chain-contract violation.

### R-CLW-5 — Inputs match upstream outputs

Every value name the SKILL declares it consumes MUST be either:

- A value listed in the `outputs` column of any upstream link (chain-internal
  baton), OR
- A value declared as a chain entry-point input in the manifest's Acceptance
  paragraph (chain-external baton).

A SKILL that consumes a value that no upstream link produces is a
chain-contract violation.

### R-CLW-6 — Mode declaration consistency

If the manifest says `mode: dispatch`, the link directory MUST contain
`instructions.txt` and the SKILL MUST follow the dispatch routing-card pattern
(per `skill-writing` Dispatch Skill section). If the manifest says
`mode: inline`, the link directory MUST NOT contain `instructions.txt`.

### R-CLW-7 — Terminus and first-link constraints

The manifest MUST have exactly one row with `prev: —` (the first link). The
manifest MUST have at least one row with `next-pass: —` (a terminus). A row
that is both first AND terminus is permitted only for one-link chains.

### R-CLW-8 — SKILL body brevity target

A chain-link SKILL body is short by design. Pie-in-sky target: the SKILL
describes the link's work in **one sentence to one paragraph**, because every
other concern (inputs, outputs, mode, neighbours, tier) lives in the chain
manifest and the chain-link-auditing checklist.

Working budgets:

- Pure-dispatch link: SKILL is a routing card; aim ≤ 40 lines. The work lives
  in `instructions.txt`; the SKILL is mostly the dispatch invocation.
- Pure-inline link with no internal loop: aim ≤ 60 lines.
- Inline link with a cap-N internal audit/iterate loop: aim ≤ 100 lines.

Any chain-link SKILL over 120 lines is presumptively bloated. Justify or trim.

Hard line-count limits live in `chain-link-auditing` findings; this is
authoring guidance.

### R-CLW-9 — Hash-record is permitted, not required

A chain-link SKILL MAY use the hash-record skill for cache hits when the link
is re-runnable against unchanged inputs. The manifest MAY note this in `tags`
(e.g. `cacheable`). Hash-record usage is at the author's discretion; it is
not a chain-contract concern.

### R-CLW-10 — Repo-relative paths

All paths referenced in the SKILL body, manifest, and any persisted artifact
MUST be repo-relative. No drive letters, no usernames.

## Authoring Workflow

A chain-link SKILL is a SKILL plus a chain contract. Inherit the
`skill-writing` workflow; add the chain steps around it.

1. **Read `skill-writing`.** Everything in it still applies.
2. **Read or create `chain.md` at the chain root.** Confirm the link's row
   exists and the contract (mode, tier, prev, next-pass, next-fail,
   next-blocked, outputs) is filled in. If creating, follow the manifest
   format above.
3. **Write `spec.md`** for the link via `spec-writing`. The spec carries the
   normative requirements and the chain-contract restated for the audit
   surface.
4. **Write `uncompressed.md`** for the link via `skill-writing` (and
   `instructions.uncompressed.md` if dispatch). Limit SKILL content per
   R-CLW-3; hit the brevity target in R-CLW-8.
5. **Run `chain-link-auditing`** on the link folder. Findings MUST PASS
   before the next step.
6. **Run `skill-auditing`** on the link folder (general SKILL hygiene).
   Findings MUST PASS before shipping.
7. **Compress** uncompressed sources to `SKILL.md` (and `instructions.txt`
   if dispatch) via the `compression` skill.

Order matters: chain-link-auditing runs BEFORE skill-auditing. If the
chain contract is wrong, general hygiene is moot — fix the contract first.

For pure-dispatch links, the workflow is largely mechanical: chain manifest
declares the link, `instructions.txt` carries the work, SKILL is a tiny
routing card. Don't over-engineer.

## Constraints

- **C1** — Manifest is single source of truth. Chain orchestration in the
  SKILL body is a contract violation.
- **C2** — SKILL body stays maximum-compressed. Bloat reasons that belong in
  spec.md belong in spec.md.
- **C3** — Author chain-link-auditing PASS before skill-auditing.
- **C4** — One link per directory. Multiple link SKILLs in one directory is
  prohibited.
- **C5** — Stack-specific assumptions belong only in stack-specific chains.

## Don'ts

- Do not duplicate manifest content in the SKILL body.
- Do not leave the chain manifest absent or stale.
- Do not declare outputs in SKILL that the manifest does not list.
- Do not declare inputs in SKILL that no upstream link produces.
- Do not include `instructions.txt` in an inline link, or omit it from a
  dispatch link.
- Do not bake stack-specific file extensions or language idioms into a
  general-purpose chain link.

## Related

- `skill-writing` — general SKILL hygiene; follow after chain-link-writing
  for any SKILL.
- `spec-writing` — author the link's spec.md normative requirements.
- `chain-link-auditing` — verify the SKILL matches the manifest contract.
- `skill-auditing` — verify general SKILL hygiene (frontmatter, brevity,
  triggers, etc.).
- `compression` — compress uncompressed sources to runtime SKILL.md.
- `dispatch` — dispatch mechanics for `mode: dispatch` links.
