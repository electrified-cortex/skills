# spec-auditing

Audit spec and companion file pairs for alignment, coverage, and contradictions.
Dispatch this skill when a spec or its paired skill has been modified.

## When to Use

- After editing a `.spec.md` to verify it still aligns with its `SKILL.md`
- After editing a `SKILL.md` to verify the spec still covers the new behavior
- When a skill audit (`skill-auditing`) flags a spec compliance issue
- As part of the release pipeline before sign-off

It runs as a separate agent — provide a spec file path and it returns a verdict with any issues found.

## What It Does

The audit operates in two modes:

**Read-only mode** — reports issues without making changes:

- Missing requirements (in spec but not in skill, or vice versa)
- Contradictions between spec and skill
- Spec language that is too vague to be testable

**Fix mode** — attempts to resolve issues automatically (up to 3 passes):

- Adds missing content to the appropriate file
- Flags contradictions that require human judgment
- Re-audits after each fix pass

Returns one of three outcomes:

| Result | Meaning |
| --- | --- |
| `ALIGNED` | Spec and skill are consistent and complete |
| `NEEDS_REVISION` | Issues found; specific items flagged for correction |
| `FAIL` | Fundamental misalignment; manual review required |

## Usage

Invoke with the spec file path:

```txt
Read and follow spec-auditing/SKILL.md for: path/to/skill/spec.md
```

The skill locates the companion `SKILL.md` automatically from the same directory.

## Related Skills

- [`spec-writing`](../spec-writing/) — guide for authoring the spec in the first place
- [`skill-auditing`](../skill-auditing/) — audits the skill independently
- [`compression`](../compression/) — skills compress; specs do not

## Standards

This skill follows the [Agent Skills](https://agentskills.io) open standard.

## License

MIT — see [LICENSE](../LICENSE) in the repository root.
