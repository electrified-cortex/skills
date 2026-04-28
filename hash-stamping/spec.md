# Hash Stamp — Suite Spec

Normative spec for the hash-stamp skill suite. Defines the stamp format, stamp policy, and sub-skill routing.

## Purpose

Define the stamp format, policy for when stamps are required, and the routing between two sub-skills: `audit/` (verify) and `stamp/` (write/update).

## Scope

Covers all SHA-256 companion file operations for the fleet. Does not cover source code files (git history is the integrity record), log files, temp files, or generated outputs.

## Definitions

- **Companion file**: a `.sha256` file co-located with a stamped file, containing a single `sha256sum`-format line.
- **Stamp**: the act of writing or updating a companion file.
- **Drift**: a mismatch between the hash stored in a companion file and the current hash of its target.
- **Stampable file**: a file that meets the stamp policy criteria (see Requirements).

## Requirements

### Stamp Format

Standard sha256sum one-line format: `{64-hex-chars}  {filename}` (two spaces, filename only — no path, no BOM, no trailing newline). Companion `.sha256` file is co-located with the stamped file in the same directory. Written with UTF-8 NoBOM encoding.

### Stamp Policy

A file MUST carry a stamp when:

- It is loaded by an agent and acted upon directly (skill files, agent definitions, instruction files, skill indexes).
- Silent drift in the file's content could cause incorrect agent behavior.
- The file acts as a lock — other processes depend on a known-good state.

Files that MUST NOT be stamped:

- `.sha256` files themselves.
- Source code files (git history is the integrity record).
- Log files, temp files, and generated outputs.
- Human-facing prose where incremental editing is expected and visible.

### Sub-skill Routing

| Situation | Sub-skill |
| --- | --- |
| Verify whether a file has changed since last stamp | `audit/` |
| Write or update stamps after editing files | `stamp/` |

## Constraints

- `hash-stamping/` is a combo node: it carries its own `SKILL.md` manifest AND indexes two child sub-skills.
- Agents MUST read `SKILL.md` at this level to understand the suite, then dispatch into the appropriate sub-skill via its `instructions.txt`.
- Companion files MUST NOT be stamped themselves.
