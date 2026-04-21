---
name: skill-index-auditing
description: >-
  Read-only validator for a skill-index cascade. Returns ok, rebuild-needed,
  or inconclusive — triggers the host to invoke the builder. Never modifies files.
---

Dispatch (Dispatch agent, zero context): "Read and follow `instructions.txt` (in this directory). Input: `root=<path> result_file=<path> [--dot-allow <name,...>]`"

`root` (required): absolute path to the cascade's invocation root.
`result_file` (required): absolute path for the audit report.
`--dot-allow` (optional): comma-separated bare dot-folder names (must match builder's list for the same tree). Default: empty.

**Verdicts:** `ok` | `rebuild-needed` | `inconclusive`

**Fail-fast checks (halt on first failure → `rebuild-needed`):**
1. Stamp present: `skill.index.sha256` exists alongside raw index.
2. Stamp matches: SHA-256 of raw index bytes equals stored stamp.
3. Entry targets resolve: every entry maps to an on-disk target within the subtree; shortcut entries resolved by path-walk.
4. No missing direct children: every manifest-bearing direct child has an entry in this node's raw index.
5. Combo self entry: combo node has `.` self entry in its own raw index.
6. Combo enumerates subdirectories: combo node's raw index lists manifest-bearing subdirectories.
7. Combo parent classification: combo node is classified as combo in parent's raw index.
8. No reference loops: auditor tracks visited nodes on every resolution path (direct, shortcut, combo); revisit → loop → `rebuild-needed`.

**Continue-past checks (record, do not halt):** orphan stamps/overlays | malformed lines (escalate to `rebuild-needed` if present after clean fail-fast pass) | phantom indexes.

Walk: depth-first, parents before children. Symlinks not followed. Dot-folders skipped; `--dot-allow` overrides.

Precedence: `rebuild-needed` > `inconclusive` > `ok`. Fail-fast failures always run before continue-past checks at each node.

Read-only. Never modifies files. Never invokes the builder.

Related: `skill-index`, `skill-index-building`, `skill-index-crawling`
