---
name: skill-index-building
description: Dispatch skill. Creates or updates skill.index and skill.index.md at every indexed directory in a skill tree. Integrity stamp written by auditor after PASS.
---

# Skill Index Building

Dispatch skill. Creates or updates two index artifacts at every indexed dir in a skill tree: `skill.index` (raw index) and `skill.index.md` (metadata overlay). Integrity stamp (`skill.index.sha256`) written by auditor after PASS — not builder.

Artifacts:

Every indexed dir gets exactly two files from builder:

| File | Description |
| --- | --- |
| `skill.index` | Plain-text raw index. One entry per line. No header, no footer, no blank lines. Deterministic for mechanical portion. |
| `skill.index.md` | Markdown metadata overlay. H1 + one `## name` section per entry. One-sentence paragraphs. Requires compression pass before write. |

Absent stamp = unaudited since last build, not needs-rebuild.

Invocation:

Use Dispatch agent (zero context): "Read and follow `instructions.txt` (in this dir). Input: `root=<path> [--dot-allow <name,...>] [--rebuild]`"

Parameters:
`root` (required): absolute path to invocation root.
`--dot-allow` (optional): comma-separated dot-folder bare names to traverse (no globs, no paths). Default: empty.
`--rebuild` (optional): full-rebuild — regenerates all nodes regardless of stored raw index content.

Returns change manifest: nodes created, updated, unchanged, blocked (overlay compression failed), broken-shortcut targets, unreadable dir skips.

Raw Index Format (`skill.index`):

Each entry is one line:

```
key: keyword, keyword, keyword
```

Single space after colon. `, ` between keywords.
Entry key: child dir name. Sub-node marker: append `/` when child contains own `skill.index`.
Self entry: key is `.` when current dir is combo node (manifest present + at least one indexable child). Self entry first, before sorted block. Pure leaf (manifest present, no indexable children): no index node, no self entry.
Sort: byte-lexicographic on full UTF-8 key. `.` always first. Shortcut keys share sort space with single-segment keys; `/` (0x2F) compares by byte value. Shorter key first when one is proper prefix of another.
Keywords: natural-language trigger phrases. Mustn't duplicate entry key verbatim. Synonyms, phrasings, related concepts.

Metadata Overlay Format (`skill.index.md`):

H1: dir's identifying title.
Optional preamble (at most two sentences) between H1 and first section. Helps locate skill; doesn't describe index mechanics.
One `## name` section per entry key in same order as raw index. Self entry's section uses dir's own name, not `.`.
Each section: single paragraph; one sentence preferred.
Mustn't describe trailing slashes, dot entries, nav mechanics, or index artifact internals.
Must pass full compression pass before builder writes. Compression fails → builder aborts node (blocked), leaves prior artifacts unchanged, continues with siblings.

Build Logic:

Incremental Mode (default):

For each node:
1. Compute mechanical portion: self entry (combo node — manifest + at least one indexable child) + direct-child entries.
2. Merge with preserved shortcut entries from existing `skill.index`.
3. Sort combined list per sort rule.
4. Serialize as one line per entry.
5. Compute SHA-256 of serialized content.
6. Compare against SHA-256 of stored `skill.index` bytes. `skill.index.sha256` stamp not consulted — auditor's artifact, not builder freshness marker.
7. Hashes match: no writes. Record unchanged.
8. Hashes differ (or no stored `skill.index`): generate overlay in memory → compression check → on success, write strict order: `skill.index` first, then `skill.index.md`. Don't terminate normally between two writes of single node.

Full-Rebuild Mode (`--rebuild`):

Regenerates all nodes regardless of stored raw index content. Same write order and compression gate as incremental.

Write Order (strict):

1. `skill.index`
2. `skill.index.md`

Don't terminate normally between these two writes for single node.

Traversal Rules:

Walk downward from invocation root.
Skip dot-prefixed dirs by default; only traverse dot-folders named in `--dot-allow`.
Don't follow symlinks.
Dir has indexable children: write artifacts and descend.
Dir has no indexable children, no skill manifest: write empty `skill.index` (zero bytes) and overlay with only H1, no sections.
Dir has no indexable children but has skill manifest (pure leaf): don't write `skill.index`. Parent's index already references leaf as plain entry; leaf's manifest describes it.

Combo Nodes:

Combo node: dir with own skill manifest + at least one manifest-bearing child.
Emits `.` self entry in own `skill.index`. Emits sub-node-marked entry (key ending in `/`) in parent's `skill.index`. Manifest-bearing subdirs traversed normally.

Curator-Added Shortcut Entries:

Shortcut entries: multi-segment keys (e.g. `tools/compression/`). Curator-added; never mechanically generated.

When existing `skill.index` at node contains shortcut entries:
Preserve verbatim: same key, same keyword list, same character sequence.
Merge with freshly generated mechanical portion.
Sort combined list per sort rule. Self entry (if any) remains first.
Preserved shortcut target missing from filesystem: record as `broken-shortcut` in change manifest; emit entry unchanged. Don't repair or remove — curator decision.
Don't evaluate shortcut structural legality (subtree containment or acyclicity). Auditor's responsibility.
Curator keyword lists inside preserved shortcuts are authoritative even if non-conformant; treat as opaque text for that entry.

Error Handling:

Unreadable dir: skip, record as skipped in change manifest, continue with siblings.
Overlay compression failure: record as `blocked`, leave prior artifacts unchanged, continue.
Partial-write protection: don't terminate normally between two writes of single node.
Change manifest not producible: emit non-zero exit; don't silently succeed.

Footguns:

F1: Stamp consulted for change detection.
Mitigation: Builder never reads `skill.index.sha256` for change detection. Compare SHA-256 of recomputed raw content against SHA-256 of stored `skill.index` bytes. Stamp is auditor's artifact.

F2: Builder writes stamp.
Mitigation: Write order is `skill.index` → `skill.index.md`. No stamp write. Auditor writes stamp on PASS.

F3: Combo node treated as pure leaf.
Mitigation: Emit self entry AND enumerate manifest-bearing subdirs. Traversal not suppressed.

F4: Dot-folder allow-list used as path expression.
Mitigation: Allow-list entries: bare names only — no globs, paths, regexes.

F5: Builder erases curated shortcuts on rebuild.
Mitigation: Preserve shortcut entries verbatim across all runs.

Don'ts:

Doesn't author skill content.
Doesn't validate or audit skills.
Doesn't decide which dot-folders to traverse — supplied via `--dot-allow`.
Doesn't emit `skill.index` with `.md` extension.
Doesn't embed nav or mechanical explanation in overlay sections.
Doesn't write `skill.index.sha256`. Stamp-writing is auditor's responsibility; only after PASS.
Doesn't consult network.
Doesn't modify files outside two artifact classes (raw index and overlay).

Related:

`skill-index` — root spec and toolkit overview.
`skill-index-auditing` — validates cascade, writes stamp; run after building.
`skill-index-crawling` — consumes artifacts produced here.
`compression` — required for overlay compression pass before write.
