# rekey.ps1 — hash-record re-key after file content change
#Requires -Version 7
# Usage: rekey.ps1 <file_path> <op_kind> <record_filename>
# Outputs one of:
#   REKEYED: <new_abs_path>                                       (exit 0)
#   CURRENT: <abs_path>      (hash unchanged, no-op)             (exit 0)
#   NOT_FOUND: no record for <op_kind>/<record_filename>         (exit 0)
#   AMBIGUOUS: <n> records found -- manual resolution required   (exit 1)
#   ERROR: <reason>                                              (exit 1)

param(
    [string]$file_path,
    [string]$op_kind,
    [string]$record_filename,
    [switch]$help,
    [switch]$h
)

$ErrorActionPreference = 'Continue'

if ($help -or $h) {
    [Console]::Out.Write(@"
Usage: rekey <file_path> <op_kind> <record_filename>

Re-key a hash-record entry after the source file content changes.

Arguments:
  file_path        Absolute path to the changed file (new content, not yet committed).
  op_kind          Operation kind, e.g. "markdown-hygiene" or "skill-auditing/v2". May contain /.
  record_filename  Leaf filename, e.g. "claude-haiku.md". No path separators or ...

Output (stdout, one line):
  REKEYED: <abs-path>   Record moved to new hash path.
  CURRENT: <abs-path>   Old hash == new hash. No move needed.
  NOT_FOUND: ...        No record exists for this op_kind/record_filename.
  AMBIGUOUS: <n> ...    Multiple records found -- manual resolution required.
  ERROR: <reason>       Argument or runtime error.

Exit codes:
  0   Success (REKEYED, CURRENT, or NOT_FOUND).
  1   Error (AMBIGUOUS or ERROR).
"@)
    exit 0
}

if (-not $file_path -or -not $op_kind -or -not $record_filename) {
    [Console]::Out.Write("ERROR: missing arguments -- expected <file_path> <op_kind> <record_filename>`n")
    exit 1
}

if ($op_kind -match '\.\.' -or $op_kind -match '[\\]') {
    [Console]::Out.Write("ERROR: invalid op_kind: $op_kind`n")
    exit 1
}

if ($record_filename -match '\.\.' -or $record_filename -match '[/\\]') {
    [Console]::Out.Write("ERROR: invalid record_filename: $record_filename`n")
    exit 1
}

$target_dir = Split-Path -Parent $file_path
$repo_root = (& git -C $target_dir rev-parse --show-toplevel 2>$null)
if (-not $repo_root) {
    $repo_root = $target_dir
    [Console]::Error.WriteLine("WARN: not in a git repo; falling back to file's parent dir as repo_root: $repo_root")
}
$repo_root = $repo_root.TrimEnd('/', '\') -replace '\\', '/'

$new_hash = (& git hash-object $file_path 2>$null)
if ($LASTEXITCODE -ne 0 -or -not $new_hash) {
    [Console]::Out.Write("ERROR: git hash-object failed for: $file_path`n")
    exit 1
}
$new_hash = $new_hash.Trim()
$new_shard = $new_hash.Substring(0, 2)

$hash_record_root = "$repo_root/.hash-record"

if (-not (Test-Path $hash_record_root -PathType Container)) {
    [Console]::Out.Write("NOT_FOUND: no record for $op_kind/$record_filename`n")
    exit 0
}

$op_kind_path = $op_kind -replace '/', [IO.Path]::DirectorySeparatorChar
$found = [System.Collections.Generic.List[object]]::new()

Get-ChildItem -Path $hash_record_root -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $shard_dir = $_
    Get-ChildItem -Path $shard_dir.FullName -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $hash_dir = $_
        $candidate_dir = Join-Path $hash_dir.FullName $op_kind_path
        $candidate = Join-Path $candidate_dir $record_filename
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            $found.Add([PSCustomObject]@{
                Hash      = $hash_dir.Name
                Shard     = $shard_dir.Name
                Path      = ($candidate -replace '\\', '/')
                ParentDir = ($candidate_dir -replace '\\', '/')
            })
        }
    }
}

if ($found.Count -eq 0) {
    [Console]::Out.Write("NOT_FOUND: no record for $op_kind/$record_filename`n")
    exit 0
}

if ($found.Count -gt 1) {
    [Console]::Out.Write("AMBIGUOUS: $($found.Count) records found -- manual resolution required`n")
    exit 1
}

$old_record = $found[0]

if ($old_record.Hash -eq $new_hash) {
    [Console]::Out.Write("CURRENT: $($old_record.Path)`n")
    exit 0
}

$new_record_dir  = "$hash_record_root/$new_shard/$new_hash/$op_kind"
$new_record_path = "$new_record_dir/$record_filename"

New-Item -ItemType Directory -Force -Path $new_record_dir | Out-Null

$old_rel = $old_record.Path.Substring($repo_root.Length).TrimStart('/')
$new_rel = $new_record_path.Substring($repo_root.Length).TrimStart('/')

& git -C $repo_root mv $old_rel $new_rel
if ($LASTEXITCODE -ne 0) {
    [Console]::Out.Write("ERROR: git mv failed: $old_rel -> $new_rel`n")
    exit 1
}

[Console]::Out.Write("REKEYED: $new_record_path`n")
exit 0
