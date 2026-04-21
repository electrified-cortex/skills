# skill-auditing

Audit a skill for quality, classification, cost-efficiency, and spec compliance.
Dispatch this skill after writing or modifying a skill to validate it before sign-off.

## When to Use

- After `skill-writing` produces a new skill
- After editing an existing skill's `SKILL.md`
- When a skill has failed in production and needs review
- As part of the standard skill release pipeline

The auditor runs as a separate agent — call it with a skill path and it returns a verdict.

## What It Does

The audit runs in three phases:

1. **Classification check** — verifies skill type (dispatch vs inline), tool
   declarations, and subagent usage match the intended pattern
2. **Quality review** — checks clarity, completeness, actionability, and absence
   of bloat or contradictions
3. **Spec compliance** — cross-references the skill against its `.spec.md`
   companion; flags missing requirements or mismatches

Two modes:

- **Audit** (default) — read-only; reports issues without making changes.
- **Fix** (`--fix`) — single-pass repair of the skill's authoritative source
  files (`uncompressed.md` and `instructions.uncompressed.md`, siblings of the
  audited `SKILL.md`). Runs only on a NEEDS_REVISION verdict. Refuses to write
  to any candidate with pending git changes (untracked, unstaged, staged, or
  merge-conflicted) or any path that escapes the skill directory. The companion
  `spec.md`, the `README.md`, and the compiled runtime files (`SKILL.md`,
  `instructions.txt`) are never modified — the caller recompresses via the
  `compression` skill and re-runs the auditor for verification. This preserves
  the repo's source-of-truth chain (`spec.md` → `uncompressed.md` → `SKILL.md`).

Returns one of three verdicts:

| Result | Meaning |
| --- | --- |
| `PASS` | Skill meets all quality and compliance criteria |
| `NEEDS_REVISION` | Specific issues found; skill should be revised and re-audited |
| `FAIL` | Fundamental problems; skill requires significant rework |

## Usage

Call the auditor with the skill path:

```
Read and follow skill-auditing/SKILL.md for: path/to/skill/SKILL.md
```

Add `--fix` to apply repairs automatically (subject to the git-clean
precondition above).

## Related Skills

- [`skill-writing`](../skill-writing/) — the skill-writing guide this audits against
- [`spec-auditing`](../spec-auditing/) — audits the spec companion separately
- [`compression`](../compression/) — compress after audit passes

## Standards

This skill follows the [Agent Skills](https://agentskills.io) open standard.

## License

MIT — see [LICENSE](../LICENSE) in the repository root.
