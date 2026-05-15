#Requires -Version 7
# watch.ps1 — watch a single file for modification, emit one line per event.
#
# Native event-driven (System.IO.FileSystemWatcher). Zero idle CPU. No polling.
#
# Usage:
#   pwsh -File watch.ps1 <file-path> [-Single] [-Prefix <s>] [-Timeout <s>] [-Debounce <s>] [-Heartbeat <s>] [-Help]
#
# Output (stdout, one line per event):
#   changed    — file mtime changed; act on it
#   heartbeat  — -Heartbeat window elapsed with no change (proves watcher is alive)
#   timeout    — -Timeout window elapsed with no change (script exits 0)
#
# Exit code: 0 on clean timeout or normal termination; 1 on argument error; 2 on watch failure.

param(
    [Parameter(Position = 0)]
    [string]$Path,

    [switch]$Single,

    [string]$Prefix = "",

    [int]$Timeout = 0,

    [int]$Debounce = 2,

    [int]$Heartbeat = 0,

    [switch]$Help
)

$ErrorActionPreference = 'Stop'

function Show-Usage {
    @'
Usage: watch.ps1 <file-path> [-Single] [-Prefix <s>] [-Timeout <s>] [-Debounce <s>] [-Heartbeat <s>] [-Help]

Watches a single file for modification and emits one `changed` per settled burst.

Arguments:
  <file-path>        Absolute path to the file to watch (required, positional).

Options:
  -Single            Exit after the first `changed` (debounce-respecting). Combined with
                     -Timeout, whichever fires first ends the script. Exit code: 0.
  -Prefix <string>   Prepend "<prefix>: " to every emitted line (changed/heartbeat/timeout/gone).
                     Default empty (no prefix).
  -Timeout <s>       Exit after <s> consecutive idle seconds. Prints "timeout" then exits 0. Default: 0 (disabled).
  -Debounce <s>      Coalescing window: rapid-fire changes collapse into one `changed` after
                     <s> seconds of quiet. Range 0-60. Default: 2.
  -Heartbeat <s>     Emit "heartbeat" every <s> idle seconds. Default: 0 (disabled).
  -Help              Print this help and exit.

Off-ramp:
  Delete the watched file while the script is running → emits `gone` (or
  `<prefix>: gone`) and exits 0. Use this as a clean shutdown signal.

Output (one line per event on stdout):
  changed        File mtime changed.
  heartbeat      No change in the last -Heartbeat seconds.
  timeout        -Timeout elapsed with no change; script exits 0.

Notes:
- File-event-driven via System.IO.FileSystemWatcher (Windows native). Zero idle CPU.
- Watches one file. Spawn N processes for N files.
- Filters atime/chmod via NotifyFilter = LastWriteTime + FileName + Size.
- Atomic temp+rename saves are caught via the Created/Renamed events in addition to Changed.
- Internal: uses Register-ObjectEvent + Wait-Event (WaitForChanged drops events in some pwsh runtimes).
'@
}

if ($Help) {
    Show-Usage
    exit 0
}

if (-not $Path) {
    Write-Error 'watch.ps1: <file-path> is required (positional argument).'
    Show-Usage
    exit 1
}

if (-not [System.IO.Path]::IsPathRooted($Path)) {
    Write-Error "watch.ps1: <file-path> must be absolute. Got: $Path"
    exit 1
}

if ($Debounce -lt 0 -or $Debounce -gt 60) {
    Write-Error "watch.ps1: -Debounce must be 0..60 seconds. Got: $Debounce"
    exit 1
}

$dir = Split-Path -Parent $Path
$file = Split-Path -Leaf $Path

if (-not (Test-Path -LiteralPath $dir -PathType Container)) {
    Write-Error "watch.ps1: parent directory does not exist: $dir"
    exit 2
}

# If the file is missing at start, exit immediately with `missing` (or `<prefix>: missing`).
# We never auto-create — the watcher is a pure consumer. Producers (or wrappers like
# monitor.sh) own file lifecycle. Missing file = nothing to watch = clean exit.
if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    if ([string]::IsNullOrEmpty($Prefix)) {
        Write-Output 'missing'
    } else {
        Write-Output "$($Prefix): missing"
    }
    [Console]::Out.Flush()
    exit 0
}

# Create the watcher. Filter to LastWriteTime + FileName + Size so we catch all real writes
# (including atomic temp+rename which fires a Created on the new file).
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $dir
$watcher.Filter = $file
$watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWriteTime -bor `
                       [System.IO.NotifyFilters]::FileName -bor `
                       [System.IO.NotifyFilters]::Size
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true

# Use Register-ObjectEvent + Wait-Event for reliable event delivery.
# WaitForChanged() is unreliable in some pwsh environments (events silently dropped).
$srcChanged = "fw_changed_$([Guid]::NewGuid().ToString('N'))"
$srcCreated = "fw_created_$([Guid]::NewGuid().ToString('N'))"
$srcRenamed = "fw_renamed_$([Guid]::NewGuid().ToString('N'))"
$srcDeleted = "fw_deleted_$([Guid]::NewGuid().ToString('N'))"
Register-ObjectEvent -InputObject $watcher -EventName Changed -SourceIdentifier $srcChanged | Out-Null
Register-ObjectEvent -InputObject $watcher -EventName Created -SourceIdentifier $srcCreated | Out-Null
Register-ObjectEvent -InputObject $watcher -EventName Renamed -SourceIdentifier $srcRenamed | Out-Null
Register-ObjectEvent -InputObject $watcher -EventName Deleted -SourceIdentifier $srcDeleted | Out-Null

# Per-iteration wait window. Long when no Heartbeat/Timeout configured; otherwise short
# enough to fire them on schedule.
$tickSeconds = 60
if ($Heartbeat -gt 0 -and $Heartbeat -lt $tickSeconds) { $tickSeconds = $Heartbeat }
if ($Timeout -gt 0 -and $Timeout -lt $tickSeconds) { $tickSeconds = $Timeout }
if ($tickSeconds -lt 1) { $tickSeconds = 1 }

# Two independent clocks:
#   $lastChangedTime   — last real file-event; drives Timeout
#   $lastHeartbeatTime — last heartbeat or change; drives Heartbeat cadence (rate-limit only)
$lastChangedTime = [DateTime]::UtcNow
$lastHeartbeatTime = [DateTime]::UtcNow

function Drain-Events {
    param([string[]]$SourceIdentifiers)
    $count = 0
    foreach ($sid in $SourceIdentifiers) {
        while ($true) {
            $evt = Get-Event -SourceIdentifier $sid -ErrorAction SilentlyContinue | Select-Object -First 1
            if (-not $evt) { break }
            Remove-Event -EventIdentifier $evt.EventIdentifier
            $count++
        }
    }
    return $count
}

function Wait-AnyEvent {
    param([string[]]$SourceIdentifiers, [int]$TimeoutSeconds)
    # Wait-Event takes a single SourceIdentifier; we want any of N. Loop with very short
    # waits and Get-Event to peek at the queue across all sources.
    $deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
    while ([DateTime]::UtcNow -lt $deadline) {
        foreach ($sid in $SourceIdentifiers) {
            $peek = Get-Event -SourceIdentifier $sid -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($peek) { return $peek }
        }
        Start-Sleep -Milliseconds 50
    }
    return $null
}

# All emits go through Emit so prefix handling is centralized.
function Emit {
    param([string]$Token)
    if ([string]::IsNullOrEmpty($Prefix)) {
        Write-Output $Token
    } else {
        Write-Output "$($Prefix): $Token"
    }
    [Console]::Out.Flush()
}

function Emit-Changed { Emit -Token 'changed' }

function Check-Deleted {
    # If the watched file is gone, emit `gone` (with prefix) and exit 0.
    # Atomic temp+rename saves trigger a brief Deleted then Created/Renamed; verify the
    # file is REALLY gone by sleeping 200ms and re-checking before exiting.
    $deletedEvent = Get-Event -SourceIdentifier $srcDeleted -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $deletedEvent) { return }
    Start-Sleep -Milliseconds 200
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        # File is back — atomic save in progress, treat as touch.
        Drain-Events -SourceIdentifiers @($srcDeleted) | Out-Null
        return
    }
    Drain-Events -SourceIdentifiers @($srcDeleted) | Out-Null
    Emit -Token 'gone'
    exit 0
}

try {
    # Sources for `changed` semantics (the change events).
    $changeSources = @($srcChanged, $srcCreated, $srcRenamed)
    # Sources used for the wait — include $srcDeleted so file deletion immediately
    # wakes the loop instead of sitting until the next heartbeat tick.
    $allSources = @($srcChanged, $srcCreated, $srcRenamed, $srcDeleted)

    while ($true) {
        # IDLE state: wait for the first event. Tick determines heartbeat/timeout cadence.
        $evt = Wait-AnyEvent -SourceIdentifiers $allSources -TimeoutSeconds $tickSeconds

        # Off-ramp: file deleted while watching → emit `gone` and exit 0.
        Check-Deleted

        # If the wait was woken by a Deleted-only event, Check-Deleted has either exited or
        # treated it as atomic-rename noise; the change sources may still be empty. Re-check
        # whether any change event actually fired before treating $evt as a real touch.
        if ($evt) {
            $changePending = $false
            foreach ($sid in $changeSources) {
                if (Get-Event -SourceIdentifier $sid -ErrorAction SilentlyContinue | Select-Object -First 1) {
                    $changePending = $true; break
                }
            }
            if (-not $changePending) {
                # Wait was woken by Deleted that turned out to be atomic noise; loop.
                continue
            }
        }

        if ($evt) {
            # First touch from idle — fire IMMEDIATELY (leading-edge).
            Drain-Events -SourceIdentifiers $allSources | Out-Null
            Emit-Changed
            $lastChangedTime = [DateTime]::UtcNow
            $lastHeartbeatTime = $lastChangedTime

            if ($Single) { exit 0 }

            if ($Debounce -le 0) { continue }

            # COOLDOWN state: roll until either a quiet cooldown elapses (→ IDLE)
            # or a touch arrives during cooldown (→ batched changed + new cooldown).
            while ($true) {
                $touchInCooldown = $false
                $cooldownDeadline = [DateTime]::UtcNow.AddSeconds($Debounce)

                # Wait out the cooldown, watching for any touch.
                while ([DateTime]::UtcNow -lt $cooldownDeadline) {
                    $remaining = ($cooldownDeadline - [DateTime]::UtcNow).TotalSeconds
                    if ($remaining -le 0) { break }
                    $secs = [int][Math]::Ceiling($remaining)
                    if ($secs -lt 1) { $secs = 1 }
                    $extra = Wait-AnyEvent -SourceIdentifiers $allSources -TimeoutSeconds $secs
                    # Off-ramp: file deleted during cooldown → exit 0.
                    Check-Deleted
                    if ($extra) {
                        # Confirm it's a change event (not just deleted-noise we already absorbed).
                        $hasChange = $false
                        foreach ($sid in $changeSources) {
                            if (Get-Event -SourceIdentifier $sid -ErrorAction SilentlyContinue | Select-Object -First 1) {
                                $hasChange = $true; break
                            }
                        }
                        if ($hasChange) {
                            $touchInCooldown = $true
                            Drain-Events -SourceIdentifiers $allSources | Out-Null
                        }
                    }
                }

                if ($touchInCooldown) {
                    # Batched `changed` representing every touch during the cooldown.
                    Emit-Changed
                    $lastChangedTime = [DateTime]::UtcNow
                    $lastHeartbeatTime = $lastChangedTime
                    # Restart cooldown — sustained chatter = one `changed` per Debounce seconds.
                    continue
                }

                # Cooldown ended quiet — back to IDLE.
                break
            }

            continue
        }

        # IDLE this tick. Check heartbeat / timeout windows independently.
        $now = [DateTime]::UtcNow
        $idleSinceChanged = ($now - $lastChangedTime).TotalSeconds
        $idleSinceHeartbeat = ($now - $lastHeartbeatTime).TotalSeconds

        if ($Timeout -gt 0 -and $idleSinceChanged -ge $Timeout) {
            Emit -Token 'timeout'
            exit 0
        }

        if ($Heartbeat -gt 0 -and $idleSinceHeartbeat -ge $Heartbeat) {
            Emit -Token 'heartbeat'
            $lastHeartbeatTime = $now
        }
    }
} finally {
    foreach ($sid in @($srcChanged, $srcCreated, $srcRenamed, $srcDeleted)) {
        Unregister-Event -SourceIdentifier $sid -ErrorAction SilentlyContinue
        Get-Event -SourceIdentifier $sid -ErrorAction SilentlyContinue | Remove-Event
    }
    if ($watcher) {
        $watcher.EnableRaisingEvents = $false
        $watcher.Dispose()
    }
}
