# Skill Index Auditing — Agent Instructions

Dispatch skill. You are a standard agent operating in zero context. Your job is to validate an existing skill-index cascade and return one of three verdicts: `ok`, `rebuild-needed`, or `inconclusive`. You do not rebuild. You do not invoke the builder. You do not modify any files.

---

## Verdicts

| Verdict | Condition |
| --- | --- |
| `ok` | Walk completed; no fail-fast failures; no malformed-line, overlay trigger-shape, or keyword-quality findings at any node. |
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

1. **Entry targets resolve**: every entry in the raw index must resolve to an on-disk target within the current node's subtree.
   - Plain leaf entry (no trailing `/`): target must be an existing directory.
   - Descent-marked entry (trailing `/`): target must be an existing directory containing `skill.index`.
   - Combo entry: target must satisfy both conditions.
   - Shortcut entry (multi-segment key): walk the path from the current node to the target; apply subtree-containment check (no `..`, no absolute paths, no escape above invocation root) at every step.
   - Missing target or out-of-subtree target → `rebuild-needed`; record reason and failing-node path; halt.

2. **No missing direct children**: every manifest-bearing direct child directory of the current directory must appear as an entry in this node's raw index, unless that child is already reachable via a shortcut entry present elsewhere in the cascade. Missing → `rebuild-needed`; record reason and failing-node path; halt.

2a. **No index at pure leaf**: no manifest-bearing directory with zero manifest-bearing children may have a `skill.index`. If the auditor encounters a `skill.index` at such a directory, the cascade contains a stale or erroneous index node the builder should not have produced → `rebuild-needed`; record reason and the path of the offending directory; halt.

3. **Combo self entry**: if the current directory is a combo node (has a skill manifest and at least one manifest-bearing child), it must have a self entry (key `.`) in its own raw index. Missing → `rebuild-needed`; record reason and failing-node path; halt.

4. **Combo enumerates subdirectories**: a combo node's raw index must enumerate all its manifest-bearing subdirectories, either as direct-child entries or as shortcut entries. Missing entry → `rebuild-needed`; record reason and failing-node path; halt.

5. **Combo classified in parent**: a combo node must be classified as combo (sub-node-marked, key ending in `/`) in its parent's raw index. Missing or wrong classification → `rebuild-needed`; record reason and failing-node path; halt.

6. **No reference loops**: on every resolution path — whether the step is a direct-child descent, a shortcut path-walk, or a combo sub-node descent — maintain the full ordered set of nodes visited on that path. Before opening any node, check whether its directory is already in the set. If it is: a reference loop exists → `rebuild-needed`; record reason and the ordered visited sequence; halt. The visited set is scoped to the current resolution path; crossing into a sibling subtree resets it.

When any fail-fast check fails: produce the audit report with `verdict: rebuild-needed`, the reason, and the failing-node path, then halt. Do not run continue-past checks at the failing node.

### B. Run continue-past checks (record, do not halt)

These findings are recorded in the audit report but do not halt the walk and do not by themselves produce `rebuild-needed`.

1. **Orphans**: a `skill.index.md` present without a corresponding `skill.index` in the same directory. Record as janitorial signal.

2. **Malformed lines**: any raw index line with a missing key, missing colon, or forbidden characters. Record the line and the node. If the node completes all fail-fast checks without halting, and any malformed-line finding exists at that node, raise the final verdict for that node to `rebuild-needed` when the walk ends (per R12 escalation).

3. **Phantom indexes**: a `skill.index` within the invocation root's subtree that is not reachable, directly or transitively, from the root node's cascade. Record as janitorial signal.

4. **Overlay trigger-shape** (R24): for any `skill.index.md` present at a node, inspect the overlay sections. A section is non-conformant if it reads as a description or summary of what the skill does without stating when/why to load it. Conformant sections express a triggering condition: an operator phrase ("When asked to…") or an agent-self-triggered imperative ("When the task requires…"). Record each non-conformant section as a `trigger-shape` finding. Findings here escalate the final verdict to `rebuild-needed` per R19.

5. **Keyword quality** (R25): for every raw-index entry at the node, inspect its keyword list. Flag the entry if any of the following is true: fewer than three keywords; a keyword that exactly duplicates the entry key verbatim; all keywords are single words (no multi-word phrases); or all keywords are only the skill's technical identifier with punctuation stripped. Record each failing entry as a `keyword-quality` finding. Findings here escalate the final verdict to `rebuild-needed` per R19.

---

## Check Ordering

Within a single node: fail-fast checks (A.1–A.6) run before continue-past checks (B.1–B.5). When a fail-fast check fails, halt without running continue-past checks at that node.

---

## Visited-Node Tracking

Maintain the ordered set of nodes visited on the current resolution path. A node is appended to the set before it is inspected. Tracking applies to every step of every resolution path: direct-child descent, shortcut path-walk endpoint, and combo sub-node descent. If a step would land on a node already in the current set: loop detected, halt per check A.6. The visited set is scoped to the current path; crossing into a sibling subtree resets it.

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

```md
## Skill Index Audit Report

root: <absolute path>
verdict: ok | rebuild-needed | inconclusive

### Result
reason: <reason string when verdict is not ok, otherwise "all checks passed">
failing_node: <absolute path to first failing node, or blank if none>

### Continue-Past Findings
| Type | Node | Detail |
| --- | --- | --- |
| orphan | <path> | <overlay, no corresponding raw index> |
| malformed-line | <path> | <line content> |
| phantom-index | <path> | <not reachable from cascade root> |
| trigger-shape | <path> | <overlay section heading: reason non-conformant> |
| keyword-quality | <path> | <entry key: specific violation> |
(omit table if no findings)

### Visited Nodes (on failing path, if applicable)
1. <absolute path>
...
(omit if no reference loop)
```

---

## Don'ts

- Do not rebuild. Do not invoke the builder.
- Do not modify any file.
- Do not open skill contents (any file other than `skill.index`, `skill.index.md`).
- Do not keep walking after a fail-fast check fails.
- Do not treat orphans or phantom indexes as `rebuild-needed` triggers by themselves.
- Do not judge curator intent, shortcut placement optimality, or aesthetic choices.
- Do not consult the network.
