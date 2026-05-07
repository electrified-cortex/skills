---
operation_kind: skill-auditing/v2
skill: swarm
result: findings
verdict: NEEDS_REVISION
file_paths:
  - swarm/SKILL.md
  - swarm/reviewers/devils-advocate.md
  - swarm/reviewers/security-auditor.md
  - swarm/spec.md
  - swarm/specs/arbitrator.md
  - swarm/specs/dispatch-integration.md
  - swarm/specs/glossary.md
  - swarm/specs/personality-file.md
  - swarm/specs/registry-format.md
  - swarm/uncompressed.md
---

# Result

NEEDS_REVISION. Three HIGH findings, three MEDIUM, one LOW. The skill bundle is structurally sound and procedurally complete. All findings are correctable without restructuring.

## Per-File Basic Checks

| File | Non-empty | Frontmatter | Absolute paths |
| --- | --- | --- | --- |
| `swarm/SKILL.md` | Yes | Present (`name`, `description`) | None |
| `swarm/uncompressed.md` | Yes | Present (`name`, `description`) | None |
| `swarm/spec.md` | Yes | N/A | None |
| `swarm/reviewers/devils-advocate.md` | Yes | None (intentional per resolved items) | None |
| `swarm/reviewers/security-auditor.md` | Yes | None (intentional per resolved items) | None |
| `swarm/specs/arbitrator.md` | Yes | N/A | None |
| `swarm/specs/personality-file.md` | Yes | N/A | None |
| `swarm/specs/registry-format.md` | Yes | N/A | None |

`swarm/specs/dispatch-integration.md` and `swarm/specs/glossary.md` — existence confirmed via directory listing; content not checked in this pass. No per-file findings to report for either.

All checked files pass per-file basic checks.

---

## Step 1 — Compiled Artifacts

**Classification**: inline. No `instructions.txt` present; `SKILL.md` contains full 8-step procedure.

| Check | Result |
| --- | --- |
| A-FM-1: `name` matches folder | PASS — `name: swarm` in both `SKILL.md` and `uncompressed.md`; folder is `swarm` |
| A-FM-4: Only `name` + `description` in frontmatter | PASS — both files |
| A-FM-11: `Triggers -` in description | PASS — both files |
| A-FM-12: `uncompressed.md` mirrors `SKILL.md` frontmatter | PASS — exact match |
| A-FM-3: No real H1 in `SKILL.md`; H1 present in `uncompressed.md` | PASS |
| A-FS-1: No orphan files | PASS — all non-well-known files referenced in `SKILL.md`, `uncompressed.md`, or `spec.md` |

### F-A2 — A-FS-2: Stale filename in `specs/arbitrator.md` (HIGH)

**Check**: A-FS-2 (missing referenced file) / Step 3 spec internal consistency
**File**: `swarm/specs/arbitrator.md`

`specs/arbitrator.md`, Output Structure section states:

> "Source personality indices (from the runtime index in `reviewers/index.md`)"

The file `reviewers/index.md` does not exist. The actual registry index is `reviewers/index.yaml`. The SKILL.md and uncompressed.md both correctly reference `reviewers/index.yaml`. The sub-spec has a stale filename.

Note: `specs/registry-format.md` recommends `index.md` as the default format but allows any parseable format. The implementation chose YAML. The sub-spec was not updated to match.

**Fix**: In `specs/arbitrator.md`, replace `reviewers/index.md` with `reviewers/index.yaml`.

---

## Step 2 — Parity Check

### F-P1 — "personality indices" vs "personality names": SKILL.md contradicts uncompressed.md (HIGH)

**Check**: Step 2 parity
**Files**: `swarm/SKILL.md` vs `swarm/uncompressed.md`

`SKILL.md` Step 7:
> "For each item, record: personality indices cited, finding summary, cited evidence."

`SKILL.md` arbitrator output format (both Obvious and Critical actions):
> "Each entry: action description + source personality indices + evidence cite."

`uncompressed.md` Step 7:
> "the skill records: personality names cited, finding summary, evidence cite."

`uncompressed.md` arbitrator output format (both sections):
> "Each item includes: description, source personality names, and evidence cite."

The two artifacts specify different attribution fields for disagree-set tracking and arbitrator output. "Indices" (positional integer) and "names" (string identifiers) are not interchangeable. The parity failure is present in both Step 7 and the arbitrator format block.

**Fix**: Determine canonical value from spec (see F-S1 — primary spec uses "names"). Edit `uncompressed.md` to use "indices" or "names" per the resolved spec, then recompress to `SKILL.md`.

---

## Step 3 — Spec Alignment

### F-S1 — Primary spec vs sub-spec contradiction: "personality names" vs "personality indices" (HIGH)

**Check**: Step 3 internal consistency
**Files**: `swarm/spec.md` vs `swarm/specs/arbitrator.md`

Primary `spec.md`, Step 7:
> "the skill records: personality names cited, finding summary, evidence cite."

Primary `spec.md`, arbitrator format (a) and (b):
> "Each item includes: description, source personality names, and evidence cite."
> "Each item includes: description, source personality names, evidence cite, and severity rationale."

`specs/arbitrator.md`, Output Structure:
> "Source personality indices (from the runtime index in `reviewers/index.md`)"

The primary spec consistently uses "personality names." The sub-spec uses "personality indices." SKILL.md follows the sub-spec (uses "indices"); uncompressed.md follows the primary spec (uses "names"). This produces the parity failure in F-P1. Primary spec is authoritative.

**Fix**: Update `specs/arbitrator.md` to use "personality names" to align with primary spec. Then resolve F-P1 (update `uncompressed.md` to use "names", recompress to `SKILL.md`).

### F-S2 — Spec internal inconsistency: gpt-class absent from C6 but present in Req 12 and Definitions (MEDIUM)

**Check**: Step 3 internal consistency
**File**: `swarm/spec.md`

`spec.md` Req 12:
> "only model class terms (`haiku-class`, `sonnet-class`, `opus-class`, `gpt-class`) may be used"

`spec.md` Definitions (model class):
> "`gpt-class` (alias for GPT-family models of roughly sonnet-class capability)"

`spec.md` C6:
> "Use model class terms only: `haiku-class`, `sonnet-class`, `opus-class`."

C6 lists three terms; Req 12 and Definitions list four (adding `gpt-class`). C6 was not updated when `gpt-class` was added to Req 12 and Definitions. An implementor reading C6 may incorrectly reject `gpt-class` as invalid.

**Fix**: Update `spec.md` C6 to: `Use model class terms only: haiku-class, sonnet-class, opus-class, gpt-class.`

### F-S3 — Coverage failure: gpt-class absent from SKILL.md and uncompressed.md model class definition (MEDIUM)

**Check**: Step 3 coverage
**Files**: `swarm/SKILL.md`, `swarm/uncompressed.md`

`SKILL.md` Key Terms, model class:
> "`haiku-class` (shallow/mechanical), `sonnet-class` (moderate reasoning, default), `opus-class` (heavy architectural reasoning). No bare model names anywhere."

`uncompressed.md` Key Terms, model class — identical, omits `gpt-class`.

`spec.md` Req 12 lists `gpt-class` as a valid term. `reviewers/index.yaml` Devil's Advocate entry uses it: `suggested_models: [sonnet-class, gpt-class]`. The term appears in the registry the skill crawls but is absent from the runtime instruction set that defines valid terms.

An agent executing `SKILL.md` won't know `gpt-class` is a valid model class term. When reading Devil's Advocate's `suggested_models`, it may treat `gpt-class` as unrecognized.

Note: parity is consistent between `SKILL.md` and `uncompressed.md` — both omit `gpt-class` — so this is a spec coverage failure, not an additional parity failure.

**Fix**: Add `gpt-class` to the model class definition in `uncompressed.md`, then recompress to `SKILL.md`. Also fix `spec.md` C6 per F-S2.

### F-S4 — Coverage failure: B8 diversity rule referenced by label only, not defined inline (MEDIUM)

**Check**: Step 3 coverage
**Files**: `swarm/SKILL.md`, `swarm/uncompressed.md`

`SKILL.md` Step 5:
> "Apply diversity preference rule (B8) after model selection."

`uncompressed.md` Step 5:
> "Apply the diversity preference rule (B8) after model selection to attempt cross-vendor coverage."

`spec.md` B8 (full text):
> "Cross-vendor diversity: prefer at least one personality on a different model family or vendor than the host. Best-effort: if no diverse option is available after availability gating, proceed and note monoculture in synthesis output. Devil's Advocate is the natural carrier for diversity (always required, `vendor` frontmatter field expresses preference for non-Anthropic model)."

Both `SKILL.md` and `uncompressed.md` reference B8 by label only. The best-effort nature, the fallback behavior, the monoculture note, and the mechanism (vendor field as the diversity signal) are all absent from the runtime instructions. An agent executing `SKILL.md` cannot apply this rule without consulting `spec.md`.

**Fix**: Inline the B8 content in `uncompressed.md` Step 5 (or as a named behavior block at end of Step 5). Remove the bare "(B8)" label. Then recompress to `SKILL.md`.

### F-S5 — Coverage gap: B2 empty-swarm error not in SKILL.md (LOW)

**Check**: Step 3 coverage
**File**: `swarm/SKILL.md`

`spec.md` B2:
> "If the swarm is empty after availability gating, return error: 'Swarm empty after gating — no personalities available.' Do not attempt synthesis."

`SKILL.md` Step 3 states: "Note drop in synthesis output. Don't fail-stop or surface error to caller." This describes individual personality drops. It does not specify the error return when all personalities are dropped (swarm fully empty after gating).

Without B2, an agent may proceed to synthesis with an empty swarm and produce an invalid output rather than returning the specified error.

**Fix**: Add an explicit empty-swarm guard to `uncompressed.md` Step 3 or Step 5: if all personalities are dropped and swarm is empty, return error "Swarm empty after gating — no personalities available." Do not proceed to synthesis. Then recompress.

---

## Finding Summary

| ID | Severity | Step | Check | File(s) |
| --- | --- | --- | --- | --- |
| F-A2 | HIGH | Step 1 | A-FS-2 — `reviewers/index.md` referenced but does not exist | `specs/arbitrator.md` |
| F-P1 | HIGH | Step 2 | Parity — "indices" vs "names" in Step 7 and arbitrator format | `SKILL.md` vs `uncompressed.md` |
| F-S1 | HIGH | Step 3 | Internal consistency — primary spec vs sub-spec contradiction on "names" vs "indices" | `spec.md` vs `specs/arbitrator.md` |
| F-S2 | MEDIUM | Step 3 | Internal consistency — `gpt-class` absent from C6, present in Req 12 + Definitions | `spec.md` |
| F-S3 | MEDIUM | Step 3 | Coverage — `gpt-class` absent from model class definition | `SKILL.md`, `uncompressed.md` |
| F-S4 | MEDIUM | Step 3 | Coverage — B8 diversity rule not defined inline | `SKILL.md`, `uncompressed.md` |
| F-S5 | LOW | Step 3 | Coverage gap — B2 empty-swarm error not represented | `SKILL.md` |
