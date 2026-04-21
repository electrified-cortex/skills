# Skill Index Building

Dispatch skill. Creates or updates the three index artifacts at every indexed directory in a skill tree: `skill.index` (raw index), `skill.index.md` (metadata overlay), `skill.index.sha256` (integrity stamp). Conforms to the root `skill-index` spec.

## Artifacts

Every indexed directory receives exactly these three files:

| File | Description |
| --- | --- |
| `skill.index` | Plain-text raw index. One entry per line. No header, no footer, no blank lines. Deterministic for the mechanical portion. |
| `skill.index.md` | Markdown metadata overlay. H1 + one `## name` section per entry. One-sentence paragraphs. Requires compression pass before write. |
| `skill.index.sha256` | SHA-256 hex digest of `skill.index`'s stored bytes. Written only after overlay is refreshed. |

## Invocation

Dispatch via Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory). Input: `root=<path> [--dot-allow <name,...>] [--rebuild]`"

Parameters:

- `root` (required): absolute path to the invocation root directory
- `--dot-allow` (optional): comma-separated list of dot-folder bare names to traverse (no globs, no paths). Default: empty.
- `--rebuild` (optional): full-rebuild mode — regenerates all nodes regardless of stamp state.

Returns: a change manifest listing which nodes were created, updated, unchanged, blocked (overlay failed compression), broken-shortcut targets, and any orphan or phantom findings.

## Raw Index Format (`skill.index`)

Each entry is one line:

```
key: keyword, keyword, keyword
```

- Single space after the colon. `,` between keywords.
- Entry key is the child's directory name.
- Sub-node marker: append `/` to the key when that child directory contains its own `skill.index`.
- Self entry: key is literally `.` when the current directory contains a skill manifest. Self entry appears first, before the sorted block.
- Sort: entries sorted by key using byte-lexicographic comparison of the full UTF-8 key string. Self entry (`.`) always first. Multi-segment shortcut keys participate in the same sort space as single-segment keys; `/` (0x2F) compares by byte value. Shorter key sorts first when one key is a proper prefix of another.
- Keywords: natural-language trigger phrases. Must not duplicate the entry key verbatim. Synonyms, phrasings, related concepts.

## Metadata Overlay Format (`skill.index.md`)

- H1: the directory's identifying title.
- Optional preamble (at most two sentences) between H1 and first section. Helps locate a skill; does not describe index mechanics.
- One `## name` section per entry key in the same order as the raw index. The self entry's section uses the directory's own name, not `.`.
- Each section: a single paragraph. One sentence preferred.
- Must not describe trailing slashes, dot entries, navigation mechanics, or any index artifact internals.
- Must pass a full-compression pass before the builder writes it. If compression fails, the builder aborts the node (records as blocked), leaves all three prior artifacts unchanged, and continues with siblings.

## Integrity Stamp (`skill.index.sha256`)

- SHA-256 hex digest of the exact bytes of the stored `skill.index`.
- Written only when a refreshed overlay exists for those same bytes (spec R18), EXCEPT when no overlay exists at all for the node — in that case the stamp may be written immediately after the raw index (spec R21).
- When R18 and R21 both could apply, R18 takes precedence.

## Build Logic

**Incremental mode (default):**

1. Compute SHA-256 of the raw index that would be written (mechanical portion + any preserved shortcut entries, sorted per sort rule).
2. Compare against stored `skill.index.sha256`.
3. If hashes match: no writes for this node.
4. If hashes differ (or stamp missing): generate overlay in memory → run compression check → on success, write `skill.index`, then `skill.index.md`, then `skill.index.sha256` in strict order. No early termination between the three writes.

**Full-rebuild mode (`--rebuild`):**

- Regenerates all nodes regardless of stamp state.
- Same write order and compression gate as incremental.
- Stamps are not reset to the new raw content until the overlay is refreshed (spec R27).

**Write discipline:**

- Raw index only written when computed content differs from stored, or when `--rebuild` is in effect.
- Stamp written only when R18 or R21 is satisfied.

## Traversal Rules

- Walks downward from the invocation root.
- Skips dot-prefixed directories by default.
- `--dot-allow` list: bare names only; no globbing, no paths, no regexes.
- Does not follow symlinks.
- Combo nodes (directory is both a leaf skill and a parent of further leaf skills): emits a self entry in own `skill.index` and a sub-node-marked entry in parent's `skill.index`; traverses manifest-bearing subdirectories.
- Empty directory (no indexable children, no manifest): writes empty `skill.index` (zero bytes), H1-only overlay, and stamp of SHA-256 of zero bytes.
- Directory with no indexable children but with manifest: writes `skill.index` with only a self entry.

## Curator-Added Shortcut Entries

Shortcut entries (multi-segment keys, e.g. `tools/compression/`) are curator-added, not mechanically generated.

When the builder runs over a node whose existing `skill.index` already contains shortcut entries:

- Preserve them verbatim: same key, same keyword list, same character sequence.
- Merge them with the freshly regenerated mechanical portion.
- Sort the combined list per the sort rule. Self entry (if any) remains first.
- If a preserved shortcut's target does not exist on the current filesystem: record as broken shortcut in the change manifest; emit the entry unchanged. Do not repair or remove — that is a curator decision.
- The builder does not evaluate shortcut structural legality (subtree containment, acyclicity). That is the auditor's responsibility.
- Curator keyword lists inside preserved shortcuts are authoritative even if they do not conform to R2's format; the builder treats them as opaque text.

## Error Handling

- Unreadable directory: skip, record in change manifest, continue with siblings.
- Overlay compression failure: record node as blocked, leave all prior artifacts unchanged, continue.
- Stamp write failure after overlay success: record node as drifted in change manifest, continue.
- Partial-write protection: the builder must not terminate normally between the three writes of a single node (spec E4).
- Change manifest not producible: emit non-zero exit signal; do not silently succeed.

## Footguns

F1: Stamp updated before overlay refresh.
Mitigation: Enforce spec R18. Exception: no overlay exists (spec R21). When both could apply, R18 takes precedence.

F2: Combo node treated as pure leaf.
Mitigation: Emit self entry AND enumerate manifest-bearing subdirectories. Traversal not suppressed.

F3: Dot-folder allow-list used as path expression.
Mitigation: Allow-list entries are bare names only — no globs, paths, or regexes.

F4: Builder erases curated shortcuts on rebuild.
Mitigation: Preserve shortcut entries verbatim across all runs (spec R36).

## Don'ts

- Does not author skill content.
- Does not validate or audit skills.
- Does not decide which dot-folders to traverse — that decision is supplied via `--dot-allow`.
- Does not emit `skill.index` with a `.md` extension.
- Does not embed navigation or mechanical explanation in overlay sections.

## Related

- `skill-index` — root spec and toolkit overview
- `skill-index-auditing` — validates the cascade; use before deciding to rebuild
- `skill-index-crawling` — consumes the artifacts produced here
- `compression` — compression pass required for overlay before write
