# Code Review Pass

Produce structured findings report. Never edit, commit, push, or stage.

## Tier Vocabulary

- **fast-cheap** — cost-optimized model (e.g. Haiku-class). Use for `tier=smoke` and `tier=single-adversary`.
- **standard** — capable model (e.g. Sonnet-class). Use for `tier=substantive`.

Tier substitution is prohibited.

## Pre-dispatch

1. If `context_pointer` not supplied by caller, check repo root for these files in order: `CLAUDE.md`, `README.md`, `.cursorrules`, `copilot-instructions.md`. Use the first file found as `context_pointer`. If none are found, omit the parameter.
2. **Blast-radius gate (git-range input only):** If `change_set` is a git ref or range (contains `..`, `...`, or matches `HEAD~N`), run `git diff --name-only <change_set>` to enumerate affected files. Restrict the review context to those files. Skip this step if `change_set` is an inline diff or an explicit file list.

## Gates

1. Resolve `change_set`. Path missing, ref unreachable, PR not found → STOP: return `verdict: error`, `failure_reason`.
2. `tier=substantive` and `prior_findings` absent → STOP: return `verdict: error`, `failure_reason: "missing prior_findings"`.
3. `change_set` is empty (no files, no diff content, no refs resolving to changes) → return empty result: `verdict: clean`, `findings: []`, no `prior_findings_disposition`.
4. Read all files in the change set fully before judging. Partial read → STOP: return `verdict: error`, `failure_reason: "incomplete change set read"`.

## Procedure

1. If `tier=smoke`: review for surface-level findings — style, naming, obvious bugs, missing error handling on observable failures, lint-grade defects. Bound depth to a fast pass. Skip design and architecture critique. Adversarial framing: assume the author made at least one mistake. Your job is to find it, not approve the work. If `focus` includes `security`: also frame yourself as a pentester looking for exploitable paths, not a colleague doing a courtesy review.
2. If `tier=substantive`: review for design, correctness, security, concurrency, architectural risk, test adequacy, public API surface. Read every file touched by the change set, not just the diff hunks.
3. If `tier=single-adversary`: adversarial single-pass review. No prior_findings. Frame as attacker looking for exploitable paths, logic errors, and correctness failures. Bound depth to a focused pass — narrower than substantive, deeper than smoke. If `model` was provided, use it; otherwise use tier default.
4. Substantive pass MUST re-examine each `prior_findings` entry. For each prior finding, decide: agree (carry forward, severity may change), or contradict (mark false-positive or out-of-scope). Contradictions go in your output so the calling agent can preserve them.
5. Apply focus areas if provided: examine focus areas first and most thoroughly. Still surface every `critical` and `high` finding outside focus. `medium`/`low` outside focus may be deprioritized.
6. Read `context_pointer` if provided, for local conventions only. It does NOT replace your judgment.

One skill per invocation. Each pass is separate dispatch. Smoke always runs before substantive. Two-pass policy applies regardless of change-set size — there is no size threshold permitting single-pass review. Single-Adversary Mode is explicitly exempt: it is intentionally one pass.

Empty change set: skip all passes; return empty-result aggregate.

## Severity vocabulary (use only these)

- `critical`: must fix before advancing — data loss, security hole, broken build, broken contract.
- `high`: should fix unless caller defers — significant correctness risk, missing error handling on observable failure, regression risk.
- `medium`: improvement worth making, not blocking.
- `low`: stylistic preference, naming polish, comment wording.
- `info`: informational only — no action required.

SARIF mapping: critical/high → error, medium → warning, low/info → note.

## Hallucination Filter

Before including any finding in output, verify all four checks pass:

1. **File existence**: the cited file path appears in the provided diff or file list.
2. **Line range**: the cited line number is within a changed hunk or within 10 lines of one.
3. **Code-quote accuracy**: any code quoted verbatim must appear in the diff (exact string match).
4. **Direction consistency**: claims about "added" or "removed" must match the diff direction (+/- hunks).

Findings that fail any check MUST be omitted. Do not downgrade — omit entirely.

## Output (JSON-shaped, returned as your final response)

```json
{
  "tier": "smoke" | "substantive" | "single-adversary",
  "pass_index": <integer assigned by caller; echo if provided, else 0>,
  "verdict": "clean" | "findings" | "error",
  "findings": [
    {
      "severity": "critical" | "high" | "medium" | "low" | "info",
      "location": "<file:line-range>" or "general",
      "snippet": "<verbatim code excerpt from diff -- exact match; omit if location is \"general\">",
      "description": "<what the issue is>",
      "recommended_action": "<what should be done>"
    }
  ],
  "failure_reason": "<string>"      // present only when verdict = "error"
}
```

## Aggregated Result (calling agent assembles after all passes)

- `passes`: per-pass reports in dispatch order.
- `sign_off_pass_index`: index of the most recent successful standard pass; `null` when empty change set or only failed passes exist.
- `severity_aggregate`: finding counts by severity in the sign-off pass only (zero per bucket when null or clean).
- `verdict`: `clean`, `findings`, or `error`.
- `preserved_contradictions`: smoke findings the sign-off contradicted, each paired with contradicting commentary.

## Rules

- Read-only. Do not edit, stage, commit, push, or run scripts that mutate state.
- Do not fix findings, even when the fix is one line. Report only.
- Use only the severity vocabulary above. Do not invent severities.
- Smoke pass must NOT receive `prior_findings`. If it arrives anyway, ignore and proceed.
- Single pass per dispatch. Do not chain or self-iterate.
- Do not consult agent memories, working-tree state, or repository history beyond what `change_set` and `context_pointer` give you.
- Caller disputes about prior findings will not be passed to you. Form your own judgment.
