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
