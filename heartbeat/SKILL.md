---
name: heartbeat
description: Workspace liveness primitive — pods write a refreshed .heartbeat file; owners detect zombies via the state table combining heartbeat file + outbox "session closed" signal + OS PID check. Triggers — pod liveness, zombie detection, session alive check, heartbeat, .heartbeat file, is pod running, detect orphan, stale pod.
---

# Heartbeat

Application-level liveness for pods. The host harness does NOT guarantee that
`TaskStop` propagates to spawned children. Heartbeat is the only reliable
signal. Full rationale and implementation details in `spec.md`.

---

## How It Works

Each pod maintains two files in pod root:

| File | Written by | Content |
|------|-----------|---------|
| `.pid` | Agent at boot | Agent PID (one line) |
| `.heartbeat` | Cron every 5 min | `<ISO-8601-timestamp> <agent-PID>` |

At clean shutdown: `.heartbeat` is deleted, then `session closed <PID>` is
posted to outbox. PID in the outbox lets owners cross-check without reading
a file that no longer exists.

---

## State Table

Owners evaluate in row order and stop at first match.

| Heartbeat | Outbox `session closed` | PID alive | State | Owner action |
|-----------|------------------------|-----------|-------|--------------|
| Present, fresh | absent | yes | alive | none |
| Present, stale | absent | yes | zombie | kill via PID |
| Present, stale | absent | no | already-dead orphan | clean heartbeat file |
| Absent | present | no | clean shutdown | none |
| Absent | present | yes | shutdown signaled; process didn't exit | kill via PID |
| Absent | absent | unknown | never started OR pre-shutdown crash | probe (drop inbox msg) OR fresh spawn |

**Fresh** = timestamp within `stale_threshold` of now. Default: 10 min
(= 5 min interval × 2 + buffer). Configurable per pod.

**PID-alive check:**
```bash
ps -p <PID> > /dev/null 2>&1 && echo alive || echo dead
```
```powershell
if (Get-Process -Id <PID> -ErrorAction SilentlyContinue) { "alive" } else { "dead" }
```

---

## Observer Modes

Three modes; mix and match as needed.

**Watched (real-time):** Run `file-watching` skill on `.heartbeat`. Each cron
refresh fires `changed`; file deletion fires `gone` (watcher exits 0 — this is
the existing file-watching off-ramp, no extra config needed). Set `-Timeout` to
`stale_threshold` to get a `timeout` alarm when the pod goes silent.

**Polled (on-demand):** Read `.heartbeat`, compare timestamp to now against
`stale_threshold`. Use before spawning a pod, during triage, or in any periodic
check. No persistent process.

**PID-alive cross-check:** Read PID from `.heartbeat` or from the outbox
`session closed <PID>` body, then query the OS (see commands above). Always run
this before taking destructive action (kill, clean, respawn) on a stale or
absent heartbeat.

---

## Pod Boot Checklist (additions)

At session boot, before arming the cron:

```bash
# bash
echo "$$" > .pid
echo "$(date -Iseconds) $$" > .heartbeat
```

```powershell
# PowerShell
Set-Content -Path .pid -Value $PID
Set-Content -Path .heartbeat -Value "$(Get-Date -Format o) $PID"
```

Then register the cron (replace `<pod-root>` with the actual path):

```
CronCreate(
  schedule: "*/5 * * * *",
  prompt: "Run heartbeat tick: cd <pod-root> && bash skills/heartbeat/tick.sh"
)
```

`tick.sh` / `tick.ps1` are implemented separately (follow-up dispatch). The
cron MUST read the PID from `.pid` — never use `$$` inside a cron prompt.

---

## Session-End Integration

The `session-end` **Close out** helper gains two steps between cron cancellation
and the existing outbox post:

1. Cancel all crons — CronList + CronDelete loop (existing).
2. **[NEW]** `rm -f .heartbeat` — must happen after cron cancel so the cron
   cannot re-create the file.
3. **[NEW]** Post `session closed <PID>` — literal prefix `session closed` is
   preserved; callers must update matchers to `startsWith("session closed")`.
4. Exit.

Actual edits to session-end SKILL.md files happen in a follow-up task.

---

## Don'ts

- Don't track PIDs in memory or env vars — memory doesn't survive compaction.
- Don't write a second `.closed` marker — absence of `.heartbeat` + `session
  closed <PID>` outbox is the shutdown signal.
- Don't delete `.heartbeat` before cancelling crons — the cron can re-create it.
- Don't use `$$` in cron prompts — always read from `.pid`.
- Don't set `stale_threshold` equal to the interval — use `interval × 2 + buffer`.

Full spec: `spec.md` in this directory.
