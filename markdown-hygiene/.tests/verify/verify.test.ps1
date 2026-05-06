#!/usr/bin/env pwsh
# verify.test.ps1 — eval suite for verify.ps1
# Usage: verify.test.ps1 [-VerifyScript path/to/verify.ps1]
# Exit: 0 all pass; 1 one or more fail

param(
    [string]$VerifyScript = ''
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $VerifyScript) {
    $VerifyScript = Join-Path $scriptDir '..\..\verify.ps1'
}

if (-not (Test-Path $VerifyScript -PathType Leaf)) {
    Write-Error "ERROR: verify.ps1 not found at: $VerifyScript"
    exit 1
}

$pass = 0
$fail = 0

function Invoke-Fixture([string]$name) {
    $fixture  = Join-Path $scriptDir $name
    $expected = Join-Path $scriptDir "$name.expected.txt"

    if (-not (Test-Path $fixture)) {
        Write-Host "SKIP: $name (fixture missing)"
        return
    }
    if (-not (Test-Path $expected)) {
        Write-Host "SKIP: $name (expected file missing)"
        return
    }

    # Run verify.ps1, capture stdout with explicit LF output
    $proc = [System.Diagnostics.Process]::new()
    $proc.StartInfo.FileName = 'pwsh'
    $proc.StartInfo.Arguments = "-NoProfile -File `"$VerifyScript`" `"$fixture`""
    $proc.StartInfo.RedirectStandardOutput = $true
    $proc.StartInfo.UseShellExecute = $false
    $proc.StartInfo.StandardOutputEncoding = [System.Text.UTF8Encoding]::new($false)
    $proc.Start() | Out-Null
    $actualRaw = $proc.StandardOutput.ReadToEnd()
    $proc.WaitForExit()

    # Normalize to LF for comparison
    $actual = $actualRaw.Replace("`r`n", "`n").Replace("`r", "`n")

    $expBytes = [System.IO.File]::ReadAllBytes($expected)
    $exp = [System.Text.UTF8Encoding]::new($false).GetString($expBytes)

    if ($actual -eq $exp) {
        Write-Host "PASS: $name"
        $script:pass++
    } else {
        Write-Host "FAIL: $name"
        Write-Host "  expected: $($exp -replace "`n",' LF ')"
        Write-Host "  actual:   $($actual -replace "`n",' LF ')"
        $script:fail++
    }
}

Invoke-Fixture 'clean.md'
Invoke-Fixture 'trailing-spaces.md'
Invoke-Fixture 'tabs.md'
Invoke-Fixture 'blanks.md'
Invoke-Fixture 'no-frontmatter-no-h1.md'
Invoke-Fixture 'no-trailing-newline.md'
Invoke-Fixture 'mono-escape-bad.md'
Invoke-Fixture 'mono-escape-good.md'

Write-Host ""
Write-Host "$pass passed, $fail failed"
exit ($fail -gt 0 ? 1 : 0)
