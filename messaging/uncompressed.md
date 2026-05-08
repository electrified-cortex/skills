---
name: messaging
description: File-based agent-to-agent messaging via shared inbox. Triggers - registering an inbox, posting a message to another agent, reading inbox messages, monitoring for incoming messages, draining an inbox, checking inbox status, setting up inter-agent communication, leaving a message for another agent.
---

# Messaging

Agents communicate by posting message files into one another's inbox. Four tools handle
all mechanics — the agent supplies intent only.

- **`init`** — register your inbox on startup; claims your name atomically
- **`post`** — post a message to another agent's inbox
- **`drain`** — collect all pending messages from your own inbox
- **`status`** — Monitor callback; counts unclaimed messages and reports the pending count

The inbox is a directory in the shared workspace. Any agent with filesystem access can
post to any inbox. There is no security model; isolation is conventional.

## Concepts

**Inbox** — `.inbox/<agent-name>/` relative to the workspace root. Each agent owns one.

**Signal file** — `.inbox/<agent-name>/.signal`. The `post` tool writes this file after
every successful message write. Agents watch this file for changes to know when new
messages have arrived.

**Archive** — `.inbox/<agent-name>/archive/`. Drained messages are moved here after
being read. Archive has no protocol role; it may be purged freely.

**Claim** — an exclusive reservation the `drain` tool takes on a message file before
reading it. Prevents a concurrent drain from reading the same message.

**Name claim** — the atomic directory creation `init` performs. Only one caller can
create `.inbox/<name>/`; all others get "already registered." Establishes the agent's
identity in the shared inbox space.

**Status** — a lightweight, read-only probe. Wire it directly to your Monitor as the
signal-change callback. When the signal fires, the Monitor calls `status`, which counts
unclaimed messages in the inbox and outputs the pending count. Does not claim or modify
any files.

**Message file** — a `.json` file in the inbox. Filename format:
`YYYYMMDDTHHmmssZ-<nonce>.json`. Example: `20260508T143022Z-a3f91b.json`.

Every message file is a JSON object with fields `from`, `sent`, `body`, and optional `subject`:

```json
{
  "from": "curator",
  "sent": "2026-05-08T14:30:22Z",
  "subject": "Task complete \u2014 review requested",
  "body": "The batch run finished. Results are in .work/batch-42/. Ready for your review."
}
```

## Registering Your Inbox

Call `init` once on first startup. It creates your inbox, archive, and signal file, and
claims your name atomically. If the name is taken, `init` exits non-zero.

```text
init --name <your-name>
```

On restart, use `--force` to reclaim your inbox without failing:

```text
init --name <your-name> --force
```

`--force` never modifies existing messages.

## Posting a Message

Invoke the `post` tool. The tool generates the filename, timestamp, nonce, and writes
atomically. Do not write inbox files directly.

```text
post --from <your-name> --to <recipient> --body "<body>" [--subject "<subject>"]
```

`--from`, `--to`, and `--body` are required. `--subject` is optional. `post` exits zero on success, non-zero on failure with an
error on stderr. Check the exit code.

**Example:**

```text
post --from curator --to overseer --body "Results in .work/batch-42/." --subject "Batch complete"
```

Do not post to your own inbox.

## Receiving Messages — Monitoring

Watch the signal file for changes. When the signal changes, drain your inbox.

Signal file path: `.inbox/<own-name>/.signal`

### Option A — Wire status to your Monitor

The simplest integration. Configure your Monitor to call `status` when the signal file
changes. `status` counts unclaimed messages and outputs a single line.

```text
status --inbox <your-name>
# outputs: [2026-05-08T14:30:22Z]: 5 messages waiting
```

Read the count. Then drain if messages are waiting.

### Option B — Implement the loop yourself

```text
on startup:
    drain and process until empty

watch .inbox/<own-name>/.signal for changes:
    on change:
        loop:
            messages = drain --inbox <own-name>
            if messages is empty: break
            for each message: process it
        resume watching
```

The drain-to-quiescence loop (inner `loop`) is required. Draining to empty ensures
nothing is stranded.

### On Startup

1. Call `init --name <own-name>` (or `--force` on restart).
2. Drain your inbox once — messages posted while you were offline are waiting.
3. Enter the monitoring loop.

## Draining an Inbox

```text
drain --inbox <your-name>
```

`drain` returns a JSON array of all pending messages in ascending timestamp order
(oldest first). For each message it: claims the file, reads the content, moves it to
`archive/`. On claim failure (another drain got there first) it skips silently.

`drain` **always** does a full sweep — one invocation collects all pending messages, not
just one. Drain exits zero even if some files were skipped. An empty inbox returns `[]`.

Do not drain another agent's inbox. Drain archives files even if they cannot be parsed;
the failure is reported on stderr.

## Processing Messages

For each message object in the JSON array returned by drain:

1. Read fields: `from`, `sent`, `body`. Check for optional `subject`.
2. Process the body.
3. If a field is missing or the body is unhandled, log the failure and continue.

A single bad message **must not** halt inbox processing.

## Message Ordering

Messages are processed oldest-first within an inbox. This is guaranteed by the filename
sort order — filenames begin with a UTC timestamp. Per-sender ordering is preserved.
Messages from different senders interleave by timestamp.

## Constraints

- No delivery guarantee. If the recipient is offline, messages accumulate unread.
- No security model. Any process with filesystem access can read or post to any inbox.
- Single reader per inbox. Multiple concurrent drains are not a supported configuration.
- No message expiry or TTL in v1.

## Don'ts

- Do NOT skip `init` on startup — register before draining or watching.
- Do NOT call `init` without `--force` on restart.
- Do NOT write inbox files directly — always use `post`.
- Do NOT drain another agent's inbox.
- Do NOT delete message files — archive is the only terminal state.
- Do NOT post to your own inbox.
- Do NOT halt on a single failing message — log and continue.
- Do NOT assume the inbox is private.

## Related

`markdown-hygiene` — sealing step; run on uncompressed sources after audit PASS
`skill-auditing` — audits this skill
`compression` — compresses `uncompressed.md` to `SKILL.md`
