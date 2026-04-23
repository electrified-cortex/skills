---
name: skill-index-auditing
description: >-
  Validator for a skill-index cascade. Returns ok, rebuild-needed, or
  inconclusive. On PASS, writes skill.index.sha256 as sign-off. Never invokes
  the builder.
---

Dispatch (Dispatch agent, zero context): "Read and follow `instructions.txt` (in this directory). Input: `root=<path> result_file=<path> [--dot-allow <name,...>]`"

`root` (required): abs path to cascade's invocation root.
`result_file` (required): abs path for audit report.
`--dot-allow` (optional): comma-separated bare dot-folder names (must match builder's list). Default: empty.

Returns: audit report at `result_file`. On PASS, also writes `skill.index.sha256` alongside each validated raw index.

Verdicts:

| Verdict | Condition |
| --- | --- |
| `ok` | Walk completed; no fail-fast failures; no malformed-line findings |
| `rebuild-needed` | Any fail-fast check failed, OR walk completed with malformed-line findings |
| `inconclusive` | Invocation root unreadable, or subtrees couldn't be evaluated. Subordinate to `rebuild-needed`. |

Walk order: depth-first from invocation root, parents before children. Parent-level failure halts before descending into potentially invalid subtrees. Dot-folders skipped; `--dot-allow` overrides. Symlinks not followed. Shortcut entries resolved by path-walk at declaring node, subject to loop detection.

Fail-fast checks (halt on first failure → `rebuild-needed`):
1. Stamp present: each raw index must have `skill.index.sha256`.
2. Stamp matches: SHA-256 of raw index bytes must equal stored stamp.
3. Entry targets resolve: every entry resolves to on-disk target within node's subtree. Plain entry → leaf-skill dir. Descent-marked → descendant dir with own `skill.index`. Combo → satisfies both. Shortcut entries (multi-segment keys) resolved by path-walk from current node. Missing or out-of-subtree → `rebuild-needed`.
4. No missing direct children: every manifest-bearing direct child must appear as entry in node's raw index, unless reachable via shortcut elsewhere in cascade.
4a. No index at pure leaf: manifest-bearing dir with zero manifest-bearing children must not have `skill.index`. Stale/erroneous if found → `rebuild-needed`.
5. Combo self entry: every combo node must have self entry (key `.`) in its raw index.
6. Combo enumerates subdirectories: every combo node must enumerate manifest-bearing subdirs in its raw index (direct-child or shortcut entries).
7. Combo classified in parent: every combo node must be classified combo in parent's raw index.
8. No reference loops: on every resolution path, track full ordered set of nodes visited. Step landing on already-visited node → `rebuild-needed`. Auditor is primary enforcer per root spec.

Continue-past checks (record, don't halt):
1. Orphans: `skill.index.sha256` or `skill.index.md` with no corresponding `skill.index`. Janitorial; doesn't trigger `rebuild-needed` alone.
2. Malformed lines: raw index line with missing key, missing colon, or forbidden chars. Recorded without halting. Any finding raises verdict to `rebuild-needed` after clean fail-fast walk.
3. Phantom indexes: `skill.index` in invocation root's subtree not reachable from root cascade. Janitorial; doesn't trigger `rebuild-needed` alone.
4. Overlay trigger shape (R24): overlay section describing what skill does rather than when to load it (doesn't express triggering conditions per `skill-index-building` spec R22–R25). Escalates to `rebuild-needed` after clean fail-fast walk.
5. Keyword quality (R25): raw-index entry failing quality: fewer than three keywords; keyword duplicating entry key verbatim; all keywords single-word; keywords only technical identifier with punctuation stripped. Escalates to `rebuild-needed` after clean fail-fast walk.

Check ordering: fail-fast runs before continue-past at each node. Fail-fast failure → halt without running continue-past.

Visited-node tracking: maintain ordered set of nodes on current resolution path. Applies to every step — direct-child descent, shortcut path-walk endpoint, combo sub-node descent. Append new node before inspection. Step landing on already-visited node → loop, halt. Set resets on sibling subtree entry.

Stamp sign-off: after walk completes and PASS determined, write `skill.index.sha256` alongside each validated raw index. Stamps written only after verdict known — not incrementally during walk — so non-PASS never leaves partial stamp state. Content: SHA-256 hex digest of exact bytes of stored `skill.index` for that node — no trailing newline unless raw index ends with one; no other content. Sign-off confirming cascade valid at time of audit.

On non-PASS (`rebuild-needed` or `inconclusive`), mustn't write any stamp. Existing stamps left untouched — stale stay stale, absent stay absent. Stale/absent stamp after non-PASS intentional: signals "unaudited since last build," triggering build-then-audit cycle.

Stamp write is only file-write auditor ever performs.

Audit report fields:
- `verdict`: `ok` | `rebuild-needed` | `inconclusive`
- `reason`: reason string when verdict isn't `ok`
- `failing_node`: path to first failing node (when fail-fast check failed)
- `continue_past_findings`: list of orphan, malformed-line, and phantom index findings

Error handling:
- Invocation root unreadable → `inconclusive` with reason, halt.
- Per-subtree unreadable → `inconclusive` for subtree, continue siblings.
- Audit report not producible → non-zero exit; don't silently succeed.
- Stamp write failure after PASS → downgrade to `inconclusive`, list failed nodes in report, non-zero exit. Partial stamp state unacceptable — incomplete sign-off = no sign-off.

Precedence:
1. `rebuild-needed` takes precedence over `ok`. Single fail-fast failure downgrades otherwise-ok cascade.
2. `inconclusive` takes precedence over `ok` but not `rebuild-needed`.
3. Fail-fast failures take precedence over continue-past findings in report.

Footguns:
F1: Auditor rebuilds instead of signalling. Only file-write is stamp on PASS. Never invoke builder.
F2: Keeps walking after fail-fast failure. Halt on first. Builder finds all problems during rebuild.
F3: Orphans/phantoms treated as fail-fast. They're continue-past (janitorial), not rebuild triggers alone.
F4: Judges shortcut placement. Correctness only — subtree containment (check 3) + acyclicity (check 8). Intent and optimality out of scope.
F5: Loop detection skipped under shortcut resolution. Track visited nodes on every step of every resolution path, regardless of descent kind.

Don'ts:
- Doesn't rebuild.
- Doesn't modify any file except writing `skill.index.sha256` on PASS. Non-PASS → no files modified, not even pre-existing stale stamps.
- Doesn't invoke builder.
- Doesn't re-derive own rules — validates against root spec.
- Doesn't produce metadata overlay content.
- Doesn't judge curator intent, optimality, or aesthetic choices.

Related:
- `skill-index` — root spec and toolkit overview
- `skill-index-building` — invoke after `rebuild-needed` verdict
- `skill-index-crawling` — consumer that benefits from validated cascade
