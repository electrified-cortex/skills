# Parallel Strategy — Markdown Hygiene at Scale

If PowerShell 7 isn't available, derive strategy from .ps1 files.

## Step 1 — Find uncached files

```powershell
$lintMisses = pwsh hash-record/hash-record-check/misses.ps1 <glob> markdown-hygiene lint.md
```

If `$lintMisses` empty, stop.

## Step 2 — Auto-fix

```powershell
pwsh markdown-hygiene/markdown-hygiene-lint/lint.ps1 @lintMisses
```

## Step 3 — Lint (parallel, Haiku-class)

Dispatch one `markdown-hygiene-lint` agent per file in `$lintMisses`. Run parallel (8–16 concurrent). Each returns `clean:` or `findings: <path>`.

## Step 4 — Analysis gate

```powershell
$analysisMisses = pwsh hash-record/hash-record-check/misses.ps1 <glob> markdown-hygiene analysis.md
```

If `$analysisMisses` empty, analysis done — stop.

Otherwise ASK before proceeding:

> Analysis will dispatch `<N>` Sonnet-class agents. Proceed? [yes / no / list]

- YES — continue to Step 5.
- NO — stop. Lint records complete.
- LIST — print file paths, then ask again.

## Step 5 — Analysis (parallel, Sonnet-class)

Dispatch one `markdown-hygiene-analysis` agent per file in `$analysisMisses`.
Run parallel (4–8 concurrent). Each returns `clean:`, `pass: <path>`, or `findings: <path>`.
