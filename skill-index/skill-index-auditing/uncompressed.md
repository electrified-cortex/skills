# Skill Index Auditing

Dispatch skill. Validator for a skill-index cascade. Returns `ok`, `rebuild-needed`, or `inconclusive`. On a PASS verdict, writes `skill.index.sha256` alongside each validated raw index as a sign-off artifact. Never invokes the builder. Conforms to the root `skill-index` spec.

## Purpose

Provide a cheap, fast check: is this cascade structurally valid, or does the builder need to run? The auditor detects the first structural problem and stops. It does not collect all failures — the builder will find all problems during the rebuild. On a clean PASS, the auditor writes integrity stamps to confirm the cascade was valid at time of audit.

## Invocation

Dispatch via Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory). Input: `root=<path> result_file=<path> [--dot-allow <name,...>]`"

Parameters:

- `root` (required): absolute path to the invocation root of the cascade to audit.
- `result_file` (required): absolute path for the audit report file.
- `--dot-allow` (optional): comma-separated bare dot-folder names to traverse (must match the list used by the builder for the same tree). Default: empty.

Returns: an audit report written to `result_file`, and on PASS, `skill.index.sha256` written alongside each validated raw index.

## Verdicts

| Verdict | Condition |
| --- | --- |
| `ok` | Walk completed; no fail-fast failures; no malformed-line findings |
| `rebuild-needed` | Any fail-fast check failed, OR walk completed with at least one malformed-line finding |
| `inconclusive` | Invocation root unreadable, or one or more subtrees could not be evaluated. Subordinate to `rebuild-needed`: if any part triggered `rebuild-needed`, that is the final verdict. |

## Walk Order

Depth-first from the invocation root, parent nodes before their children. This ensures a parent-level failure halts the audit before descending into potentially invalid subtrees.

- Dot-folders skipped by default; `--dot-allow` provides bare names that override the skip.
- Symlinks not followed.
- Shortcut entries resolved by path-walk at the node that declares them, subject to loop detection.

## Fail-Fast Checks (halt on first failure)

These checks, if failed, immediately produce `rebuild-needed` with the reason and the failing node's path:

1. **Stamp present:** each raw index must have an accompanying `skill.index.sha256`.
2. **Stamp matches:** SHA-256 of the raw index's stored bytes must equal the stored stamp.
3. **Entry targets resolve:** every entry must resolve to an on-disk target within the current node's subtree. Plain entry → leaf-skill directory. Descent-marked entry → descendant directory with its own `skill.index`. Combo entry → satisfies both. Shortcut entries (multi-segment keys) resolved by path-walk from the current node. Missing or out-of-subtree target → `rebuild-needed`.
4. **No missing direct children:** every manifest-bearing direct child must appear as an entry in this node's raw index, unless already reachable via a shortcut entry elsewhere in the cascade.
4a. **No index at pure leaf:** no manifest-bearing directory with zero manifest-bearing children may have a `skill.index`. A `skill.index` found at such a directory is a stale or erroneous index node the builder should not have produced → `rebuild-needed`.
5. **Combo self entry:** every combo node must have a self entry (key `.`) in its own raw index.
6. **Combo enumerates subdirectories:** every combo node must enumerate its manifest-bearing subdirectories in its own raw index (direct-child or shortcut entries).
7. **Combo classified in parent:** every combo node must be classified as combo in its parent's raw index.
8. **No reference loops:** on every resolution path (direct-child, shortcut, or combo sub-node descent), the auditor tracks the full ordered set of nodes visited. If any step would land on a node already in that set, the cascade contains a loop → `rebuild-needed`. The auditor is the primary enforcer of this rule per the root spec.

## Continue-Past Checks (record without halting)

These findings do not halt the audit but are reported in the audit report:

1. **Orphans:** a `skill.index.sha256` or `skill.index.md` with no corresponding `skill.index`. Janitorial signal; does not trigger `rebuild-needed` by itself.
2. **Malformed lines:** a raw index line with missing key, missing colon, or forbidden characters. Recorded without halting. If the node completes inspection without a fail-fast failure, any malformed-line finding raises the final verdict to `rebuild-needed`.
3. **Phantom indexes:** a `skill.index` within the invocation root's subtree not reachable from the root node's cascade. Janitorial signal; does not trigger `rebuild-needed` by itself.

## Check Ordering

Within a single node: fail-fast checks run before continue-past checks. When a fail-fast check fails, the auditor halts without running continue-past checks at that node.

## Visited-Node Tracking

The auditor maintains the ordered set of nodes visited on the current resolution path. Tracking applies to every step of every resolution path — direct-child descent, shortcut path-walk endpoint, and combo sub-node descent. A new node is appended before inspection. If a step would land on a node already in the set, the auditor declares a loop and halts. The visited set is scoped to the current resolution path; entering a sibling subtree resets it.

## Stamp Sign-Off

After the walk completes and a PASS verdict is determined, the auditor writes `skill.index.sha256` alongside each raw index it validated during the walk. Stamps are written only after the verdict is known — not incrementally during the walk — so that a non-PASS verdict never leaves partial stamp state. The stamp content is the SHA-256 hex digest of the exact bytes of the stored `skill.index` for that node — no trailing newline unless the raw index itself ends with one; no other content. This write is the auditor's sign-off artifact, confirming the cascade was structurally valid at time of audit.

On any non-PASS verdict (`rebuild-needed` or `inconclusive`), the auditor must not write any stamp. Existing stamps are left untouched — stale stamps remain stale, absent stamps remain absent. A stale or absent stamp after a non-PASS verdict is intentional: it signals "unaudited since last build," giving the host agent a clear trigger that a build-then-audit cycle is required.

Writing the stamp is the only file-write the auditor ever performs.

## Audit Report Fields

- `verdict`: `ok` | `rebuild-needed` | `inconclusive`
- `reason`: reason string when verdict is not `ok`
- `failing_node`: path to the first failing node (when a fail-fast check failed)
- `continue_past_findings`: list of orphan, malformed-line, and phantom index findings

## Error Handling

- Invocation root unreadable: return `inconclusive` with reason, halt.
- Per-subtree unreadable: record as `inconclusive` for that subtree, continue with siblings.
- Audit report not producible: emit non-zero exit signal; do not silently succeed.
- Stamp write failure after PASS: downgrade verdict to `inconclusive`, list failed nodes in audit report, emit non-zero exit signal. A partial stamp state (some nodes stamped, others not) is not acceptable — incomplete sign-off is treated as no sign-off.

## Precedence Rules

1. `rebuild-needed` takes precedence over `ok`. Any single fail-fast failure downgrades an otherwise-ok cascade.
2. `inconclusive` takes precedence over `ok` but not over `rebuild-needed`.
3. Fail-fast failures take precedence over continue-past findings in the report.

## Footguns

F1: Auditor rebuilds instead of signalling.
Mitigation: The only file-write permitted is the stamp on PASS. Any other modification is a violation. Never invoke the builder.

F2: Auditor keeps walking after a fail-fast failure.
Mitigation: Halt on the first fail-fast failure. The builder will find all problems during the rebuild.

F3: Orphans or phantoms treated as fail-fast failures.
Mitigation: Orphans and phantom indexes are continue-past findings — janitorial signals, not rebuild triggers by themselves.

F4: Auditor judges shortcut placement.
Mitigation: Correctness only. Sole structural concerns about shortcuts: subtree containment (check 3) and acyclicity (check 8). Intent and optimality are out of scope.

F5: Loop detection skipped under shortcut resolution.
Mitigation: Track visited nodes on every step of every resolution path, regardless of descent kind.

## Don'ts

- Does not rebuild.
- Does not modify any file except writing `skill.index.sha256` on PASS. On non-PASS verdict, no files are modified — not even pre-existing stale stamps.
- Does not invoke the builder.
- Does not re-derive its own rules — validates against the root spec.
- Does not produce metadata overlay content.
- Does not judge curator intent, optimality, or aesthetic choices.

## Related

- `skill-index` — root spec and toolkit overview
- `skill-index-building` — invoke after `rebuild-needed` verdict
- `skill-index-crawling` — consumer that benefits from a validated cascade
