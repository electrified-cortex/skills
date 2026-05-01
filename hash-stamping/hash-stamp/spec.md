# Hash Stamp — Stamp Spec

Normative spec for the stamp sub-skill. Writes or updates SHA-256 companion files alongside target files.

## Purpose

After editing a stamped file, its `.sha256` companion must be updated. This skill accepts a single file, a glob pattern, or a directory tree and writes/updates companions for all matching targets.

## Scope

Covers writing and updating `.sha256` companion files. Does not cover verifying stamps (see `audit/` sub-skill) or modifying the target files themselves.

## Definitions

- **Companion file**: a `.sha256` file co-located with the stamped target, containing a single `sha256sum`-format line.
- **Target**: a file (or files matching a glob/tree pattern) for which a companion is written or updated.
- **WRITTEN**: status for a new companion created where none existed.
- **UPDATED**: status for a companion overwritten because the stored hash differed from the current hash.
- **UNCHANGED**: status for a companion skipped because the stored hash matches the current hash.
- **ERROR**: status for any failure to read the target or write the companion.

## Requirements

R1. Accept one of: a single file path, a glob pattern, or `--tree <root>` for recursive discovery.

R2. For each resolved target, compute SHA-256 of the file's content.

R3. If no companion exists → write → WRITTEN.

R4. If companion exists and stored hash matches computed hash → skip → UNCHANGED (unless `--force`).

R5. If companion exists and stored hash differs from computed hash → overwrite → UPDATED.

R6. `--force` flag: write all targets unconditionally, treating result as WRITTEN.

R7. Must never stamp `.sha256` files themselves.

R8. Stamp format: `{64-hex-chars}  {filename}` (two spaces, filename only, no path, no BOM, no trailing newline).

R9. Write with UTF-8 NoBOM encoding.

R10. Output: table (relative path from invocation dir | WRITTEN / UPDATED / UNCHANGED / ERROR) + summary line `{N} processed | {W} written | {U} updated | {X} unchanged`.

R11. Exit non-zero only on ERROR. Zero if all WRITTEN, UPDATED, or UNCHANGED.

R12. `--tree` mode must include: files with an existing `.sha256` companion, files with extensions `.md .txt .ps1 .sh`, and files with the exact name `skill.index`.

## Constraints

- Must not modify the target file itself — writes only the companion.
- Must not create directories; writes companion alongside target in the same existing directory.
- Must not stamp `.sha256` files themselves (skip and note in output).
