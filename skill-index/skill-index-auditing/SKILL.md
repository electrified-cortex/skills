---
name: skill-index-auditing
description: >-
  Validator for a skill-index cascade. Returns ok, rebuild-needed, or
  inconclusive. On PASS, writes skill.index.sha256 as sign-off. Never invokes
  the builder.
---

Dispatch (Dispatch agent, zero context): "Read and follow `instructions.txt` (in this directory). Input: `root=<path> result_file=<path> [--dot-allow <name,...>]`"

`root` (required): absolute path to cascade's invocation root.
`result_file` (required): absolute path for audit report.
`--dot-allow` (optional): comma-separated bare dot-folder names (must match builder's list for same tree). Default: empty.

Returns: audit report written to `result_file`. On PASS, also writes `skill.index.sha256` alongside each validated raw index.

Verdicts:

| Verdict | Condition |
| --- | --- |
| `ok` | Walk complete; no fail-fast failures; no malformed-line findings |
| `rebuild-needed` | Any fail-fast check failed, OR walk complete with malformed-line findings |
| `inconclusive` | Invocation root unreadable, or subtrees couldn't be evaluated. Subordinate to `rebuild-needed`. |

Fail-fast checks (halt on first failure → `rebuild-needed`):
1. Stamp present: `skill.index.sha256` exists alongside raw index.
2. Stamp matches: SHA-256 of raw index bytes equals stored stamp.
3. Entry targets resolve: every entry maps to on-disk target within subtree; shortcut entries resolved by path-walk.
4. No missing direct children: every manifest-bearing direct child has entry in this node's raw index.
5. Combo self entry: combo node has `.` self entry in its own raw index.
6. Combo enumerates subdirectories: combo node's raw index lists manifest-bearing subdirectories.
7. Combo parent classification: combo node is classified as combo in parent's raw index.
8. No reference loops: auditor tracks visited nodes on every resolution path (direct, shortcut, combo); revisit → loop → `rebuild-needed`.

Continue-past checks (record, don't halt): orphan stamps/overlays | malformed lines (escalate to `rebuild-needed` if present after clean fail-fast pass) | phantom indexes.

Walk: depth-first, parents before children. Symlinks not followed. Dot-folders skipped; `--dot-allow` overrides.

Visited-node tracking: ordered set of nodes on current resolution path. New node appended before inspection. Revisit → loop declared, halt. Set resets when entering sibling subtree.

Stamp sign-off: on PASS, writes `skill.index.sha256` alongside each validated raw index. Content: SHA-256 hex digest of exact stored bytes of `skill.index` — no trailing newline unless raw index ends with one; no other content. This is the only file-write the auditor ever performs. On non-PASS, mustn't write or delete any stamp — stale stamp signals "unaudited since last build."

Check ordering: fail-fast runs before continue-past at each node. Fail-fast failure halts without running continue-past.

Precedence: `rebuild-needed` > `inconclusive` > `ok`. Fail-fast failures always reported before continue-past.

Error handling:
- Invocation root unreadable → `inconclusive`, halt.
- Per-subtree unreadable → record `inconclusive` for subtree, continue siblings.
- Audit report not producible → non-zero exit, don't silently succeed.

Footguns:
F1: Auditor rebuilds instead of signalling. Only file-write is stamp on PASS. Never invoke builder.
F2: Keeps walking after fail-fast failure. Halt on first. Builder finds all problems during rebuild.
F3: Orphans/phantoms treated as fail-fast. They're continue-past (janitorial), not rebuild triggers.
F4: Judges shortcut placement. Correctness only — subtree containment + acyclicity. Intent out of scope.
F5: Loop detection skipped under shortcut resolution. Track visited nodes on every step of every path.

Don'ts:
- Doesn't rebuild.
- Doesn't modify any file except writing `skill.index.sha256` on PASS; non-PASS → no files modified.
- Doesn't invoke builder.
- Doesn't re-derive rules — validates against root spec.
- Doesn't produce overlay content.
- Doesn't judge curator intent, optimality, or aesthetic choices.

Related: `skill-index`, `skill-index-building`, `skill-index-crawling`
