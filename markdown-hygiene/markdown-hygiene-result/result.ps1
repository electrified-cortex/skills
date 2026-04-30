#!/usr/bin/env pwsh
# result.ps1 — markdown-hygiene result tool
# Wraps hash-record-check and translates HIT into the cached verdict.
# Usage: result <markdown_file_path>
# Outputs one of:
#   CLEAN                       (exit 0)
#   findings: <abs-path>        (exit 0)
#   MISS: <abs-path>            (exit 0)
#   ERROR: <reason>             (exit 1)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------
if ($args.Count -eq 0 -or $args[0] -eq '--help' -or $args[0] -eq '-h') {
    if ($args.Count -eq 0) {
        [Console]::Out.Write("ERROR: missing argument -- expected <markdown_file_path>`n")
        exit 1
    }
    [Console]::Out.Write(@"
Usage: result <markdown_file_path>

Wraps hash-record-check for markdown-hygiene and translates a HIT into
the cached verdict by reading the report's frontmatter.

Arguments:
  markdown_file_path  Absolute path to the .md file (must be readable).

Output (stdout, one line):
  CLEAN                       Cached report says result: pass.
  findings: <abs-path>        Cached report says result: findings.
  MISS: <abs-path>            No cache entry; this path is where the
                              executor MUST write its report.
  ERROR: <reason>             Argument or runtime error, or malformed
                              cache record.

Exit codes:
  0  Success (CLEAN, findings, or MISS).
  1  Error.
"@)
    exit 0
}

$FilePath = $args[0]

# ---------------------------------------------------------------------------
# Locate sibling check.ps1 (hash-record-check)
# ---------------------------------------------------------------------------
$ScriptDir = Split-Path -Parent $PSCommandPath
$CheckPs1 = Join-Path $ScriptDir '../hash-record/hash-record-check/check.ps1'

if (-not (Test-Path $CheckPs1)) {
    [Console]::Out.Write("ERROR: cannot locate hash-record-check at: $CheckPs1`n")
    exit 1
}

# ---------------------------------------------------------------------------
# Invoke hash-record-check
# ---------------------------------------------------------------------------
try {
    $CheckOut = & pwsh -NoProfile -File $CheckPs1 $FilePath 'markdown-hygiene' 'report.md' 2>$null
    $CheckOut = $CheckOut -join "`n" -replace "`r", '' -split "`n" | Where-Object { $_ -ne '' } | Select-Object -Last 1
} catch {
    [Console]::Out.Write("ERROR: hash-record-check failed for: $FilePath`n")
    exit 1
}

if (-not $CheckOut) {
    [Console]::Out.Write("ERROR: hash-record-check returned no output for: $FilePath`n")
    exit 1
}

# Normalize forward slashes
$CheckOut = $CheckOut -replace '\\', '/'

# ---------------------------------------------------------------------------
# Branch on hash-record-check stdout
# ---------------------------------------------------------------------------
if ($CheckOut -like 'MISS: *') {
    [Console]::Out.Write("$CheckOut`n")
    exit 0
}
if ($CheckOut -like 'ERROR: *') {
    [Console]::Out.Write("$CheckOut`n")
    exit 1
}
if ($CheckOut -like 'HIT: *') {
    $ReportPath = $CheckOut -replace '^HIT: ', ''
    if (-not (Test-Path $ReportPath)) {
        [Console]::Out.Write("ERROR: cache record vanished at: $ReportPath`n")
        exit 1
    }
    # Parse frontmatter result: line.
    $ResultLine = (Get-Content $ReportPath -ErrorAction SilentlyContinue) | Where-Object { $_ -match '^result:' } | Select-Object -First 1
    if (-not $ResultLine) {
        [Console]::Out.Write("ERROR: malformed cache record at $ReportPath`n")
        exit 1
    }
    $ResultValue = ($ResultLine -split ':', 2)[1].Trim() -split '\s+' | Select-Object -First 1
    switch ($ResultValue) {
        'pass' {
            [Console]::Out.Write("CLEAN`n")
            exit 0
        }
        'findings' {
            [Console]::Out.Write("findings: $ReportPath`n")
            exit 0
        }
        default {
            [Console]::Out.Write("ERROR: malformed cache record at $ReportPath`n")
            exit 1
        }
    }
}

[Console]::Out.Write("ERROR: unrecognized hash-record-check output: $CheckOut`n")
exit 1
