---
name: skill-optimize
description: Analyzes single skill for architectural and structural improvement. Dispatches topic analysis to sub-agents, records findings in optimize-log. NEVER modifies source files. Triggers — optimize skill, skill review, architectural review, skill improvement, find skill issues, analyze skill structure.
---

Prerequisite: audit the target skill using `../skill-auditing/SKILL.md`

Inputs:

Required: `<skill-path>` — path to the **target skill being analyzed** (not this skill's own directory). Contains SKILL.md, spec.md, uncompressed.md, etc.

Optional:
`<topic>` — slug; provided → skip assessor, analyze directly.
`<mode>` — `assess-only` (pick only) | default (assess + analyze)

Step 1 — Read Source Files:

Read all from `<skill-path>` in order; don't analyze yet.

1. `spec.md`
2. `uncompressed.md`
3. `SKILL.md`
4. `instructions.txt`
5. `instructions.uncompressed.md`

None found → `ERROR: no skill source files found at <skill-path>`.

Allowed write targets (inside the **target skill's** directory): `<skill-path>/optimize-log.md` (5a), `<skill-path>/.optimization/<slug>.md` (5b). Read scope: `<skill-path>` and `<skill-optimize-root>/topics/` only.

Step 2 — Check Optimize Log:

Log: `<skill-path>/optimize-log.md`. Read if exists; exclude `clean`/`rejected`/`acted` from candidates. No log → first pass.

```markdown
(H1) Optimize Log: <skill-name>

## Topics Analyzed

| Topic | Date | Model | Findings | Status | Action |
| DISPATCH | 2026-04-29 | Sonnet | 1 | pending | — |
| CACHING  | 2026-04-29 | Sonnet | 0 | clean   | No change. |
```

Status: `pending` | `acted` | `deferred` | `rejected` | `clean`

Step 2a — Pre-flight Audit Check:

Run `pwsh result.ps1 <skill-path>` from `skill-auditing/` dir. Note verdict; proceed regardless.

Step 2b — Explicit Topic Guard:

If `<topic>` provided AND log exists AND `<topic>` row status is `clean`, `acted`, or `rejected` → emit `SKIP: <topic> already <status> — pass --force to re-analyze` and stop. (Bypass with `--force` flag.)

Step 3 — Assessor Pass:

Pick best next topic. Skip if `<topic>` provided — verify `topics/<topic>.md` exists; missing → `ERROR: topic file not found at topics/<topic>.md`. Go to Step 4.

Assessor model: Sonnet-class.

3a — Qualifier (Haiku-class, one call):

Pass: source files (Step 1), ordered candidates (unanalyzed, not `clean`/`rejected`/`acted`, priority-sorted), one-line descriptions.

```text
Read the skill files below.
Scan the following topic list in order.
Return the FIRST topic that applies. Short-circuit at first match.

Format:
TOPIC: <SLUG>
APPLICABLE: yes | maybe
REASON: <one sentence>

If none apply: TOPIC: none
```

Second candidate: one extra call starting after prev slug. No further chaining.

3b — Assessor Decision:

Pick one `yes`/`maybe` topic most likely to yield HIGH finding.
`TOPIC: none` → `No applicable topics found — all logged or none apply.`

Tie-breaking: 1. `yes` > `maybe` 2. Structural > stylistic 3. Shorter spec 4. Default: DISPATCH → CACHING → DETERMINISM → INTERFACE CLARITY → LESS IS MORE

Emit: `Assessor selected: <TOPIC-SLUG> — <one-line reason>`. `assess-only` → stop.

Fallback (no dispatch):

| Signal | Topic |
| ------ | ----- |
| Expensive/repetitive, no cache | HASH RECORD |
| Sub-agents or external tools | DISPATCH |
| Steps replaceable via regex/file/git | DETERMINISM |
| Contract undocumented | INTERFACE CLARITY |
| Description vague or similar to neighbors | TOOL SIGNATURES |
| Instructions long relative to scope | LESS IS MORE |
| Judgment calls, no review | SELF CRITIQUE |
| No output schema; format varies | OUTPUT FORMAT |
| Loops, no hard cap | ITERATION SAFETY |
| Version refs pinned | TEMPORAL DECAY |
| Default | DISPATCH |

Step 4 — Topic Analysis (Dispatched):

Dispatch Sonnet-class sub-agent. Pass: source files (Step 1), `topics/<slug>.spec.md`, `topics/<slug>.md` (if exists).

```md
You are a skill optimizer running a focused topic analysis.

Topic: <SLUG>

Skill files: <attach all>
Topic spec: <attach spec>
Topic assessment guide (if exists): <attach .md>

Apply assessment. Return findings or CLEAN:

### <CATEGORY> — HIGH | MEDIUM | LOW

**Reasoning:** <grounded in skill content>

**Recommendation:** <concrete, actionable>

HIGH = clear benefit, direct evidence. MEDIUM = likely, context-dependent. LOW = minor.
CLEAN if none apply. Universal findings: `audit-candidate: <description>`
Verify severity before output. All paths repo-relative.
```

CLEAN → `clean`. Findings → record. Missing `### CATEGORY` or `**Reasoning:**` → `ERROR: unexpected analysis format`, stop.

Step 5 — Record Results:

5a: Append to `<skill-path>/optimize-log.md`:
`| <TOPIC> | <date> | <model> | <N> | <status> | <action> |`

Status: `acted` | `deferred` | `rejected` | `clean` | `audit-candidate`. No log → create with Step 2 header.

5b: Write `<skill-path>/.optimization/<slug>.md`:

```md
# <TOPIC> — <date>

**Severity:** HIGH | MEDIUM | LOW
**Finding:** <observed>
**Action taken:** <changed or "No change.">
```

Clean → `CLEAN — no findings.`

Step 6 — Output:

```text
TOPIC: <TOPIC-SLUG> | FINDINGS: <N> | LOG: <repo-relative path>
```

Tier-1+2 all `clean`/`acted`/`deferred` → also emit:

```text
CONVERGENCE: tier-1+2 topics complete — <N acted>, <M clean>, <K deferred>
Next: re-run with higher model tier to verify.
```

Stop. Caller re-runs if needed.

Topic slugs: `dispatch` `caching` `determinism` `composition` `model-selection` `compressability` `wording` `less-is-more` `reuse` `output-format` `examples` `chain-of-thought` `tool-signatures` `self-critique` `convergence` `iteration-safety` `progressive-optimization` `antipatterns` `error-handling` `interface-clarity` `observability` `temporal-decay` `context-sensitivity` `autonomy-level` `activation-discipline` `context-budget` `failure-mode` `verification-strategy` `evaluation-harness`

Context budget: prefer shorter specs (DISPATCH, CACHING, DETERMINISM lean). One topic vs. thin coverage.

Related: skill-auditing (conformance auditing), hash-stamping (caching pattern), compression (compress uncompressed.md → SKILL.md after changes).
