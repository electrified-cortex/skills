---
name: graceful-shutdown
description: >-
  graceful shutdown, shut down the fleet, close all sessions, initiate shutdown, fleet shutdown procedure, shutdown all agents
---

# Graceful Shutdown

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.

## Trigger Phrases

ordered shutdown, wrap up and close, session teardown, fleet teardown, closing all workers, stop all agents, end session, shutdown sequence

## Pre-conditions

- Curator session is active.
- Overseer session is active.
- At least one Worker session is active.
- If no Workers are active at shutdown time, Steps 3–5 are no-ops; Overseer proceeds directly from Step 2 to Step 6 coordination.
- Curator has write access to `<workspace-root>/.agents/agents/curator/memory/`.

## Key Terms

- **Clean point** — a task state from which another agent can resume without loss: at minimum a commit exists; if all acceptance criteria in the current task file are met, sealed is required; otherwise a commit suffices.
- **Sealed** — a task is sealed when a `## Completion` section has been added to its task file and committed in the worktree. Overseer handles downstream pipeline directory moves; Workers only write the Completion section.
- **Bridge** — the Telegram MCP server process; auto-exits when the last session closes.
- **Pending-messages guard** — the `shutdown` tool returns `{shutting_down: false, warning: "PENDING_MESSAGES"}` (not an error) when session queues are non-empty and `force` is not set.
- **SID** — Session ID: the numeric identifier assigned to an agent session by the Telegram MCP bridge.
- **DM** — Direct Message: a targeted message sent directly to a specific session's queue via `send(type: "dm", target: <SID>)` where `target` accepts a numeric session ID. Use the `target` parameter (not `target_sid`, which is invalid).
- **Session token** — the numeric token issued by `session/start` and stored in the agent's memory file. **Wipe** — overwrite the stored token value with an empty string.
- **workspace-root** — the top-level directory containing the `.agents/` folder; resolved at runtime as the parent of the `.agents/` directory visible to the agent.
- **Pipeline stages** — the ordered directory stages used by the task engine: `40-queued` (pending), `50-active` (claimed, in progress), `60-review` (ready for review), `70-done` (completed). Open tasks are those in any stage other than `70-done`.

## Full Procedure

### Step 1 — Pre-signal warning (Curator)

Curator MUST call `shutdown/warn` before signaling Workers.

Call:

```text
action(type: "shutdown/warn", token: <token>)
```

Proceed regardless of response — this call is advisory only. Do not wait for acknowledgment before moving to Step 2.

### Step 2 — Curator signals Overseer

Curator sends a DM to Overseer instructing it to coordinate Worker shutdown. Curator MUST NOT skip Overseer and DM Workers directly.

Example DM text (adapt wording as needed):
> "Initiating shutdown. Signal each Worker individually to reach clean point and call session/close. Include your own SID in each Worker DM so Workers know where to reply with CLOSED confirmation. DM me when all Workers have confirmed closed or the 300 s timeout elapses."

Call:

```text
send(type: "dm", target: <Overseer-SID>, message: "...", token: <token>)
```

Curator then waits for Overseer's confirmation DM (Step 5 output) before proceeding to Step 6.

### Step 3 — Overseer signals each Worker individually

Overseer sends separate DMs to each Worker — not a broadcast. Each DM MUST include Overseer's own SID in the message body so Workers know where to send the CLOSED reply.

Example DM text to each Worker:
> "Shutting down. Reach clean point and close. Confirm via DM to SID `<Overseer-SID>`."

Call for each Worker:

```text
send(type: "dm", target: <Worker-SID>, message: "Shutting down. Reach clean point and close. Confirm via DM to SID `<Overseer-SID>`.", token: <token>)
```

Overseer MUST track the count of Workers signaled. The 300 s timeout begins after Overseer's `send` call for the last signal DM returns successfully.

### Step 4 — Workers reach clean point and close

Each Worker executes the following sequence independently:

#### a. Commit staged work (reach clean point)

If mid-task with staged changes, commit with a descriptive message, e.g.:

```text
WIP: [task-id] — shutdown mid-task
```

If all acceptance criteria are met, add a `## Completion` section to the task file and commit (seal the task).

An uncommitted worktree is NOT a clean point.

#### b. Wipe stored session token (local file operation only)

Overwrite the token value in the agent's memory file with an empty string. This is a local file write only — the MCP session stays active until `session/close` is called.

#### c. DM Overseer "CLOSED"

Send the confirmation DM to Overseer using the SID Overseer included in the Step 3 signal:

```text
send(type: "dm", target: <Overseer-SID>, message: "CLOSED: session/close complete", token: <token>)
```

#### d. Call session/close

```text
action(type: "session/close", token: <token>)
```

Workers MUST NOT pass `force: true`. After `session/close` succeeds, Worker exits the dequeue loop and does not call `session/start` again.

### Step 5 — Overseer tracks confirmations and closes

Each Worker's confirmation is a DM containing "CLOSED: session/close complete". Overseer MUST wait until it has received a confirmation DM from every Worker it signaled.

If confirmation is not received within 300 s (timer starts per Step 3), Overseer MUST notify Curator with a timeout DM that includes:

- List of Worker SIDs that did not confirm
- The elapsed time
- The message: "Proceeding with session/close despite missing confirmations."

Example timeout DM to Curator:
> "Timeout reached (300 s elapsed). Workers SID [X, Y] did not confirm. Proceeding with session/close despite missing confirmations."

Once all Workers have confirmed (or the 300 s timeout elapses), Overseer calls:

```text
action(type: "session/close", token: <token>)
```

No `force: true` needed.

### Step 6 — Curator writes handoff document

Curator MUST write `memory/handoff.md`, resolved as:

```text
<workspace-root>/.agents/agents/curator/memory/handoff.md
```

If the file already exists, Curator MUST overwrite it — prior content is superseded by the current shutdown record.

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

Notes:

- `operator` is sourced from the operator's Telegram display name or from `memory/operator.md` if present. If neither source is available, write `operator: unknown`.
- The `## Carryovers` section MUST contain at least one bullet per open task (tasks in `40-queued`, `50-active`, or `60-review`). Empty Carryovers is valid only if no tasks exist in those stages.
- This file MUST be written before calling `shutdown` in Step 7.

### Step 7 — Curator calls shutdown

Curator calls:

```text
action(type: "shutdown", token: <token>)
```

Check the response:

- `{shutting_down: true}` — proceed to Step 8.
- `{shutting_down: false, warning: "PENDING_MESSAGES"}` — this is not an error; call `shutdown` again with `force: true`:

  ```text
  action(type: "shutdown", token: <token>, force: true)
  ```

  Then proceed to Step 8.

Do NOT treat `{shutting_down: false}` as a completed shutdown. The `shutting_down` field is authoritative.

### Step 8 — Curator closes session

Curator calls:

```text
action(type: "session/close", token: <token>, force: true)
```

`force: true` is required.

## Sequence Diagram

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

## Error Handling

- **Worker can't reach clean point:** commit WIP with a note ("partial — [reason]") in the commit message, wipe token, DM Overseer "CLOSED: session/close complete", then call `session/close`. Do not block shutdown waiting for an impossible clean state.
- **`shutdown` returns PENDING_MESSAGES:** always retry with `force: true`. This is expected when messages are queued; it is not an error condition.

## Footguns

### F1 — Worker closes session before reaching clean point

Mitigation: Worker MUST commit (and seal if all acceptance criteria are met) before calling `session/close`. An uncommitted worktree is not a clean point.

ANTI-PATTERN: `session/close()` called immediately after an in-flight event handler completes, without first committing staged changes.

---

### F2 — Curator skips shutdown/warn and calls shutdown immediately

Mitigation: `shutdown/warn` MUST precede `shutdown`. See Step 1.

ANTI-PATTERN: calling `action(type: "shutdown")` as the first shutdown action without first calling `shutdown/warn`.

---

### F3 — Curator calls shutdown, gets PENDING_MESSAGES, ignores it

Mitigation: always check the `shutting_down` field, not just for the absence of errors. If the response is `{shutting_down: false, warning: "PENDING_MESSAGES"}`, call `shutdown` again with `force: true`.

ANTI-PATTERN: treating `{shutting_down: false}` as a completed shutdown and proceeding to `session/close`.

---

### F4 — Curator calls session/close without force: true as last session

Mitigation: Curator MUST use `force: true` on its own `session/close` call. Without it, the last-session guard returns a `LAST_SESSION` error and the session is not closed.

ANTI-PATTERN: `action(type: "session/close")` without `force: true` when only Curator remains.

---

### F5 — Curator DMs Workers directly, bypassing Overseer

Mitigation: Curator signals Overseer only (Step 2). Overseer owns the Worker fleet and is responsible for sending individual DMs to Workers and tracking their confirmations.

ANTI-PATTERN: Curator sends "please close" DMs to individual Worker SIDs instead of delegating to Overseer.

## Related Skills

- `markdown-hygiene` — run after any edit to this file
- `iteration-safety` — pointer block in this file cites this skill
