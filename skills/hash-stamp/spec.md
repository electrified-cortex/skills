# Hash Stamp — Suite Spec

Normative spec for the hash-stamp skill suite. Defines the stamp format, stamp policy, and sub-skill routing.

## Stamp Format

Standard sha256sum one-line format: `{64-hex-chars}  {filename}` (two spaces, filename only — no path, no BOM, no trailing newline). Companion `.sha256` file is co-located with the stamped file in the same directory. Written with UTF-8 NoBOM encoding.

## Stamp Policy

A file should carry a stamp when:

- It is loaded by an agent and acted upon directly (skill files, agent definitions, instruction files, skill indexes).
- Silent drift in the file's content could cause incorrect agent behavior.
- The file acts as a lock — other processes depend on a known-good state.

Files that must NOT be stamped:

- `.sha256` files themselves.
- Source code files (git history is the integrity record).
- Log files, temp files, and generated outputs.
- Human-facing prose where incremental editing is expected and visible.

## Sub-skill Routing

| Situation | Sub-skill |
| --- | --- |
| Verify whether a file has changed since last stamp | `audit/` |
| Write or update stamps after editing files | `stamp/` |

## Combo Node

`hash-stamp/` is a combo node: it carries its own `SKILL.md` manifest AND indexes two child sub-skills. Agents should read `SKILL.md` at this level to understand the suite, then dispatch into the appropriate sub-skill via its `instructions.txt`.
