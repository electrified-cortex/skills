# skill-writing

> Non-normative. For orientation only. The authoritative requirements are in `spec.md`.

Guide for writing new skills. Use this when authoring or editing a skill — it
describes conventions, workflow, and classification rules.

## When to Use

- Starting a new skill from scratch
- Restructuring an existing skill that has grown inconsistent
- Learning the skill authorship conventions used in this repo

## Workflow

Four steps, in order. No step may be skipped.

1. **Spec** — write `spec.md` using the `spec-writing` skill. Captures
   requirements, constraints, and acceptance criteria.
2. **Uncompressed draft** — write `uncompressed.md` derived from the spec.
   This is the human-readable baseline. `uncompressed.md` is the draft;
   `SKILL.md` is the compiled output (not the draft).
3. **Compress** — run the `compression` skill (`--source uncompressed.md
   --target SKILL.md`) to produce the compressed runtime file agents load.
4. **Audit** — run `skill-auditing` to validate quality and spec compliance.
   Fix findings, recompress, re-audit until PASS.

## Key Conventions

- Every skill folder contains `SKILL.md` (runtime), `uncompressed.md`
  (baseline), and `spec.md` (normative spec — required for dispatch and
  complex inline skills)
- Dispatch skills use a routing card `SKILL.md` (~10–15 lines) plus a
  separate instruction file (`instructions.txt` or `<name>.md`)
- Inline skills load into the caller's context; dispatch skills spawn an
  isolated agent
- Specs are never compressed — they preserve the full reasoning record
- Nested sub-skills use fully-qualified names with the parent as a prefix
  (e.g., `skill-index-auditing/`, not `auditing/`)

## Related Skills

- [`spec-writing`](../spec-writing/) — write the spec first (step 1)
- [`compression`](../compression/) — compress uncompressed.md to SKILL.md (step 3)
- [`skill-auditing`](../skill-auditing/) — audit the finished skill (step 4)
- [`markdown-hygiene`](../markdown-hygiene/) — clean up lint violations before auditing

## License

MIT — see [LICENSE](../LICENSE) in the repository root.
