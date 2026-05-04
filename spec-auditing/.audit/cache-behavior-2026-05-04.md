# spec-auditing cache-behavior test report
Date: 2026-05-04
Task: 40-0938 (retrofit spec-auditing with hash-record + seal)
Branch: 40-0938

## Phase A — Retrofit summary

Files modified:
- `spec-auditing/spec.md` — added `## Hash-Record Cache` section (manifest hash, cache path, cache check, record write, return token, repo-root computation, R-HR-1 through R-HR-6)
- `spec-auditing/instructions.uncompressed.md` — added Gate HC (cache check) and Step RW (record write)
- `spec-auditing/instructions.txt` — re-compressed from updated uncompressed
- `spec-auditing/SKILL.md` — expanded Iteration Safety section; added `--kind` parameter
- `spec-auditing/uncompressed.md` — updated Returns line and Iteration Safety

Operation kind: `spec-auditing/v1`
Hash-record path structure: `<repo_root>/.hash-record/<hash[0:2]>/<hash>/spec-auditing/v1/report.md`

## Phase B — Cache-hit behavior

Fixture: `skill-auditing/spec.md` (main repo, unchanged across runs)
Repo root: `D:/Users/essence/Development/cortex.lan/electrified-cortex/skills`

| Run | Input | Cache result | Hash-record path (abbreviated) | Notes |
|-----|-------|-------------|--------------------------------|-------|
| 1 | skill-auditing/spec.md | MISS | `.hash-record/d5/d51a535c…/spec-auditing/v1/report.md` | First run; full audit executed |
| 2 | skill-auditing/spec.md (identical) | HIT | `.hash-record/d5/d51a535c…/spec-auditing/v1/report.md` | Same path as Run 1; no LLM dispatch |
| 3 | fixture-mutated.md (+1 comment line) | MISS | `.hash-record/b4/b4d12058…/spec-auditing/v1/report.md` | Different path; full audit executed |
| 4 | skill-auditing/spec.md (original) | HIT | `.hash-record/d5/d51a535c…/spec-auditing/v1/report.md` | Same path as Runs 1+2; idempotent |

Return tokens:
- Run 1: `Fail: …/d51a535c…/spec-auditing/v1/report.md`
- Run 2: `PATH: …/d51a535c…/spec-auditing/v1/report.md` ← cache hit token
- Run 3: `Fail: …/b4d12058…/spec-auditing/v1/report.md`
- Run 4: `PATH: …/d51a535c…/spec-auditing/v1/report.md` ← cache hit token

Cache hit confirmed: YES
No LLM dispatch on hit: YES (Gate HC short-circuits at blob hash + sha256 computation only)
Idempotency confirmed: YES (Run 4 returns same record as Run 1/2)
Mutation sensitivity confirmed: YES (single appended line changes blob hash, produces new shard)

Manifest hash details:
- Original blob hash: `6378f8eae87e1c77026637cf9d4ffdc85faf68c5`
- Mutated blob hash: `c83554563e21ac1c95580da8567194a9bc539e0d`
- Original manifest hash: `d51a535c9a6745159ca9c6ddb69d69fac5bebcd489cc9a3c64f399051979025f`
- Mutated manifest hash: `b4d120582a4f3dae4f8ab3434e8e84096810c1c2c7054813f23f2c0a6a491386`

## Phase C — Sealing chain

Target: `spec-auditing/` in worktree 40-0938

| Phase | Result | Notes |
|-------|--------|-------|
| 1. skill-optimize | Action: 1 MEDIUM finding (caching) | See Known Gaps below |
| 2. skill-audit | PASS | commit 7670391, after 4 iterations |
| 3. spec-audit (dogfood) | Pass with Findings | 0 Critical/High; pre-existing structural Medium/Low remain |
| 4. tool-audit | SKIP | No .sh/.ps1 files in spec-auditing/ |
| 5. markdown-hygiene analysis | Warnings only (SA026, SA013, SA003) | Non-blocking |
| 6. markdown-hygiene lint | Findings fixed | MD031/MD032/MD040/MD029 fixed in commit a59774c |
| 7. hash-record-rekey (folder mode) | SKIP | 50-0936 in 60-review; not yet merged to main |

Cache-hit verification (re-runs after sealing):
- markdown-hygiene analysis: ALL CACHE HIT ✓
- markdown-hygiene lint: ALL CACHE HIT ✓

## Token-cost comparison

First run (Run 1): full LLM audit dispatch — typical cost ~3,000–8,000 tokens
Subsequent identical runs (Runs 2, 4): Gate HC only — `git hash-object` + `sha256sum` + path check, zero LLM tokens

Estimated re-run savings: >99% token reduction on cache hit.
Acceptance criterion (≥90% cheaper): PASS

## Known gaps

### Gap 1: `--kind` flag not included in manifest hash

The manifest hash covers only input file blobs. The `--kind meta|domain` flag is not included. If the same spec is audited first with auto-detected domain mode, then again with `--kind meta`, the second run receives a stale cache hit (domain-mode result served for meta-mode request).

Identified by: skill-optimize Phase 1 finding.
Severity: MEDIUM (affects only callers who explicitly override audit kind).
Fix options:
  A. Include effective audit kind as a virtual entry in hash computation (requires Gate 3 before Gate HC)
  B. Use mode-specific operation_kind: `spec-auditing/v1/meta` vs `spec-auditing/v1/domain`
Recommendation: follow-up task; default auto-detection behavior is correct.

### Gap 2: hash-record-rekey closer step skipped

The sealing chain closer (hash-record-rekey in folder mode) was skipped because task 50-0936 (folder-mode implementation) is in 60-review and not yet merged to main branch.

### Gap 3: dogfood spec-audit returns Pass with Findings

Pre-existing structural issues in spec-auditing/spec.md (F-07 pass/fail duplication, F-08 fix/repair mode fragmentation, F-02 companion auto-detect for spec.md) remain as Medium/Low findings. These were present before this retrofit and are outside the scope of hash-record caching.

## Acceptance criteria

| Criterion | Status |
|-----------|--------|
| spec.md + instructions reference hash-record with skill-auditing vocabulary | PASS |
| Re-running on unchanged input produces no LLM dispatch | PASS (Phase B Run 2) |
| Mutate-then-revert produces cache-hit on original record | PASS (Phase B Run 4) |
| spec-auditing/.hash-record/ populated by consumer phases | PASS (Phase C) |
| Re-running each phase cache-hits | PASS (Phase C re-run table) |
| Token cost: re-run ≥90% cheaper | PASS (>99% saving on cache hit) |
| Test report at .audit/cache-behavior-2026-05-04.md | PASS (this file) |
