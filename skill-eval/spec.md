# Skill Eval

## Purpose

Evaluate a target skill across multiple trials and model classes to produce a recommendation: which model class executes the skill best, what outcomes a caller can expect, and where the skill is fragile.

## Scope

Any skill whose execution can be measured by a caller-defined success criterion. Inputs are sample workloads; outputs are per-trial scoring + an aggregate recommendation.

Out of scope: evaluating skills that have no defined success criterion. The caller MUST supply scoring rules or explicit criteria — skill-eval orchestrates, the caller defines what "good" means for the target.

## Definitions

- **Target skill** — the skill being evaluated.
- **Trial** — one execution of the target skill against one sample input on one model class.
- **Sample input** — a fixture file the target skill consumes during a trial.
- **Model class** — an abstraction over concrete model IDs (haiku-class / sonnet-class / opus-class). Concrete IDs come from the dispatch skill's model-class mapping.
- **Score** — caller-supplied verdict for a single trial: PASS, FAIL, or PARTIAL with optional numeric metric.
- **Run** — the full matrix: every sample input × every model class × N trials each.

## Parameters

- `target_skill` (required) — path to the target skill folder (e.g. `../compression/`).
- `sample_inputs` (required) — path to a folder of sample input files OR a JSON array of input objects.
- `trials` (required, integer) — number of trials per (input × model class) cell. Minimum 1, maximum 10.
- `model_classes` (optional, default `haiku-class,sonnet-class,opus-class`) — which model classes to test.
- `scoring` (required) — path to a scoring module OR an inline scoring directive the caller provides. Without scoring there is no eval.

## Procedure

1. Load target skill SKILL.md to confirm it is dispatchable.
2. Load sample inputs and scoring.
3. For each model class in scope:
   a. For each sample input:
      i. Run `trials` trials. Each trial dispatches the target skill at the named model class against the input.
      ii. Capture output, latency, error if any.
      iii. Apply scoring to obtain a per-trial score.
4. Aggregate per (model class × input): pass rate, mean latency, error rate.
5. Aggregate per model class: overall pass rate across inputs, mean latency, error rate.
6. Generate recommendation: best model class by pass rate, with cost/latency notes.
7. Write report via audit-reporting (target-kind = `eval`).

## Caller obligations

- Provide a scoring directive. No default scoring; eval refuses to run without one.
- Pre-create or pre-write the sample input set. Eval does not synthesize inputs.
- Set `trials` deliberately. More trials = more cost; fewer trials = less signal.

## Output

Eval report follows the audit-reporting skill at the appropriate relative path. Frontmatter records: target skill, sample input count, trials per cell, model classes tested, run timestamp.

Body:

- Recommendation block (one line: best model class + caveats).
- Per-model-class summary table (pass rate, mean latency, error rate).
- Per-input results table.
- Failure inventory (every FAIL with input ID, model class, trial number, error).

## Requirements

1. Caller MUST supply `target_skill`, `sample_inputs`, `trials`, and `scoring` — all are required unless noted optional.
2. `trials` MUST be an integer between 1 and 10 inclusive.
3. Each trial MUST dispatch the target skill at the named model class with one sample input.
4. Eval MUST apply caller-supplied scoring to each trial output to obtain a per-trial score.
5. Eval MUST aggregate results per (model class × input) and per model class.
6. Eval MUST write a report via audit-reporting (target-kind = `eval`).
7. Eval MUST NOT run without a scoring directive — no default scoring exists.
8. Eval MUST NOT modify the target skill during execution. Eval is read-only against the target.
9. Model classes MUST be resolved via the dispatch skill's class mapping — bare model IDs MUST NOT be hardcoded.
10. Eval MUST NOT re-audit unchanged files. See `../iteration-safety/SKILL.md`.

## Constraints

1. `trials` MUST NOT exceed 10.
2. Eval MUST NOT infer success from absence of error — scoring is required.
3. Eval MUST NOT write sample inputs into the target skill folder.
4. If a target skill's spec contradicts eval results, the empirical eval result takes precedence over the spec claim.
