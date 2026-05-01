# parallel-strategy.md — Spec

## Purpose

Defines the spec for `parallel-strategy.md`, an orchestration guide agents
read when applying the markdown-hygiene skill to **many files at once**. The
document describes a four-phase pipeline that minimises agent cost by
front-loading cheap mechanical work and dispatching agents only for files that
genuinely need them.

## The Document This Spec Governs

`parallel-strategy.md` lives at `markdown-hygiene/parallel-strategy.md`.
It is read by an orchestrating agent (e.g., a Curator or Dispatch worker) that
has been asked to hygiene a glob or a set of files. It is **not** read by the
lint or analysis executor sub-agents — those follow their own `instructions.txt`.

## Pipeline Overview

```text
glob
 │
 ▼
Phase 0 — Miss filter (free)
  misses.ps1 <glob> markdown-hygiene lint.md
 │
 ▼  files without a cached lint record
Phase 1 — Lightweight auto-fix sweep (free, no agent)
  lint.ps1 <miss1> <miss2> ...
 │
 ▼  same file list, now auto-fixed
Phase 2 — Distributed lint (Haiku-class, parallel)
  one markdown-hygiene-lint dispatch per file
 │
 ▼
Phase 3 — Analysis cost gate (confirmation required)
  misses.ps1 <glob> markdown-hygiene analysis.md  → count N
  prompt: "Dispatch N Sonnet agents? [yes / no / list]"
 │  (stop here if operator declines)
 ▼  operator confirmed
Phase 4 — Distributed analysis (Sonnet-class, parallel)
  one markdown-hygiene-analysis dispatch per file
```

## Phase Descriptions

### Phase 0 — Miss Filter

**Tool:** `hash-record/hash-record-check/misses.ps1`

```powershell
$lintMisses = pwsh misses.ps1 <glob> markdown-hygiene lint.md
```

Outputs only the file paths that have **no** cached `lint.md` record. Files
already in cache are silently skipped — zero agent cost for them.

This is the first filter. Every subsequent phase operates only on files
returned here, or a subset thereof. Files not in `$lintMisses` are considered
already processed and are not touched.

### Phase 1 — Lightweight Auto-Fix Sweep

**Tool:** `markdown-hygiene/markdown-hygiene-lint/lint.ps1`

```powershell
pwsh lint.ps1 $lintMisses
```

Runs `markdownlint --fix` for the deterministic rules (MD009, MD012, MD047)
across all miss files in a single call. No agent involved. Mutates files in
place. This makes the subsequent lint executor pass cheaper and more likely to
produce `result: clean` on the first attempt.

The file list passed is exactly `$lintMisses` — the output of Phase 0.

### Phase 2 — Distributed Lint (Haiku-class)

**Tool:** `markdown-hygiene/markdown-hygiene-lint/instructions.txt` via dispatch

For each file in `$lintMisses`, dispatch one `markdown-hygiene-lint` sub-agent.
Dispatches run in parallel up to the orchestrator's available concurrency.

Each agent writes its own `lint.md` cache record and returns `clean:` or
`findings: <path>`. The orchestrator collects results and proceeds.

**Model class:** Haiku (cheap, deterministic pattern-matching only).

### Phase 3 — Analysis Cost Gate (confirmation required)

Before running any analysis, the orchestrator **must** pause and ask the
operator or calling agent whether to proceed.

The orchestrator first runs the miss probe to produce a count:

```powershell
$analysisMisses = pwsh misses.ps1 <glob> markdown-hygiene analysis.md
```

Then surfaces a confirmation prompt before dispatching anything:

```text
Analysis will dispatch <N> Sonnet-class agents for <N> uncached files.
This incurs real token cost. Proceed? [yes / no / list]
```

- `yes` — proceed to Phase 4.
- `no` — stop here; lint records are already cached and usable.
- `list` — show the file paths in `$analysisMisses` before asking again.

**Do not skip this gate.** Analysis is optional and expensive. If the caller
is an automated pipeline with no interactive channel, it must pass an explicit
`--run-analysis` flag (or equivalent) to bypass the gate programmatically —
silence is not consent.

If `$analysisMisses` is empty (all files already cached), skip the gate
entirely and report that analysis is already complete.

### Phase 4 — Distributed Analysis (Sonnet-class)

**Tool:** `markdown-hygiene/markdown-hygiene-analysis/instructions.txt` via dispatch

For each file in `$analysisMisses`, dispatch one `markdown-hygiene-analysis`
sub-agent. Parallel dispatch up to available concurrency.

Each agent reads the `lint.md` record (written in Phase 2), evaluates SA rules,
writes `analysis.md`, and returns `clean:`, `pass:`, or `findings:`.

**Model class:** Sonnet (or GPT-5.4). Semantic reasoning required.

## Cost Profile

| Phase | Agent cost | Notes                                              |
| ----- | ---------- | -------------------------------------------------- |
| 0     | Free       | Pure PowerShell, git hash-object probe             |
| 1     | Free       | markdownlint --fix, no LLM                         |
| 2     | Haiku × N  | N = count of lint misses; parallelised             |
| 3     | Free       | Miss probe + confirmation gate; operator may stop  |
| 4     | Sonnet × M | M ≤ N; only runs with explicit operator approval   |

On repeat runs against the same glob, Phases 0 and 3 will return smaller sets
as the cache fills. Incremental runs converge toward zero agent cost.

## Bash / Non-PowerShell Callers

Phase 0 and 3 require `misses.ps1` which is PowerShell 7+ only.
Bash callers must implement equivalent miss-checking themselves (e.g., loop
with `git hash-object` + path probe) or call `pwsh misses.ps1` if PS7 is
available.

Phase 1 (`lint.ps1`) has a Bash equivalent (`lint.sh`) that accepts the same
glob arguments.

Phase 2 and 4 dispatch is orchestrator-dependent and not shell-specific.

## Constraints

- `misses.ps1` requires PS7 and `git` on `PATH`.
- `lint.ps1` requires `markdownlint-cli` on `PATH`.
- Phase 2 dispatches should not exceed the orchestrator's token/concurrency budget.
  Recommended batch size: 8–16 files per wave.
- Phase 4 dispatches are more expensive — limit parallel concurrency to 4–8.
- Do not skip Phase 0. Dispatching agents for already-cached files wastes tokens.

## Related Files

- `markdown-hygiene/SKILL.md` — single-file orchestration flow
- `markdown-hygiene/spec.md` — architecture of the skill layers
- `markdown-hygiene/markdown-hygiene-lint/lint.ps1` — Phase 1 tool
- `markdown-hygiene/markdown-hygiene-lint/lint.spec.md` — lint tool spec
- `hash-record/hash-record-check/misses.ps1` — Phase 0 / Phase 3 tool
- `hash-record/hash-record-check/misses.spec.md` — miss tool spec
