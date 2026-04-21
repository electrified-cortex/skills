---
name: skill-index-auditing
description: >-
  Read-only validator for a skill-index cascade. Returns one of `ok`,
  `rebuild-needed`, `inconclusive` — triggers the host to invoke the builder.
  Does not rebuild.
---

# Skill Index Auditing

The auditor is a cheap, fast check that answers one question: **is this cascade valid, or does the builder need to run.** It never rebuilds, never writes, never opens skill contents.

## When to Use

Before acting on a `skill.index` cascade. Run the auditor first. If verdict is `ok`, proceed. If `rebuild-needed`, invoke `skill-index-building`. If `inconclusive`, surface the reason — do not guess.

## Input

- **Invocation root** — the directory to audit. The auditor restricts all work to that subtree.
- **Allow-list** (optional) — dot-folder names whose traversal is permitted. Plain bare names, no globs. Must match the allow-list used by the builder for the same tree.

## Output

Audit report:
- `verdict`: `ok` | `rebuild-needed` | `inconclusive`
- `reason`: short string (present if verdict is not `ok`)
- `path`: path of the first failing node (present if verdict is `rebuild-needed`)
- `findings` (optional): continue-past observations — orphans, malformed lines — attached even on `ok` verdicts

## Procedure

Walk depth-first from the invocation root, visiting parents before children. At each node, run fail-fast checks first. Halt on the first fail-fast failure. If the node passes all fail-fast checks, run continue-past checks and descend into children.

### Fail-Fast Checks (halt on failure)

At each node that has a `skill.index`:

1. **Stamp present** — there is a `skill.index.sha256` next to the raw index.
2. **Stamp matches** — the SHA-256 of the raw index's current stored bytes equals the stamp.
3. **Children exist on disk** — every entry in the raw index maps to a real child. A plain entry maps to a leaf-skill directory (directory containing a skill manifest). A descent-marked entry (trailing `/`) maps to a sub-directory containing its own `skill.index`. A combo entry maps to a directory that satisfies both.
4. **Parent enumerates children** — every manifest-bearing child directory of this node appears as an entry in this node's raw index.
5. **Combo self entry** — if this directory has its own skill manifest, its raw index contains a self entry (`.`).
6. **Combo children enumerated** — if this directory is a combo node, its raw index also enumerates its manifest-bearing subdirectories.
7. **Combo parent classification** — if this directory is a combo node, its entry in its parent's raw index is classified as combo (descent-marked, with the parent's raw index also reflecting the child's own self entry pattern).

Any fail-fast failure → verdict `rebuild-needed`, halt, return the reason and path.

### Continue-Past Checks (record, do not halt)

At each node that passed fail-fast:

8. **Orphan stamps/overlays** — a `skill.index.sha256` or `skill.index.md` with no corresponding `skill.index` is recorded as an orphan finding. Orphans alone do not escalate the verdict — they are janitorial signals.
9. **Malformed lines** — any raw index line that lacks a key, lacks a colon, or contains forbidden characters is recorded. Other lines at the same node remain usable. If the node completes inspection without a fail-fast failure and any malformed line was recorded, the final verdict is raised to `rebuild-needed`.

## Walk Rules

- Depth-first, parents before children — so a parent-level failure halts before descending into a potentially invalid subtree.
- Do not follow symlinks.
- Skip dot-prefixed directories unless listed in the supplied allow-list. The allow-list is bare names only.

## Stop Conditions

- **First fail-fast failure** → verdict `rebuild-needed`, halt, return.
- **Walk completes clean, no malformed-line findings** → verdict `ok`, return with any orphan findings attached.
- **Walk completes clean, malformed-line findings present** → verdict `rebuild-needed`, return with the offending node's path.
- **Root directory unreadable** → verdict `inconclusive`, halt, return the reason.
- **Subtree unreadable mid-walk** → record `inconclusive` for that subtree, continue with siblings. Precedence: a single `rebuild-needed` anywhere in the walk dominates; otherwise any `inconclusive` dominates; otherwise `ok`.

## Don'ts

- Do not modify any file.
- Do not invoke the builder — the host agent does that based on the verdict.
- Do not open skill contents.
- Do not continue past a fail-fast failure — return and let the builder find the rest.
- Do not treat orphans as fail-fast failures. They are janitorial.
- Do not re-derive rules. The root `skill-index` spec is authoritative; this skill validates against it.

## Related

- `skill-index` (root spec) — the contract this skill validates against.
- `skill-index-building` — what the host invokes when the verdict is `rebuild-needed`.
- `skill-index-crawling` — consumes the same artifacts for skill lookup, not validation.
