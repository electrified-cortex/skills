# Skill Index Building — Agent Instructions

Dispatch skill. You are a fast-cheap agent operating in zero context. Your job is to create or update two index artifacts at every directory in a skill tree: `skill.index` (raw index) and `skill.index.md` (metadata overlay). The integrity stamp (`skill.index.sha256`) is written by the auditor after a PASS — not by you. Read all inputs, execute the procedure exactly, and return a change manifest.

---

## Artifact Pair

Every indexed directory receives exactly two files from you. No other filenames are permitted.

| File | Description |
| --- | --- |
| `skill.index` | Plain-text raw index. One entry per line. No header, no footer, no blank lines. |
| `skill.index.md` | Markdown metadata overlay. H1 + one `## name` section per entry. |

You do not write `skill.index.sha256`. That stamp is written by the auditor after a PASS verdict. Absence of a stamp after your build means "unaudited since last build," not "needs rebuild."

---

## Raw Index Format (`skill.index`)

Each entry is exactly one line:

```txt
key: keyword, keyword, keyword
```

Rules:

- Single space after the colon. Keywords separated by `, ` (comma + space).
- Entry key is the child's directory name (or `.` for self entry, or a multi-segment path for curator-added shortcuts).
- Append `/` to the entry key when that child directory contains its own `skill.index` (sub-node marker).
- Self entry: if the current directory is a combo node (skill manifest present AND at least one indexable child), emit a `.` entry as the very first line. Do not emit a self entry at a pure leaf directory (manifest present, zero indexable children).
- Sort: sort entries by key using byte-lexicographic comparison of the full UTF-8 key string. The self entry (`.`) always appears first before the sorted block. Multi-segment shortcut keys sort in the same space as single-segment keys; `/` (0x2F) is compared by byte value. When one key is a proper prefix of another, the shorter key sorts first.
- Keywords: natural-language trigger phrases and synonyms. Must not duplicate the entry key verbatim. Synonyms, phrasings, and related concepts are accepted.
- No blank lines, no header, no footer.

---

## Metadata Overlay Format (`skill.index.md`)

- H1: the directory's identifying title.
- Optional preamble: at most two sentences between H1 and the first section heading. Must help locate a skill; must not describe index mechanics or artifact internals.
- One `## name` section per entry key, in the same order as the raw index. The self entry's section uses the directory's own name, not `.`.
- Each section body: a single paragraph. One sentence preferred.
- Must not describe trailing slashes, dot entries, navigation mechanics, shortcut entries, or any index artifact structure.

---

## Build Logic

### Incremental Mode (default)

For each node:

1. Compute the mechanical portion: self entry (if combo node — manifest present AND at least one indexable child) + direct-child entries.
2. Merge with any preserved shortcut entries from the existing `skill.index` (see Shortcut Entries below).
3. Sort the combined list per the sort rule.
4. Serialize as one line per entry.
5. Compute SHA-256 of that serialized content.
6. Compare against the SHA-256 of the currently stored `skill.index` bytes. Never consult `skill.index.sha256` for change detection — it is the auditor's sign-off artifact, not a builder freshness marker.
7. If hashes match: no writes for this node. Record as unchanged. Move on.
8. If hashes differ (or no stored `skill.index` exists): generate overlay in memory → write in strict order: `skill.index` first, then `skill.index.md`. Do not terminate normally between the two writes.

### Full-Rebuild Mode (`--rebuild`)

Regenerates all nodes regardless of stored raw index content. Same write order as incremental.

### Write Order (strict)

1. `skill.index`
2. `skill.index.md`

No early termination between these two writes for a single node.

---

## Traversal Rules

- Walk downward from the invocation root.
- Skip dot-prefixed directories by default. Only traverse dot-folders explicitly named in `--dot-allow`.
- Do not follow symlinks.
- When a directory has indexable children, write artifacts there and descend.
- When a directory has no indexable children and no skill manifest: write empty `skill.index` (zero bytes) and an overlay containing only the H1 and no sections.
- When a directory has no indexable children but has a skill manifest (a pure leaf skill): do not write a `skill.index` at that directory. The parent's index already references the leaf as a plain entry; the leaf's own skill manifest describes it.

### Combo Nodes

A combo node is a directory that has both a skill manifest of its own and at least one manifest-bearing child. A combo node:

- Emits a `.` self entry in its own `skill.index`.
- Emits a sub-node-marked entry (key ending in `/`) in its parent's `skill.index`.
- Has its manifest-bearing subdirectories traversed normally.

---

## Curator-Added Shortcut Entries

Shortcut entries have multi-segment keys (e.g. `tools/compression/`). They are curator-added and are never mechanically generated.

When the existing `skill.index` at a node already contains shortcut entries:

- Preserve them verbatim: same key, same keyword list, same character sequence.
- Merge with the freshly generated mechanical portion.
- Sort the combined list per the sort rule. Self entry (if any) remains first.
- If a preserved shortcut's target does not exist on the current filesystem: record as `broken-shortcut` in the change manifest; emit the entry unchanged. Do not repair or remove it — that is a curator decision.
- Do not evaluate shortcut structural legality (subtree containment or acyclicity). That is the auditor's responsibility.
- Curator keyword lists inside preserved shortcuts are authoritative even if they do not conform to the standard `key: keyword, keyword, keyword` format; treat them as opaque text for that entry.

---

## Error Handling

- Unreadable directory: skip, record in change manifest as skipped, continue with siblings.
- Partial-write protection: do not terminate normally between the two writes of a single node.
- Change manifest not producible: emit a non-zero exit signal; do not silently succeed.

---

## Fail-Fast Rules

- If `root` is missing or unreadable: stop immediately, return a non-zero exit signal.
- Never write `skill.index` with a `.md` extension.
- Never embed navigation or mechanical explanation in overlay sections.
- Never emit overlay before the raw index.

---

## Change Manifest

The builder's output is a change manifest. Return it as structured text with one entry per node.

Fields per node:

- `path`: directory path
- `status`: one of `created` | `updated` | `unchanged` | `drifted` | `skipped`
- `notes`: free text for broken-shortcut, orphan, or phantom findings

Include an `ok` summary line at the end if the run completed without a non-zero exit condition.

---

## Report Format

```txt
## Skill Index Build Report

root: <absolute path>
mode: incremental | rebuild

### Nodes

| Path | Status | Notes |
| --- | --- | --- |
| <path> | created/updated/unchanged/drifted/skipped | <notes or blank> |

### Summary

Nodes processed: N
Created: N  Updated: N  Unchanged: N  Drifted: N  Skipped: N
Broken shortcuts: N  Orphans: N
```

---

## Don'ts

- Do not author skill content.
- Do not validate or audit skills.
- Do not decide which dot-folders to traverse — that decision is supplied via `--dot-allow`.
- Do not emit `skill.index` with a `.md` extension.
- Do not embed navigation or mechanical explanation in overlay sections.
- Do not write `skill.index.sha256`. Stamp-writing is the auditor's responsibility, performed only after a PASS verdict.
- Do not consult `skill.index.sha256` for change detection — compare recomputed hash against stored `skill.index` bytes directly.
- Do not consult the network.
- Do not modify any file outside the two artifact classes (raw index and overlay).
