---
name: hash-stamp
description: Dispatch skill. Writes or updates SHA-256 companion files alongside target files.
---

# Hash Stamp — Stamp

## Invocation

Without reading `instructions.txt` yourself, use a Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory). Input: `<path|glob|--tree <root>> [--force]`"

Parameters:

- `<path>` or `<glob>`: one or more explicit paths or a glob pattern.
- `--tree <root>`: recursive — finds all files under root that already have a `.sha256` companion or match stampable extensions (`.md`, `.txt`, `.ps1`, `.sh`) and stamps them.
- `--force` (optional): overwrite existing companion even if hash already matches.

## Output

Table of relative path | WRITTEN / UPDATED / UNCHANGED / ERROR.

Summary line: `{N} processed | {W} written | {U} updated | {X} unchanged`.

Zero exit if no errors; non-zero on ERROR.
