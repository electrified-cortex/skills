# markdown-hygiene

Fix markdownlint violations in `.md` files. Dispatch this skill before
compressing or committing markdown to ensure clean, lint-passing output.

## When to Use

- Before running the `compression` skill on a markdown file
- Before committing new or edited `.md` files
- When a linter reports markdownlint violations in CI
- As a final pass after `skill-writing` or `spec-writing` produces new content

It runs as a separate agent — provide a file path and it handles the full read-fix-verify cycle.

## What It Does

The skill reads the target file, identifies markdownlint rule violations, and
applies fixes. It returns one of three outcomes:

| Result | Meaning |
| --- | --- |
| `CLEAN` | No violations found; file unchanged |
| `FIXED` | All violations resolved |
| `PARTIAL` | Some violations fixed; manual review needed for remainder |

Common rules enforced: heading levels, trailing spaces, blank lines around
headings and fences, list indentation, line length, link formatting.

## Usage

Invoke with the target file path:

```
Read and follow markdown-hygiene/SKILL.md for: path/to/file.md
```

The skill handles detection and fixing autonomously. Provide the path — it reads,
fixes, and verifies without needing the file content passed in advance.

## Notes

- The skill is read/fix mode by default; it edits the file in place
- Large files with many violations may return `PARTIAL`; re-dispatch to continue
- Do not run hygiene on compressed ultra-tier files — compression intentionally
  breaks some markdown conventions

## Related Skills

- [`compression`](../compression/) — compress after hygiene passes
- [`skill-auditing`](../skill-auditing/) — audit checks hygiene as part of quality review
- [`spec-writing`](../spec-writing/) — produces spec files that should pass hygiene
- [`skill-writing`](../skill-writing/) — produces skill files that should pass hygiene

## Standards

This skill follows the [Agent Skills](https://agentskills.io) open standard.

## License

MIT — see [LICENSE](../LICENSE) in the repository root.
