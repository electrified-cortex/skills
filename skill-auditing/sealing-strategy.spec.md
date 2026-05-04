# Spec: Skill Sealing Strategy

## Purpose

Define a deterministic, token-efficient procedure for bringing a skill to a fully sealed
(official) state. "Sealed" means: skill audited, tools audited, all markdown clean, all
changes committed, a process activity log exists, and valid hash-record entries exist that
will hit on re-audit.

The core problem this solves: post-audit maintenance (markdown hygiene, tool audit)
invalidates the hash record by changing file content, forcing expensive re-audit rounds
just to restore a passing state. This spec defines when to re-audit vs. when to rename
an existing audit record to the new hash key, and how to track what was applied without
re-running completed work.

## Canonical sealing order (operator-codified, 2026-05-03)

Apply phases top-down. Each phase is broader than the next; output of an earlier phase
shapes what the next phase audits.

| # | Phase | Why this order |
| - | ----- | -------------- |
| 1 | Skill optimization | Highest level. Reorganizes / consolidates the skill itself. Leverages existing optimize-folder idempotency. |
| 2 | Skill audit | Codifies the actual truth of how the skill works (post-optimize). |
| 3 | Spec audit | Validates specs against the audited truth from step 2. Specs follow audit findings. |
| 4 | Tool audit | Validates executor scripts (`.sh`/`.ps1`) against the now-aligned specs. Skip if no tools in scope. |
| 5 | Markdown hygiene **analysis** | Semantic / structural review of every `.md` file. Fix all analysis findings BEFORE running lint. |
| 6 | Markdown hygiene **lint** | Mechanical formatting. Last step. Runs on semantically-settled content. |

Rationale for ordering:

- Highest level first — broad work shapes narrower work.
- Audit before spec — the spec must conform to truth, not the other way around.
- Tool audit after spec — tools are validated against the now-stable spec.
- Hygiene **analysis before lint** — analysis can change content; lint applied to
  unsettled content is wasted work.

After step 6, the skill is content-stable. Move to the rekey trick below.

## The rekey trick — preserve all phase outputs without re-running

Each phase produces artifacts: hash records, manifests, audit reports. Downstream phases
typically modify some of the files referenced by upstream artifacts. Without intervention,
the upstream records are now stale, and re-running the upstream phase would re-audit
from scratch — burning tokens for work that has already been done correctly.

**The fix is a single folder-level rekey at the end of the chain.**

At the end of step 6:

1. Identify all produced artifacts. They surface as **untracked or modified files in
   `git status`** — that is the canonical signal. The folder-level rekey tool walks the
   sealing-target folder, finds every hash-record entry and every manifest reference to
   files in the folder, and rekeys each to the current file content.
2. Run the folder-level rekey BEFORE any prune. (Prune deletes records that don't match
   current content; running it before rekey would discard records we want to preserve.)
3. After rekey, every record's recorded hash matches its file's current hash. Re-running
   any earlier phase short-circuits as a **cache hit** — the audit-execution layer sees
   the record exists with a current hash and skips re-execution.

**No per-skill rekey-flag.** The rekey tool is responsible for finding records and
manifests on its own from a folder argument. Skills don't have to declare what files
they produced.

## Idempotency guarantee (must be tested)

After the full chain + folder-level rekey:

- Re-run skill optimize → cache hit.
- Re-run skill audit → cache hit.
- Re-run spec audit → cache hit.
- Re-run tool audit → cache hit.
- Re-run hygiene analysis → cache hit.
- Re-run hygiene lint → cache hit.

If ANY of these re-executes work after a clean rekey, the rekey is incomplete or the
phase's cache-detection logic is wrong. Both are bugs.

This guarantee must be tested. The first integration test of the rekey-folder mode
should be a full chain → rekey → re-run-each-phase that asserts cache hits across the
board.

## Why this order is canonical

Operator (2026-05-03): "*This has to be the way we do things from now on. To prevent
redoing processing and doing things more than once, things should be idempotent in
smart ways, even if pieces of them change.*"

The strategy defends against the failure mode that surfaced through the day: skills
that touched the same files in different phases produced records that invalidated each
other, and re-running any single phase to "verify" forced full re-execution of work
that was already complete.

## Scope

Applies to any skill directory containing: a `SKILL.md`, one or more executor scripts
(`.sh` / `.ps1`), a companion spec (`result.spec.md`), and optionally `instructions.txt`
/ `instructions.uncompressed.md`.

Out of scope: auditing skills that are themselves under active development mid-session.
Sealing is a finalizing act, not a development loop.

## Definitions

| Term | Meaning |
| --- | --- |
| Skill audit | A full pass of the `skill-auditing` skill against a target skill |
| Tool audit | A full pass of the `tool-auditing` skill against each `.sh`/`.ps1` trio in the skill |
| Hygiene analysis | The semantic/advisory pass of `markdown-hygiene` — higher-level structural review |
| Hygiene lint | The mechanical lint-fix pass of `markdown-hygiene` — rule violations, whitespace, formatting |
| Hash record | The content-hash-keyed audit record written by the skill-auditing/tool-auditing scripts |
| Activity log | A timestamped record of which passes were applied during this sealing run |
| Stage | `git add <specific files>` — never `git add -A` |
| Semantic change | A diff that alters meaning, logic, requirements, or behavioral intent |
| Whitespace-only change | A diff that only alters spacing, blank lines, indentation, punctuation style |
| Re-sign | Moving an existing audit report to the hash key of the post-hygiene content via `git mv` |

## Sealing Procedure

Execute phases in order. Stage after each phase. Do not commit until Phase 5.

### Phase 1 — Skill audit

1. Load the `skill-auditing` skill.
2. Run a full skill audit against the target skill. Fix all findings in-place.
   - The skill audit may update `result.spec.md` to align with actual tool behavior.
     It must NOT modify the executor scripts (`.sh` / `.ps1`) themselves — spec alignment
     only. Actual script fixes happen in Phase 2 (tool audit).
3. Repeat until verdict is PASS or PASS_WITH_FINDINGS (trivial only). Hard cap: 3 passes.
4. The skill-auditing script writes the hash record automatically on PASS.
5. Stage all changed files (SKILL.md, instructions.txt, instructions.uncompressed.md,
   result.spec.md, uncompressed.md, and the new `.hash-record/` entry).
6. Log to activity log: `phase=1 verdict=<verdict> passes=<n> timestamp=<ISO>`

**Non-convergence escalation:** If the 3-pass cap is hit without PASS, stop and surface
to the caller: "Phase 1 could not converge after 3 passes — findings: `<summary>`. Proceed
to Phase 2 anyway, or abort sealing?" Do not proceed silently. Let the caller decide.

**Stop condition:** PASS verdict + hash record written + staged + activity log entry.

### Phase 2 — Tool audit

Run after Phase 1 because the skill audit may have updated `result.spec.md`. The tool
audit validates the executor scripts against the (now updated) spec.

1. For each executor script pair (`result.sh` + `result.ps1`) in the skill:
   - Load the `tool-auditing` skill.
   - Run a tool audit. Fix all findings in-place.
   - Script writes its own hash record on PASS.
2. Stage all changed files (scripts, spec, new `.hash-record/` entries).
3. Log to activity log: `phase=2 verdict=<verdict> tools=<list> timestamp=<ISO>`

Note: Tool audit produces a separate hash record keyed to the tool files. It does not
invalidate the Phase 1 skill audit record.

**Stop condition:** Tool audit PASS for each executor pair + hash records written + staged.

### Phase 3 — Markdown hygiene

Sub-phase ordering: **analysis before lint** — most impactful to least impactful. Structural
and semantic concerns must be resolved before mechanical formatting is locked in. Running
lint before analysis wastes a pass: if analysis finds structural issues and changes content,
the lint pass becomes stale and must be re-run. Analysis first keeps re-work minimal.

#### Phase 3a — Analysis (semantic, first)

1. Run `markdown-hygiene` analysis on all `.md` files.
2. Fix any semantic or structural findings in-place. Stage changes.
3. Log: `phase=3a findings=<n> changed=[list] timestamp=<ISO>`

**Opportunistic sealing gate:** After fixing analysis findings, assess each file — if it is
clearly stable (no subsequent phase will change it), seal it immediately by writing/re-signing
its hash record now rather than waiting for Phase 5. This avoids unnecessary re-sign passes.

#### Phase 3b — Lint (mechanical, last)

Run lint after analysis so the mechanical formatting pass applies to the semantically-settled
content. Lint is the final touch before sealing.

1. Run `markdown-hygiene` lint in **detect-only** mode on all `.md` files.
2. Examine proposed changes: semantic or whitespace-only?

**Decision gate:**

| Change type | Action |
| --- | --- |
| No changes | Skip to Phase 5 |
| Whitespace-only | Apply fixes -> re-sign stale hash records (Phase 4A) |
| Semantic content change | Apply fixes -> re-audit (Phase 4B) |

### Phase 4A — Re-sign (whitespace-only path)

1. Apply lint fixes to all `.md` files.
2. For each Phase 1 / Phase 2 / Phase 3a hash record now stale due to content hash change:
   a. Run the result script (`result.sh` or `result.ps1`) — expect a cache MISS.
   b. Use `hash-record-rekey` to move the record to the new key automatically (or
      `git mv <old-record-path> <new-record-path>` if the sub-skill is unavailable).
      Do not re-run the full audit.
3. Stage all changed `.md` files and renamed hash records.
4. Log: `phase=4a action=resign files=<list> lint-changes=whitespace-only timestamp=<ISO>`

Rationale: whitespace/formatting changes do not alter what was audited. The verdict,
findings, and metadata remain valid — only the content hash changed. Lint-last ordering
ensures re-sign happens at most once per sealing run.

### Phase 4B — Re-audit (semantic change path)

1. Apply lint fixes to all `.md` files.
2. If lint changes are semantic, that content must be re-audited — include in scope.
3. Re-run Phase 1 (skill audit) once. Hard cap: 1 additional pass.
4. If the re-audit passes, the new hash record supersedes the stale one. Stage everything.
5. If the re-audit fails, stop and report — do not loop further.
6. Log: `phase=4b action=reaudit verdict=<verdict> timestamp=<ISO>`

### Phase 5 — Commit

1. Review all staged changes: `git diff --staged`.
2. Confirm every changed file is intentional.
3. Finalize the activity log with a summary of all phases applied.
4. Commit: `seal(<skill>): skill audit + tool audit + hygiene pass`.
5. Confirm hash records exist and are committed.

## Activity Log

Maintain a lightweight log during the sealing run to track which passes were applied,
verdicts, and timestamps. Purpose: if any hash record is stale after a phase, the log
tells you exactly what changed and whether a re-sign or re-audit is needed — without
having to reconstruct history from git diff alone.

Format: append to `.sealing-log.md` in the skill directory during the run (delete after
commit, or retain as a session artifact — caller's choice).

Example entry:

```md
## Sealing run — 2026-05-02T21:30Z
- phase=1 verdict=PASS passes=2 record=abc123 timestamp=2026-05-02T21:31Z
- phase=2 verdict=PASS tools=[result.sh,result.ps1] record=def456 timestamp=2026-05-02T21:35Z
- phase=3a findings=2 changed=[SKILL.md] timestamp=2026-05-02T21:37Z
- phase=3b change_type=whitespace-only timestamp=2026-05-02T21:38Z
- phase=4a action=resign old=abc123 new=ghi789 timestamp=2026-05-02T21:39Z
- phase=5 commit=seal(skill-auditing) timestamp=2026-05-02T21:40Z
```

## Future: Consolidated dispatch

The skill-auditing executor can route to markdown analysis instructions within the same
haiku dispatch, reducing agent spin-up overhead. This is a future optimization — current
spec treats each phase as a separate dispatch. When consolidated dispatch is implemented,
the activity log becomes the primary record that each sub-phase completed.

## Invariants

- Never commit between phases — staging gives full visibility into what changed.
- Never run `git add -A` — stage specific files only.
- Hard caps: Phase 1 max 3 passes, Phase 4B max 1 re-audit. These are absolute.
- If any hard cap is hit, stop and surface to caller. Do not improvise.
- Phase 4A re-sign is only valid for whitespace-only diffs. Any doubt -> Phase 4B.
- Activity log is required for any sealing run involving 3+ phases.

## Token cost profile

| Path | Approximate cost |
| --- | --- |
| Happy path (no hygiene changes) | 1 skill audit + 1 tool audit + 2 hygiene passes |
| Whitespace hygiene | + re-sign (git mv, no extra audit) |
| Semantic hygiene change | + 1 re-audit |
| Slow convergence worst case | 3 skill audit passes + tool audit + hygiene + 1 re-audit |

Target: happy path. Report and escalate if worst case is reached.

## Non-goals

- Does not govern mid-development audit loops.
- Does not govern bulk-sealing multiple skills in sequence.
- Does not replace skill-auditing or tool-auditing — it orchestrates them.
- Does not define when to trigger sealing (that is the caller's decision).
