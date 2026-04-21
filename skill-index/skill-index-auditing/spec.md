---
name: skill-index-auditing
description: >-
  Specification for the validator half of the skill-index toolkit — detects
  first failure in a cascade, signals whether a rebuild is needed, and writes
  the integrity stamp on PASS as a sign-off artifact.
type: spec
---

# Skill Index Auditing Specification

Normative spec for the auditor. The auditor validates existing index artifacts and, on PASS, writes the integrity stamp (`skill.index.sha256`) as a sign-off artifact. It conforms to the root `skill-index` spec.

## Changelog

- R22 added: auditor writes `skill.index.sha256` on PASS.
- R23 added: auditor does not write (and does not delete) the stamp on FAIL or inconclusive.
- C2 updated: auditor must not modify any artifact except writing the stamp on PASS.
- N2 updated: auditor does not modify any file except the stamp on PASS.
- D1 updated: lightweight check budget, plus one write on PASS.

---

## Purpose

Provide a cheap, fast trigger that tells a host agent whether to invoke `skill-index-building`. The auditor detects the first structural problem in an index cascade and returns a rebuild-needed signal with a reason. It does not rebuild.

---

## Scope

Applies to any directory subtree containing one or more index nodes. The auditor walks the cascade, checks each node against the root spec, and stops on the first failure it cannot safely continue past. Overlay-content freshness (whether a metadata overlay is semantically in sync with its raw index beyond stamp-hash equality) is out of scope for the auditor; that is the builder's concern per root spec R18. Optimality judgments (whether a shortcut entry is well-placed, whether a curator's choice is best) are also out of scope — the auditor validates correctness, not intent.

---

## Definitions

- **Auditor** — the actor performing operations defined by this spec.
- **Audit report** — the auditor's structured output: a verdict, a reason (if any), and the path to the first failing node (if any).
- **Verdict** — one of `ok`, `rebuild-needed`, `inconclusive`.
- **PASS** — informal shorthand for an `ok` verdict: the walk completed with no fail-fast failures and no malformed-line findings per R12. Used throughout this spec for readability; equivalent to `ok`.
- **Fail-fast check** — a check that, on failure, produces a `rebuild-needed` verdict and halts the audit.
- **Continue-past check** — a check that, on failure, is recorded in the audit report but does not halt the audit.
- **Orphan** — an integrity stamp or metadata overlay with no corresponding raw index.
- **Malformed-line finding** — a recorded observation that a raw index line lacks a key, lacks a colon, or contains forbidden characters. Recorded without halting, but escalates the final verdict per R12.
- **Phantom index** — per root spec: an index file that exists within the invocation root's subtree but is not reachable, directly or transitively, from the root node's cascade.
- **Reference loop** — per root spec: a cycle in the cascade graph.

---

## Requirements

### Invocation

R1. The auditor must accept an invocation root and restrict its work to the subtree rooted there.

R2. The auditor must not modify any file during its validation walk. After the walk completes and a PASS verdict is determined, the auditor writes `skill.index.sha256` per R22. On any non-PASS verdict, no files are modified at any point.

### Per-Node Checks (Fail-Fast)

R3. The auditor must verify that each visited raw index has an accompanying integrity stamp. Missing stamp is `rebuild-needed`.

R4. The auditor must verify that the integrity stamp matches the SHA-256 of the raw index's current stored bytes. Mismatch is `rebuild-needed`.

R5. The auditor must verify that every entry in a raw index resolves to an on-disk target within the current node's subtree: a leaf skill's directory (for a leaf or combo classification), a descendant directory with its own raw index (for a sub-node classification), or both (for a combo classification). A shortcut entry (multi-segment relative path per root spec R33) must resolve by walking the path from the current node. A missing or out-of-subtree target is `rebuild-needed`.

R6. The auditor must verify that every manifest-bearing direct child of the current directory is represented by an entry in this node's raw index — unless that child is reached by a shortcut entry already present elsewhere in the cascade. A manifest-bearing direct child with no reachable entry is `rebuild-needed`.

R7. The auditor must verify that every combo node has a self entry in its own raw index (per root spec R9). A missing self entry is `rebuild-needed`.

R8. The auditor must verify that every combo node enumerates its manifest-bearing subdirectories in its own raw index (per root spec R10), either as direct-child entries or as shortcut entries. A missing entry is `rebuild-needed`.

R9. The auditor must verify that every combo node is classified as combo in its parent's raw index (per root spec R11). A missing or wrong classification is `rebuild-needed`.

R10. The auditor must detect reference loops in the cascade graph. On every resolution path — whether the step is a direct-child descent, a shortcut-entry path-walk, or a combo-node descent into its own sub-node — the auditor tracks the full ordered set of nodes visited on that path. If any step would land on a node already present in that set, the cascade contains a loop. A reference loop is `rebuild-needed`. Per root spec R34, the auditor is the primary enforcer of this rule; the builder does not introduce cycles, and the crawler merely terminates them at consumption time.

### Per-Node Checks (Continue-Past)

R11. The auditor must record any orphan (a stamp or overlay with no corresponding raw index) without halting. Orphans are reported but are not by themselves a `rebuild-needed` trigger — they are janitorial signals.

R12. The auditor must record any malformed raw index line (key missing, colon missing, forbidden characters) without halting, and must continue auditing other lines of the same node. If the node completes inspection without a fail-fast failure, the presence of any malformed line raises the final verdict to `rebuild-needed`. If a fail-fast check halts the node before inspection completes, R12 does not apply at that node — R18 governs.

R13. The auditor must record any phantom index (an index file within the invocation root's subtree not reachable from the root node's cascade) without halting. Phantom indexes are reported but are not by themselves a `rebuild-needed` trigger — they are janitorial signals, comparable to orphans.

### Check Ordering

R14. Within a single node, the auditor must evaluate fail-fast checks before continue-past checks. When a fail-fast check fails, the auditor halts per R18 without running the continue-past checks at that node.

### Walk Order

R15. The auditor must walk depth-first from the invocation root, visiting parent nodes before their children, so that parent-level failures halt the audit before the auditor descends into potentially invalid subtrees. Shortcut entries are resolved by path-walk at the node that declares them; the resolution is subject to R10's loop detection.

R16. The auditor must not follow symlinks by default.

R17. The auditor must apply the same dot-folder skip and allow-list rules as the builder (root spec R30 and R31).

### Halting and Reporting

R18. On the first fail-fast failure, the auditor must halt and return an audit report with verdict `rebuild-needed`, the reason, and the path of the failing node.

R19. If the walk completes with no fail-fast failure, the auditor must return an audit report with the continue-past findings attached. The verdict is `rebuild-needed` if any node produced a malformed-line finding under R12; otherwise the verdict is `ok`. Orphans and phantom indexes alone do not escalate the verdict.

R20. If the auditor cannot reach a fail-fast conclusion (for example, a directory it was asked to audit is unreadable at the root), it must return verdict `inconclusive` with the reason.

### Consistency with Root

R21. The auditor must treat the root spec as authoritative. When a check in this spec conflicts with the root spec, the root spec wins and the check must be re-derived from it.

### Stamp Sign-Off

R22. After the walk completes and a PASS verdict is determined, the auditor must write `skill.index.sha256` alongside each raw index it validated during the walk. Stamps are written only after the verdict is known — not incrementally during the walk — so that a non-PASS verdict never leaves partial stamp state. The stamp content is the SHA-256 hex digest of the exact bytes of the stored `skill.index` for that node — no trailing newline unless the raw index itself ends with one; no other content. This stamp is the auditor's sign-off artifact, confirming the cascade was structurally valid at time of audit. Writing the stamp is the only file-write the auditor performs.

R23. On any verdict other than PASS (`rebuild-needed` or `inconclusive`), the auditor must not write any stamp. Existing stamps are left untouched — stale stamps remain stale, absent stamps remain absent. A stale or absent stamp after a non-PASS verdict is intentional: it signals "unaudited since last build," giving the host agent a clear indicator that a build-then-audit cycle is required.

---

## Constraints

C1. The auditor must not access the network.

C2. The auditor must not modify any index artifact during its walk. The sole exception is writing `skill.index.sha256` after the walk completes and a PASS verdict is determined, per R22. On any non-PASS verdict, no files are modified.

C3. The auditor must not invoke the builder. Triggering the builder is the host agent's decision based on the audit report.

C4. The auditor must not open skill contents.

C5. The auditor must not judge the optimality, placement, or curation quality of an index. Correctness only.

---

## Behavior

B1. The auditor produces an audit report and, on PASS, writes the integrity stamp alongside each validated raw index per R22. No other outputs or side effects are permitted.

B2. When the auditor encounters a child directory it cannot read, it records the failure as `inconclusive` for that subtree and continues with siblings. Subtree-level `inconclusive` records aggregate into the final verdict per P3. Top-level unreadability is handled per E1.

B3. When the auditor encounters an orphan stamp, orphan overlay, or phantom index, it records it without halting. None of these alone sets the verdict to `rebuild-needed`.

B4. The auditor's visited-node tracking under R10 applies to every step of every resolution path, regardless of descent kind. Each time the auditor opens a new node — as a direct child, as the endpoint of a shortcut path-walk, or as the sub-node of a combo — it appends the node to the current path's visited set before inspecting it. If the step would land on a node already in that set, the auditor declares a reference loop per R10 and halts. The visited set is scoped to the current resolution path; crossing into a sibling subtree resets it.

---

## Defaults and Assumptions

D1. The auditor is expected to be run by a lightweight LLM class. Its checks are chosen to fit within that budget. On PASS, it performs one stamp write per validated node, all executed after the walk completes; each write is small and atomic.

D2. The dot-folder allow-list used by the auditor must match the one used by the builder for the same tree. The host agent supplies both.

---

## Error Handling

E1. Invocation-root unreadable: return verdict `inconclusive` with the reason and halt.

E2. Per-subtree unreadability: per B2, record and continue with siblings.

E3. If the audit report itself cannot be produced, the auditor must emit a non-zero exit signal.

E4. If one or more stamp writes fail after a PASS verdict (disk error, permission denied, I/O failure), the auditor must downgrade the verdict to `inconclusive`, list the failed nodes in the audit report, and emit a non-zero exit signal. A partial stamp state — some nodes stamped, others not — is not acceptable; incomplete sign-off is treated as no sign-off.

---

## Precedence Rules

P1. Fail-fast failures take precedence over continue-past findings in the audit report.

P2. A `rebuild-needed` verdict takes precedence over an `ok` verdict. Any single fail-fast failure downgrades an otherwise-ok cascade.

P3. An `inconclusive` verdict takes precedence over `ok` but not over `rebuild-needed`. If any part of the cascade triggered `rebuild-needed`, that is the verdict; otherwise if any part was inconclusive, the verdict is inconclusive.

---

## Footguns

F1: Auditor rebuilds instead of signalling.
Description: The auditor tries to fix problems it finds rather than halting and returning `rebuild-needed`.
Why: The auditor is designed to be the cheap fast check. Builder work is not cheap. Mixing the two defeats the triage and makes audits heavy.
Mitigation: Enforce R2 and C3. The auditor's outputs are: a verdict (always) and a stamp write (on PASS only). It does not rebuild or patch index content.

F2: Auditor keeps walking after a fail-fast failure.
Description: The auditor collects all failures before returning.
Why: The auditor exists to trigger the builder. The builder will find all the problems anyway. Continuing past the first halting failure wastes time and produces a noisy report.
Mitigation: Enforce R18. Halt on first fail-fast failure.

F3: Orphans or phantoms treated as fail-fast failures.
Description: A stray stamp, overlay, or unreachable index marks the cascade `rebuild-needed`.
Why: These are usually leftovers or pre-curation artifacts, not corruption. Triggering a full rebuild for them is overkill.
Mitigation: Enforce R11, R13, and B3. Orphans and phantoms are continue-past findings.

F4: Auditor judges shortcut placement.
Description: The auditor flags a shortcut entry as wrong because a more direct path exists, or a deeper index would be prettier.
Why: Shortcut entries are curator-added per root spec R33. The curator's choice may be optimal for the consuming agent even if it looks redundant. The auditor must validate resolution, not intent.
Mitigation: Enforce C5. Correctness-only. The auditor's sole structural concern about shortcuts is loop prevention (R10) and subtree-containment (R5).

F5: Loop detection skipped under shortcut resolution.
Description: The auditor resolves shortcut entries without tracking visited nodes, so a cycle in the cascade graph goes undetected.
Why: Without cycle tracking, a curator-added shortcut that loops back into a parent's subtree can send the auditor (and later consumers) into unbounded resolution. The bug is silent and only surfaces under specific tree shapes.
Mitigation: Enforce R10 and B4. Track nodes on each resolution path. On revisit, declare a loop and halt.

---

## Don'ts

N1. The auditor does not rebuild.

N2. The auditor does not modify any file except writing `skill.index.sha256` on PASS per R22. On FAIL or inconclusive, it leaves all files untouched — including any pre-existing stale stamps.

N3. The auditor does not invoke the builder.

N4. The auditor does not re-derive its own rules — it validates against the root spec.

N5. The auditor does not produce metadata overlay content. It checks what is there.

N6. The auditor does not judge curator intent. Optimality, aesthetic, or redundancy judgments are out of scope.
