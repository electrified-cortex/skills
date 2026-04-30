# Autonomy Level

Assess whether the skill is correctly calibrated on the autonomy spectrum
— how much authority it has to act without human confirmation, when it
should pause and ask, and whether that calibration is documented and
appropriate for the skill's risk profile.

## The autonomy spectrum

**Fully autonomous** — The skill executes from start to finish without
any human interaction. Decisions are made, files are written, changes are
committed. The operator sees the result, not the process.

**Semi-autonomous** — The skill executes autonomously up to decision
points, then pauses to surface options and await confirmation. Proceeds
only when directed.

**Interactive** — The skill operates as a dialog: asks questions, takes
answers, proceeds incrementally. The human is in the loop at every
meaningful step.

No point on the spectrum is inherently correct. The right calibration
depends on: the risk of the action being taken, the reversibility of the
action, the confidence in the skill's judgment, and the expected operating
context (batch automation vs. attended interactive session).

## Risk and reversibility as calibration inputs

**Low risk + reversible** — read-only analysis, generating a report,
computing a hash. Fully autonomous is correct. No confirmation needed.

**Low risk + irreversible but easily undone** — writing a findings file,
creating a new branch. Fully autonomous is fine. Git provides recovery.

**Higher risk + less reversible** — modifying existing skill files,
moving or renaming tracked files, publishing artifacts. Pause and confirm
is appropriate, especially on the first invocation in a new context.

**High risk + irreversible** — deleting files, pushing to shared branches,
external API calls with side effects. Interactive or confirmation-required.
The model should not autonomously execute high-risk irreversible actions
without explicit documentation that this is intended.

## The confirmation anti-pattern

Confirming things that don't need confirmation is as much a failure as
not confirming things that do. A skill that asks "are you sure you want
to proceed?" before every step, regardless of risk, is confirmation
theater — it trains operators to click through without reading. This
wastes time and degrades the value of genuine confirmation requests.

Confirmation should be reserved for actions that genuinely warrant it.
The test: if the operator always approves this confirmation, it should
not exist. If the operator sometimes rejects it, it should.

## Documenting autonomy level

The skill should explicitly state its autonomy model:

- What it will do autonomously
- What it will pause and confirm before doing
- Under what conditions it will stop and request operator input
- Whether it is designed for attended or unattended execution

Without this, callers cannot safely integrate the skill into a pipeline
(a fully autonomous skill in a batch pipeline will not pause to confirm
— callers need to know this before including it).

## Autonomy in the SKILL.md description

The skill's description field should hint at its autonomy level. "Analyzes
and reports" signals read-only autonomy. "Modifies and commits" signals
that the skill takes permanent action. A caller reading the description
should be able to predict the autonomy behavior without reading the full
instructions.

## Autonomy drift

Skills can gain autonomy over time through incremental changes —
individual updates each seem small, but cumulatively the skill now
takes actions that the original authors would have required confirmation
for. Autonomy drift is a finding when the skill's documented autonomy
level doesn't match its actual current behavior.

## Autonomous skills and the fail-safe principle

A fully autonomous skill that can fail should be designed to fail safely.
"Fail safe" means: on error, do nothing rather than doing the wrong thing.
An autonomous skill that partially executes an action on failure (writes
half a file, commits half a change) is worse than one that errors early.

The fail-safe pattern: verify all preconditions before beginning any
irreversible action; on any failure during execution, clean up and surface
an error rather than leaving partial state.

## Finding criteria

Produce a finding when:

- **HIGH**: The skill takes irreversible high-risk actions autonomously
  without documenting that this is intended behavior, or without a
  fail-safe cleanup path.
- **HIGH**: The skill's autonomy level is not documented — callers cannot
  determine whether it will pause for confirmation or proceed unattended.
- **MEDIUM**: The skill confirms low-risk reversible actions (confirmation
  theater) — wastes operator time and degrades the value of real confirmations.
- **MEDIUM**: The skill's documented autonomy level doesn't match its
  actual behavior (autonomy drift).
- **LOW**: The SKILL.md description doesn't hint at the autonomy model —
  callers must read the full instructions to understand the action footprint.

Do not produce a finding when the skill's autonomy level is appropriate
for its risk profile, clearly documented, and consistent with its
description. A fully autonomous read-only skill needs no confirmation
and no caveat — that is the correct design.
