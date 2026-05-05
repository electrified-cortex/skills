---
audit: prune-ordering
task: "30-0948"
date: "2026-05-04"
auditor: "Worker 1"
verdict: PASS
scope: electrified-cortex/skills — all .md files
---

# Prune-ordering audit — 2026-05-04

## Purpose

Confirm that every skill and doc in `electrified-cortex/skills` that mentions
`hash-record-prune` correctly states or implies that **prune runs AFTER rekey,
never before**. Prune deletes orphaned records; rekey moves records to new hash
keys. Running prune first would destroy records rekey still needs.

Requested by operator 2026-05-04: "The follow-up for prune should never happen
before a rekey."

## Scope

- All `.md` files under `electrified-cortex/skills/`
- Terms searched: `hash-record-prune`, `prune.sh`, `prune.ps1`, `prune`
  (in skill context)
- `.hash-record/` cached audit artifacts excluded from normative analysis

## Summary

| Classification | Count |
| -------------- | ----- |
| **OK**         | 28    |
| **AMBIGUOUS**  | 0     |
| **WRONG**      | 0     |

**Verdict: PASS — zero violations found.**

---

## Findings

### sealing-strategy.spec.md

**OK** — Two explicit correct-ordering statements.

Line 55-56:
> "Run the folder-level rekey BEFORE any prune. (Prune deletes records that
> don't match current content; running it before rekey would discard records
> we want to preserve.)"

Dedicated Order Constraint section (lines ~423-427):
> "Folder-mode rekey runs BEFORE `hash-record-prune`. Pruning before rekeying
> would delete records the rekey is trying to preserve."

---

### hash-record/hash-record-rekey/rekey.spec.md

**OK** — Five distinct correct-ordering statements across the spec.

- §Scope "Out of scope": "Deleting orphaned records (that is `hash-record-prune`'s
  job, run AFTER this tool)."
- §Requirements req 6: "Folder mode runs before `hash-record-prune`; the order
  constraint is mandatory."
- §Folder/manifest mode motivation: "Run BEFORE `hash-record-prune`."
- §Order constraint (dedicated section): Full rationale — rekey BEFORE prune.
- §Out of scope (folder mode): "Deleting orphaned records (run AFTER folder mode)."

---

### hash-record/hash-record-rekey/usage-guide.md

**OK** — Explicit ordering on line 116:
> "Run folder-mode BEFORE `hash-record-prune`; pruning first would delete records
> the rekey is trying to preserve."

---

### hash-record/hash-record-rekey/usage-guide.uncompressed.md

**OK** — Two explicit statements:
- Line 111: "folder mode BEFORE `hash-record-prune`; pruning first would delete the
  records the rekey is trying to preserve."
- Line 152: "Does NOT delete records; use `hash-record-prune` for that (run AFTER
  rekey)."

---

### hash-record/hash-record-rekey/SKILL.md

**OK** — Reference link only (`Related: hash-record-prune`). No ordering instruction;
not applicable.

---

### markdown-hygiene/spec.md

**OK** — Prune is the terminal-stop cleanup step (lines 190-196). No rekey
involvement in markdown-hygiene; ordering constraint not applicable. Prune
described in isolation as a clean-up tool after fix iterations complete.

---

### markdown-hygiene/SKILL.md

**OK** — Same context as spec.md. Prune in isolation; no rekey; ordering N/A.

---

### markdown-hygiene/uncompressed.md

**OK** — Same as above.

---

### hash-record/hash-record-prune/\* (prune.spec.md, SKILL.md, uncompressed.md)

**OK** — Prune tool's own normative docs. Describe prune's own behavior only;
make no ordering claims relative to rekey. N/A for this audit.

---

### hash-record/skill.index.md

**OK** — Index entry for hash-record-prune. No ordering context.

---

### hash-record/hash-record-manifest/\* and hash-record/hash-record-index/\*

**OK** — Reference links only (`Related: hash-record-prune`). No ordering claims.

---

### hash-record/hash-record-check/SKILL.md

**OK** — Reference link only.

---

### hash-record/spec.md

**OK** — Contextual mention of cleanup (janitor skill, operator-invoked). No
ordering implication.

---

### .audit/frontmatter-trigger-sweep-2026-05-03.md

**OK** — Audit metadata file listing trigger keywords. Not normative.

---

### .hash-record/\*\*/\*.md (cached audit reports)

**OK** — Cache artifacts, not normative source. Excluded from classification.

---

## Conclusion

Prune-ordering discipline is **sound across the entire repo**. The constraint
(rekey → prune, never prune → rekey) is:

1. Explicitly documented in `sealing-strategy.spec.md` (canonical orchestration
   doc) — two places.
2. Explicitly documented in `hash-record-rekey/rekey.spec.md` — five dedicated
   statements including a named "Order constraint" section.
3. Consistently repeated in the rekey usage guides.
4. Where prune is mentioned without rekey (markdown-hygiene), no ordering
   constraint is implied because that skill does not invoke rekey.

No WRONG or AMBIGUOUS findings. No follow-up fix tasks required.
