#!/usr/bin/env pwsh
# prune.ps1 — hash-record orphan pruner
# Usage: prune.ps1 -repo_root <path> [-dry_run] [-limit <N>]
# Prunes orphaned hash directories from <repo_root>/.hash-record/.
#
# Requires PowerShell 7+ (Microsoft PowerShell, cross-platform).
# Windows PowerShell 5.1 is not supported.

param(
    [Parameter(Position = 0)]
    [string]$repo_root,
    [switch]$dry_run,
    [int]$limit = -1,
    [switch]$help,
    [switch]$h
)

$ErrorActionPreference = 'Continue'

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------
if ($help -or $h) {
    $usage = "Usage: prune.ps1 -repo_root <path> [-dry_run] [-limit <N>]`n" +
        "`n" +
        "Prune orphaned entries from <repo_root>/.hash-record/.`n" +
        "A record is orphaned when no current file in the repo hashes to its key.`n" +
        "`n" +
        "Parameters:`n" +
        "  -repo_root <path>  Absolute path to the repository root.`n" +
        "                     Must not contain '..' or shell metacharacters.`n" +
        "`n" +
        "Flags:`n" +
        "  -dry_run           Report orphan count without deleting.`n" +
        "  -limit <N>         Cap deletions at N per invocation.`n" +
        "  -help/-h           Print this help and exit 0.`n" +
        "`n" +
        "Output (stdout, one line):`n" +
        "  CLEAN           No orphans found.`n" +
        "  pruned: <N>     N orphans deleted.`n" +
        "  dry-run: <N>    Dry-run mode; N would be deleted.`n" +
        "  ERROR: <reason> Pre-execution failure.`n" +
        "`n" +
        "Exit codes:`n" +
        "  0  Success.`n" +
        "  1  Error.`n"
    [Console]::Out.Write($usage)
    exit 0
}

# ---------------------------------------------------------------------------
# Validate repo_root
# ---------------------------------------------------------------------------
if (-not $repo_root) {
    [Console]::Out.Write("ERROR: missing required argument: repo_root`n")
    exit 1
}

# Reject '..' path traversal
if ($repo_root -match '\.\.') {
    [Console]::Out.Write("ERROR: repo_root must not contain '..': $repo_root`n")
    exit 1
}

# Reject shell metacharacters
if ($repo_root -match '[;|&$><`(){}\n\r]') {
    [Console]::Out.Write("ERROR: repo_root contains shell metacharacters: $repo_root`n")
    exit 1
}

# Require absolute path
if (-not ([System.IO.Path]::IsPathRooted($repo_root))) {
    [Console]::Out.Write("ERROR: repo_root must be an absolute path: $repo_root`n")
    exit 1
}

# Normalize to forward slashes for byte-identical stdout
$repo_root_fwd = $repo_root.TrimEnd('/', '\') -replace '\\', '/'
$hash_record_dir = "$repo_root_fwd/.hash-record"
$hash_record_literal = $repo_root.TrimEnd('/', '\') + [System.IO.Path]::DirectorySeparatorChar + '.hash-record'

# ---------------------------------------------------------------------------
# CLEAN exit if .hash-record/ is absent
# ---------------------------------------------------------------------------
if (-not (Test-Path -LiteralPath $hash_record_literal -PathType Container)) {
    [Console]::Out.Write("CLEAN`n")
    exit 0
}

# ---------------------------------------------------------------------------
# Collect submodule paths (excluded from hash scan)
# ---------------------------------------------------------------------------
$submodule_paths = @()
$gitmodules = Join-Path $repo_root '.gitmodules'
if (Test-Path -LiteralPath $gitmodules -PathType Leaf) {
    $sm_raw = (& git config -f $gitmodules --get-regexp '^submodule\..*\.path$' 2>$null)
    if ($sm_raw) {
        $submodule_paths = $sm_raw -split "`n" `
            | Where-Object { $_ -ne '' } `
            | ForEach-Object { ($_ -split '\s+', 2)[1] } `
            | Where-Object { $_ -ne '' }
    }
}

# ---------------------------------------------------------------------------
# Build valid-hash set (for non-manifest hash dirs)
# Compute atomically before any deletion begins.
# ---------------------------------------------------------------------------
$valid_hashes = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)

$ls_output = (& git -C $repo_root ls-files --cached --others --exclude-standard 2>$null)
if ($ls_output) {
    foreach ($rel_path in ($ls_output -split "`n" | Where-Object { $_ -ne '' })) {
        # Skip .worktrees/ paths
        if ($rel_path -match '^\.worktrees/') { continue }

        # Skip submodule paths
        $skip = $false
        foreach ($sm in $submodule_paths) {
            if ($rel_path -eq $sm -or $rel_path.StartsWith("$sm/")) {
                $skip = $true; break
            }
        }
        if ($skip) { continue }

        $abs_path = Join-Path $repo_root $rel_path
        if (-not (Test-Path -LiteralPath $abs_path -PathType Leaf)) { continue }
        # Skip symlinks
        $item = Get-Item -LiteralPath $abs_path -ErrorAction SilentlyContinue
        if ($null -eq $item -or $item.LinkType) { continue }

        $blob_h = (& git hash-object $abs_path 2>$null)
        if ($blob_h) { [void]$valid_hashes.Add($blob_h.Trim()) }
    }
}

# ---------------------------------------------------------------------------
# Manifest validity check
# Returns $true (VALID) or $false (ORPHANED).
# ---------------------------------------------------------------------------
function Test-ManifestValid {
    param(
        [string]$RepoRoot,
        [string]$HashName,
        [string]$ManifestPath
    )

    # Parse file_paths from YAML
    $file_paths = [System.Collections.Generic.List[string]]::new()
    $in_fp = $false
    $content = Get-Content -LiteralPath $ManifestPath -ErrorAction SilentlyContinue
    if ($null -eq $content) { return $false }

    foreach ($line in $content) {
        if ($line -match '^file_paths:') { $in_fp = $true; continue }
        if ($in_fp) {
            if ($line -match '^\s+-\s+(.+)') {
                $fpath = $Matches[1].TrimEnd()
                if ($fpath -ne '') { $file_paths.Add($fpath) }
            } elseif ($line -match '^\S') {
                break  # non-indented line ends the file_paths block
            }
        }
    }

    if ($file_paths.Count -eq 0) { return $false }

    # Build (path hash) pairs; bail if any file is missing or unhashable
    $pairs = [System.Collections.Generic.List[string]]::new()
    foreach ($fpath in $file_paths) {
        $abs = Join-Path $RepoRoot $fpath
        if (-not (Test-Path -LiteralPath $abs -PathType Leaf)) { return $false }
        $fblob = (& git hash-object $abs 2>$null)
        if (-not $fblob) { return $false }
        $pairs.Add("$fpath $($fblob.Trim())")
    }

    # Sort lexically (case-sensitive, byte-order — matches bash LC_ALL=C sort)
    $sorted = $pairs | Sort-Object -CaseSensitive -Culture ''

    # Build manifest text with explicit LF endings (no CRLF)
    $manifest_text = ''
    foreach ($pair in $sorted) {
        $manifest_text += "$pair`n"
    }

    # Hash via temp file to avoid PowerShell piping encoding issues
    # (Byte-identical to bash: printf '%s' "$manifest_text" | git hash-object --stdin)
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($manifest_text)
    $tmp = [System.IO.Path]::GetTempFileName()
    try {
        [System.IO.File]::WriteAllBytes($tmp, $bytes)
        $computed = (& git hash-object $tmp 2>$null)
        if (-not $computed) { return $false }
        return ($computed.Trim() -eq $HashName)
    } finally {
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
    }
}

# ---------------------------------------------------------------------------
# Walk .hash-record/ two levels deep and classify each hash directory
# ---------------------------------------------------------------------------
$orphans = [System.Collections.Generic.List[string]]::new()

$shard_dirs = Get-ChildItem -LiteralPath $hash_record_literal -Directory -ErrorAction SilentlyContinue
foreach ($shard in $shard_dirs) {
    # Skip symlinks
    if ($shard.LinkType) { continue }
    # Skip dot-prefixed admin directories
    if ($shard.Name.StartsWith('.')) { continue }

    $hash_dirs = Get-ChildItem -LiteralPath $shard.FullName -Directory -ErrorAction SilentlyContinue
    foreach ($hash_dir in $hash_dirs) {
        # Skip symlinks
        if ($hash_dir.LinkType) { continue }

        $hash_name = $hash_dir.Name
        $manifest = Join-Path $hash_dir.FullName 'manifest.yaml'

        $is_valid = $false
        if (Test-Path -LiteralPath $manifest -PathType Leaf) {
            # Manifest strategy: re-derive the manifest hash and compare
            $manifest_item = Get-Item -LiteralPath $manifest -ErrorAction SilentlyContinue
            if ($null -ne $manifest_item -and -not $manifest_item.LinkType) {
                $is_valid = Test-ManifestValid -RepoRoot $repo_root -HashName $hash_name -ManifestPath $manifest
            } else {
                # Symlink manifest or unreadable — fall through to full-workspace check
                $is_valid = $valid_hashes.Contains($hash_name)
            }
        } else {
            # Full-workspace fallback: hash must be in the valid-hash set
            $is_valid = $valid_hashes.Contains($hash_name)
        }

        if (-not $is_valid) {
            # Store as forward-slash path for byte-identical stdout
            $orphans.Add(($hash_dir.FullName -replace '\\', '/'))
        }
    }
}

# ---------------------------------------------------------------------------
# Count orphans
# ---------------------------------------------------------------------------
$orphan_count = $orphans.Count

# ---------------------------------------------------------------------------
# Dry-run
# ---------------------------------------------------------------------------
if ($dry_run) {
    [Console]::Out.Write("dry-run: $orphan_count`n")
    exit 0
}

# CLEAN if no orphans
if ($orphan_count -eq 0) {
    [Console]::Out.Write("CLEAN`n")
    exit 0
}

# ---------------------------------------------------------------------------
# Delete orphans (up to -limit)
# ---------------------------------------------------------------------------
$deleted = 0
$hash_record_prefix = ($hash_record_literal -replace '\\', '/') + '/'

foreach ($odir in $orphans) {
    # Cap at limit (-limit -1 means unlimited)
    if ($limit -ge 0 -and $deleted -ge $limit) { break }

    # Safety: path must be under .hash-record/
    $odir_fwd = $odir -replace '\\', '/'
    if (-not $odir_fwd.StartsWith($hash_record_prefix)) {
        [Console]::Error.WriteLine("skipping path outside .hash-record/: $odir")
        continue
    }

    Remove-Item -LiteralPath $odir -Recurse -Force -ErrorAction SilentlyContinue
    $deleted++
}

# ---------------------------------------------------------------------------
# Prune now-empty shard directories
# ---------------------------------------------------------------------------
$remaining_shards = Get-ChildItem -LiteralPath $hash_record_literal -Directory -ErrorAction SilentlyContinue
foreach ($shard in $remaining_shards) {
    if ($shard.LinkType) { continue }
    if ($shard.Name.StartsWith('.')) { continue }
    $children = Get-ChildItem -LiteralPath $shard.FullName -ErrorAction SilentlyContinue
    if ($null -eq $children -or $children.Count -eq 0) {
        Remove-Item -LiteralPath $shard.FullName -Force -ErrorAction SilentlyContinue
    }
}

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------
if ($deleted -eq 0) {
    [Console]::Out.Write("CLEAN`n")
} else {
    [Console]::Out.Write("pruned: $deleted`n")
}

exit 0
