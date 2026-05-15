# file-watching/watch.ps1 — test results 2026-05-15

## Test plan executed

| # | Scenario | Expected | Actual | Verdict |
|---|----------|----------|--------|---------|
| 1 | `-Help` flag | Usage printed, exit 0 | Usage printed | PASS |
| 2 | Missing positional arg | Error + exit 1 | Error + exit 1 | PASS |
| 3 | Relative path arg | Error + exit 1 | Error + exit 1 | PASS |
| 4 | 5 sequential file writes (700ms apart) + atomic temp+rename | 6 `kick` lines | 6 `kick` lines | PASS |
| 5 | 3s heartbeat with idle gap | `heartbeat` lines every 3s | 3 `heartbeat` lines fired | PASS |
| 6 | 10s timeout after no kicks | `timeout` line + exit 0 | `timeout` + exit 0 | PASS |

## Bugs found and fixed during driving

### Bug 1: WaitForChanged drops events silently (FATAL)

`System.IO.FileSystemWatcher.WaitForChanged()` returned `TimedOut=true` even when file writes were happening inside the wait window. Confirmed via bare-FSW diagnostic: 2 sequential `WaitForChanged` calls with explicit `[System.IO.File]::AppendAllText()` between them — both timed out.

**Fix:** Switched to `Register-ObjectEvent` + `Wait-Event` / `Get-Event` pattern. Events fire reliably via the async handler path. WaitForChanged is broken in this PWSH 7 environment.

### Bug 2: Heartbeat reset clobbered Timeout clock

Original code reset `$lastEventTime` after every heartbeat — meaning `Timeout` would never fire when `Heartbeat < Timeout` (the heartbeat kept restarting the timeout countdown).

**Fix:** Two independent clocks — `$lastKickTime` (drives Timeout) and `$lastHeartbeatTime` (drives Heartbeat cadence rate-limit only). Heartbeat firing no longer affects Timeout.

### Bug 3: Multi-event coalescing

Even with WaitForChanged working, rapid-fire writes only produced one `kick` because the call is single-shot and didn't drain the buffer.

**Fix (in new design):** After each `kick`, drain pending events from all 3 sources (Changed/Created/Renamed) with `Get-Event`, emit one `kick` per drained event.

## Stress test (post-fix)

```
5 file writes at 700ms intervals + 1 atomic temp+rename save
→ 6 kicks emitted (perfect 1:1)
→ 3 heartbeats during idle period (every 3s)
→ timeout fires after 10s idle, exit code 0
```

## Confidence

HIGH — all six scenarios PASS, including the previously-broken multi-event and timeout-during-heartbeat cases.
