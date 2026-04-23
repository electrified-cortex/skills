---
name: skill-index-crawling
description: Reads an existing skill-index cascade to locate the skill matching an agent's stated need — read-only, no filesystem walking.
---

# Skill Index Crawling

Dispatch skill. Reads an existing skill-index cascade to locate the skill that matches an agent's stated need. Read-only — the crawler produces no files and modifies nothing.

## Purpose

Let an agent find the right skill by reading only index nodes. Never opens skill contents, never walks the filesystem, never climbs above the working directory.

## Invocation

Dispatch via Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory). Input: `root=<path> need=<phrase>`"

Parameters:

- `root` (required): absolute path to the directory whose `skill.index` is the starting node.
- `need` (required): the agent's stated need as a plain phrase.

Returns: a crawl report (see Output below).

## How the Crawler Works

1. Open `skill.index` at `root`. If missing: return outcome "no index here" and stop.
2. Parse each line as `key: keyword, keyword, keyword`. Split at first colon; keyword list splits on `,`. Malformed lines recorded and skipped.
3. Check the stamp: open `skill.index.sha256`; compute SHA-256 of `skill.index`'s stored bytes; compare. Mismatch or missing stamp → overlay is untrusted for this node (still usable for identity; not consulted for disambiguation).
4. Match: case-fold both sides; declare a Hit when `need` appears as a substring of any entry key or any keyword.
5. Rank hits: self entry or plain leaf beats descent-marked entry. Consult the overlay only to break ties among equally ranked hits that already exist in the raw index (overlay never produces new candidates).
6. If exactly one hit survives ranking: return that hit.
7. If no hits: return outcome "no match" and stop.
8. If two or more hits remain tied after overlay consultation: return outcome "ambiguous".
9. If best hit is descent-marked: resolve the target, open that target's `skill.index`, and re-apply from step 2. Each descent lands on exactly one new node.
10. Track every visited node on the current resolution path. If a descent would land on a node already in that set: return outcome "reference loop" with the ordered visited sequence and stop.

## Entry Types

| Key form | Meaning |
| --- | --- |
| `foo` | Leaf skill at `./foo/` |
| `foo/` | Sub-node: descend into `./foo/skill.index` |
| `.` | Self entry: current directory is itself a skill |
| `tools/compression/` | Shortcut entry: walk path from current node; trailing `/` means a deeper index exists |
| `tools/compression` | Shortcut entry: no trailing `/` means target is a leaf skill |

## Shortcut Entry Resolution

A shortcut entry's key contains more than one path segment (e.g. `a/b/c/`). The crawler:

1. Walks each segment from the current node's directory.
2. At each step, verifies the resolved path does not ascend above the invocation root (no `..` segments, no absolute paths). If it does: record `subtree-escape` in the crawl report and do not follow; return outcome "subtree-escape".
3. At the final segment: if trailing `/`, open `skill.index` there (sub-node); if no trailing `/`, the target is a leaf skill.

## Combo Entry Handling

A combo entry has a descent marker AND its target emits a `.` self entry in its own `skill.index`. The crawler:

1. Treats the combo entry as a leaf first.
2. If the leaf does not produce a hit, descends into its sub-node and re-applies the procedure there.

## Stop Conditions

| Outcome | Condition |
| --- | --- |
| Hit returned | Exactly one hit survives ranking |
| "no index here" | `skill.index` absent at working directory |
| "no match" | Current node produces no hits |
| "ambiguous" | Two or more hits remain tied after overlay consultation |
| "reference loop" | Descent would revisit a node already on the current resolution path |
| "subtree-escape" | Shortcut resolution attempts to leave the invocation root's subtree |
| "unreadable node" | `skill.index` exists but cannot be read |
| "broken descent" | Descent target lacks required file; recorded, treated as absent |

## Crawl Report Fields

- `outcome`: one of the outcomes above
- `hit`: the matched entry key and resolved path (when outcome is a hit)
- `visited`: ordered list of node paths visited on the resolution path
- `inconsistencies`: list of recorded findings (malformed lines, broken descents, stamp mismatches, subtree-escape attempts)

## Overlay Trust

The overlay (`skill.index.md`) is trusted for disambiguation only when its stamp matches the SHA-256 of the current raw index bytes. Missing or mismatched stamp → overlay is untrusted for this node; raw index only. This is recorded in the crawl report.

## Footguns

F1: Overlay consulted before ranking against raw index.
Mitigation: Compute hits against raw index first. Overlay is consulted only to break ties among existing hits.

F2: Stamp mismatch ignored.
Mitigation: On mismatch or missing stamp, downgrade overlay to untrusted for that node.

F3: Crawler climbs or scans outside the working directory.
Mitigation: Only open `skill.index` at the working directory; descend only via explicit descent markers.

F4: Shortcut entry escapes the invocation root's subtree.
Mitigation: Enforce subtree check at every step of every shortcut walk. Record `subtree-escape`; do not follow.

F5: Cycle detection skipped on non-shortcut descents.
Mitigation: Track visited nodes on every descent — direct-child, shortcut, and combo sub-node. Halt on revisit.

## Don'ts

- Does not produce, author, or update any artifact.
- Does not open skill contents.
- Does not climb above the working directory.
- Does not trust the overlay when its stamp is absent or mismatched.
- Does not follow a shortcut entry out of the invocation root's subtree.

## Related

- `skill-index` — root spec and toolkit overview
- `skill-index-building` — produces the artifacts this skill reads
- `skill-index-auditing` — validates the cascade before crawling
