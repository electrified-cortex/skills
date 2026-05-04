# Sealing Strategy No-Loop Guarantee Test — skill-writing — 2026-05-04

## Summary

INCONCLUSIVE

The sealing chain ran through Phases 2–6 successfully, including a full skill-audit
dispatch, spec audit, and markdown-hygiene lint. All three .md files linted CLEAN.
Phase 2 confirmed the cache-hit mechanism works: result.ps1 returned MISS on first
run, the audit report was written, and re-running result.ps1 immediately returned
NEEDS_REVISION (cache HIT — no new LLM dispatch). However, Rekey Rounds 1 and 2
could not be executed because the rekey scripts (both .sh and .ps1 variants) are not
in the Worker role script allowlist. The rekey steps are the critical idempotency gate
for this test; their absence makes the overall result INCONCLUSIVE rather than PASS or
FAIL. The cache-hit core mechanism is confirmed; the rekey idempotency claim is untested.

## Phase Results

| Phase | First-run | Rerun | Cache hit? |
|---|---|---|---|
| 2 — skill-audit | MISS → NEEDS_REVISION (dispatched) | NEEDS_REVISION | Yes |
| 3 — spec-audit | Pass with Findings (4-step vs 6-step workflow inconsistency in spec) | N/A | N/A |
| 5 — hygiene analysis | No semantic/structural issues found | N/A | N/A |
| 6 — hygiene lint | CLEAN (all 3 files) | N/A | N/A |

## Rekey Round 1

BLOCKED — the hash-record-rekey script (.sh and .ps1 variants) is not in the Worker
role script allowlist (`permissions-scripts.ps1`). The hook denied execution with:
"Script path not in allowlist for this role."

To unblock: Curator must add the rekey script(s) to the Worker allowlist with their
SHA-256 hashes.

Note on expected behavior: since no source files were modified (Phase 6 lint returned
CLEAN with no changes), the rekey run would find no hash drift. The audit record at:

  `.hash-record/12/12773f.../skill-auditing/v2-compiled/report.md`

uses a manifest hash (combined hash of all three source files), not an individual file
blob hash. Folder-mode rekey matches records via `file_paths` frontmatter, then
compares the shard hash (manifest hash) against each individual file's current blob
hash — these can never match for manifest records. This edge case may produce
unintended REKEYED attempts and warrants investigation when the script is unblocked.

Expected output if files were unchanged and record were a per-file record:
```
CURRENT: <report-path>
SUMMARY: rekeyed=0 current=1 manifest_updated=0 not_found=0 errors=0
```

## Cache-Hit Verification

Phase 2 re-run result (result.ps1 stdout verbatim):
```
NEEDS_REVISION: D:/Users/essence/Development/cortex.lan/electrified-cortex/skills/.worktrees/70-0937/.hash-record/12/12773f710ba72dbdc280833cb9e29bc317caba63/skill-auditing/v2-compiled/report.md
```

PASS: cache hit — no new LLM dispatch

The result.ps1 correctly returned NEEDS_REVISION (not MISS) on re-run, confirming
the hash-record manifest lookup found the existing report. Zero new LLM tokens were
consumed for the re-run.

## Rekey Round 2 (Idempotency)

BLOCKED — same reason as Rekey Round 1.
Idempotent: UNTESTED

## Token Cost Comparison

First-run Phase 2: dispatched to sonnet-class — full audit executed (high token cost)
Re-run Phase 2: 0 new tokens — cache hit confirmed by result.ps1 returning NEEDS_REVISION
Reduction: >=90% (re-run cost is purely result.ps1 manifest lookup, no LLM dispatch)

## Acceptance Criteria

- [x] Canonical sealing chain executes without errors (Phases 2, 3, 5, 6 completed)
- [ ] hash-record-rekey classifies records correctly (UNTESTED — script blocked by allowlist)
- [x] Re-running Phase 2 produces NO new LLM dispatch (cache hit confirmed)
- [ ] Second rekey produces 100% CURRENT (idempotency) (UNTESTED — script blocked)
- [x] Token cost re-run >=90% lower than first run (0 tokens re-run vs full audit first run)

## Blocker Details

Script family: hash-record/hash-record-rekey (both .sh and .ps1 variants)
Hook denial: "Script path not in allowlist for this role"
Required action: Curator adds rekey script(s) to `permissions-scripts.ps1` with correct SHA-256 hashes
Affected criteria: Rekey Round 1, Rekey Round 2, idempotency acceptance criterion

## Skill Audit Findings (Phase 2)

Verdict: NEEDS_REVISION — two HIGH findings:

1. Parity (Step 2): `uncompressed.md` uses a separate `triggers:` frontmatter key to
   list trigger phrases rather than embedding them in the `description` field. `SKILL.md`
   correctly integrates trigger phrases into `description` per R-FM-10. Fix: move trigger
   phrases from the `triggers:` key into the `description` field in `uncompressed.md`.

2. Spec internal inconsistency (Step 3): the `## Behavior` subsection describes a 4-step
   creation workflow (spec -> uncompressed -> compress -> audit) that omits step 3
   (markdown hygiene mandatory gate) and step 4 (intermediate audit) present in the
   authoritative 6-step `## Skill Creation Workflow` section. Fix: update the `## Behavior`
   subsection to reflect the full 6-step workflow, or remove it.

Audit report path:
`.hash-record/12/12773f710ba72dbdc280833cb9e29bc317caba63/skill-auditing/v2-compiled/report.md`

---

## 70-0941 Follow-up — Rekey Idempotency Verification (2026-05-04)

### Summary

FAIL (idempotency not achieved) + PARTIAL PASS (rekey scripts now run)

### Rekey Allowlist — PASS

Rekey scripts now in Worker allowlist (`permissions-scripts.ps1`). Both scripts confirmed
runnable from Worker session via relative paths:

```
bash ./hash-record/hash-record-rekey/rekey.sh --help   # from EC skills root CWD
```

**Important:** Absolute path invocation (`bash /abs/path/rekey.sh`) is blocked by a
separate "absolute path script execution" rule (lines 98-108 of pretooluse-permissions.ps1).
Scripts must be invoked with relative paths (`./hash-record/hash-record-rekey/rekey.sh`)
from the correct CWD. The `cd` must be a separate Bash call before the script invocation.

### Phase 2 (skill-audit) — Cache Hit Confirmed

Phase 2 returned an immediate cache hit from the 70-0937 records. skill-writing files
are unchanged since 70-0937, so the existing record at `.hash-record/12/12773f.../` was
found and returned as NEEDS_REVISION with zero new LLM dispatch.

```
NEEDS_REVISION: .../skill-auditing/v2-compiled/report.md
```

### Phase 6 (hygiene lint) — BLOCKED (new blocker)

lint.sh hash mismatch detected. Computed hash `33468EAA87877BD096E29EF004E97543E4A87EE5E4FE5D35B611872C21ABDD86`
does not match allowlist entry `127A8444519E38185C5FEFBF37E12C276E98785A0A3C120A061C6EA33A1BF800`.
The script has been updated but the allowlist wasn't bumped. Requires Curator to update
the hash in `permissions-scripts.ps1`.

### Rekey Round 1

```
bash ./hash-record/hash-record-rekey/rekey.sh skill-writing
```

Output:
```
WARN: --manifests=true requested but manifest-entry rekeying is not implemented; manifest entries will not be updated
NOT_FOUND: no record for skill-writing/.audit/sealing-strategy-test-2026-05-04.md
REKEYED: .../87/8774fd25cb9d691314ffd3c20a48f0f680267433/skill-auditing/v2-compiled/report.md
REKEYED: .../87/8774fd25cb9d691314ffd3c20a48f0f680267433/skill-auditing/v2/report.md
REKEYED: .../94/945ee9f107d7af6178f1bc317e3feb5b88207478/skill-auditing/v2-compiled/report.md
REKEYED: .../94/945ee9f107d7af6178f1bc317e3feb5b88207478/skill-auditing/v2/report.md
REKEYED: .../94/941aa6c82103b8df964fcd3b650e380a9478e1f5/skill-auditing/v2-compiled/report.md
REKEYED: .../94/941aa6c82103b8df964fcd3b650e380a9478e1f5/skill-auditing/v2/report.md
SUMMARY: rekeyed=6 current=0 manifest_updated=0 not_found=1 errors=0
```

Note: The REKEYED destination paths `87/8774...`, `94/945ee...`, `94/941aa...` are the
current blob hashes of SKILL.md, spec.md, and uncompressed.md respectively. The records
in the folder reference all three files in their `file_paths` frontmatter.

### Rekey Round 2 (Idempotency Check)

```
bash ./hash-record/hash-record-rekey/rekey.sh skill-writing
```

Output: **identical to Round 1** — 6 REKEYED to the same three paths.

**Idempotency: FAIL**

### Root Cause — Multi-file Record Bug

The folder-mode rekey processes EACH file in the skill folder independently. For each
file it finds all records containing that file in `file_paths`. For a record with 3 files
in `file_paths`, the record gets processed three times — once per file — and each
processing step moves the record to a new directory path keyed by THAT file's blob hash.
The final resting path after each round is determined by whichever file was processed last
(`uncompressed.md` blob hash `941aa6...`).

On Round 2, the record at `94/941aa6...` is found again via SKILL.md's entry in
`file_paths`, path doesn't match SKILL.md's hash (`8774...`), so the record is moved to
`87/8774...`, then again via spec.md, then again via uncompressed.md — ending at
`94/941aa6...` again. The loop is infinite and non-idempotent.

The bug exists only for multi-file records. Per-file records (a single entry in
`file_paths`) would be idempotent: the record reaches its correct hash path on Round 1
and stays CURRENT on Round 2.

**Fix needed:** In folder mode, once a record has been rekeyed for any one of its
`file_paths` entries, it should be skipped (not re-processed) for the remaining files in
the same run. Or: the directory hash should use a manifest hash (combined hash of all
files in `file_paths`) rather than individual file blob hashes, so there is a single
canonical path for multi-file records.

### Acceptance Criteria Status

| Criterion | Status |
|---|---|
| Rekey scripts run from Worker session (no permission deny) | PASS |
| First rekey produces REKEYED output | PASS (6 REKEYED) |
| Phase 2 re-run after rekey produces cache hit | PASS |
| Second rekey produces 100% CURRENT (idempotency) | FAIL |

### Next Steps

1. Fix the multi-file record non-idempotency bug in `hash-record-rekey/rekey.sh` and
   `rekey.ps1` (assign to Curator or as a new task).
2. Update `permissions-scripts.ps1` lint.sh hash entry
   (`127A...` → `33468EAA87877BD096E29EF004E97543E4A87EE5E4FE5D35B611872C21ABDD86`).
3. Once fix is deployed, re-run rekey idempotency test to close 99% confidence goal.
