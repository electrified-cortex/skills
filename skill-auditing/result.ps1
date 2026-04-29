#!/usr/bin/env pwsh
# result.ps1 — skill-auditing result tool
# Wraps hash-record-manifest and translates HIT into the cached audit verdict.
# Usage: result <skill_dir>
# Outputs one of:
#   PASS: <abs-path>            (HIT, result: pass)         (exit 0)
#   NEEDS_REVISION: <abs-path>  (HIT, result: findings)     (exit 0)
#   FAIL: <abs-path>            (HIT, result: error)        (exit 0)
#   MISS: <abs-path>            (no cache; this is the report path) (exit 0)
#   ERROR: <reason>             (argument or runtime error) (exit 1)

param(
    [Parameter(Position=0)]
    [string]$skill_dir,
    [switch]$uncompressed,
    [switch]$help,
    [switch]$h
)

$ErrorActionPreference = 'Continue'

if ($help -or $h) {
    [Console]::Out.Write(@"
Usage: result <skill_dir>

Wraps hash-record-manifest for skill-auditing and translates a HIT into
the cached audit verdict by reading the report's frontmatter.

Arguments:
  skill_dir  Absolute path to the skill folder being audited.
             Tool enumerates spec.md, uncompressed.md,
             instructions.uncompressed.md (whichever exist).

Output (stdout, one line):
  PASS: <abs-path>            Cached report says result: pass.
  NEEDS_REVISION: <abs-path>  Cached report says result: findings.
  FAIL: <abs-path>            Cached report says result: error.
  MISS: <abs-path>            No cache entry; executor MUST write here.
  ERROR: <reason>             Argument, runtime, or malformed-record error.

Exit codes:
  0  Success (PASS, NEEDS_REVISION, FAIL, or MISS).
  1  Error.
"@)
    exit 0
}

if (-not $skill_dir) {
    [Console]::Out.Write("ERROR: missing argument -- expected <skill_dir>`n")
    exit 1
}

if (-not (Test-Path -LiteralPath $skill_dir -PathType Container)) {
    [Console]::Out.Write("ERROR: skill_dir not found: $skill_dir`n")
    exit 1
}

# Enumerate ALL regular files in skill_dir, recursively, skipping any path
# where any component starts with '.' (dot-prefixed files or directories like
# .hash-record/, .tests/, .worktrees/, .gitignore).
$skill_dir_full = (Resolve-Path -LiteralPath $skill_dir).Path
$skill_dir_full_fwd = $skill_dir_full -replace '\\', '/'
$files_raw = Get-ChildItem -LiteralPath $skill_dir -Recurse -File -Force | ForEach-Object { $_.FullName }
$files = @()
foreach ($f in $files_raw) {
    $f_fwd = $f -replace '\\', '/'
    # Strip the skill_dir prefix to get relative path
    if ($f_fwd.StartsWith($skill_dir_full_fwd + '/')) {
        $rel = $f_fwd.Substring($skill_dir_full_fwd.Length + 1)
    } else {
        $rel = $f_fwd
    }
    # Skip if any DIRECTORY component starts with '.' (leaf filename can be a dotfile).
    $segments = $rel -split '/'
    $dir_segments = $segments[0..([math]::Max(0, $segments.Length - 2))]
    $skip = $false
    if ($segments.Length -gt 1) {
        foreach ($component in $dir_segments) {
            if ($component.StartsWith('.')) {
                $skip = $true
                break
            }
        }
    }
    if (-not $skip) {
        $files += $f
    }
}
# Sort by relative path (byte-order) for stable manifest input
$files = $files | Sort-Object -CaseSensitive

if ($files.Count -eq 0) {
    [Console]::Out.Write("ERROR: no files found in skill_dir`n")
    exit 1
}

# Locate sibling manifest tool
$script_dir = Split-Path -Parent $PSCommandPath
$manifest_ps1 = Join-Path $script_dir '../hash-record/hash-record-manifest/manifest.ps1'

if (-not (Test-Path -LiteralPath $manifest_ps1)) {
    [Console]::Out.Write("ERROR: cannot locate hash-record-manifest at: $manifest_ps1`n")
    exit 1
}

# Determine op_kind based on --uncompressed flag
$op_kind = if ($uncompressed) { 'skill-auditing/v1.2-uncompressed' } else { 'skill-auditing/v1.2-compiled' }

# Invoke manifest with computed op_kind + record_filename=report.md
try {
    $manifest_args = @($op_kind, 'report.md') + $files
    $manifest_out = & pwsh -NoProfile -File $manifest_ps1 @manifest_args 2>$null
    $manifest_out = $manifest_out -join "`n" -replace "`r", '' -split "`n" | Where-Object { $_ -ne '' } | Select-Object -Last 1
} catch {
    [Console]::Out.Write("ERROR: hash-record-manifest failed for: $skill_dir`n")
    exit 1
}

if (-not $manifest_out) {
    [Console]::Out.Write("ERROR: hash-record-manifest returned no output for: $skill_dir`n")
    exit 1
}

# Normalize forward slashes
$manifest_out = $manifest_out -replace '\\', '/'

# Branch on manifest stdout
if ($manifest_out -like 'MISS: *') {
    [Console]::Out.Write("$manifest_out`n")
    exit 0
}
if ($manifest_out -like 'ERROR: *') {
    [Console]::Out.Write("$manifest_out`n")
    exit 1
}
if ($manifest_out -like 'HIT: *') {
    $report_path = $manifest_out -replace '^HIT: ', ''
    if (-not (Test-Path -LiteralPath $report_path)) {
        [Console]::Out.Write("ERROR: cache record vanished at: $report_path`n")
        exit 1
    }
    # Parse frontmatter result: line.
    $result_line = (Get-Content $report_path -ErrorAction SilentlyContinue) | Where-Object { $_ -match '^result:' } | Select-Object -First 1
    if (-not $result_line) {
        [Console]::Out.Write("ERROR: malformed cache record at $report_path`n")
        exit 1
    }
    $result_value = ($result_line -split ':', 2)[1].Trim() -split '\s+' | Select-Object -First 1
    switch ($result_value) {
        'pass' {
            [Console]::Out.Write("PASS: $report_path`n")
            exit 0
        }
        'findings' {
            [Console]::Out.Write("NEEDS_REVISION: $report_path`n")
            exit 0
        }
        'error' {
            [Console]::Out.Write("FAIL: $report_path`n")
            exit 0
        }
        default {
            [Console]::Out.Write("ERROR: malformed cache record at $report_path`n")
            exit 1
        }
    }
}

[Console]::Out.Write("ERROR: unrecognized hash-record-manifest output: $manifest_out`n")
exit 1
