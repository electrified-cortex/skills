# Code Review Pass

Read change set, produce findings report. Read-only — never edit, commit, push, stage. Reporting and fixing are separate concerns.

## Tier Vocabulary

- **fast-cheap** — cost-optimized model (e.g. Haiku-class). Use for `tier=smoke`.
- **standard** — capable model (e.g. Sonnet-class). Use for `tier=substantive`.

Tier substitution is prohibited.

## Parameters

- `change_set` (required): inline unified diff text, list of absolute file paths, or git ref/range (refs require shell access in the dispatched agent).
- `tier` (required): `smoke` or `substantive`. Governs depth.
- `prior_findings` (substantive only, required): findings from every prior pass on the same change set, forwarded unmodified. Required for substantive; smoke mustn't receive this.
- `focus` (optional): comma-separated focus areas (e.g. `security,concurrency`). Reorders priority; doesn't reduce depth — `blocker` and `major` outside focus must still surface.
- `context_pointer` (optional): path to CLAUDE.md/README/style guide for local conventions. Read for conventions only.

## Gates

1. Resolve `change_set`. Path missing, ref unreachable, PR not found → STOP: return `verdict: error`, `failure_reason`.
2. `tier=substantive` and `prior_findings` absent → STOP: return `verdict: error`, `failure_reason: "missing prior_findings"`.
3. `change_set` is empty (no files, no diff content, no refs resolving to changes) → return empty result: `verdict: clean`, `findings: []`, no `prior_findings_disposition`.
4. Read all files in the change set fully before judging. Partial read → STOP: return `verdict: error`, `failure_reason: "incomplete change set read"`.

## Procedure

1. If `tier=smoke`: review for surface-level findings — style, naming, obvious bugs, missing error handling on observable failures, lint-grade defects. Bound depth to a fast pass. Skip design and architecture critique.
2. If `tier=substantive`: review for design, correctness, security, concurrency, architectural risk, test adequacy, public API surface. Read every file touched by the change set, not just the diff hunks.
3. Substantive pass MUST re-examine each `prior_findings` entry. For each prior finding, decide: agree (carry forward, severity may change), or contradict (mark false-positive or out-of-scope). Contradictions go in your output so the calling agent can preserve them.
4. Apply focus areas if provided: examine focus areas first and most thoroughly. Still surface every `blocker` and `major` finding outside focus. `minor`/`nit` outside focus may be deprioritized.
5. Read `context_pointer` if provided, for local conventions only. It does NOT replace your judgment.
6. Smoke pass orchestration: calling agent dispatches smoke first, reviews findings, optionally acts on them, then dispatches substantive.
7. Substantive pass is authoritative: most recent standard pass is the sign-off. Calling agent records sign-off so downstream consumers can verify review occurred.

One skill per invocation. Each pass is separate dispatch. Smoke always runs before substantive. Two-pass policy applies regardless of change-set size — there is no size threshold permitting single-pass review.

Empty change set: skip all passes; return empty-result aggregate.

## Severity vocabulary (use only these)

- `blocker`: must fix before advancing — data loss, security hole, broken build, broken contract.
- `major`: should fix unless caller defers — significant correctness risk, missing error handling on observable failure, regression risk.
- `minor`: improvement worth making, not blocking.
- `nit`: stylistic preference, naming polish, comment wording.

## Output (JSON-shaped, returned as your final response)

```json
{
  "tier": "smoke" | "substantive",
  "pass_index": <integer assigned by caller; echo if provided, else 0>,
  "verdict": "clean" | "findings" | "error",
  "findings": [
    {
      "severity": "blocker" | "major" | "minor" | "nit",
      "location": "<file:line-range>" or "general",
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

## Calling Agent Rules

- Never treat smoke-only as authoritative. Skipping the substantive pass is prohibited.
- Forward prior-pass findings unmodified — no annotations, dispute flags, or reordering.
- Do not communicate caller disputes about smoke findings to the substantive pass.
- Do not modify the change set during a pass. Edits happen between passes only.
- Record the sign-off so downstream consumers can verify the review occurred.

## When to Use

Reviewing a change set of executable or compilable code: source files, build scripts, CI configuration, infrastructure-as-code manifests.

For non-code artifacts (specs, skills, docs), use `spec-auditing` or `skill-auditing` instead — they use a different tier policy.

## Iteration Safety

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.

## Rules

- Read-only. Do not edit, stage, commit, push, or run scripts that mutate state.
- Do not fix findings, even when the fix is one line. Report only.
- Use only the severity vocabulary above. Do not invent severities.
- Smoke pass must NOT receive `prior_findings`. If it arrives anyway, ignore and proceed.
- Single pass per dispatch. Do not chain or self-iterate.
- Do not consult agent memories, working-tree state, or repository history beyond what `change_set` and `context_pointer` give you. Zero-context isolation is normative.
- Caller disputes about prior findings will not be passed to you. Form your own judgment.
