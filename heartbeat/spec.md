# Skill: heartbeat

## Purpose

The heartbeat skill is a workspace primitive that lets pods — Curator, Overseer,
Foreman, Worker, and any future pod role — prove they are alive by continuously
refreshing a single file. Parent pods and peers consume this signal rather than
relying on process-supervisor coupling, which the host harness does not guarantee.
Empirical confirmation (2026-05-15) established that the Bash tool's `TaskStop`
does NOT propagate to spawned children; the host cannot guarantee lifecycle
coupling. Application-level liveness is therefore the only reliable detection
mechanism. A `.heartbeat` file, refreshed every 5 minutes by a cron, provides
a low-cost, broadly compatible signal that owners can watch in real time, poll
on demand, or cross-check against the OS process table.

---

## Contract

### File format

A `.heartbeat` file contains exactly one line:

```
<ISO-8601-timestamp> <PID>
```

Example:

```
2026-05-15T11:23:45-07:00 12345
```

- **Timestamp** — local ISO-8601 with timezone offset (not UTC-Z), second
  precision. Produced by `date -Iseconds` (bash) or
  `Get-Date -Format o` (PowerShell).
- **PID** — the PID of the AGENT PROCESS, not the PID of the cron job that
  writes the file. See § Cron Implementation Requirements for how this is
  resolved.

The file must not contain a trailing newline beyond the single content line, and
must not contain any other content.

### Location

Pod root. Examples:

- `.foreman-pod/.heartbeat`
- `.overseer-pod/.heartbeat`
- `.curator-pod/.heartbeat`
- `.worker-pod/.heartbeat`

Pod root is the directory that is the pod's identity anchor (the directory
containing `inbox/`, `outbox/`, and `CLAUDE.md` for that pod). Heartbeat is
pod-identity, not inbox content — do not place it inside `inbox/` or `outbox/`.

### Lifecycle

**Created** — on session boot, as part of the pod's startup / refresh
operational checklist. The pod writes the file once at startup (initial PID
capture), then hands maintenance off to a scheduled cron.

**Refreshed** — by a cron job every 5 minutes (the **heartbeat interval**,
configurable per pod). The cron reads the agent PID from `.pid` (see
§ Cron Implementation Requirements) and writes the current timestamp + PID to
`.heartbeat`.

**Deleted** — at session-end, after all crons have been cancelled and before
the `session closed` outbox post. This is the pod's clean-shutdown signal; the
absence of the heartbeat file, combined with the presence of a `session closed`
outbox entry, means the pod shut down cleanly.

---

## State Table

Owners resolve pod state by combining three observable signals. Each row is a
distinct combination; evaluate top to bottom and stop at the first match.

| Heartbeat | Outbox `session closed` | PID alive | State | Owner action |
|-----------|------------------------|-----------|-------|--------------|
| Present, fresh | absent | yes | alive | none |
| Present, stale | absent | yes | zombie | kill via PID |
| Present, stale | absent | no | already-dead orphan | clean heartbeat file |
| Absent | present | no | clean shutdown | none |
| Absent | present | yes | shutdown signaled but process didn't exit | kill via PID |
| Absent | absent | unknown | never started OR pre-shutdown crash | probe (drop inbox msg) OR fresh spawn |

**Definitions:**

- **fresh** — timestamp within `stale_threshold` of now. Default: 10 minutes
  (heartbeat interval × 2 + a small safety buffer). Configurable per pod.
- **stale** — timestamp older than `stale_threshold`.
- **PID alive** — owner runs `ps -p <PID>` (POSIX) or
  `Get-Process -Id <PID> -ErrorAction SilentlyContinue` (Windows). A result
  with exit 0 / non-null output means alive; exit non-zero / null means dead.
  "unknown" in the table means the owner has not yet checked (acceptable when
  the `.heartbeat` file is absent and no `.pid` or outbox signal carries the
  PID).

---

## Observer Modes

Owners may use any combination of the three modes below. The modes are not
mutually exclusive; combining polled + PID-cross-check is the recommended
minimum for probes.

### Mode 1 — Watched (real-time)

Owner runs the `file-watching` skill on `.heartbeat`. The watcher emits
`changed` each time the cron refreshes the file. If the file is deleted (clean
shutdown), the watcher emits `gone` and exits 0 — the existing file-watching
off-ramp handles this automatically with no special configuration.

Stale-detection in watched mode: owners that need stale-detection (not just
event-driven change notification) must implement their own timer alongside the
watcher; file-watching alone does not fire on absence of change. An inactivity
timeout (`-Timeout`) on the watcher can serve as a stale alarm — set it to
`stale_threshold` so the watcher emits `timeout` when the pod goes quiet.

### Mode 2 — Polled (on-demand)

Owner reads `.heartbeat` at relevant moments — before spawning a new pod,
during a probe-and-confirm sequence, or as part of a triage pass. Cheap; no
persistent process. Owner checks the timestamp against `stale_threshold`.

Polled mode does not detect liveness changes in real time. It reflects the pod's
state at the moment of the read. Use it when the owner acts periodically anyway
and sustained real-time observation is not required.

### Mode 3 — PID-alive cross-check

Owner reads the PID from `.heartbeat` (or from the `session closed` outbox body,
see § PID in `session closed` Signal), then queries the OS:

```bash
# POSIX
ps -p <PID> > /dev/null 2>&1 && echo alive || echo dead
```

```powershell
# Windows
if (Get-Process -Id <PID> -ErrorAction SilentlyContinue) { "alive" } else { "dead" }
```

PID-alive cross-check is bulletproof against cron-orphan false positives (a cron
that kept refreshing the file after the agent exited). It is also the decisive
check when the heartbeat is stale but the owner is uncertain whether the pod
crashed or is merely slow. Always run PID-alive when classifying a stale-or-absent
heartbeat before taking destructive action (kill, clean, respawn).

---

## Session-End Integration

The `session-end` skill (already present in all pods) must be extended with two
new steps inserted into the **Close out** helper, between the existing
cron-cancel loop and the `session closed` outbox post:

**New step: Delete `.heartbeat`.**
After all crons are cancelled (existing step), delete the pod's `.heartbeat`
file from pod root. This is a simple `rm -f .heartbeat` (bash) or
`Remove-Item -Force -ErrorAction SilentlyContinue .heartbeat` (PowerShell).
Deletion MUST happen after cron cancellation so the cron cannot write a fresh
file after the pod has signalled its exit.

**Revised `session closed` post (new step): Include PID in message body.**
The existing step posts `session closed` verbatim. This spec extends that step:
the post body must be `session closed <PID>`, where `<PID>` is the agent's
current PID. Example: `session closed 12345`. The literal phrase `session closed`
must still appear as the leading token so that existing consumers that match on
that phrase continue to work.

Revised Close out sequence (full, with new steps highlighted):

1. TaskStop the inbox monitor (existing).
2. TaskStop every other persistent monitor (existing).
3. Cancel every scheduled cron via CronList + CronDelete loop (existing).
4. **[NEW]** Delete `.heartbeat` from pod root: `rm -f .heartbeat`.
5. **[NEW]** Post `session closed <PID>` to outbox (PID = agent's current PID).
6. Exit (existing, formerly step 5).

The invariant that nothing follows the `session closed` post remains.
Callers that previously matched `session closed` verbatim must now
treat it as a prefix match (`startsWith("session closed")`) or update
their match to accept `session closed <PID>`.

---

## Cron Implementation Requirements

### Agent PID resolution — the core problem

A naive cron job that writes `$(date ...) $$` captures the CRON's PID, not the
agent's PID. The agent process and the cron process are distinct. A cron PID in
`.heartbeat` makes PID-alive cross-checks useless — querying the cron PID will
return dead (the cron exited immediately after writing) even when the agent is
healthy.

### Recommended approach — Option B: `.pid` file

The agent writes its own PID to a `.pid` file at session boot, before arming the
cron. The cron reads `.pid` and uses that value when writing `.heartbeat`.

**At session boot (startup / refresh checklist):**

```bash
# bash — write agent PID to .pid
echo "$$" > .pid
```

```powershell
# PowerShell — write agent PID to .pid
Set-Content -Path .pid -Value $PID
```

**Cron job command (tick.sh / tick.ps1):**

```bash
# bash — read agent PID from .pid, write heartbeat
agent_pid=$(cat .pid 2>/dev/null); echo "$(date -Iseconds) ${agent_pid:-unknown}" > .heartbeat
```

```powershell
# PowerShell — read agent PID from .pid, write heartbeat
$agentPid = try { Get-Content .pid -Raw -ErrorAction Stop } catch { "unknown" }
Set-Content -Path .heartbeat -Value "$(Get-Date -Format o) $($agentPid.Trim())"
```

**Why Option B over Option A (pass PID inline in CronCreate):**
Option A inlines the PID as a literal in the CronCreate prompt string at boot
time. This is simpler but brittle: the PID is embedded in the cron definition
and cannot be recovered independently if the session is compacted or the cron
definition is lost. Option B stores the PID as a file-system artifact that
persists for the life of the session, is readable by any owner or tool without
consulting the cron registry, and doubles as a boot-time record for probes that
arrive before the first heartbeat refresh.

### Implementation concern: cron PID context

CronCreate prompts run in their own Claude tool invocation. `$$` in a bash
string inside a prompt may resolve to the harness PID, the cron scheduler's PID,
or an interpolated literal — behavior is implementation-dependent. NEVER rely on
`$$` inside a cron prompt. Option B (read from `.pid`) is the only safe
resolution path.

### Cron schedule

Default heartbeat interval: **5 minutes**. CronCreate expression: `*/5 * * * *`
(every 5 minutes). The interval is configurable; pods with tighter liveness SLAs
may use shorter intervals. The `stale_threshold` must be updated proportionally
(`interval × 2 + buffer`).

### Cron registration (at session boot)

After writing `.pid`:

```
CronCreate(
  schedule: "*/5 * * * *",
  prompt: "Run heartbeat tick: read agent PID from .pid in pod root, write '<timestamp> <PID>' to .heartbeat"
)
```

The actual command text is defined in `tick.sh` / `tick.ps1` (to be authored in
a follow-up dispatch). The cron prompt references the script by relative path
from pod root.

---

## Acceptance Criteria

An implementor may consider this skill correctly instantiated in a pod when:

1. A `.pid` file is written to pod root at session boot containing exactly the
   agent's PID and no other content.
2. A `.heartbeat` file is written to pod root at session boot, refreshed every 5
   minutes by a registered cron, containing one line of `<ISO-8601> <PID>` where
   PID matches `.pid`.
3. Reading the PID from `.heartbeat` and running a PID-alive check returns alive
   while the session is running.
4. On clean shutdown, `.heartbeat` is deleted before `session closed <PID>` is
   posted to outbox. After shutdown, `.heartbeat` is absent and outbox contains
   `session closed <PID>`.
5. A stale-threshold calculation of `(interval × 2) + buffer` (default: 10 min
   + buffer for 5 min interval) is documented for any owner that polls heartbeat
   freshness.
6. All three observer modes (watched, polled, PID-cross-check) are usable
   against the produced artifacts without special pod cooperation beyond
   standard file-system access.
7. The state table resolves without ambiguity for all six state rows when the
   observable signals are present.

---

## Don'ts

- Do NOT track pod PIDs in host memory or environment variables. The `.pid` file
  is the durable, self-describing source of truth. Memory does not survive
  compaction.
- Do NOT add a second `.closed` marker file. The absence of `.heartbeat` combined
  with the `session closed <PID>` outbox post is the shutdown signal. A separate
  marker creates a third artifact that must be kept in sync.
- Do NOT write the cron's own PID into `.heartbeat`. Always read from `.pid`.
  A cron PID makes the PID-alive cross-check useless.
- Do NOT delete `.heartbeat` before cancelling all crons. A live cron can
  re-create the file after deletion, producing a false "alive" signal.
- Do NOT skip writing `.pid` at boot and rely solely on the cron to capture the
  PID. The cron fires 5 minutes after boot; probes that arrive in that window
  would find `.heartbeat` absent (or stale from a prior session).
- Do NOT set `stale_threshold` equal to the heartbeat interval. Network lag,
  cron jitter, and compaction pauses can delay refreshes; the threshold must be
  at least `interval × 2`.
- Do NOT infer "never started" vs "crashed before writing `.pid`" from external
  signals alone. The probe path (drop an inbox message) is the correct resolution
  when both `.heartbeat` and outbox `session closed` are absent.

---

## Source

Operator design session, 2026-05-15. Key verbatim framings:

> "It would be great if the session closed could say what the PID is as well, so
> the host doesn't have to track what PIDs it owns. Now it doesn't, right, because
> it just looks and goes, oh, there's the PID. I should probably kill that."

> Empirical confirmation (2026-05-15 test) that the Bash tool's `TaskStop` does
> NOT propagate to spawned children. The host harness cannot guarantee lifecycle
> coupling. Application-level liveness is the only reliable detection mechanism.
