# Hash-Record Manifest

Compute a deterministic manifest hash for a set of files. The manifest hash is the multi-file cache key used by hash-record consumers (skill audits, code reviews on a directory, anything that bundles multiple sources into a single result).

## Input

- `repo_root` (required): absolute path to the repository root. Used to compute repo-relative paths for the manifest text.
- `files` (required): paths to include. May be absolute or repo-relative; the skill normalizes all to repo-relative against `repo_root`.

## Dispatch

Variables:

`<instructions>` = `instructions.txt` (this folder; NEVER READ THIS FILE)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `repo_root=<abs-path> files=<comma-or-newline-separated-list>`
`<tier>` = `fast-cheap`
`<description>` = `Computing manifest hash: <repo_root>`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`

Follow `dispatch` skill. See `../../dispatch/SKILL.md`.
Returns: `manifest: <40-char-hash>` | `ERROR: <reason>`

Related: `hash-record`, `hash-record-index`, `hash-record-prune`
