# Stamp Auditing — Spec

Normative spec for the stamp-auditing skill. Verifies SHA-256 stamp integrity across a skill tree or any directory.

## Purpose

Every non-trivial artifact in the skill library carries a `.sha256` companion recording the expected hash at a known-good state. Over time files drift: edits happen without restamping, or stamps get regenerated against the wrong version. This skill surfaces those mismatches before they become silent bugs.

## Stamp Format

Standard sha256sum format: `{64-hex-chars}  {filename}` (two spaces, filename only — no path, no BOM, no trailing newline). Companion file is co-located in the same directory as the `.sha256` file.

## Requirements

R1. The skill must accept a `root` parameter (required): absolute path to the directory tree to audit.

R2. The skill must find all `.sha256` files under `root` recursively.

R3. For each `.sha256` file the skill must:
   a. Parse the stored hash and filename from content.
   b. Resolve the companion path: same directory as the `.sha256` file, filename from content.
   c. If companion missing → `MISSING`.
   d. Compute SHA-256 of the companion file.
   e. Compare computed hash to stored hash. Match → `PASS`. Mismatch → `FAIL`.

R4. `.sha256` files whose content does not match the two-space format → `MALFORMED`.

R5. The skill must support `--git-only` mode: limit scope to `.sha256` companions whose companion file appears in `git diff --name-only HEAD` or `git ls-files --others --exclude-standard` under `root`. Files not listed by git are skipped.

R6. Output must be a table: relative path (from root) | status | notes. FAIL rows include stored vs computed hash truncated to 8 chars each.

R7. Output must end with a summary line: `{N} checked | {P} PASS | {F} FAIL | {M} MISSING` (append `| {X} MALFORMED` when non-zero).

R8. Exit non-zero if any FAIL, MISSING, or MALFORMED; zero if all PASS.

## Constraints

- Read-only skill. Must not modify any file, write any stamp, or create any artifact.
- Must not attempt to repair mismatches — reporting only.
