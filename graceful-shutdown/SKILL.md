---
name: graceful-shutdown
description: >-
  graceful shutdown, shut down the fleet, close all sessions, initiate shutdown, fleet shutdown procedure, shutdown all agents
---

Don't re-audit unchanged files.
See `../iteration-safety/SKILL.md`.

Trigger Phrases: ordered shutdown, wrap up and close, session teardown, fleet teardown, closing all workers, stop all agents, end session, shutdown sequence

Pre-conditions:
Curator, Overseer, and at least one Worker session active.
If no Workers active at shutdown, Steps 3–5 are no-ops; Overseer skips to Step 6.
Curator has write access to `<workspace-root>/.agents/agents/curator/memory/`.

Key Terms:
Clean point — task state from which another agent can resume without loss: commit exists minimum; if all acceptance criteria met, sealed required; else commit suffices.
Sealed — task has `## Completion` added and committed in worktree. Overseer handles pipeline dir moves; Workers only write Completion section.
Bridge — Telegram MCP server process; auto-exits when last session closes.
Pending-messages guard — `shutdown` returns `{shutting_down: false, warning: "PENDING_MESSAGES"}` (not an error) when sess queues non-empty and `force` not set.
SID — numeric session ID assigned by Bridge.
DM — targeted msg via `send(type: "dm", target: <SID>)`. Use `target` param (not `target_sid`, invalid).
Session token — numeric token from `session/start`, stored in agent memory file. Wipe = overwrite stored value with empty string.
workspace-root — top-level dir containing `.agents/`; resolved at runtime as parent of `.agents/`.
Pipeline stages — `40-queued` (pending), `50-active` (claimed), `60-review` (ready), `70-done` (completed). Open tasks = any stage except `70-done`.

Full Procedure:

Step 1 — Pre-signal warning (Curator)

Curator MUST call `shutdown/warn` before signaling Workers.

```text
action(type: "shutdown/warn", token: <token>)
```

Advisory only — proceed regardless of response. Don't wait for acknowledgment.

Step 2 — Curator signals Overseer

Curator DMs Overseer to coordinate Worker shutdown. Curator MUSTN'T skip Overseer and DM Workers directly.

```text
send(type: "dm", target: <Overseer-SID>, message: "Initiating shutdown. Signal each Worker individually to reach clean point and call session/close. Include your own SID in each Worker DM so Workers know where to reply with CLOSED confirmation. DM me when all Workers have confirmed closed or the 300 s timeout elapses.", token: <token>)
```

Curator waits for Overseer's confirmation DM (Step 5 output) before Step 6.

Step 3 — Overseer signals each Worker individually

Separate DMs to each Worker — not broadcast. Each DM MUST include Overseer's own SID so Workers know where to send CLOSED reply.

```text
send(type: "dm", target: <Worker-SID>, message: "Shutting down. Reach clean point and close. Confirm via DM to SID `<Overseer-SID>`.", token: <token>)
```

Overseer MUST track count of Workers signaled. 300 s timeout begins after last signal DM `send` returns successfully.

Step 4 — Workers reach clean point and close

Each Worker executes independently:

a. Commit staged work (reach clean point)

If mid-task with staged changes, commit:

```text
WIP: [task-id] — shutdown mid-task
```

If all acceptance criteria met, add `## Completion` and commit (seal). Uncommitted worktree is NOT a clean point.

b. Wipe stored session token

Overwrite token value in agent memory file with empty string. Local file write only — MCP session stays active until `session/close` called.

c. DM Overseer "CLOSED"

```text
send(type: "dm", target: <Overseer-SID>, message: "CLOSED: session/close complete", token: <token>)
```

d. Call session/close

```text
action(type: "session/close", token: <token>)
```

Workers MUSTN'T pass `force: true`. After `session/close` succeeds, Worker exits dequeue loop and doesn't call `session/start` again.

Step 5 — Overseer tracks confirmations and closes

Confirmation = DM containing "CLOSED: session/close complete". Overseer MUST wait for confirmation from every Worker signaled.

If not received within 300 s (timer per Step 3), Overseer MUST notify Curator with timeout DM including: Worker SIDs that didn't confirm, elapsed time, "Proceeding with session/close despite missing confirmations."

Once all Workers confirmed (or 300 s elapsed):

```text
action(type: "session/close", token: <token>)
```

No `force: true` needed.

Step 6 — Curator writes handoff document

Curator MUST write `memory/handoff.md` at:

```text
<workspace-root>/.agents/agents/curator/memory/handoff.md
```

If file exists, overwrite — prior content superseded. MUST be written before Step 7.

Required structure:

```markdown
---
date: <ISO 8601 date, e.g. 2026-04-26>
operator: <operator name or email>
reason: <free text describing why shutdown was triggered>
---

## State

<Active branches, open task IDs, and open PRs>

## Carryovers

- <one bullet per open task in 40-queued, 50-active, or 60-review>
```

`operator` from Telegram display name or `memory/operator.md` if present; else `operator: unknown`.
`## Carryovers` MUST have one bullet per open task (40-queued, 50-active, 60-review). Empty valid only if no tasks in those stages.

Step 7 — Curator calls shutdown

```text
action(type: "shutdown", token: <token>)
```

`{shutting_down: true}` — proceed to Step 8.
`{shutting_down: false, warning: "PENDING_MESSAGES"}` — not an error; retry with `force: true`:

```text
action(type: "shutdown", token: <token>, force: true)
```

Then Step 8. Don't treat `{shutting_down: false}` as completed shutdown. `shutting_down` field is authoritative.

Step 8 — Curator closes session

```text
action(type: "session/close", token: <token>, force: true)
```

`force: true` required — Curator is last session; without it, `session/close` returns `LAST_SESSION` error.

Sequence Diagram:

```text
Curator         Overseer        Worker(s)       Bridge
  |                  |               |               |
  |--shutdown/warn-→ | (broadcast)   |               |
  |                  |               |               |
  |--DM: initiate--→ |               |               |
  |                  |--DM: close-→  |               |
  |                  |--DM: close-→  |               |
  |                  |               |--commit-----→ |
  |                  |               |--wipe token   |
  |                  |←-DM: CLOSED--|               |
  |                  |←--CLOSED DM---|               |
  |                  |               |--session/close→ (session removed)
  |                  |--DM: all done-→               |
  |←--confirmed------|               |               |
  |                  |--session/close-------------→  | (session removed)
  |--handoff.md      |               |               |
  |--shutdown--------------------------------→        | (bridge signals SHUTDOWN)
  |--session/close (force:true)-------→              | (last session → bridge exits)
```

Error Handling:
Worker can't reach clean point: commit WIP with note ("partial — [reason]"), wipe token, DM Overseer "CLOSED: session/close complete", call `session/close`. Don't block shutdown waiting for impossible clean state.
`shutdown` returns PENDING_MESSAGES: always retry with `force: true`. Expected when msgs queued; not an error.

Footguns:

F1 — Worker closes session before reaching clean point
Worker MUST commit (and seal if all acceptance criteria met) before `session/close`. Uncommitted worktree isn't a clean point.
ANTI-PATTERN: `session/close()` called immediately after in-flight event handler, without committing staged changes.

F2 — Curator skips shutdown/warn and calls shutdown immediately
`shutdown/warn` MUST precede `shutdown`. See Step 1.
ANTI-PATTERN: `action(type: "shutdown")` as first shutdown action without prior `shutdown/warn`.

F3 — Curator calls shutdown, gets PENDING_MESSAGES, ignores it
Always check `shutting_down` field, not just absence of errors. `{shutting_down: false, warning: "PENDING_MESSAGES"}` → call `shutdown` again with `force: true`.
ANTI-PATTERN: treating `{shutting_down: false}` as completed shutdown and proceeding to `session/close`.

F4 — Curator calls session/close without force: true as last session
Curator MUST use `force: true` on own `session/close`. Without it, last-session guard returns `LAST_SESSION` error and session isn't closed.
ANTI-PATTERN: `action(type: "session/close")` without `force: true` when only Curator remains.

F5 — Curator DMs Workers directly, bypassing Overseer
Curator signals Overseer only (Step 2). Overseer owns Worker fleet; sends individual DMs and tracks confirmations.
ANTI-PATTERN: Curator sends "please close" DMs to individual Worker SIDs instead of delegating to Overseer.

Related Skills:
`markdown-hygiene` — run after any edit to this file
`iteration-safety` — pointer block in this file cites this skill
