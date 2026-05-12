# GH CLI Escaping Investigation

## 1. Affected Scripts — File Paths Inspected

All files are under `skills/gh-cli/` (relative paths shown; prefix `D:\Users\essence\Development\cortex.lan\electrified-cortex\skills\gh-cli\`).

| File | Variant | Body-posting? |
|------|---------|--------------|
| `gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-post/instructions.uncompressed.md` | instruction doc (md) | YES — primary subject |
| `gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-post/SKILL.md` | skill dispatch (md) | YES — carries BODY param |
| `gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-post/uncompressed.md` | skill dispatch (md) | YES |
| `gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-post/spec.md` | spec (md) | YES — defines Step 5 |
| `gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-edit/SKILL.md` | skill (md) | YES |
| `gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-edit/uncompressed.md` | skill (md) | YES |
| `gh-cli-pr/gh-cli-pr-comments/SKILL.md` | skill (md) | YES |
| `gh-cli-pr/gh-cli-pr-comments/uncompressed.md` | skill (md) | YES |
| `gh-cli-pr/gh-cli-pr-review/SKILL.md` | skill (md) | YES |
| `gh-cli-pr/gh-cli-pr-review/uncompressed.md` | skill (md) | YES |
| `gh-cli-pr/gh-cli-pr-create/SKILL.md` | skill (md) | YES |
| `gh-cli-pr/gh-cli-pr-create/uncompressed.md` | skill (md) | YES |
| `gh-cli-issues/SKILL.md` | skill (md) | YES |
| `gh-cli-issues/uncompressed.md` | skill (md) | YES |
| `gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-post/verify-line-in-diff.sh` | bash (.sh) | NO — read-only diff tool |
| `gh-cli-pr/gh-cli-pr-inline-comment/gh-cli-pr-inline-comment-post/verify-line-in-diff.ps1` | PowerShell 7+ (.ps1) | NO — read-only diff tool |

The two `.sh` / `.ps1` scripts are helper tools that verify diff ranges only. They never construct a `gh` comment-posting command and are not implicated in the escaping bug.

The actual `gh` invocations are **not in compiled scripts**. They are embedded as code-block examples inside markdown instruction documents that the sub-agent reads and then executes verbatim (or with `{PLACEHOLDER}` substitutions) inside a shell it calls. This is the root of the problem — the shell invocation pattern is baked into the skill docs, not into a safe wrapper script.

---

## 2. Findings Per File

### 2a. `gh-cli-pr-inline-comment-post/instructions.uncompressed.md` — PRIMARY DEFECT

**Input contract**: BODY is passed as a named template parameter `{BODY}` in the instruction text. The agent interpolates it directly into the shell command string.

**The buggy command (Step 5, single-line):**
```bash
gh api --method POST repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments \
  --field body="{BODY}" \
  ...
```

**Bug class**: Shell word-splitting / interpolation via `--field body="{BODY}"`.

When the agent synthesizes and runs this command, it passes the body as a double-quoted string argument. Characters that corrupt output:
- Backtick `` ` `` — bash: command substitution. PowerShell: escape character.
- Dollar sign `$` — bash: variable expansion (`$foo`, `$(cmd)`). PowerShell: variable expansion.
- Double quote `"` — terminates the shell string.
- Backslash `\` — escape char in bash double-quotes; consumed/mutated.
- Newlines — shell may split on them or the argument is truncated at first newline depending on quoting.
- Ampersand `&` — background-job operator in bash; must be escaped.
- Backtick sequences like `` `sh` `` — executed as subshell.

**Severity**: CRITICAL. Any markdown body with a code fence, a shell variable reference, or a backtick inline code span will produce wrong output or cause command execution.

**Evidence excerpt** (from `instructions.uncompressed.md`, Step 5):
```
gh api --method POST repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments \
  --field body="{BODY}" \
  --field commit_id="{COMMIT_SHA}" \
  --field path="{FILE_PATH}" \
  --field line={LINE_NUMBER} \
  --field side="{SIDE}"
```

Also contains a dedup check with an inline-substituted `--jq` filter (Step 4):
```bash
gh api --paginate repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments \
  --jq '.[] | select(.path == "{FILE_PATH}" and .line == {LINE_NUMBER} and .side == "{SIDE}") | {id, body, author: .user.login}'
```
The `--jq` string here uses literal curly braces (`{id, body, author: .user.login}`) that happen to not clash with the template substitution but would collide if the agent misinterprets them.

---

### 2b. `gh-cli-pr-inline-comment-edit/SKILL.md` — SAME BUG

**Input contract**: BODY substituted inline into `--field body="{BODY}"`.

**Buggy command:**
```bash
gh api --method PATCH repos/{OWNER}/{REPO}/pulls/comments/{COMMENT_ID} \
  --field body="{BODY}"
```

**Bug class**: Same shell interpolation defect as 2a. Identical severity.

**Note in the SKILL.md**: "Large content edits may require JSON body escaping." This acknowledges the problem but provides no safe pattern. The note is insufficient — it transfers burden to the caller without prescribing a fix.

**Severity**: CRITICAL.

---

### 2c. `gh-cli-pr-comments/SKILL.md` and `uncompressed.md` — TWO BUG LOCATIONS

**Input contract**: Body passed inline as shell argument.

**Buggy commands (two patterns):**
```bash
gh pr comment 123 --body "text"
```
and (for edit):
```bash
gh api --method PATCH \
  /repos/{owner}/{repo}/issues/comments/{comment_id} \
  --field body="updated text"
```

`gh pr comment --body "text"` is safe only when `text` is a literal constant. When an agent substitutes a multi-line markdown body into the `"text"` slot, it breaks identically to 2a.

**Severity**: HIGH for `--body "..."` form. Same interpolation risk.

**Additional note**: The file also contains `/repos/{owner}/{repo}/issues/{issue_number}/comments` with a leading slash, which the spec notes elsewhere causes Git Bash to rewrite as a filesystem path on Windows. This is a separate (documented) bug, but it appears in both the SKILL and uncompressed files.

---

### 2d. `gh-cli-pr-review/SKILL.md` and `uncompressed.md`

**Buggy commands:**
```bash
gh pr review 123 --approve --body "LGTM"
gh pr review 123 --request-changes --body "Please address X before merging"
gh pr review 123 --comment --body "Thoughts inline"
```

Review bodies are typically short prose, so in practice this is triggered less often. But any backtick in a review body (e.g., quoting a symbol: `` `MyMethod` ``) will corrupt.

**Severity**: MEDIUM. Lower impact than inline comments because review bodies are less likely to contain complex markdown, but the defect is identical.

---

### 2e. `gh-cli-pr-create/SKILL.md` and `uncompressed.md`

**Buggy command:**
```bash
gh pr create --title "title" --body "body" --base main
```

The `--body` substitution is inline. PR descriptions frequently contain markdown (code blocks, backticks, dollar signs). `--body-file` is mentioned as an alternative (`--body-file .github/PULL_REQUEST_TEMPLATE.md`) but only in the context of using a template file, not as the canonical safe pattern for arbitrary body content.

**Severity**: HIGH. PR descriptions are the most likely to contain full markdown with code fences.

---

### 2f. `gh-cli-issues/SKILL.md` and `uncompressed.md`

**Buggy commands (three patterns):**
```bash
gh issue create --title "title" --body "body" --label bug,high-priority
gh issue comment 123 --body "text"
gh api --method PATCH /repos/{owner}/{repo}/issues/comments/{comment_id} \
  --field body="updated"
```

`--body-file issue.md` is mentioned as an alternative for `gh issue create`, but again only as an option rather than the canonical safe pattern.

**Severity**: HIGH.

---

### 2g. `verify-line-in-diff.sh` — CLEAN

Read-only. Accepts only structured parameters (owner, repo, PR number, file path, line number, side). Never constructs a body-posting `gh` command. No escaping defect.

### 2h. `verify-line-in-diff.ps1` — CLEAN

Same verdict as 2g.

---

## 3. Recommended Canonical Pattern

### 3a. Bash — write body to temp file, pass `--body-file`

```bash
# Step 1: write body to a temp file with no shell expansion
BODY_FILE=$(mktemp /tmp/gh-body-XXXXXX.md)
# Use printf with %s to avoid any interpretation of the content
printf '%s' "$BODY" > "$BODY_FILE"

# Step 2: pass --body-file to gh
gh api --method POST repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments \
  --field commit_id="{COMMIT_SHA}" \
  --field path="{FILE_PATH}" \
  --field line={LINE_NUMBER} \
  --field side="{SIDE}" \
  --field body=@"$BODY_FILE"

# OR use --body-file for gh pr comment / gh issue comment / gh pr review:
gh pr comment {PR_NUMBER} --body-file "$BODY_FILE"

# Cleanup
rm -f "$BODY_FILE"
```

**Key rules**:
- `--field body=@"$BODY_FILE"` — the `@` prefix tells `gh api` to read the field value from a file. The file content is passed verbatim; no shell expansion occurs.
- `--body-file <path>` — accepted by `gh pr comment`, `gh issue comment`, `gh pr review`, and `gh pr create`. Reads content from disk without shell interpretation.
- The temp file is written with `printf '%s'` (not `echo`) to avoid trailing-newline injection. If the body variable contains a trailing newline, `printf '%s'` preserves it faithfully.
- `$BODY` in the `printf` call must be in double quotes to preserve the value as a single argument, but at that point it is passed to `printf` (not to a shell), so no further expansion risk.

**What this prevents**: backtick command substitution, `$VAR` expansion, double-quote termination, backslash escape consumption, newline argument splitting, `&` backgrounding.

---

### 3b. PowerShell 7+ — write body to temp file, pass `--body-file`

```powershell
# Step 1: write body to a temp file using [IO.File]::WriteAllText for binary-clean output
$bodyFile = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($bodyFile, $BODY, [System.Text.Encoding]::UTF8)

# Step 2: pass --body-file to gh
gh pr comment $prNumber --body-file $bodyFile

# OR for gh api with --field body=@<path>:
gh api --method POST "repos/$owner/$repo/pulls/$prNumber/comments" `
  --field "commit_id=$commitSha" `
  --field "path=$filePath" `
  --field "line=$lineNumber" `
  --field "side=$side" `
  --field "body=@$bodyFile"

# Cleanup
Remove-Item $bodyFile -Force
```

**Key rules**:
- `[System.IO.File]::WriteAllText($bodyFile, $BODY, UTF8)` — bypasses all PowerShell string interpretation; writes the variable's value byte-for-byte.
- `--field "body=@$bodyFile"` — the `@` prefix on the `gh api` side reads from disk; the PowerShell side only expands `$bodyFile` (a file path), never the body content.
- Never use `--field "body=$BODY"` or `--field "body=`"$BODY`""` — PowerShell backtick is the escape character and dollar sign triggers variable expansion even inside a double-quoted string.
- Do NOT use a PowerShell here-string `@"..."@` to pass the body inline — it still goes through argument binding and can be mangled by the argument parser or `NativeCommandArgumentPassing` on Windows.
- `[IO.File]::WriteAllText` with explicit UTF-8 encoding ensures non-ASCII characters (em-dash, Unicode arrows, etc.) survive intact.

---

## 4. Migration Plan (No Edits Applied — Description Only)

### Priority order: highest severity first.

#### 4a. `instructions.uncompressed.md` (Step 4 dedup + Step 5 POST)

Minimal diff:
1. **Before Step 5**, add a "Write body to temp file" sub-step using the bash or PowerShell pattern from Section 3.
2. Replace `--field body="{BODY}"` with `--field body=@"$BODY_FILE"` (bash) or `--field "body=@$bodyFile"` (PowerShell).
3. Add cleanup after the `gh api` call.
4. Optionally add a note: "BODY may contain any markdown including backticks, code fences, dollar signs, and quotes — the temp-file route is mandatory for correct delivery."

No other structural changes needed. Step order (fetch SHA → verify file → verify line → dedup → POST) remains unchanged.

#### 4b. `gh-cli-pr-inline-comment-edit/SKILL.md` and `uncompressed.md`

Replace:
```bash
gh api --method PATCH repos/{OWNER}/{REPO}/pulls/comments/{COMMENT_ID} \
  --field body="{BODY}"
```

With the temp-file pattern (bash) or `[IO.File]::WriteAllText` + `--field "body=@$bodyFile"` (PowerShell). Remove the vague note "Large content edits may require JSON body escaping" — it is no longer needed once the temp-file pattern is canonical.

#### 4c. `gh-cli-pr-comments/SKILL.md` and `uncompressed.md`

Two replacements:
1. `gh pr comment 123 --body "text"` → `gh pr comment 123 --body-file "$BODY_FILE"` (after writing body to temp file).
2. `--field body="updated text"` → `--field body=@"$BODY_FILE"`.

Also fix leading-slash paths (`/repos/{owner}/...` → `repos/{owner}/...`) as a co-located non-escaping bug affecting Windows Git Bash — this is already documented in spec but not fixed in the command examples.

#### 4d. `gh-cli-pr-review/SKILL.md` and `uncompressed.md`

`gh pr review` does not accept `--body-file`. The canonical pattern here is: write the body to a temp file and use process substitution in bash (`--body "$(cat "$BODY_FILE")"` with `set +e` and caution) — but this re-introduces shell expansion.

Better: use `gh api` directly to submit the review body instead of `gh pr review --body`. However, if the SKILL is constrained to `gh pr review`, the safest approach is:
```bash
gh pr review {PR_NUMBER} --approve --body-file "$BODY_FILE"
```
`gh pr review` DOES accept `--body-file` (check: `gh pr review --help`). If confirmed, the migration is identical to 4c. If `--body-file` is unavailable on the installed `gh` version, the fallback is to write the body to a JSON-encoded temp payload and use `gh api`.

#### 4e. `gh-cli-pr-create/SKILL.md` and `uncompressed.md`

Replace the example:
```bash
gh pr create --title "title" --body "body" --base main
```
With:
```bash
gh pr create --title "title" --body-file "$BODY_FILE" --base main
```
`gh pr create` accepts `--body-file`; this is already noted in the skill as an option. Elevate it from "option" to "required pattern when BODY contains arbitrary content."

#### 4f. `gh-cli-issues/SKILL.md` and `uncompressed.md`

Replace:
```bash
gh issue create --title "title" --body "body"
gh issue comment 123 --body "text"
gh api --method PATCH ... --field body="updated"
```
With temp-file variants. `gh issue create` and `gh issue comment` both accept `--body-file`. The `gh api --field body=@"$file"` pattern handles the PATCH case.

---

## 5. Reproducible Failure Cases

These inputs will trip current scripts as written (substitution into `--field body="{BODY}"` or `--body "text"`). Do not run them against live repos — they are presented for static identification only.

**Case 1 — Backtick inline code (bash)**
```
Use `git commit -m "msg"` to commit.
```
In bash, the backtick triggers command substitution: `` `git commit -m "msg"` `` is executed as a subshell command. Output of that command is spliced into the body argument, and the actual text is destroyed.

**Case 2 — Dollar-sign variable reference (bash and PowerShell)**
```
Set $HOME to your home directory. Check $PATH for issues.
```
In bash double-quoting, `$HOME` and `$PATH` expand to actual values (e.g., `/root`, `/usr/local/bin:...`). In PowerShell, same: `$HOME` becomes the PS home variable value. The comment body sent to GitHub will contain the expanded value, not the literal `$HOME`.

**Case 3 — Code fence with shell command (bash)**
```
Run:
```bash
curl -s https://api.github.com | jq '.rate_limit'
```
```
The triple-backtick fences cause bash to attempt subshell substitution and the pipe character `|` is interpreted as a shell pipe operator. The `gh api` command may crash or execute `jq` as a side-effecting process.

**Case 4 — Double quotes inside body (bash and PowerShell)**
```
He said "this is fine" but it's not.
```
The double quote in `"this is fine"` terminates the outer shell argument string. The rest of the body (`but it's not.`) is parsed as a new shell token. Depending on the shell, this is either a parse error or a command-not-found error. The body is silently truncated or the command fails entirely.

**Case 5 — Multiline body with embedded newlines (PowerShell)**
```
Line one.

Line two with `backtick`.
```
PowerShell's argument parsing on multiline string values passed to native executables (like `gh`) via `--field body="..."` is governed by `$PSNativeCommandArgumentPassing`. On Windows with PS7 the default (`Standard` mode) wraps arguments with quotes but may split on embedded newlines or produce extra quoting. The `backtick` in line two is treated as a PS escape sequence and the character after it may be consumed. Result: the body arrives as a single mangled line or fails.

---

## 6. Operator-Facing Summary

- **Root cause**: Every comment/body-posting command in this skill family substitutes the body text inline as a shell argument (`--body "..."` or `--field body="..."`). Neither bash nor PowerShell treats double-quoted string arguments as raw bytes — both expand backticks, dollar signs, and double quotes, corrupting any markdown that contains them.
- **What breaks**: Any body containing backtick code spans (`` `foo` ``), code fences (` ``` `), `$VAR`-style references, embedded double quotes, or multiline content with certain characters will arrive at GitHub mangled, truncated, or cause the `gh` command to fail with a parse error.
- **Fix path**: Write the body to a temp file first, then pass `--body-file <path>` (for `gh pr comment`, `gh issue comment`, `gh pr create`, `gh pr review`) or `--field body=@<path>` (for `gh api`). The file route bypasses all shell expansion; `gh` reads it byte-for-byte.
- **Scope**: The two `verify-line-in-diff` helper scripts (`.sh` / `.ps1`) are clean — they never post comment bodies and are not affected.
- **Migration size**: 6 markdown instruction/skill files need targeted edits — each edit is small (add a temp-file write step, swap `--body "..."` for `--body-file`, swap `--field body="..."` for `--field body=@<file>`); no structural changes to the skill architecture required.
