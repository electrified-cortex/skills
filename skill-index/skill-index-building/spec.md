---
name: skill-index-building
description: >-
  Specification for the builder half of the skill-index toolkit — creates or
  updates the raw index, the markdown overlay, and the integrity stamp for a
  directory of skills.
type: spec
---

# Skill Index Building Specification

Normative spec for the builder. The builder creates or updates three artifacts at every indexed directory: `skill.index` (raw), `skill.index.md` (overlay), `skill.index.sha256` (stamp). Conforms to the root `skill-index` spec.

---

## Purpose

Produce artifacts a reader can consume without opening any skill's contents. Names plus a handful of trigger keywords plus one plain sentence per skill. Nothing more.

---

## Scope

Applies to any directory passed as the builder's invocation root. The builder walks downward and writes artifacts at every directory that contains at least one indexable child, plus the invocation root itself.

---

## Definitions

- **Builder** — the actor performing operations defined by this spec.
- **Entry** — one line in `skill.index` describing a single indexable child of the current directory.
- **Entry key** — the child's directory name.
- **Sub-node marker** — a trailing `/` appended to the entry key when the child has its own `skill.index` beneath it.
- **Self entry** — an entry whose key is literally `.`, used when the current directory itself contains a skill manifest. Appears first if present.
- **Combo node** — a directory that is simultaneously a skill (its own manifest present) and a parent of at least one further indexed child. Emits a self entry in its own `skill.index` and a sub-node-marked entry in its parent's `skill.index`.
- **Shortcut entry** — an entry whose key is a multi-segment relative path (per root spec R33). Curator-added, not mechanically emitted by the builder.
- **Mechanical portion** — the subset of a `skill.index`'s entries that the builder would produce deterministically given only the filesystem: self entry (if applicable) plus direct-child entries. Excludes curator-added shortcut entries.
- **Overlay section** — one `## name` heading in `skill.index.md` corresponding to an entry.
- **Preamble** — optional prose between the H1 and the first `## name` heading.
- **Refreshed overlay** — an overlay whose content was generated against the current raw index and passed the compression check within the same build step.

---

## Requirements

### Raw Index (`skill.index`)

R1. When entries exist, the builder must write one entry per line in `skill.index`. No blank lines, no header, no footer. An empty `skill.index` (zero bytes) per B4 is an explicit exception to this rule.

R2. The builder must format each entry as `key: keyword, keyword, keyword`, with a single space after the colon and `, ` between keywords.

R3. The builder must append `/` to the entry key of any child directory that itself contains a `skill.index`.

R4. The builder must emit a `.` self entry as the first line of a node's `skill.index` whenever the current directory contains a skill manifest.

R5. The builder must sort entries by key using byte-lexicographic comparison of the full UTF-8-encoded key string, placing any self entry (key `.`) before the sorted block. Multi-segment shortcut keys participate in the same sort space as single-segment keys; the `/` separator (0x2F) compares by its byte value against other key characters. When one key is a proper prefix of another, the shorter key sorts first. Sort is stable with respect to input order for ties (ties should not occur; R32 of the root spec forbids duplicate keys at a node).

R6. The builder must treat keywords as natural-language trigger phrases. Keywords must not duplicate the entry key verbatim; synonyms, phrasings, and related concepts are retained.

### Overlay (`skill.index.md`)

R7. The builder must set the H1 to the directory's identifying title.

R8. The builder may include a preamble between the H1 and the first section heading. When present, the preamble must be at most two sentences and must help locate a skill, not describe the index.

R9. The builder must emit one `## name` section per entry key, in the same order as the raw index. The self entry's section uses the directory's own name, not `.`.

R10. The builder must write each section as a single paragraph. One sentence is preferred.

R11. The builder must not describe index mechanics (trailing slashes, dot entries, navigation) inside overlay sections.

R12. The builder must subject the overlay to a full-compression pass before committing it. An overlay that does not pass compression must not be written.

### Stamp (`skill.index.sha256`)

R13. The builder must write the stamp as the SHA-256 hex digest of the exact bytes of `skill.index` as stored, and nothing else. The stamp may be written only when a refreshed overlay (see Definitions) exists for those same bytes, except per root spec R21 (when no overlay exists for the node, the stamp may be written without the refreshed-overlay precondition).

### Traversal

R14. The builder must skip dot-folders by default. An explicit allow-list of dot-folder names overrides the skip for those names only. The allow-list is a plain list of bare names with no globbing.

R15. The builder must not follow symlinks by default.

R16. The builder must treat a combo node as both a self entry in its own `skill.index` and a sub-node-marked entry in its parent's `skill.index`, and must traverse its manifest-bearing subdirectories.

### Curator-Added Shortcut Entries

R17. The builder's mechanical output populates only the mechanical portion (self entry plus direct-child entries). The builder does not generate shortcut entries.

R18. When the builder runs over a node whose existing `skill.index` contains shortcut entries (multi-segment keys per root spec R33, R36), the builder must preserve those entries verbatim — same key, same keyword list, same character sequence — and merge them with its freshly regenerated mechanical portion. Preservation is verbatim even when a shortcut entry's keyword list does not conform to R2's `key: keyword, keyword, keyword` format; curator authorship (R20) overrides R2 for preserved shortcut entries, which the builder treats as opaque text for that entry.

R19. When merging, the builder must sort the combined entry list (mechanical portion + preserved shortcut entries) per R5. Shortcut entries and single-segment entries interleave in one sorted block; no segregation by entry kind. The self entry, if present, remains at the head.

R20. The builder must not rewrite, reorder, or reword keywords inside a preserved shortcut entry. Curator intent in a shortcut entry is authoritative.

R21. If a preserved shortcut entry's target path does not exist on the current filesystem, the builder must record the condition in the change manifest as a broken shortcut and emit the entry unchanged. Structural legality of the shortcut (subtree containment per root spec R33, acyclicity per root spec R34) is the auditor's responsibility, not the builder's; the builder does not evaluate those properties at write time. Repairing or removing a broken shortcut is a curator decision.

---

## Constraints

C1. The builder must not require network access.

C2. The builder must not modify any file outside the three artifact classes.

C3. The builder must not modify skill contents.

C4. The builder must not emit the raw index with a markdown extension.

---

## Behavior

B1. When the SHA-256 of the computed raw index for a node (mechanical portion plus any preserved shortcut entries, sorted and serialized per R2/R5/R19) is equal to the value stored in `skill.index.sha256`, the builder performs no writes for that node. The stamp remains as stored. The comparison is hash-based, not timestamp-based; timestamp heuristics are prohibited.

B2. When the hash under B1 differs from the stored stamp (including when the stamp is missing), the builder performs the following in strict order: (a) generate the overlay in memory; (b) run compression check on the generated overlay; (c) on success, write `skill.index` first, then `skill.index.md`, then `skill.index.sha256`. The builder must not terminate normally between steps (c)'s three writes; partial-write recovery follows root spec E4.

B3. When the overlay fails its compression check, the builder aborts the node, reports it as blocked in the change manifest, and performs no writes for that node in this run. The prior stored `skill.index`, `skill.index.md`, and `skill.index.sha256` remain at their prior values. Preserved shortcut entries remain available in the prior stored raw index; a failed overlay does not lose them, because the computed merge is held in memory and discarded rather than persisted.

B4. When a directory has zero indexable children and no skill manifest of its own, the builder produces: an empty `skill.index` (zero bytes), an overlay containing only the H1 and no sections, and a stamp that is the SHA-256 of zero bytes. The three artifacts are subject to B2's write order and compression gate exactly as for any non-empty node: the H1-only overlay must pass the compression check per R12 (an H1-only overlay trivially satisfies compression, since there is no content to compress; this is stated here to make the chain explicit), then the raw index, overlay, and stamp are written in that order. If compression fails on the H1-only overlay for any implementation reason, B3 governs and no writes occur.

B5. When a directory has zero indexable children but does have a skill manifest of its own, the builder writes a `skill.index` containing only a self entry. The overlay and stamp follow B2's write order and compression gate without modification.

---

## Defaults and Assumptions

D1. The allow-list for dot-folder traversal is empty by default. Each consuming environment supplies its own.

D2. Keyword generation is assumed to require language-model processing; it is not mechanical.

D3. Overlay generation is assumed to require language-model processing; it is not mechanical.

---

## Error Handling

E1. If a directory is unreadable, the builder skips it, records the skip in the change manifest, and continues with siblings.

E2. If the overlay fails the compression check, see B3.

E3. If the stamp write fails after the overlay succeeded, the builder records the node as drifted in the change manifest (using "drifted" per the root spec definition) and continues.

E4. If the change manifest itself cannot be produced, the builder must emit a non-zero exit signal and must not silently succeed.

---

## Precedence Rules

P1. Raw index content is authoritative over overlay content.

P2. The stamp reflects the raw index's current stored bytes, never the overlay's.

P3. Filesystem structure overrides any cached prior state.

---

## Don'ts

N1. The builder does not author skill content.

N2. The builder does not validate or audit skills.

N3. The builder does not decide which dot-folders to traverse — that decision is supplied.

N4. The builder does not emit a raw index in markdown format.

N5. The builder does not embed navigation or mechanical explanation in overlay sections.
