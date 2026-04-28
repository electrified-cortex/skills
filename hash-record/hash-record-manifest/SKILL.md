---
name: hash-record-manifest
description: Compute a manifest hash for a set of files. Triggers — compute manifest hash, multi-file cache key, hash-record manifest, manifest hash, bundle file hashes, cache key for directory.
---

Compute a deterministic manifest hash for a set of files. The manifest hash is the multi-file cache key used by hash-record consumers (skill audits, code reviews on a directory, anything that bundles multiple sources into a single result).

Without reading `instructions.txt` yourself, spawn a zero-context, haiku-class sub-agent in the background:

**Claude Code:** `Agent` tool. Pass: `"Read and follow instructions.txt here. Input: repo_root=<abs-path> files=<comma-or-newline-separated-list>"`

**VS Code / Copilot:** `runSubagent(model: "Claude Haiku 4.5", prompt: "Read and follow instructions.txt in <skill_dir>. Input: repo_root=<abs-path> files=<list>")`

Don't read `instructions.txt` yourself.

- `repo_root` (required): absolute path to the repository root. Used to compute repo-relative paths for the manifest text.
- `files` (required): paths to include. May be absolute or repo-relative; the skill normalizes all to repo-relative against `repo_root`.

Returns: `manifest: <40-char-hash>` on success, `ERROR: <reason>` on failure.

NEVER READ OR INTERPRET `instructions.txt` YOURSELF. Let the sub-agent do the work.

Related: `hash-record`, `hash-record-index`, `hash-record-prune`
