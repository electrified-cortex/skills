---
id: "10-0963"
title: "Hash-Record Shared Worktree Friction — Investigation Findings"
date: "2026-05-04"
decision: "option-4-cleanup"
status: "draft"
---

# 10-0963 — Hash-Record Shared Worktree Friction

## Summary

`.hash-record/` is git-tracked and shared across all worktrees. 8+ consumer skills
write to it. Merge conflicts reported once (10-0951). Investigation evaluated 4 options.
Option 4 selected: status quo + automated post-merge cleanup via existing `hash-record-prune`.

## Why Not Options 1–3

**Option 1 — Per-worktree dirs:** Breaks cache-hit model; consumers can't cross-validate.

**Option 2 — Git merge driver:** Complexity overhead for friction reported only once.

**Option 3 — Schema change:** Migration cost unjustified; substrate design is sound.

## Decision

**Option 4 — Status Quo + Automated Cleanup.**

Design holds. Prune tool already exists. Integrating into post-finalization workflow
eliminates friction without schema changes, merge driver complexity, or cache model breakage.

## Cleanup Procedure

Run after all task branches for a batch have merged:

1. `prune.ps1 -dry_run` — preview orphaned records
2. `prune.ps1` — delete them
3. `git add .hash-record/` + `git commit -m "chore: prune orphaned hash records — post-merge cleanup"`
4. `git status` — verify no untracked files in `.hash-record/`

Safe to run anytime. Frequency: once per finalization batch.

## Integration Point

Add to finalization checklist after last task branch merges, before release PR.
Slot: after `worktree-cleanup` skill, before changelog finalization.

## Related Tasks

- **10-0951** — original merge conflict report that triggered investigation
- **10-0962** — hash-record prune tool implementation

## Operator Final Decision (2026-05-05)

Operator refined Option 4 away from auto-prune in finalization. The deterministic protocol for hash-record collision at merge time is:

1. **Remove the incoming record** (worktree-side orphan). Never let it pollute dev's hash-record.
2. **Keep target as-is** (dev-side record survives).
3. **Re-audit the affected file(s)** in target post-merge. Re-audit produces a fresh record regardless — cheap and deterministic.

**Yellow-flag escalation** only if re-audit itself cannot run (skill broken, file deleted in target, etc.). Routine collisions require no operator involvement.

**Integration point:** This protocol belongs in Overseer's workflow (context/memory), not the finalization-runbook. Overseer detects the collision at merge time and executes the protocol autonomously.

**Supersedes:** Earlier recommendation of `hash-record-prune` in finalization checklist. No prune step. Detection + remove-incoming + re-audit is the full resolution path.
