# Claude Code Marketplace Packaging Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Repackage the `electrified-cortex/skills` repo as an internal Claude Code plugin marketplace without breaking the repo's existing platform-agnostic layout beyond the unavoidable path shift.

**Architecture:** Single-bundle plugin served from the existing GitHub repo. The 15 skill directories move into a top-level `skills/` subfolder to match Claude Code's plugin loader expectation. Two dispatch agent files are promoted to a top-level `agents/` folder and renamed from `*.agent.md` to `*.md`. A `.claude-plugin/` folder containing `marketplace.json` and `plugin.json` is added at the repo root.

**Tech Stack:** Claude Code plugin format (JSON manifests), git, PowerShell / Bash for scripted verification, existing `skill-index-building` dispatch skill for index rebuild, existing `hash-stamp` skill for stamp audit.

**Reference spec:** `docs/claude-code-marketplace.md`

**Verification toolchain note:** This repo has no test runner, no CI, no package scripts. Verification is performed by (a) running JSON validation, (b) invoking `claude plugin marketplace add` against a local clone, (c) invoking the repo's own dispatch skills (`skill-index-building`, `hash-stamp`), and (d) inspecting file listings. Each task's "run" command is either a shell command or a well-formed dispatch prompt.

---

## File Structure

Files created:
- `.claude-plugin/marketplace.json` — marketplace manifest consumed by `claude plugin marketplace add`.
- `.claude-plugin/plugin.json` — plugin manifest consumed by Claude Code's plugin loader.
- `agents/claude-dispatch.md` — promoted from `skills/dispatch/agents/claude-dispatch.agent.md`.
- `agents/vscode-dispatch.md` — promoted from `skills/dispatch/agents/vscode-dispatch.agent.md`.

Files moved (via `git mv`, 15 skill directories):
- `audit-reporting/` → `skills/audit-reporting/`
- `code-review/` → `skills/code-review/`
- `compression/` → `skills/compression/`
- `dispatch/` → `skills/dispatch/`
- `gh-cli/` → `skills/gh-cli/`
- `hash-stamp/` → `skills/hash-stamp/`
- `markdown-hygiene/` → `skills/markdown-hygiene/`
- `session-logging/` → `skills/session-logging/`
- `skill-auditing/` → `skills/skill-auditing/`
- `skill-index/` → `skills/skill-index/`
- `skill-writing/` → `skills/skill-writing/`
- `spec-auditing/` → `skills/spec-auditing/`
- `spec-writing/` → `skills/spec-writing/`
- `tool-auditing/` → `skills/tool-auditing/`
- `tool-writing/` → `skills/tool-writing/`

Files modified:
- `README.md` — skill/agent table links updated, new "Install as a Claude Code plugin" section.
- `skills/dispatch/SKILL.md` — update agent-file reference on line 92.
- `skills/dispatch/uncompressed.md` — update agent-file references.
- `skills/dispatch/spec.md` — update agent-file references.
- `skills/dispatch/installation.md` — update agent-file references.
- `skills/dispatch/agents/README.md` — update self-references after move/rename (this file remains in place to explain the legacy location).
- `skill.index`, `skill.index.md`, `skill.index.sha256` — rebuilt against new tree (builder + auditor handle this).
- All `.sha256` companion files for edited markdown — restamped via `hash-stamp` skill.

Files deleted:
- `skills/dispatch/agents/claude-dispatch.agent.md` — moved to `agents/claude-dispatch.md`.
- `skills/dispatch/agents/vscode-dispatch.agent.md` — moved to `agents/vscode-dispatch.md`.

---

## Task 1: Restructure — move 15 skill directories into `skills/`

**Files:**
- Move: 15 top-level skill directories listed above into `skills/`.

- [ ] **Step 1: Create the `skills/` directory (empty, so git tracks the move cleanly)**

```bash
mkdir -p skills
```

- [ ] **Step 2: Move every skill directory with `git mv`**

```bash
git mv audit-reporting skills/audit-reporting
git mv code-review skills/code-review
git mv compression skills/compression
git mv dispatch skills/dispatch
git mv gh-cli skills/gh-cli
git mv hash-stamp skills/hash-stamp
git mv markdown-hygiene skills/markdown-hygiene
git mv session-logging skills/session-logging
git mv skill-auditing skills/skill-auditing
git mv skill-index skills/skill-index
git mv skill-writing skills/skill-writing
git mv spec-auditing skills/spec-auditing
git mv spec-writing skills/spec-writing
git mv tool-auditing skills/tool-auditing
git mv tool-writing skills/tool-writing
```

- [ ] **Step 3: Verify the tree**

Run:
```bash
ls skills/
git status
```

Expected: `ls skills/` lists all 15 directory names. `git status` shows 15 renamed directories (as R100 entries) and no untracked files from the skill tree.

- [ ] **Step 4: Commit**

```bash
git add -A skills/
git commit -m "refactor: move 15 skill directories into skills/ subtree

Prepares the repo for Claude Code plugin packaging. Claude Code's
plugin loader expects skills at skills/<name>/SKILL.md. File contents
and companion .sha256 stamps are unchanged by the move.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: Promote and rename the two dispatch agents

**Files:**
- Create: `agents/claude-dispatch.md` (from `skills/dispatch/agents/claude-dispatch.agent.md`)
- Create: `agents/vscode-dispatch.md` (from `skills/dispatch/agents/vscode-dispatch.agent.md`)
- Delete: the two files in their old location

- [ ] **Step 1: Create the `agents/` directory**

```bash
mkdir -p agents
```

- [ ] **Step 2: Move and rename both agent files**

```bash
git mv skills/dispatch/agents/claude-dispatch.agent.md agents/claude-dispatch.md
git mv skills/dispatch/agents/vscode-dispatch.agent.md agents/vscode-dispatch.md
```

- [ ] **Step 3: Verify**

Run:
```bash
ls agents/
ls skills/dispatch/agents/
```

Expected: `ls agents/` shows `claude-dispatch.md` and `vscode-dispatch.md`. `ls skills/dispatch/agents/` shows only `README.md` (the explanatory file stays).

- [ ] **Step 4: Commit**

```bash
git add -A agents/ skills/dispatch/agents/
git commit -m "refactor: promote dispatch agents to top-level agents/

Claude Code discovers subagent types from <plugin-root>/agents/*.md.
The two dispatch agent definitions move from skills/dispatch/agents/
and drop the .agent suffix to match Claude Code's naming. The legacy
README.md stays in place and will be updated in the next commit.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: Update cross-references inside the dispatch skill

**Files:**
- Modify: `skills/dispatch/SKILL.md` (line 92 reference to `dispatch/agents/`)
- Modify: `skills/dispatch/uncompressed.md` (all agent-file references)
- Modify: `skills/dispatch/spec.md` (all agent-file references)
- Modify: `skills/dispatch/installation.md` (all agent-file references)
- Modify: `skills/dispatch/agents/README.md` (self-reference — explain where the files moved)

- [ ] **Step 1: Grep for every remaining reference to the old agent paths**

Run:
```bash
grep -rn "dispatch/agents/\|\.agent\.md" skills/dispatch/
```

Expected: a list of lines inside the five files above referencing `dispatch/agents/claude-dispatch.agent.md`, `dispatch/agents/vscode-dispatch.agent.md`, or bare `dispatch/agents/`. No hits outside `skills/dispatch/`.

- [ ] **Step 2: Update `skills/dispatch/SKILL.md`**

Change line 92 (and any other matching line):

From:
```
- Agent files: `dispatch/agents/` — ready-to-install Dispatch agent definitions for Claude Code CLI and VS Code.
```

To:
```
- Agent files: `agents/claude-dispatch.md` and `agents/vscode-dispatch.md` at the repo root — ready-to-install Dispatch agent definitions for Claude Code CLI and VS Code.
```

- [ ] **Step 3: Update `skills/dispatch/installation.md`**

Replace every occurrence of `dispatch/agents/claude-dispatch.agent.md` with `agents/claude-dispatch.md`. Same for the VS Code variant. Keep the rest of the prose intact.

- [ ] **Step 4: Update `skills/dispatch/uncompressed.md` and `skills/dispatch/spec.md`**

Apply the same replacements (`dispatch/agents/*.agent.md` → `agents/*.md` at repo root) in both files.

- [ ] **Step 5: Replace `skills/dispatch/agents/README.md` with a pointer**

Overwrite its contents with:

```markdown
# Dispatch agent files (moved)

The dispatch agent definitions moved to `/agents/` at the repo root to
match Claude Code's plugin loader convention (`<plugin-root>/agents/*.md`).

- `agents/claude-dispatch.md` — Claude Code CLI
- `agents/vscode-dispatch.md` — VS Code (GitHub Copilot)

See `skills/dispatch/installation.md` for install steps.
```

- [ ] **Step 6: Re-run the grep to confirm no stale references remain**

Run:
```bash
grep -rn "dispatch/agents/claude-dispatch\.agent\.md\|dispatch/agents/vscode-dispatch\.agent\.md" skills/ agents/ README.md
```

Expected: zero hits.

- [ ] **Step 7: Commit**

```bash
git add skills/dispatch/
git commit -m "refactor: update dispatch skill refs to new agent paths

SKILL.md, spec.md, uncompressed.md, installation.md, and the legacy
agents/README.md all point at the new /agents/claude-dispatch.md and
/agents/vscode-dispatch.md locations.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: Update the root `README.md`

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Update the skill table links (lines 13–24)**

Replace every table row href from `[name](name/)` to `[name](skills/name/)`. Example:

From:
```markdown
| [code-reviewer](code-reviewer/) | Two-tier code review — fast-cheap smoke pass, standard substantive sign-off; reviews only, never modifies |
```

To:
```markdown
| [code-reviewer](skills/code-review/) | Two-tier code review — fast-cheap smoke pass, standard substantive sign-off; reviews only, never modifies |
```

Apply the same transformation to every row in the skill table. Keep display labels unchanged except where the display label already mismatches the folder name (e.g., `code-reviewer` shown as the label but the folder is `code-review`) — in those cases, leave the display label alone and only fix the href.

- [ ] **Step 2: Update the agents table (lines 27–29)**

From:
```markdown
| [claude-dispatch](dispatch/agents/claude-dispatch.agent.md) | Minimal pass-through agent for Claude Code CLI — reads a target file, follows its instructions, returns the result |
| [vscode-dispatch](dispatch/agents/vscode-dispatch.agent.md) | Minimal pass-through agent for Claude Code in VS Code — same behavior, VS Code tool names |
```

To:
```markdown
| [claude-dispatch](agents/claude-dispatch.md) | Minimal pass-through agent for Claude Code CLI — reads a target file, follows its instructions, returns the result |
| [vscode-dispatch](agents/vscode-dispatch.md) | Minimal pass-through agent for Claude Code in VS Code — same behavior, VS Code tool names |
```

- [ ] **Step 3: Add a new "Install as a Claude Code plugin" section**

Insert this section immediately after the "Quick Start" section (after line ~36):

````markdown
## Install as a Claude Code plugin

This repo is also a Claude Code plugin marketplace. Internal teammates with
read access to `github.com/electrified-cortex/skills` can install the whole
bundle in two commands:

```bash
claude plugin marketplace add electrified-cortex/skills
claude plugin install electrified-cortex@electrified-cortex
```

Pull updates later with:

```bash
claude plugin marketplace update electrified-cortex
```

After install, Claude Code auto-registers all 15 skills under the
`electrified-cortex:` namespace and both dispatch agents as selectable
subagent types. Requires Claude Code with plugin marketplace support.
````

- [ ] **Step 4: Verify the README still renders**

Run a local preview if one is available, or just eyeball:
```bash
head -50 README.md
```

Expected: the section structure is intact, no unmatched backticks or broken table rows.

- [ ] **Step 5: Commit**

```bash
git add README.md
git commit -m "docs: update README for skills/ restructure and plugin install

Table links repointed to the new skills/ and agents/ paths. Adds an
\"Install as a Claude Code plugin\" section with the two-command install
flow for internal teammates.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: Create the marketplace and plugin manifests

**Files:**
- Create: `.claude-plugin/marketplace.json`
- Create: `.claude-plugin/plugin.json`

- [ ] **Step 1: Create `.claude-plugin/` directory**

```bash
mkdir -p .claude-plugin
```

- [ ] **Step 2: Create `.claude-plugin/marketplace.json`**

Exact contents:

```json
{
  "name": "electrified-cortex",
  "owner": {
    "name": "Electrified Cortex",
    "url": "https://github.com/electrified-cortex"
  },
  "plugins": [
    {
      "name": "electrified-cortex",
      "source": "./",
      "description": "Human-curated skills for workspace automation, QA, and token efficiency — skills, agents, and companion specs bundled as one plugin.",
      "version": "0.1.0",
      "category": "productivity",
      "tags": ["skills", "agents", "audit", "compression", "gh-cli"]
    }
  ]
}
```

- [ ] **Step 3: Create `.claude-plugin/plugin.json`**

Exact contents:

```json
{
  "name": "electrified-cortex",
  "version": "0.1.0",
  "description": "Human-curated skills for workspace automation, QA, and token efficiency. Bundles 15 skills (authoring, auditing, compression, dispatch, gh-cli, indexing) plus dispatch agents.",
  "author": {
    "name": "Electrified Cortex",
    "url": "https://github.com/electrified-cortex/skills"
  },
  "homepage": "https://github.com/electrified-cortex/skills",
  "license": "MIT",
  "keywords": ["skills", "agent-skills", "audit", "compression", "dispatch", "gh-cli", "markdown-hygiene", "spec-writing"]
}
```

- [ ] **Step 4: Validate both JSON files parse**

Run (PowerShell):
```powershell
Get-Content .claude-plugin/marketplace.json | ConvertFrom-Json | Out-Null; Write-Host "marketplace.json OK"
Get-Content .claude-plugin/plugin.json | ConvertFrom-Json | Out-Null; Write-Host "plugin.json OK"
```

Or (Bash with python available):
```bash
python -c "import json; json.load(open('.claude-plugin/marketplace.json')); print('marketplace.json OK')"
python -c "import json; json.load(open('.claude-plugin/plugin.json')); print('plugin.json OK')"
```

Expected: two lines, both ending `OK`. Non-zero exit = invalid JSON → fix and re-run.

- [ ] **Step 5: Commit**

```bash
git add .claude-plugin/
git commit -m "feat: add Claude Code plugin marketplace manifests (v0.1.0)

.claude-plugin/marketplace.json declares the single-bundle
electrified-cortex plugin. .claude-plugin/plugin.json names the
plugin for Claude Code's loader. Skills and agents are auto-discovered
from skills/ and agents/ — no explicit enumeration needed.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 6: Rebuild the skill-index cascade against the new tree

**Files:**
- Regenerate: all `skill.index` and `skill.index.md` files at every indexed directory.
- Restamp: all `skill.index.sha256` files via the auditor after PASS.

Context: the root `skill.index` and `skill.index.md` currently enumerate the 15 skills as direct children. After Task 1, they live under `skills/`, so the root index is stale. The `skill-index-building` dispatch skill accepts `root=<path>` and walks downward, so a single invocation at the repo root regenerates the whole cascade.

- [ ] **Step 1: Invoke `skill-index-building` via Dispatch agent, full rebuild**

Run:
```
Dispatch agent (zero context), fast-cheap tier:
"Read and follow `skills/skill-index/skill-index-building/instructions.txt`.
Input: root=<absolute-path-to-repo-root> --rebuild"
```

Replace `<absolute-path-to-repo-root>` with the real absolute path (e.g., `G:/Git/skills` or `/c/Users/.../skills` in bash form).

Expected: change manifest listing created/updated nodes at repo root, at `skills/`, and at each skill subdir that has indexable children (e.g., `skills/gh-cli/`, `skills/skill-index/`, `skills/skill-writing/`). No `blocked` entries. No `broken-shortcut` entries that weren't already broken before the move.

- [ ] **Step 2: Inspect the new root `skill.index`**

```bash
cat skill.index
cat skill.index.md
```

Expected: root `skill.index` contains a single entry `skills/` (trailing slash = sub-node marker). `skills/skill.index` contains 15 entries (one per skill subdir), each with the sub-node marker if the skill has its own `skill.index`. Leaf skills (no nested structure) appear without the trailing slash.

- [ ] **Step 3: Run the auditor to validate and stamp**

```
Dispatch agent (zero context), fast-cheap tier:
"Read and follow `skills/skill-index/skill-index-auditing/instructions.txt`.
Input: root=<absolute-path-to-repo-root>"
```

Expected: PASS verdict. `.sha256` stamps written at every indexed node. No structural violations.

- [ ] **Step 4: Spot-check one nested node**

```bash
cat skills/skill-index/skill.index
cat skills/skill-index/skill.index.sha256
```

Expected: both files present. The `.sha256` content is 64 hex chars plus a newline.

- [ ] **Step 5: Commit**

```bash
git add skill.index skill.index.md skill.index.sha256 skills/
git commit -m "chore: rebuild skill-index cascade after restructure

Full rebuild via skill-index-building --rebuild, then auditor PASS and
stamp across the whole tree. Root index now references skills/ as a
sub-node; the 15 skill entries live in skills/skill.index.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 7: Sweep for stale cross-skill path references

**Files:**
- Potentially modify: any `SKILL.md`, `spec.md`, or `uncompressed.md` inside `skills/` that references another skill by a root-relative path.

Context: some skills cross-reference each other (e.g., `skill-writing` mentions `skill-auditing`, `markdown-hygiene` is called from multiple places). If any cross-reference uses a root-relative path like `code-review/` or `markdown-hygiene/SKILL.md`, it breaks after the move. Relative sibling references (`../markdown-hygiene/`) keep working if both skills are still siblings.

- [ ] **Step 1: Grep for top-level skill-name path references inside markdown files**

Run:
```bash
grep -rnE '\]\((audit-reporting|code-review|compression|dispatch|gh-cli|hash-stamp|markdown-hygiene|session-logging|skill-auditing|skill-index|skill-writing|spec-auditing|spec-writing|tool-auditing|tool-writing)/' skills/
```

Expected: a list of files and lines that need fixing, OR no output (no matches). Each hit is a link like `[foo](code-review/SKILL.md)` that will break.

- [ ] **Step 2: For each hit, decide the right replacement**

Two cases:

1. **Sibling skills referencing each other from inside `skills/`** — relative path works: `[foo](../code-review/SKILL.md)`. Prefer this form because it's robust against the whole `skills/` tree moving.
2. **Root-relative references that need to survive a cascade rebuild** — prefix with `skills/`: `[foo](skills/code-review/SKILL.md)`.

Default: use option 1 (sibling relative) for references inside `skills/`.

- [ ] **Step 3: Apply the fixes**

For each hit, edit the file to use the correct relative/root form. Keep a running list of files touched.

- [ ] **Step 4: Re-run the grep to confirm it returns no hits**

```bash
grep -rnE '\]\((audit-reporting|code-review|compression|dispatch|gh-cli|hash-stamp|markdown-hygiene|session-logging|skill-auditing|skill-index|skill-writing|spec-auditing|spec-writing|tool-auditing|tool-writing)/' skills/
```

Expected: zero output.

- [ ] **Step 5: Restamp any `.sha256` companions for the edited `.md` files**

For each `foo.md` edited in Step 3, its companion `foo.md.sha256` is now stale. Invoke the `hash-stamp` stamper.

Run:
```
Dispatch agent (zero context), fast-cheap tier:
"Read and follow the stamper instructions at skills/hash-stamp/<stamper-subskill>/instructions.txt
(or the appropriate tool entry point per skills/hash-stamp/SKILL.md).
Input: the list of files edited in Task 7 Step 3."
```

Or invoke the stamper CLI directly per `skills/hash-stamp/SKILL.md`. Expected: new SHA-256 values written for each edited file. No other stamps touched.

- [ ] **Step 6: Commit (skip if grep found nothing in Step 1)**

```bash
git add skills/
git commit -m "fix: repoint cross-skill references after skills/ move

Updates root-relative links inside SKILL.md/spec.md files to sibling-
relative form so they survive the restructure. Restamps affected
.sha256 companions.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 8: End-to-end verification

No code changes in this task — only checks against success criteria from the spec.

- [ ] **Step 1: Verify `claude plugin marketplace add` accepts the local clone**

Run (from a scratch shell, pointing at the local worktree, not the remote):
```bash
claude plugin marketplace add <absolute-path-to-worktree>
```

Expected: the command succeeds. `claude plugin marketplace list` shows `electrified-cortex` as an available marketplace.

If it fails: the error message identifies which manifest is malformed. Fix, re-run Task 5 Step 4 JSON validation, and retry this step.

- [ ] **Step 2: Install the plugin and verify skills are discoverable**

Run:
```bash
claude plugin install electrified-cortex@electrified-cortex
```

Then inside Claude Code:
```
/plugin
```

Expected: the `electrified-cortex` plugin is listed as installed. Skills show up under the `electrified-cortex:` namespace — at minimum confirm these five are present:
- `electrified-cortex:code-review`
- `electrified-cortex:markdown-hygiene`
- `electrified-cortex:compression`
- `electrified-cortex:skill-writing`
- `electrified-cortex:dispatch`

Spot-check a sixth by name to confirm the full 15 loaded (pick any from the skill table in the README).

- [ ] **Step 3: Verify both dispatch agents registered as subagent types**

Inside Claude Code, run:
```
/agents
```

(Or whichever command lists subagent types in the current Claude Code version — the check is "are `claude-dispatch` and `vscode-dispatch` present as selectable subagent types under the electrified-cortex plugin".)

Expected: both agent names listed. Filenames in the plugin cache directory show as `claude-dispatch.md` and `vscode-dispatch.md`.

- [ ] **Step 4: Smoke-test the `markdown-hygiene` skill end-to-end**

Create a known-dirty fixture:
```bash
mkdir -p /tmp/mh-smoke
cat > /tmp/mh-smoke/dirty.md <<'EOF'
# Title

Some text

-  item with extra space
-item with no space
EOF
```

Inside Claude Code:
```
Invoke electrified-cortex:markdown-hygiene on /tmp/mh-smoke/dirty.md
```

Expected: the skill runs successfully, either fixes the file in place or reports a side-file per its behavior, and returns `CLEAN`, `FIXED`, or `PARTIAL` as documented. No "file not found" or "skill not loaded" errors. File resolution works inside the plugin's sandbox.

- [ ] **Step 5: Hash-stamp audit across the moved tree**

Run:
```
Dispatch agent (zero context), fast-cheap tier:
"Read and follow `skills/hash-stamp/<auditor-subskill>/instructions.txt`
(see skills/hash-stamp/SKILL.md for the auditor entry point).
Input: root=<absolute-path-to-repo-root>"
```

Expected: zero drift reported. Every `.sha256` file matches the hash of its companion. If drift exists, it is scoped to files edited in Tasks 3, 4, and 7 and should have been restamped — investigate and restamp any misses.

- [ ] **Step 6: Final commit if any stamp misses surfaced**

```bash
git add -A
git commit -m "chore: restamp stragglers found by final hash-stamp audit

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

Skip this step if Step 5 reported zero drift and nothing needs committing.

- [ ] **Step 7: Push the branch and open a PR**

```bash
git push -u origin HEAD
gh pr create --title "feat: package electrified-cortex as a Claude Code marketplace (v0.1.0)" --body "$(cat <<'EOF'
## Summary
- Restructure: 15 skills moved into `skills/`, two dispatch agents promoted to `agents/`
- New `.claude-plugin/marketplace.json` and `.claude-plugin/plugin.json` (v0.1.0)
- README updated with install instructions for internal teammates
- skill-index cascade rebuilt against new tree; hash-stamp audit PASS

## Design
See `docs/claude-code-marketplace.md`.

## Test plan
- [ ] `claude plugin marketplace add` against local clone succeeds
- [ ] `claude plugin install electrified-cortex@electrified-cortex` succeeds
- [ ] All 15 skills discoverable under `electrified-cortex:` namespace
- [ ] Both dispatch agents registered as subagent types
- [ ] Smoke test of `electrified-cortex:markdown-hygiene` end-to-end
- [ ] `hash-stamp` audit returns zero drift
EOF
)"
```

Expected: PR created. Include the URL in the summary back to the user.

---

## Self-Review

Placeholder scan: no TBD/TODO/vague language. Every step has either a concrete command, exact file path, or literal content.

Type consistency: `electrified-cortex` is the consistent name in both manifests and the install incantation. File paths use forward slashes throughout (Git Bash compatible on Windows). Agent filenames are consistently `claude-dispatch.md` / `vscode-dispatch.md` after Task 2.

Spec coverage check — mapping spec sections to tasks:

- Spec §"Granularity: single plugin" → Task 5 (single plugin entry in marketplace.json).
- Spec §"Distribution: existing GitHub repo" → Task 5 (`"source": "./"`) + Task 4 (install instructions in README).
- Spec §"Repo layout: restructure" → Task 1.
- Spec §"Target layout" → Tasks 1, 2, 5 collectively produce the tree.
- Spec §"Marketplace manifest" → Task 5 Step 2.
- Spec §"Plugin manifest" → Task 5 Step 3.
- Spec §"Migration plan" steps 1–6 → Tasks 1, 2, 5, 6, 4, 7 respectively.
- Spec §"Install instructions" → Task 4 Step 3.
- Spec §"Verification" criteria 1–5 → Task 8 Steps 1–5.
- Spec §"Risks and mitigations" → addressed in Task 3 (cross-references) and Task 7 (sweep). `skill-index` builder risk is moot — builder already accepts `root` parameter.

No gaps.
