---
name: skill-index-building
description: >-
  Produces two index artifacts at each directory in a skill tree: skill.index
  (raw) and skill.index.md (overlay). The auditor writes the integrity stamp
  after PASS — not the builder.
---

Dispatch (Dispatch agent, zero context): "Read and follow `instructions.txt` (in this directory). Input: `root=<path> [--dot-allow <name,...>] [--rebuild]`"

`root` (required): absolute path to invocation root.
`--dot-allow` (optional): comma-separated bare dot-folder names to traverse. Default: empty.
`--rebuild` (optional): regenerate all nodes regardless of stored raw index content.

Artifact pair per directory: `skill.index` | `skill.index.md` — no other filenames. The builder doesn't write `skill.index.sha256`; that is the auditor's sign-off artifact.

Raw index format: `key: keyword, keyword, keyword` — one line per entry, no blanks; self entry `.` first; sub-node marker `/` appended to key when child has own index; byte-lex sort. Keywords must not duplicate the entry key verbatim — synonyms, phrasings, related concepts only.

Overlay format: H1 + optional preamble (≤2 sentences, helps locate skills only) + one `## name` section per entry (same order as raw index); single-sentence paragraphs; no index-mechanic prose; must pass compression check before write.

Write order (strict): `skill.index` → `skill.index.md`. No early termination between writes. No symlinks followed.

Shortcut entries: curator-added, not generated. Preserved verbatim on every run — same key, same keywords, same character sequence — merged with mechanical portion, sorted in. Curator keyword lists inside shortcuts are authoritative even if non-conformant; treat as opaque text. Broken shortcut target → record in manifest, emit entry unchanged. Builder doesn't evaluate subtree containment or acyclicity (auditor's job).

Combo node: emits self entry in own index + sub-node-marked entry in parent index; subdirectories traversed.

Edge cases:
- No indexable children + no manifest: empty `skill.index` (zero bytes) + H1-only overlay.
- No indexable children + manifest: `skill.index` with self entry only; overlay follows normal write order.

Returns: change manifest (created / updated / unchanged / blocked / broken-shortcut / skipped).

Build procedure (per node):
1. Compute mechanical portion: self entry (if manifest present) + direct-child entries.
2. Merge with preserved shortcut entries verbatim from existing `skill.index`.
3. Sort combined list (self entry first, rest byte-lex). Serialize one line per entry.
4. Compute SHA-256 of serialized content. Compare against SHA-256 of stored `skill.index` bytes. Never consult stored stamp for change detection — it's the auditor's artifact.
5. Incremental mode: if hashes match → no writes, record unchanged, done.
   Rebuild mode (`--rebuild`): skip hash check; always regenerate.
6. Generate overlay in memory → run compression check.
7. On success, write in strict order: `skill.index` → `skill.index.md`. No early termination.

Footguns:
F1: Stamp consulted for change detection. Compare recomputed hash against stored `skill.index` bytes directly — never read `skill.index.sha256`.
F2: Builder writes the stamp. Write order is `skill.index` → `skill.index.md` only. No stamp write — auditor's job.
F3: Combo node treated as pure leaf. Emit self entry AND enumerate manifest-bearing subdirs. Don't suppress traversal.
F4: Dot-allow used as path expression. Bare names only — no globs, no paths.
F5: Shortcuts erased on rebuild. Preserve shortcut entries verbatim across all runs.

Don'ts:
- Doesn't author skill content.
- Doesn't validate or audit skills.
- Doesn't decide which dot-folders to traverse.
- Doesn't emit `skill.index` with `.md` extension.
- Doesn't embed navigation prose in overlay sections.
- Doesn't write `skill.index.sha256` — that is the auditor's responsibility.
- No network access. No files modified outside the two artifact classes.

Related: `skill-index`, `skill-index-auditing`, `skill-index-crawling`, `compression`
