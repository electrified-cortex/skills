# Skill Index Auditing — Agent Instructions

Dispatch skill. You are a haiku-class agent operating in zero context. Your job is to validate an existing skill-index cascade and return one of three verdicts: `ok`, `rebuild-needed`, or `inconclusive`. On a PASS verdict (`ok`), you also write `skill.index.sha256` alongside each validated raw index as a sign-off artifact. You do not rebuild. You do not invoke the builder. Writing the stamp on PASS is the only file modification you ever perform.

---

## Inputs

- `root` (required): absolute path to the invocation root of the cascade to audit. Audit is restricted to the subtree rooted here.
- `result_file` (required): absolute path where the audit report must be written.
- `--dot-allow` (optional): comma-separated bare dot-folder names to traverse (e.g. `.hidden,.meta`). Must match the list used by the builder for the same tree. Default: empty — all dot-prefixed directories are skipped.

---

## Outputs

Write the audit report to `result_file`. See Report Format below.

On a PASS verdict, also write `skill.index.sha256` alongside each validated raw index. The stamp content is the SHA-256 hex digest of the exact bytes of the stored `skill.index` for that node — no trailing newline unless the raw index itself ends with one; no other content. Write the stamp only after the entire walk completes with a PASS verdict. Do not write partial stamps if the walk is still in progress.

On any non-PASS verdict (`rebuild-needed` or `inconclusive`): do not write or delete any stamp. Leave pre-existing stale stamps untouched.

If the audit report cannot be written: emit a non-zero exit signal. Do not silently succeed.

---

## Verdicts

| Verdict | Condition |
| --- | --- |
| `ok` | Walk completed; no fail-fast failures; no malformed-line findings at any node. |
| `rebuild-needed` | Any fail-fast check failed, OR the walk completed with at least one malformed-line finding (after a clean fail-fast pass at the node where the malformed line occurred). |
| `inconclusive` | Invocation root is unreadable, or one or more subtrees could not be evaluated. `inconclusive` takes precedence over `ok` but not over `rebuild-needed`. |

---

## Walk Order

Walk depth-first from the invocation root, visiting parent nodes before their children. This ensures a parent-level failure halts the audit before descending into potentially invalid subtrees.

- Dot-prefixed directories: skipped by default. `--dot-allow` provides bare names (no globs, no paths) that override the skip.
- Symlinks: not followed.
- Shortcut entries: resolved by path-walk at the node that declares them, subject to loop detection per the reference-loop check below.

---

## Per-Node Procedure

For each node reached during the walk:

### A. Run fail-fast checks first (in order; halt on first failure)

1. **Stamp present**: `skill.index.sha256` must exist alongside `skill.index` in the same directory. Missing → `rebuild-needed`; record reason and failing-node path; halt.

2. **Stamp matches**: compute SHA-256 of the raw bytes of `skill.index` at this node; compare against the stored `skill.index.sha256`. Mismatch → `rebuild-needed`; record reason and failing-node path; halt.

3. **Entry targets resolve**: every entry in the raw index must resolve to an on-disk target within the current node's subtree.
   - Plain leaf entry (no trailing `/`): target must be an existing directory.
   - Descent-marked entry (trailing `/`): target must be an existing directory containing `skill.index`.
   - Combo entry: target must satisfy both conditions.
   - Shortcut entry (multi-segment key): walk the path from the current node to the target; apply subtree-containment check (no `..`, no absolute paths, no escape above invocation root) at every step.
   - Missing target or out-of-subtree target → `rebuild-needed`; record reason and failing-node path; halt.

4. **No missing direct children**: every manifest-bearing direct child directory of the current directory must appear as an entry in this node's raw index, unless that child is already reachable via a shortcut entry present elsewhere in the cascade. Missing → `rebuild-needed`; record reason and failing-node path; halt.

5. **Combo self entry**: if the current directory is a combo node (has a skill manifest and at least one manifest-bearing child), it must have a self entry (key `.`) in its own raw index. Missing → `rebuild-needed`; record reason and failing-node path; halt.

6. **Combo enumerates subdirectories**: a combo node's raw index must enumerate all its manifest-bearing subdirectories, either as direct-child entries or as shortcut entries. Missing entry → `rebuild-needed`; record reason and failing-node path; halt.

7. **Combo classified in parent**: a combo node must be classified as combo (sub-node-marked, key ending in `/`) in its parent's raw index. Missing or wrong classification → `rebuild-needed`; record reason and failing-node path; halt.

8. **No reference loops**: on every resolution path — whether the step is a direct-child descent, a shortcut path-walk, or a combo sub-node descent — maintain the full ordered set of nodes visited on that path. Before opening any node, check whether its directory is already in the set. If it is: a reference loop exists → `rebuild-needed`; record reason and the ordered visited sequence; halt. The visited set is scoped to the current resolution path; crossing into a sibling subtree resets it.

When any fail-fast check fails: produce the audit report with `verdict: rebuild-needed`, the reason, and the failing-node path, then halt. Do not run continue-past checks at the failing node.

### B. Run continue-past checks (record, do not halt)

These findings are recorded in the audit report but do not halt the walk and do not by themselves produce `rebuild-needed`.

1. **Orphans**: a `skill.index.sha256` or `skill.index.md` present without a corresponding `skill.index` in the same directory. Record as janitorial signal.

2. **Malformed lines**: any raw index line with a missing key, missing colon, or forbidden characters. Record the line and the node. If the node completes all fail-fast checks without halting, and any malformed-line finding exists at that node, raise the final verdict for that node to `rebuild-needed` when the walk ends (per R12 escalation).

3. **Phantom indexes**: a `skill.index` within the invocation root's subtree that is not reachable, directly or transitively, from the root node's cascade. Record as janitorial signal.

---

## Check Ordering

Within a single node: fail-fast checks (A.1–A.8) run before continue-past checks (B.1–B.3). When a fail-fast check fails, halt without running continue-past checks at that node.

---

## Visited-Node Tracking

Maintain the ordered set of nodes visited on the current resolution path. A node is appended to the set before it is inspected. Tracking applies to every step of every resolution path: direct-child descent, shortcut path-walk endpoint, and combo sub-node descent. If a step would land on a node already in the current set: loop detected, halt per check A.8. The visited set is scoped to the current path; crossing into a sibling subtree resets it.

---

## Error Handling

- Invocation root unreadable: return verdict `inconclusive` with reason and halt.
- Per-subtree unreadable directory: record as `inconclusive` for that subtree, continue with siblings. Subtree-level inconclusive findings aggregate into the final verdict per precedence rules.
- Audit report cannot be produced: emit non-zero exit signal; do not silently succeed.

---

## Precedence Rules

1. `rebuild-needed` takes precedence over `ok`. Any single fail-fast failure or malformed-line escalation downgrades an otherwise-ok cascade.
2. `inconclusive` takes precedence over `ok` but not over `rebuild-needed`. If any part triggered `rebuild-needed`, that is the final verdict.
3. Fail-fast failures take precedence over continue-past findings in the report.

---

## Fail-Fast Rules

- `root` missing or unreadable: `inconclusive`, halt.
- First fail-fast check failure: `rebuild-needed`, halt immediately. Do not collect further failures.
- Never invoke the builder.
- Never modify any file.
- Never open skill contents.

---

## Audit Report Format

```
## Skill Index Audit Report

root: <absolute path>
verdict: ok | rebuild-needed | inconclusive

### Result
reason: <reason string when verdict is not ok, otherwise "all checks passed">
failing_node: <absolute path to first failing node, or blank if none>

### Continue-Past Findings
| Type | Node | Detail |
| --- | --- | --- |
| orphan | <path> | <stamp or overlay, no corresponding raw index> |
| malformed-line | <path> | <line content> |
| phantom-index | <path> | <not reachable from cascade root> |
(omit table if no findings)

### Visited Nodes (on failing path, if applicable)
1. <absolute path>
...
(omit if no reference loop)
```

---

## Don'ts

- Do not rebuild. Do not invoke the builder.
- Do not modify any file except writing `skill.index.sha256` on PASS. On non-PASS verdict, no files modified — not even pre-existing stale stamps.
- Do not open skill contents (any file other than `skill.index`, `skill.index.md`, `skill.index.sha256`).
- Do not keep walking after a fail-fast check fails.
- Do not treat orphans or phantom indexes as `rebuild-needed` triggers by themselves.
- Do not judge curator intent, shortcut placement optimality, or aesthetic choices.
- Do not consult the network.
