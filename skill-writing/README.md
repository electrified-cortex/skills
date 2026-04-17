# skill-writing

Guide for writing new skills. Use this as a reference when authoring or editing
a skill — it describes conventions, workflow, and classification rules.

## When to Use

- Starting a new skill from scratch
- Restructuring an existing skill that has grown inconsistent
- Learning the skill authorship conventions used in this repo

## Workflow

The guide defines a five-stage pipeline:

1. **Spec** — write the `.spec.md` companion first; it captures rationale,
   design decisions, and requirements in full natural language
2. **Uncompressed draft** — write `SKILL.md` in normal prose, following the
   classification rules (dispatch vs inline, tool declarations, etc.)
3. **Compress** — run the `compression` skill at the appropriate tier
4. **Audit** — run `skill-auditing` to validate quality and spec compliance
5. **Sign-off** — resolve all `NEEDS_REVISION` or `FAIL` verdicts, then tag
   the skill as ready

## Key Conventions

- Every skill has a `SKILL.md` and a `.spec.md` in the same folder
- Dispatch skills declare the tools their subagents will use
- Inline skills are loaded into the caller's context; they do not spawn subagents
- Specs are never compressed — they preserve the full reasoning record
- Skill content is compressed at `ultra` tier; human-facing content at `full` or `lite`

## Related Skills

- [`spec-writing`](../spec-writing/) — guide for writing the spec companion
- [`compression`](../compression/) — compress the finished skill
- [`skill-auditing`](../skill-auditing/) — audit the finished skill
- [`markdown-hygiene`](../markdown-hygiene/) — clean up lint violations before auditing

## Standards

This skill follows the [Agent Skills](https://agentskills.io) open standard.

## License

MIT — see [LICENSE](../LICENSE) in the repository root.
