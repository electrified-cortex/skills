---
name: skill-index-building
description: Dispatch skill. Creates or updates skill.index and skill.index.md at every indexed directory in a skill tree. Integrity stamp written by auditor after PASS.
---

# Skill Index Building

Dispatch skill. Creates or updates two index artifacts at every indexed directory in a skill tree: `skill.index` (raw index) and `skill.index.md` (metadata overlay). The integrity stamp (`skill.index.sha256`) is written by the auditor after a PASS — not by the builder.

## Artifacts

Every indexed directory receives exactly two files from the builder:

| File | Description |
| --- | --- |
| `skill.index` | Plain-text raw index. One entry per line. No header, no footer, no blank lines. Deterministic for the mechanical portion. |
| `skill.index.md` | Markdown metadata overlay. H1 + one `## name` section per entry. One-sentence paragraphs. Requires compression pass before write. |

The integrity stamp (`skill.index.sha256`) is written by the auditor after a PASS verdict, not by the builder. Absence of a stamp after a build means "unaudited since last build," not "needs rebuild."

## Dispatch

Variables:

`<instructions>` = `instructions.txt` (NEVER READ)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `root=<path> [--dot-allow <name,...>] [--rebuild]`
`<tier>` = `standard` — generative index writing requires reliable output quality
`<description>` = `Skill Index Build: <path>`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`

Follow `dispatch` skill. See `../../dispatch/SKILL.md`.
Should return: change manifest (nodes created, updated, unchanged, blocked, broken-shortcut, skipped)

Parameters:

- `root` (required): absolute path to the invocation root directory.
- `--dot-allow` (optional): comma-separated list of dot-folder bare names to traverse (no globs, no paths). Default: empty.
- `--rebuild` (optional): full-rebuild mode — regenerates all nodes regardless of stored raw index content.

Returns: a change manifest listing which nodes were created, updated, unchanged, blocked (overlay failed compression), broken-shortcut targets, and any unreadable directory skips.

## Raw Index Format (`skill.index`)

Each entry is one line:

```text
key: keyword, keyword, keyword
```

- Single space after the colon. `, ` between keywords.
- Entry key is the child's directory name.
- Sub-node marker: append `/` to the key when that child directory contains its own `skill.index`.
- Self entry: key is literally `.` when the current directory is a combo node (skill manifest present and at least one indexable child). Self entry appears first, before the sorted block. Pure leaf directories (manifest present, no indexable children) do not receive an index node and do not emit a self entry.
- Sort: entries sorted by key using byte-lexicographic comparison of the full UTF-8 key string. Self entry (`.`) always first. Multi-segment shortcut keys participate in the same sort space as single-segment keys; `/` (0x2F) compares by byte value. Shorter key sorts first when one key is a proper prefix of another.
- Keywords: natural-language trigger phrases. Must not duplicate the entry key verbatim. Synonyms, phrasings, related concepts.

## Metadata Overlay Format (`skill.index.md`)

- H1: the directory's identifying title.
- Optional preamble (at most two sentences) between H1 and first section. Helps locate a skill; does not describe index mechanics.
- One `## name` section per entry key in the same order as the raw index. The self entry's section uses the directory's own name, not `.`.
- Each section: a single paragraph. One sentence preferred.
- Must not describe trailing slashes, dot entries, navigation mechanics, or any index artifact internals.
- Must pass a full compression pass before the builder writes it. If compression fails, the builder aborts the node (records as blocked), leaves all prior artifacts unchanged, and continues with siblings.

### Overlay as Trigger Surface

The overlay is loaded into agent context via `skill-index-integration` and is consulted for skill selection. Sections must state **when/why to load the skill** (triggering conditions), not describe what the skill does.

- **R22 — Trigger not description**: each `## name` section must express the conditions under which the skill should be loaded. Sections that read as summaries without stating a trigger are non-conformant.
- **R23 — Trigger kinds**: sections may use human-triggered (operator/user phrases the agent listens for, e.g., `"is the PR ready?"`) and/or agent-self-triggered (plain imperatives the agent applies to its own state, e.g., `Run at the start of every idle cycle.`).
- **R24 — Preamble convention**: if a preamble is used, establish the trigger convention in one sentence (e.g., `Match the operator's words or your current situation to an entry, then load that skill.`). Do not repeat per-entry prefixes — consolidate into the preamble.
- **R25 — Compact prose**: comma- or semicolon-separated trigger lists are preferred over full sentences when multiple triggers apply.
- **R26 — Preserve shortcut overlays**: do not reorder or rewrite overlay sections for preserved shortcut entries. Curator-authored trigger prose in those entries is opaque text.

## Build Logic

### Incremental Mode (default)

For each node:

1. Compute the mechanical portion: self entry (if combo node — manifest present AND at least one indexable child) + direct-child entries.
2. Merge with any preserved shortcut entries from the existing `skill.index` (see Shortcut Entries below).
3. Sort the combined list per the sort rule.
4. Serialize as one line per entry.
5. Compute SHA-256 of that serialized content.
6. Compare against the SHA-256 of the currently stored `skill.index` bytes. The stored `skill.index.sha256` stamp is not consulted — it is the auditor's sign-off artifact, not a builder freshness marker.
7. If hashes match: no writes for this node. Record as unchanged. Move on.
8. If hashes differ (or no stored `skill.index` exists): generate overlay in memory → run compression check → on success, write in strict order: `skill.index` first, then `skill.index.md`. Do not terminate normally between the two writes of a single node.

### Full-Rebuild Mode (`--rebuild`)

Regenerates all nodes regardless of stored raw index content. Same write order and compression gate as incremental.

### Write Order (strict)

1. `skill.index`
2. `skill.index.md`

No early termination between these two writes for a single node.

## Traversal Rules

- Walk downward from the invocation root.
- Skip dot-prefixed directories by default. Only traverse dot-folders explicitly named in `--dot-allow`.
- Do not follow symlinks.
- When a directory has indexable children, write artifacts there and descend.
- When a directory has no indexable children and no skill manifest: write empty `skill.index` (zero bytes) and an overlay containing only the H1 and no sections.
- When a directory has no indexable children but has a skill manifest (a pure leaf skill): do not write any `skill.index` at that directory. The parent's index already references the leaf as a plain entry; the leaf's own skill manifest describes it.

### Combo Nodes

A combo node is a directory that has both a skill manifest of its own and at least one manifest-bearing child. A combo node:

- Emits a `.` self entry in its own `skill.index`.
- Emits a sub-node-marked entry (key ending in `/`) in its parent's `skill.index`.
- Has its manifest-bearing subdirectories traversed normally.

## Curator-Added Shortcut Entries

Shortcut entries have multi-segment keys (e.g. `tools/compression/`). They are curator-added and are never mechanically generated.

When the existing `skill.index` at a node already contains shortcut entries:

- Preserve them verbatim: same key, same keyword list, same character sequence.
- Merge with the freshly generated mechanical portion.
- Sort the combined list per the sort rule. Self entry (if any) remains first.
- If a preserved shortcut's target does not exist on the current filesystem: record as `broken-shortcut` in the change manifest; emit the entry unchanged. Do not repair or remove it — that is a curator decision.
- Do not evaluate shortcut structural legality (subtree containment or acyclicity). That is the auditor's responsibility.
- Curator keyword lists inside preserved shortcuts are authoritative even if they do not conform to the standard `key: keyword, keyword, keyword` format; treat them as opaque text for that entry.

## Error Handling

- Unreadable directory: skip, record in change manifest as skipped, continue with siblings.
- Overlay compression failure: record node as `blocked`, leave all prior artifacts unchanged, continue.
- Partial-write protection: do not terminate normally between the two writes of a single node.
- Change manifest not producible: emit a non-zero exit signal; do not silently succeed.

## Footguns

F1: Stamp consulted for change detection.
Mitigation: The builder never reads `skill.index.sha256` for change detection. Compare the SHA-256 of the recomputed raw content against the SHA-256 of the stored `skill.index` bytes directly. The stamp is the auditor's artifact.

F2: Builder writes the stamp.
Mitigation: Enforce N6. The builder's write order is `skill.index` → `skill.index.md`. No stamp write. Stamp is written by the auditor on PASS.

F3: Combo node treated as pure leaf.
Mitigation: Emit self entry AND enumerate manifest-bearing subdirectories. Traversal not suppressed.

F4: Dot-folder allow-list used as path expression.
Mitigation: Allow-list entries are bare names only — no globs, paths, or regexes.

F5: Builder erases curated shortcuts on rebuild.
Mitigation: Preserve shortcut entries verbatim across all runs.

## Don'ts

- Does not author skill content.
- Does not validate or audit skills.
- Does not decide which dot-folders to traverse — that decision is supplied via `--dot-allow`.
- Does not emit `skill.index` with a `.md` extension.
- Does not embed navigation or mechanical explanation in overlay sections.
- Does not write `skill.index.sha256`. Stamp-writing is the auditor's responsibility, performed only after a PASS verdict.
- Does not consult the network.
- Does not modify any file outside the two artifact classes (raw index and overlay).

## Related

- `skill-index` — root spec and toolkit overview
- `skill-index-auditing` — validates the cascade and writes the stamp; run after building
- `skill-index-crawling` — consumes the artifacts produced here
- `compression` — compression pass required for overlay before write
