---
name: skill-index-building
description: >-
  Produces the three index artifacts at each directory in a skill tree:
  skill.index (raw), skill.index.md (overlay), skill.index.sha256 (stamp).
---

Dispatch (Dispatch agent, zero context): "Read and follow `instructions.txt` (in this directory). Input: `root=<path> [--dot-allow <name,...>] [--rebuild]`"

`root` (required): absolute path to invocation root.
`--dot-allow` (optional): comma-separated bare dot-folder names to traverse. Default: empty.
`--rebuild` (optional): regenerate all nodes regardless of stamp state.

**Artifact triple per directory:** `skill.index` | `skill.index.md` | `skill.index.sha256`

**Raw index format:** `key: keyword, keyword, keyword` — one line per entry, no blanks; self entry `.` first; sub-node marker `/` appended to key when child has own index; byte-lex sort.

**Overlay format:** H1 + one `## name` section per entry (same order as raw index); single-sentence paragraphs; no index-mechanic prose; must pass compression check before write.

**Stamp:** SHA-256 hex of stored `skill.index` bytes. Written only after overlay refreshed (spec R18). Exception: no overlay exists yet (spec R21).

**Write order (strict):** `skill.index` → `skill.index.md` → `skill.index.sha256`. No early termination between writes.

**Shortcut entries:** curator-added, not generated. Preserved verbatim on every run — same key, same keywords, merged with mechanical portion, sorted in. Broken shortcut target → record in manifest, emit entry unchanged. Builder does not evaluate subtree containment or acyclicity (auditor's job).

**Combo node:** emits self entry in own index + sub-node-marked entry in parent index; subdirectories traversed.

Returns: change manifest (created / updated / unchanged / blocked / broken-shortcut / orphan / phantom).

Related: `skill-index`, `skill-index-auditing`, `skill-index-crawling`, `compression`
