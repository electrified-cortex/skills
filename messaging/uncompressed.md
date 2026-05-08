---
name: messaging
description: File-based agent-to-agent messaging via shared inbox. Use when posting a message to another agent, reading inbox messages, monitoring for incoming messages, draining an inbox, setting up inter-agent communication, or leaving a message for another agent.
---

# Messaging

Agents communicate by posting message files into one another's inbox. Three tools handle
all mechanics — the agent supplies intent only.

- **`post`** — post a message to another agent's inbox
- **`drain`** — collect all pending messages from your own inbox
- **`notify`** — optional Monitor callback; runs drain-to-quiescence and outputs results

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

**Notify** — an optional convenience wrapper around the drain-to-quiescence loop. Wire
it directly to your Monitor as the signal-change callback. When the signal fires, the
Monitor calls `notify`, which drains to empty and outputs all messages. Agents that use
`notify` do not implement the loop themselves.

**Message file** — a `.md` file in the inbox. Filename format:
`YYYYMMDDTHHmmssZ-<nonce>.md`. Example: `20260508T143022Z-a3f91b.md`.

Every message file begins with a YAML frontmatter block followed by a Markdown body:

```yaml
---
from: curator
to: overseer
sent: 2026-05-08T14:30:22Z
subject: Task complete — review requested
---

The batch run finished. Results are in `.work/batch-42/`. Ready for your review.
```


## Posting a Message

Invoke the `post` tool. The tool generates the filename, timestamp, nonce, and writes
atomically. Do not write inbox files directly.

```text
post --from <your-name> --to <recipient> --subject "<subject>" --body "<body>"
```

All four flags are required. `post` exits zero on success, non-zero on failure with an
error on stderr. Check the exit code.

**Example:**

```text
post --from curator --to overseer --subject "Batch complete" --body "Results in .work/batch-42/."
```

Do not post to your own inbox.

## Receiving Messages — Monitoring

Watch the signal file for changes. When the signal changes, drain your inbox.

Signal file path: `.inbox/<own-name>/.signal`

### Option A — Wire notify to your Monitor

The simplest integration. Configure your Monitor to call `notify` when the signal file
changes. `notify` runs the drain-to-quiescence loop and outputs all messages to stdout.

```text
notify --inbox <your-name>
```

Capture stdout and process each message. The Monitor handles the rest.

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

The drain-to-quiescence loop (inner `loop`) is required. A message may arrive while you
are processing a previous batch. The signal will not fire again for that message. Draining
to empty ensures nothing is stranded.

### On Startup

Before entering the monitoring loop, drain your inbox once — or call `notify` once if
using Option A. Messages posted while you were offline are waiting.

## Draining an Inbox

```text
drain --inbox <your-name>
```

`drain` returns all pending messages in ascending timestamp order (oldest first). For each
message it: claims the file, reads the content, moves it to `archive/`, outputs the
content. On claim failure (another drain got there first) it skips silently.

`drain` **always** does a full sweep — one invocation collects all pending messages, not
just one. Drain exits zero even if some files were skipped.

Do not drain another agent's inbox. Drain returns messages even if their frontmatter is
malformed; the failure is reported on stderr and the file is archived regardless.

## Processing Messages

For each message returned by drain:

1. Parse frontmatter — verify `from`, `to`, `sent`, `subject` are present.
2. Process the body.
3. If the frontmatter is invalid or the body unhandled, log the failure and continue.

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
