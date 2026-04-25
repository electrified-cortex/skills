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

## Inputs

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

## Iteration Safety

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.

## Don'ts

- Do not run with `trials` greater than 10 — cost grows linearly and the marginal signal flattens.
- Do not run without scoring — there is no fallback.
- Do not infer success from absence of error. Scoring is required.
- Do not write inputs into the target skill folder. Sample inputs live elsewhere.
- Do not modify the target skill during eval. Eval is read-only against the target.
- Do not bake bare model IDs here. Resolve via dispatch skill's class mapping.

## Precedence

If a target skill's spec contradicts what eval observes (e.g. spec claims sonnet-class is required but eval shows haiku-class passes), the eval result is the empirical signal and the skill author should revise the spec — not the other way around.
