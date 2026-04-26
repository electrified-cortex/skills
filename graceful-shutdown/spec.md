# Graceful Shutdown

## Purpose

Codify the operator-stated graceful shutdown procedure so Curator/Overseer have a single, auditable reference. Replaces ad-hoc verbal coordination.

## Scope

Applies to all agent sessions managed by the Telegram MCP bridge. Covers the ordered shutdown of Workers → Overseer → Curator and bridge teardown.

## Definitions

- *Clean point* — a task state from which another agent can resume without loss: at minimum a commit exists; if all acceptance criteria in the current task file are met, sealed is required; otherwise a commit suffices.
- *Sealed* — a task is sealed when a `## Completion` section has been added to its task file and committed in the worktree. Overseer handles downstream pipeline directory moves; Workers only write the Completion section.
- *Bridge* — the Telegram MCP server process; auto-exits when the last session closes.
- *Pending-messages guard* — the `shutdown` tool returns `{shutting_down: false, warning: "PENDING_MESSAGES"}` (not an error) when session queues are non-empty and `force` is not set.
- *SID* — Session ID: the numeric identifier assigned to an agent session by the Telegram MCP bridge.
- *DM* — Direct Message: a targeted message sent directly to a specific session's queue via `send(type: "dm", target: <SID>)` where `target` accepts a numeric session ID. Use the `target` parameter (not `target_sid`, which is invalid).
- *Session token* — the numeric token issued by `session/start` and stored in the agent's memory file. *Wipe* — overwrite the stored token value with an empty string so the agent loop does not attempt session/start on next startup.
- *workspace-root* — the top-level directory containing the `.agents/` folder; resolved at runtime as the parent of the `.agents/` directory visible to the agent.
- *Pipeline stages* — the ordered directory stages used by the task engine: `40-queued` (pending), `50-active` (claimed, in progress), `60-review` (ready for review), `70-done` (completed). Open tasks are those in any stage other than `70-done`.

## Roles

- **Curator** — initiates shutdown, owns handoff and bridge teardown.
- **Overseer** — coordinates Worker close confirmation, closes before Curator.
- **Worker** — reaches clean point, wipes token, closes session.

## Pre-conditions

- Curator session is active.
- Overseer session is active.
- At least one Worker session is active.
- If no Workers are active at shutdown time, Steps 3–5 are no-ops; Overseer proceeds directly from Step 2 to Step 6 coordination.
- Curator has write access to `<workspace-root>/.agents/agents/curator/memory/`.

## Procedure (Normative)

### Step 1 — Pre-signal warning

Curator MUST call `action(type: "shutdown/warn")` BEFORE signaling Workers. This delivers a pre-shutdown advisory to all active sessions so agents can complete in-flight work.

### Step 2 — Curator DMs Overseer to initiate shutdown

Curator MUST DM Overseer instructing it to tell Workers to reach a clean point and call `session/close`. Curator MUST NOT skip Overseer and DM Workers directly.

### Step 3 — Overseer signals each Worker individually

Overseer signals Workers individually via separate DMs (not broadcast). Overseer's signal DM to each Worker MUST include Overseer's own SID **in the message body** (e.g., 'Shutting down. Reach clean point and close. Confirm via DM to SID `<N>`.'). Workers use this SID to address the CLOSED confirmation DM in Step 4. Overseer MUST track the count of Workers signaled. The 300 s timeout begins after Overseer's `send` call for the last signal DM returns successfully.

### Step 4 — Workers reach clean point, DM Overseer confirmation, and close

Each Worker MUST reach a clean point (commit staged changes; seal if all acceptance criteria met, otherwise commit suffices), then wipe its stored session token (local file operation only — the MCP session remains active until `session/close` is called), then send a DM to Overseer saying "CLOSED: session/close complete", then call `action(type: "session/close")`. Workers MUST NOT call `session/close` with `force: true`. The ordered shutdown procedure guarantees at least Overseer and Curator remain open when Workers close. After `session/close` succeeds, Worker exits loop.

### Step 5 — Overseer tracks confirmations and closes its session

Each Worker's confirmation is a DM containing "CLOSED: session/close complete". Overseer MUST wait until it has received a confirmation DM from every Worker it signaled. If confirmation is not received within 300 s (see Step 3 for timer start condition), Overseer MUST notify Curator and proceed with `action(type: "session/close")` anyway. The timeout notification to Curator MUST include: list of Worker SIDs that did not confirm, the elapsed time, and the message "Proceeding with session/close despite missing confirmations." Once all Workers have confirmed (or the 300 s timeout elapses), Overseer calls `action(type: "session/close")`. No `force` needed (Curator still open).

### Step 6 — Curator writes handoff document

Curator MUST write `memory/handoff.md` — resolved as `<workspace-root>/.agents/agents/curator/memory/handoff.md` — with the following structure. If the file already exists, Curator MUST overwrite it; prior content is superseded by the current shutdown record.

- **YAML frontmatter** (delimited by `---`): MUST include:
  - `date`: ISO 8601 format (e.g., `2026-04-26`)
  - `operator`: human operator's name or email — sourced from the operator's Telegram display name or from `memory/operator.md` if present. If neither source is available, write `operator: unknown`.
  - `reason`: free text describing why the shutdown was triggered
- **`## State` section:** MUST include active branches, open task IDs, and open PRs.
- **`## Carryovers` section:** MUST include at least one bullet per open task. Empty is valid only if no tasks exist in pipeline stages `40-queued`, `50-active`, or `60-review`.

### Step 7 — Curator calls shutdown

Curator calls `action(type: "shutdown")`. If `shutdown` returns `{shutting_down: false, warning: "PENDING_MESSAGES"}`, Curator MUST call `shutdown` again with `force: true` to abandon pending messages and proceed.

### Step 8 — Curator calls session/close with force: true

Curator calls `action(type: "session/close", force: true)`. `force: true` is required because Curator is the last session standing (the last-session guard requires it). Bridge auto-exits once all sessions are closed.

## Requirements

Summary of binding normative requirements (MUST/SHALL). Full procedure in [Procedure (Normative)](#procedure-normative) above.

- Curator MUST call `shutdown/warn` as the first shutdown action.
- Curator MUST signal Overseer to initiate Worker shutdown — MUST NOT signal Workers directly.
- Overseer MUST signal each Worker via separate individual DMs (not broadcast) and MUST include Overseer's own SID in the message body.
- Overseer MUST track the count of Workers signaled and await one "CLOSED: session/close complete" DM per Worker.
- Workers MUST reach a clean point (commit; seal if all acceptance criteria met) before closing.
- Workers MUST wipe their stored session token (local file operation), DM Overseer "CLOSED: session/close complete", then call `action(type: "session/close")` — in that order.
- Curator MUST write `handoff.md` before calling `shutdown`.
- Curator MUST call `action(type: "shutdown")` before `session/close`. If it returns `{shutting_down: false, warning: "PENDING_MESSAGES"}`, retry with `force: true`.
- Curator MUST call `action(type: "session/close", force: true)` as the final action.

## Constraints

Cross-cutting prohibitions. These apply throughout the procedure regardless of context.

- Workers MUST NOT call `session/close` with `force: true`. The ordered shutdown procedure guarantees at least Overseer and Curator remain open when Workers close.
- Curator MUST NOT bypass Overseer when signaling Workers (feedback: `feedback_dont_supersede_overseer`).
- Agents MUST NOT call `session/start` after closing their session during shutdown.
- `shutdown` MUST NOT be called before `handoff.md` is written and all Workers and Overseer are confirmed closed.

## Footguns

_This section is non-normative. Mitigations reference and reinforce the normative procedure steps above._

**F1** Worker closes session before reaching clean point
Mitigation: Worker MUST commit (and seal if all acceptance criteria met) before closing. An uncommitted worktree is not a clean point.
ANTI-PATTERN: `void handlePostEvent(...); session/close()` — closing mid-task without committing.

**F2** Curator skips shutdown/warn and calls shutdown immediately
Mitigation: `shutdown/warn` MUST precede `shutdown`. Workers blocked in dequeue need time to wrap up; `shutdown` delivers a SHUTDOWN signal to all sessions and triggers a grace period for them to self-close before force-closing lingering ones.
ANTI-PATTERN: calling `action(type: "shutdown")` as the first shutdown action.

**F3** Curator calls shutdown, gets PENDING_MESSAGES, ignores it
Mitigation: check the `shutting_down` field, not just for errors. If `shutting_down: false` with `warning: "PENDING_MESSAGES"`, call `shutdown` again with `force: true`.
ANTI-PATTERN: treating `{shutting_down: false}` as a completed shutdown.

**F4** Curator calls session/close without force: true as last session
Mitigation: Curator MUST use `force: true` on its own `session/close` call. Without it, the last-session guard returns `LAST_SESSION` error.
ANTI-PATTERN: `action(type: "session/close")` without `force: true` when only Curator remains.

**F5** Curator DMs Workers directly, bypassing Overseer
Mitigation: Curator signals Overseer only. Overseer owns the Worker fleet.
ANTI-PATTERN: Curator sends "please close" DMs to individual Worker SIDs.

## Acceptance Gate

Skill is complete when:
1. This spec has been reviewed by spec-auditing and all findings addressed.
2. skill-auditing returns PASS on SKILL.md against this spec.
   _Note: Criterion 2 is satisfied once SKILL.md is authored and passes skill-auditing (see `.agents/skills/electrified-cortex/skill-auditing/SKILL.md`)._
3. One end-to-end shutdown cycle runs successfully with Curator following SKILL.md, no operator intervention after trigger. Successfully means: all sessions closed in correct order, `handoff.md` written without error, no orphaned sessions remain in the bridge, and the bridge process exits cleanly.
