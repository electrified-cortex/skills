---
name: skill-index-auditing
description: Validator for a skill-index cascade. Returns ok, rebuild-needed, or inconclusive. Never invokes the builder.
---

# Skill Index Auditing

Dispatch skill.

## Purpose

Provide a cheap, fast check: is this cascade structurally valid, or does the builder need to run? The auditor detects the first structural problem and stops. It does not collect all failures — the builder will find all problems during the rebuild.

## Invocation

Without reading `instructions.txt` yourself, use a Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory). Input: `root=<path> result_file=<path> [--dot-allow <name,...>]`"

Parameters:

- `root` (required): absolute path to the invocation root of the cascade to audit.
- `result_file` (required): absolute path for the audit report file.
- `--dot-allow` (optional): comma-separated bare dot-folder names to traverse (must match the list used by the builder for the same tree). Default: empty.

Returns: an audit report written to `result_file`.

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

1. **Entry targets resolve:** every entry must resolve to an on-disk target within the current node's subtree. Plain entry → leaf-skill directory. Descent-marked entry → descendant directory with its own `skill.index`. Combo entry → satisfies both. Shortcut entries (multi-segment keys) resolved by path-walk from the current node. Missing or out-of-subtree target → `rebuild-needed`.
2. **No missing direct children:** every manifest-bearing direct child must appear as an entry in this node's raw index, unless already reachable via a shortcut entry elsewhere in the cascade.
2a. **No index at pure leaf:** no manifest-bearing directory with zero manifest-bearing children may have a `skill.index`. A `skill.index` found at such a directory is a stale or erroneous index node the builder should not have produced → `rebuild-needed`.
3. **Combo self entry:** every combo node must have a self entry (key `.`) in its own raw index.
4. **Combo enumerates subdirectories:** every combo node must enumerate its manifest-bearing subdirectories in its own raw index (direct-child or shortcut entries).
5. **Combo classified in parent:** every combo node must be classified as combo in its parent's raw index.
6. **No reference loops:** on every resolution path (direct-child, shortcut, or combo sub-node descent), the auditor tracks the full ordered set of nodes visited. If any step would land on a node already in that set, the cascade contains a loop → `rebuild-needed`. The auditor is the primary enforcer of this rule per the root spec.

## Continue-Past Checks (record without halting)

These findings do not halt the audit but are reported in the audit report:

1. **Orphans:** a `skill.index.md` with no corresponding `skill.index`. Janitorial signal; does not trigger `rebuild-needed` by itself.
2. **Malformed lines:** a raw index line with missing key, missing colon, or forbidden characters. Recorded without halting. If the node completes inspection without a fail-fast failure, any malformed-line finding raises the final verdict to `rebuild-needed`.
3. **Phantom indexes:** a `skill.index` within the invocation root's subtree not reachable from the root node's cascade. Janitorial signal; does not trigger `rebuild-needed` by itself.
4. **Overlay trigger shape (R24):** an overlay section that describes what the skill does rather than when to load it (i.e., does not express triggering conditions per `skill-index-building` spec R22–R25). Findings escalate the verdict to `rebuild-needed` after a clean fail-fast walk.
5. **Keyword quality (R25):** a raw-index entry whose keyword list fails quality requirements: fewer than three keywords; a keyword that duplicates the entry key verbatim; all keywords single-word; or keywords that are only the technical identifier with punctuation stripped. Findings escalate the verdict to `rebuild-needed` after a clean fail-fast walk.

## Check Ordering

Within a single node: fail-fast checks run before continue-past checks. When a fail-fast check fails, the auditor halts without running continue-past checks at that node.

## Visited-Node Tracking

The auditor maintains the ordered set of nodes visited on the current resolution path. Tracking applies to every step of every resolution path — direct-child descent, shortcut path-walk endpoint, and combo sub-node descent. A new node is appended before inspection. If a step would land on a node already in the set, the auditor declares a loop and halts. The visited set is scoped to the current resolution path; entering a sibling subtree resets it.

## Audit Report Fields

- `verdict`: `ok` | `rebuild-needed` | `inconclusive`
- `reason`: reason string when verdict is not `ok`
- `failing_node`: path to the first failing node (when a fail-fast check failed)
- `continue_past_findings`: list of orphan, malformed-line, and phantom index findings

## Error Handling

- Invocation root unreadable: return `inconclusive` with reason, halt.
- Per-subtree unreadable: record as `inconclusive` for that subtree, continue with siblings.
- Audit report not producible: emit non-zero exit signal; do not silently succeed.

## Precedence Rules

1. `rebuild-needed` takes precedence over `ok`. Any single fail-fast failure downgrades an otherwise-ok cascade.
2. `inconclusive` takes precedence over `ok` but not over `rebuild-needed`.
3. Fail-fast failures take precedence over continue-past findings in the report.

## Footguns

F1: Auditor rebuilds instead of signalling.
Mitigation: Enforce R2 and C3. The auditor's sole output is a verdict. It does not rebuild or patch index content.

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
- Does not modify any file.
- Does not invoke the builder.
- Does not re-derive its own rules — validates against the root spec.
- Does not produce metadata overlay content.
- Does not judge curator intent, optimality, or aesthetic choices.

## Related

- `skill-index` — root spec and toolkit overview
- `skill-index-building` — invoke after `rebuild-needed` verdict
- `skill-index-crawling` — consumer that benefits from a validated cascade
