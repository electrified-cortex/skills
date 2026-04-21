---
name: skill-index-building
description: >-
  Specification for the builder half of the skill-index toolkit — creates or
  updates the raw index and the markdown overlay for a directory of skills.
  The auditor writes the integrity stamp after a PASS.
type: spec
---

# Skill Index Building Specification

Normative spec for the builder. The builder creates or updates two artifacts at every indexed directory: `skill.index` (raw), `skill.index.md` (overlay). The integrity stamp (`skill.index.sha256`) is written by the auditor after a PASS, not by the builder. Conforms to the root `skill-index` spec.

## Changelog

- R13 removed (builder stamp-write rule). Stamp responsibility transferred to auditor. See auditor spec R22–R23.
- B1: change-detection no longer reads the stored stamp. Builder compares recomputed raw bytes against stored `skill.index` bytes directly.
- B2: write order is now a pair: `skill.index` → `skill.index.md`. No stamp write.
- B3–B5: stamp references removed.
- C2: artifact classes updated to two (raw index + overlay).
- E3: stamp-write error handling removed (no longer builder's responsibility).
- P2: updated — stamp reflects auditor sign-off, not builder freshness.
- N6 added: builder does not write the integrity stamp.
- B5 replaced: pure leaf directories (manifest present, zero indexable children) must not receive a `skill.index`. Prior rule that wrote a self-only index at such directories is revoked; parent's index already references the leaf, and the leaf's own SKILL.md describes it.
- R4 narrowed: self entry is emitted only at combo nodes (manifest present AND at least one indexable child), not at pure leaf directories.

---

## Purpose

Produce artifacts a reader can consume without opening any skill's contents. Names plus a handful of trigger keywords plus one plain sentence per skill. Nothing more.

---

## Scope

Applies to any directory passed as the builder's invocation root. The builder walks downward and writes artifacts at every directory that contains at least one indexable child, plus the invocation root itself.

### Caller Responsibilities

The caller must not read `instructions.txt` themselves. Pass the file path to a dispatch agent and let it read the file.

---

## Definitions

- **Builder** — the actor performing operations defined by this spec.
- **Entry** — one line in `skill.index` describing a single indexable child of the current directory.
- **Entry key** — the child's directory name.
- **Sub-node marker** — a trailing `/` appended to the entry key when the child has its own `skill.index` beneath it.
- **Self entry** — an entry whose key is literally `.`, used when the current directory is a combo node (skill manifest present and at least one indexable child). Appears first if present. Pure leaf directories do not receive an index node and therefore do not emit a self entry.
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

R4. The builder must emit a `.` self entry as the first line of a node's `skill.index` when the current directory is a combo node (skill manifest present AND at least one indexable child). The builder must not emit a self entry at a pure leaf directory (manifest present, zero indexable children), because pure leaf directories do not receive an index node per root spec R8.

R5. The builder must sort entries by key using byte-lexicographic comparison of the full UTF-8-encoded key string, placing any self entry (key `.`) before the sorted block. Multi-segment shortcut keys participate in the same sort space as single-segment keys; the `/` separator (0x2F) compares by its byte value against other key characters. When one key is a proper prefix of another, the shorter key sorts first. Sort is stable with respect to input order for ties (ties should not occur; R32 of the root spec forbids duplicate keys at a node).

R6. The builder must treat keywords as natural-language trigger phrases. Keywords must not duplicate the entry key verbatim; synonyms, phrasings, and related concepts are retained.

### Overlay (`skill.index.md`)

R7. The builder must set the H1 to the directory's identifying title.

R8. The builder may include a preamble between the H1 and the first section heading. When present, the preamble must be at most two sentences and must help locate a skill, not describe the index.

R9. The builder must emit one `## name` section per entry key, in the same order as the raw index. The self entry's section uses the directory's own name, not `.`.

R10. The builder must write each section as a single paragraph. One sentence is preferred.

R11. The builder must not describe index mechanics (trailing slashes, dot entries, navigation) inside overlay sections.

R12. The builder must subject the overlay to a full-compression pass before committing it. An overlay that does not pass compression must not be written.

### Overlay as Trigger Surface

The overlay is the artifact loaded into an agent's active context (via `skill-index-integration`) and is consulted on every task after context-window resets. It must drive skill selection — not describe the skills. Sections therefore state *triggering conditions*, not summaries.

R22. Each `## name` section must express the conditions under which the named skill should be loaded, not a description of what the skill does. A section that reads as a summary ("This skill handles X", "PR has unresolved Copilot comments; about to request a review") without stating the trigger is non-conformant. Readers learn what a skill does by loading it; the overlay exists to route them there.

R23. Trigger conditions fall into two kinds, and a section may use either or both:

- **Human-triggered** — quoted or paraphrased operator/user phrases the agent listens for (e.g., `"is the PR ready?"`, `"spawn a worker"`). Quoted phrases are preferred over paraphrase because the agent matches against operator wording.
- **Agent-self-triggered** — plain imperative statements the agent applies to its own state (e.g., `Use this whenever no entry above matches and you need to find a skill.`, `Run at the start of every idle cycle.`). Used when no operator prompt initiates the skill.

R24. When a preamble is used per R8, it should establish the trigger convention in one sentence (e.g., `Match the operator's words or your current situation to an entry, then load that skill.`) so the per-section framing does not repeat it. Repeated per-entry prefixes ("Read this when…", "Use when…") are token bloat and must be consolidated into the preamble when every section would otherwise carry the same prefix.

R25. Section prose must be compact and scannable. Comma- or semicolon-separated trigger lists are conformant and preferred over full sentences when multiple triggers apply.

R26. The builder must not reorder or rewrite shortcut-entry overlay sections, consistent with R20 for raw-index keywords. Curator-authored trigger prose in preserved shortcut entries is opaque text.

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

C2. The builder must not modify any file outside the two artifact classes (raw index and overlay).

C3. The builder must not modify skill contents.

C4. The builder must not emit the raw index with a markdown extension.

---

## Behavior

B1. When the SHA-256 of the computed raw index for a node (mechanical portion plus any preserved shortcut entries, sorted and serialized per R2/R5/R19) is equal to the SHA-256 of the currently stored `skill.index` bytes, the builder performs no writes for that node. The comparison is hash-based, not timestamp-based; timestamp heuristics are prohibited. The stored `skill.index.sha256` is not consulted for change detection — that stamp is the auditor's sign-off artifact, not a builder freshness marker.

B2. When the hash under B1 differs from the stored raw index (including when no raw index exists), the builder performs the following in strict order: (a) generate the overlay in memory; (b) run compression check on the generated overlay; (c) on success, write `skill.index` first, then `skill.index.md`. The builder must not terminate normally between steps (c)'s two writes; partial-write recovery follows root spec E4. The builder does not write `skill.index.sha256`.

B3. When the overlay fails its compression check, the builder aborts the node, reports it as blocked in the change manifest, and performs no writes for that node in this run. The prior stored `skill.index` and `skill.index.md` remain at their prior values. Preserved shortcut entries remain available in the prior stored raw index; a failed overlay does not lose them, because the computed merge is held in memory and discarded rather than persisted.

B4. When a directory has zero indexable children and no skill manifest of its own, the builder produces: an empty `skill.index` (zero bytes) and an overlay containing only the H1 and no sections. The two artifacts are subject to B2's write order and compression gate exactly as for any non-empty node: the H1-only overlay must pass the compression check per R12 (an H1-only overlay trivially satisfies compression, since there is no content to compress; this is stated here to make the chain explicit), then the raw index and overlay are written in that order. If compression fails on the H1-only overlay for any implementation reason, B3 governs and no writes occur.

B5. When a directory has zero indexable children but does have a skill manifest of its own (a pure leaf skill), the builder must not write a `skill.index` at that directory. The parent's index already references the leaf as an entry, and the leaf's own skill manifest describes it.

---

## Defaults and Assumptions

D1. The allow-list for dot-folder traversal is empty by default. Each consuming environment supplies its own.

D2. Keyword generation is assumed to require language-model processing; it is not mechanical.

D3. Overlay generation is assumed to require language-model processing; it is not mechanical.

---

## Error Handling

E1. If a directory is unreadable, the builder skips it, records the skip in the change manifest, and continues with siblings.

E2. If the overlay fails the compression check, see B3.

E3. If the change manifest itself cannot be produced, the builder must emit a non-zero exit signal and must not silently succeed.

---

## Precedence Rules

P1. Raw index content is authoritative over overlay content.

P2. The stamp is an auditor sign-off artifact. The builder does not write it. Absence of a stamp after a build means "unaudited since last build," not "needs rebuild."

P3. Filesystem structure overrides any cached prior state.

---

## Don'ts

N1. The builder does not author skill content.

N2. The builder does not validate or audit skills.

N3. The builder does not decide which dot-folders to traverse — that decision is supplied.

N4. The builder does not emit a raw index in markdown format.

N5. The builder does not embed navigation or mechanical explanation in overlay sections.

N6. The builder does not write `skill.index.sha256`. Stamp-writing is the auditor's responsibility, performed only after a PASS verdict.
