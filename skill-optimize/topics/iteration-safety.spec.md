# Iteration Safety

## Purpose

How to take advantage of iterative loops (convergence, self-critique,
multi-pass) without runaway token spend or infinite recursion.

## Parameters

- <skill-path> — path to the skill directory being analyzed (inherited from optimizer invocation)
- <skill-source-files> — all source files from the skill directory (inherited from Step 1)

## Output

Finding in standard format (### CATEGORY — HIGH | MEDIUM | LOW with **Reasoning:** and **Recommendation:**), or CLEAN if no issues apply.

## The core tension

Loops improve output quality — each pass catches what the previous missed.
But each pass also costs tokens, latency, and model calls. Without
constraints, a loop runs forever (or until context exhaustion), which is
worse than not looping at all. The goal: loop as many times as the problem
justifies, no more.

## The three loop failure modes

**1. Infinite loop** — The loop has no exit condition. Self-critique finds
something, the model "fixes" it, re-critiques, finds the fix introduced
a new issue, iterates. With no hard stop, this continues until context
fills.

**2. False convergence** — The model declares convergence because it has
"found nothing new" but hasn't actually improved. This happens when the
loop does not track state — each pass sees the same output, produces the
same assessment, and reports "done" without actually changing anything.

**3. Oscillation** — The model alternates between two states: pass N says
"add X," pass N+1 says "remove X," pass N+2 says "add X." This is a
degenerate loop that never converges and wastes infinite tokens.

## Designing safe loops

**Hard iteration cap** — Always specify a maximum number of iterations.
"Repeat up to N times OR until no new findings — whichever comes first."
N should be derived from the problem: for multi-pass optimization, typically
3-5 iterations captures most convergence paths — beyond that, gains are
marginal and costs compound. For a judgment-heavy skill with low error
tolerance, N = 5 may be appropriate; for a simple structural check, N = 2
is usually enough. Arbitrary N (a round number with no rationale) is a
finding.

**State tracking** — The loop must track what was found and changed in
previous passes. If the current pass finds the same issues as the previous
pass, that is a signal: either the fix didn't work (try a different fix)
or the loop has converged on a floor and should stop. Without state
tracking, the loop cannot distinguish convergence from oscillation.

**Net-new finding test** — Each pass should count findings that were NOT
present in the previous pass. If net-new findings = 0, the loop has
converged regardless of total finding count. This is a better stopping
criterion than "no findings at all" — some findings may be known and
accepted, and their persistence should not prevent convergence.

**Explicit stop criteria in the instruction** — The model should be told
explicitly when to stop, not left to infer it. "Stop when a full pass
produces zero net-new findings, or after N passes." Implicit stop
conditions invite the model to interpret "enough" as "forever."

## Oscillation detection

If finding A appears in pass 1, disappears in pass 2 (because the model
"fixed" it), and reappears in pass 3, the loop is oscillating. Detection:
track findings by identity (category + location + type) and compare pass N
to pass N-2. If the same finding set appears, stop — the loop has entered
a cycle.

Signal for oscillation risk in a skill: the skill contains two
recommendations that each partially satisfy a constraint in a way that
violates the other. REUSE and LESS IS MORE can do this: REUSE says
"extract this block," LESS IS MORE says "the extracted block is overhead."
If a loop alternates between these two, the root issue is a third decision
that needs to be made (keep the block? remove it entirely?) that the loop
is unable to make because the skill doesn't specify the deciding criterion.

## Practical loop structures for skills

**Token budget awareness** — For skills with known token ceilings, the
loop should track cumulative spend and exit before the budget is exhausted.
Leave a buffer: if a full pass costs ~X tokens, stop when remaining budget
is less than X. Partial passes at the end of a budget are worse than clean
early exits — they produce incomplete findings without convergence signal.

**Fixed-N iteration:**
```
For i in 1..N:
  run analysis pass
  if no net-new findings: break
```
Safe. Cheap. Predictable. Good for most optimization loops.

**Escalating-tier convergence:**
```
For tier in [haiku, sonnet, opus]:
  run analysis at tier
  if net-new findings: continue to next tier
  else: break (converged)
```
Safe because the tier list is finite. Opus is the ceiling. Good for
skill-optimize's R12 multi-pass pattern.

**Adversarial loop:**
```
optimizer: produce findings
adversary: challenge findings (for N rounds max)
optimizer: respond to challenges
if adversary finds nothing new: done
```
Safe with hard round cap. The adversary is also stateless and doesn't
loop internally — each round is a single pass.

## What not to loop

**Don't loop deterministic steps.** A hash computation is the same every
time. Looping it produces the same result at N times the cost. Loop only
when there is a genuine quality gradient to exploit — where the second
pass can produce a better result than the first.

**Don't loop without a way to measure improvement.** If you can't tell
whether pass N is better than pass N-1, you can't detect convergence. The
loop just runs N times. This is not iteration — it is N independent runs
with no coupling.

**Don't recurse self-critique into self-critique.** If the skill includes
a self-critique step, that step must not itself invoke another critique.
Single-depth review only. Recurse if you must, but never more than one
level deep, and always with an explicit stop.

## Iteration budget in the findings record

When producing findings on a skill that contains a loop, assess the loop
against this topic. Flag findings at the appropriate severity:

- **HIGH**: loop with no iteration cap or no exit condition
- **MEDIUM**: loop with a cap but no state tracking (can't detect oscillation)
- **LOW**: loop that is correctly bounded but could benefit from escalating-tier
  pattern or net-new detection
