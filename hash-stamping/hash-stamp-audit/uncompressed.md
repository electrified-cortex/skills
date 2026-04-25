---
name: hash-stamp-audit
description: >-
  Read-only skill. Verifies SHA-256 stamp integrity across a skill tree. Finds all .sha256
  companion files and checks each against the current hash of its target.
  Trigger: stamp verification, hash mismatch detection, companion file audit, stamp drift check,
  integrity check, sha256 validation.
---

# Stamp Auditing

Read-only skill. Verifies that every `.sha256` companion file in a directory tree matches the current hash of its target file.

## Invocation

Without reading `instructions.txt` yourself, use a Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory). Input: `root=<path> [--git-only]`"

Parameters:

- `root` (required): absolute path to the directory tree to audit.
- `--git-only` (optional): only check companions of files git reports as modified or untracked under `root`. Skips all others.

## Output

Table of relative path | PASS / FAIL / MISSING / MALFORMED, with FAIL rows showing stored vs computed hash (8-char prefix each).

Summary line: `{N} checked | {P} PASS | {F} FAIL | {M} MISSING` (MALFORMED appended when non-zero).

Non-zero exit if any FAIL, MISSING, or MALFORMED.
