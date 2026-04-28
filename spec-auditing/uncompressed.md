---
name: spec-auditing
description: >-
  Audit a spec/companion pair or a spec alone for alignment and completeness.
  Triggers — spec validation, requirements coverage, contradiction detection,
  document alignment, specification quality.
---

# Spec Auditing

Without reading `instructions.txt` yourself, spawn a zero-context, claude-haiku-class sub-agent in the background:

Claude Code: `Agent` tool. Pass: `"Read and follow instructions.txt (in this directory). Input: <target-path> [--spec <spec-path>] [--fix]"`

VS Code / Copilot: `runSubagent(model: "Claude Haiku 4.5", prompt: "Read and follow instructions.txt (in this directory). Input: <target-path> [--spec <spec-path>] [--fix]")`

Don't read `instructions.txt` yourself.

Parameters:

- `target-path` (string, required): path to spec file or companion file to audit
- `--spec <spec-path>` (string, optional): explicit path to spec file (pair-audit mode)
- `--fix` (flag, optional): fix mode — target must be git-tracked and clean; modifies target to match spec, up to 3 passes

Returns: Pass / Pass with Findings / Fail. Each finding: Finding ID, Severity, Title, Affected file(s), Evidence (with quote), Explanation, Recommended fix.

NEVER READ OR INTERPRET `instructions.txt` YOURSELF. Let the sub-agent do the work.

One skill per invocation. Chain multiple subjects as separate runs.

## Iteration Safety

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.
