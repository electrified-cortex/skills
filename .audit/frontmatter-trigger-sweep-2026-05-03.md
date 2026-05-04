# Frontmatter Trigger Sweep — 2026-05-03

Sweep of `electrified-cortex/skills/` for shy descriptions and missing `triggers:` fields.

## Summary

| Classification | Count |
|---|---|
| green | 1 |
| shy | 0 |
| missing-triggers | 20 |
| both | 30 |
| **Total** | **51** |

## Per-Skill Results

### 🟢 Green (description + triggers: both present and adequate)

| Skill | Notes |
|---|---|
| `skill-writing` | 6 use-when phrases in description; `triggers:` list matches |

### 🟡 Shy description (topic statement, no trigger phrases)

No skills are shy-only (all shy skills also lack `triggers:`, so they appear in the Both section).

### 🔴 Missing triggers: field

Skills with adequate trigger phrases in description but no `triggers:` YAML field.

| Skill | Has description triggers? | Proposed triggers: block |
|---|---|---|
| `code-review` | yes — "security, correctness, code-quality, change-review, architectural-risk" | `triggers:\n  - security review\n  - correctness check\n  - code quality review\n  - change review\n  - architectural risk` |
| `compression` | yes — "compress this file, reduce tokens, shrink instructions, caveman compress, ultra/full/lite compress" | `triggers:\n  - compress this file\n  - reduce tokens\n  - shrink instructions\n  - caveman compress\n  - ultra compress\n  - full compress\n  - lite compress` |
| `dispatch` | yes — "dispatch, sub-agent, isolated scope, background, background execution, background task, background agent" | `triggers:\n  - dispatch\n  - sub-agent\n  - isolated scope\n  - background execution\n  - background task\n  - background agent` |
| `dispatch-setup` | yes — "dispatch setup, configure dispatch, runSubagent not working, agent not found, VS Code dispatch, Cursor dispatch setup" | `triggers:\n  - dispatch setup\n  - configure dispatch\n  - runSubagent not working\n  - agent not found\n  - VS Code dispatch\n  - Cursor dispatch setup` |
| `hash-record-check` | yes — "cache check hash-record, check hash-record hit or miss, hash-record cache probe, skip if cached, cache-first lookup, check hash cache before running operation" | `triggers:\n  - cache check hash-record\n  - check hash-record hit or miss\n  - hash-record cache probe\n  - skip if cached\n  - cache-first lookup\n  - check hash cache before running operation` |
| `hash-record-index` | yes — "index hash records, refresh hash-record manifest, build manifest.yaml, hash-record-index, accelerate prune" | `triggers:\n  - index hash records\n  - refresh hash-record manifest\n  - build manifest.yaml\n  - hash-record-index\n  - accelerate prune` |
| `hash-record-manifest` | yes — "compute manifest hash, multi-file cache key, hash-record manifest, manifest hash, bundle file hashes, cache key for directory" | `triggers:\n  - compute manifest hash\n  - multi-file cache key\n  - hash-record manifest\n  - bundle file hashes\n  - cache key for directory` |
| `hash-record-prune` | yes — "prune hash records, clean up hash-record, remove orphaned records, hash-record maintenance, reclaim disk" | `triggers:\n  - prune hash records\n  - clean up hash-record\n  - remove orphaned records\n  - hash-record maintenance\n  - reclaim disk` |
| `hash-record-rekey` | yes — "rekey hash-record, move stale hash record, update hash record after lint, refresh hash-record key, phase 4A rekey, hash-record-rekey" | `triggers:\n  - rekey hash-record\n  - move stale hash record\n  - update hash record after lint\n  - refresh hash-record key\n  - hash-record-rekey` |
| `hash-stamping` | yes — "verify stamp, check integrity, detect drift, update sha256, stamp this file, hash mismatch" | `triggers:\n  - verify stamp\n  - check integrity\n  - detect drift\n  - update sha256\n  - stamp this file\n  - hash mismatch` |
| `hash-stamp-audit` | yes — "stamp verification, hash mismatch detection, companion file audit, stamp drift check, integrity check, sha256 validation" | `triggers:\n  - stamp verification\n  - hash mismatch detection\n  - companion file audit\n  - stamp drift check\n  - integrity check\n  - sha256 validation` |
| `janitor` | yes — 6 comma-separated scenarios in description | `triggers:\n  - prune accumulated artifacts\n  - session-log hygiene\n  - audit-report sweep\n  - handoff cleanup\n  - dry-run delete preview\n  - operator-invoked maintenance` |
| `markdown-hygiene` | yes — "lint markdown, fix markdown, MD violations, markdownlint pass, hygiene check" | `triggers:\n  - lint markdown\n  - fix markdown\n  - MD violations\n  - markdownlint pass\n  - hygiene check` |
| `markdown-hygiene-analysis` | yes — "analysis phase, SA rules, semantic advisory, style advisories" | `triggers:\n  - analysis phase\n  - SA rules\n  - semantic advisory\n  - style advisories` |
| `markdown-hygiene-lint` | yes — "lint phase, MD violations, markdownlint scan" | `triggers:\n  - lint phase\n  - MD violations\n  - markdownlint scan` |
| `skill-auditing` | yes — "audit this skill, check skill quality, review skill compliance, validate skill structure, skill needs review, skill audit" | `triggers:\n  - audit this skill\n  - check skill quality\n  - review skill compliance\n  - validate skill structure\n  - skill needs review\n  - skill audit` |
| `skill-optimize` | yes — "optimize skill, skill review, architectural review, skill improvement, find skill issues, analyze skill structure" | `triggers:\n  - optimize skill\n  - skill review\n  - architectural review\n  - skill improvement\n  - find skill issues\n  - analyze skill structure` |
| `spec-auditing` | yes — "spec validation, requirements coverage, contradiction detection, document alignment, specification quality" | `triggers:\n  - spec validation\n  - requirements coverage\n  - contradiction detection\n  - document alignment\n  - specification quality` |
| `swarm` | yes — "swarm review, multi-reviewer, parallel personalities, run all reviewers, arbitrate findings" | `triggers:\n  - swarm review\n  - multi-reviewer\n  - parallel personalities\n  - run all reviewers\n  - arbitrate findings` |
| `tool-auditing` | yes — "audit tool, check tool script, review tool conventions, tool compliance, tool script audit" | `triggers:\n  - audit tool\n  - check tool script\n  - review tool conventions\n  - tool compliance\n  - tool script audit` |

### 🟠 Both (shy description + missing triggers:)

Skills with topic-statement descriptions AND no `triggers:` field.

| Skill | Current description | Proposed fix |
|---|---|---|
| `code-review-setup` | "Preflight readiness check — verify the host environment can run code-review. Inline. Returns structured ready / not-ready report with remediation." | See snippet below |
| `copilot-cli` | "Router — accepts any GitHub Copilot CLI task and dispatches to the correct operation sub-skill. Does not execute copilot commands itself." | See snippet below |
| `copilot-cli-ask` | "General query or advice operation via the standalone Copilot CLI binary. Returns Copilot's plain text answer." | See snippet below |
| `copilot-cli-explain` | "Explain operation via the standalone Copilot CLI binary. Returns an explanatory markdown description of a code region or file." | See snippet below |
| `copilot-cli-review` | "Code review operation via the standalone Copilot CLI binary. Runs adversarial review of a change set and returns structured findings." | See snippet below |
| `gh-cli` | "GitHub CLI operations — routes to domain-specific sub-skills via dispatch." | See snippet below |
| `gh-cli-actions` | "Trigger, monitor, manage GitHub Actions workflows, runs, secrets, variables via CLI." | See snippet below |
| `gh-cli-api` | "Make authenticated REST and GraphQL calls to the GitHub API via the CLI. Use when no dedicated gh subcommand covers the operation." | See snippet below |
| `gh-cli-issues` | "Manage GitHub issues using the gh issue subcommand. Full lifecycle: create, list, view, edit, comment, close, transfer." | See snippet below |
| `gh-cli-pr` | "Entry point for pull request management via the GitHub CLI. Handles common PR inspection and routes write operations to sub-skills." | See snippet below |
| `gh-cli-pr-comments` | "Add, edit, delete pull request comments via GitHub CLI." | See snippet below |
| `gh-cli-pr-create` | "Open pull request via GitHub CLI." | See snippet below |
| `gh-cli-pr-file-viewed` | "Mark or unmark one, multiple, or all files in a PR as viewed via GitHub GraphQL mutations. Handles node ID resolution and pagination for large PRs." | See snippet below |
| `gh-cli-pr-inline-comment` | "Post, edit, or delete inline code review comments on PR diff lines. Routes to sub-skills by operation." | See snippet below |
| `gh-cli-pr-inline-comment-delete` | "Delete an existing inline PR review comment by comment ID via GitHub CLI." | See snippet below |
| `gh-cli-pr-inline-comment-edit` | "Edit the body of an existing inline PR review comment by comment ID via GitHub CLI." | See snippet below |
| `gh-cli-pr-inline-comment-post` | "Post a single or multi-line inline review comment on a PR diff line via GitHub CLI. Handles SHA lookup, diff verification, deduplication, and POST." | See snippet below |
| `gh-cli-pr-merge` | "Merge, update, revert, close pull request via GitHub CLI." | See snippet below |
| `gh-cli-pr-review` | "Approve, request changes on, dismiss pull request review via GitHub CLI." | See snippet below |
| `gh-cli-projects` | "Create, manage GitHub Projects v2 boards, items, fields via CLI." | See snippet below |
| `gh-cli-releases` | "Manage GitHub releases via gh release. Full lifecycle: create, publish, upload assets, edit, delete." | See snippet below |
| `gh-cli-repos` | "Create, clone, fork, sync, edit, delete GitHub repositories via CLI." | See snippet below |
| `gh-cli-setup` | "Install, authenticate, and configure the GitHub CLI. Prerequisite for all other gh-cli skills." | See snippet below |
| `hash-record` | "Content-hash-keyed durable record store. Probe / Read / Write / Invalidate API. Replaces .audit-reports/ and .code-reviews/ with one substrate that consumer skills call into directly." | See snippet below |
| `hash-stamp` | "Writes or updates SHA-256 companion files alongside target files." | See snippet below |
| `iteration-safety` | "Rules for iterating audit, compression, hygiene, or review passes. Reference this skill from callers; do not embed these rules elsewhere." | See snippet below |
| `markdown-hygiene-result` | "Check cache state of a markdown-hygiene sub-document. Returns path and cache status for report, lint, or analysis." | See snippet below |
| `session-logging` | "Standards for creating session log entries in logs/session/ and logs/telegram/. Use when writing any log entry or summary during a workspace session." | See snippet below |
| `spec-writing` | "Write precise, testable, auditable specification documents with explicit scope, stable terminology, and enforceable requirements." | See snippet below |
| `tool-writing` | "Write tool scripts with companion specs. Bash is the default; PowerShell is a legitimate alternative. Spec first, build, audit, repeat until PASS." | See snippet below |

---

## Proposed Frontmatter Fixes

### `code-review-setup`

```yaml
---
name: code-review-setup
description: >-
  Use when setting up code-review for the first time, checking environment readiness,
  verifying git is installed, confirming .code-reviews/ is writable, or diagnosing
  why code-review cannot run.
triggers:
  - code-review setup
  - check environment readiness
  - verify git installed
  - code-reviews dir writable
  - diagnose code-review prerequisites
---
```

### `copilot-cli`

```yaml
---
name: copilot-cli
description: >-
  Use when running any GitHub Copilot CLI operation — code review, ask a question,
  or explain code. Routes to the correct sub-skill automatically.
triggers:
  - copilot cli
  - github copilot cli
  - copilot review
  - copilot ask
  - copilot explain
  - run copilot
---
```

### `copilot-cli-ask`

```yaml
---
name: copilot-cli-ask
description: >-
  Use when asking Copilot CLI a general question, requesting advice, or querying
  for information via the standalone Copilot binary.
triggers:
  - copilot ask
  - ask copilot
  - copilot general question
  - copilot advice
  - query copilot cli
---
```

### `copilot-cli-explain`

```yaml
---
name: copilot-cli-explain
description: >-
  Use when asking Copilot CLI to explain a code region, file, or snippet — returns
  an explanatory markdown description of what the code does.
triggers:
  - copilot explain
  - explain code via copilot
  - copilot code explanation
  - explain this file with copilot
  - describe code with copilot
---
```

### `copilot-cli-review`

```yaml
---
name: copilot-cli-review
description: >-
  Use when running a Copilot CLI adversarial code review on a change set — returns
  structured findings with severity ratings.
triggers:
  - copilot code review
  - copilot review change set
  - adversarial review via copilot
  - run copilot review
  - copilot findings
---
```

### `gh-cli`

```yaml
---
name: gh-cli
description: >-
  Use when performing any GitHub CLI operation and the correct sub-skill is
  unknown, or when auto-routing to the right domain (issues, PRs, releases,
  repos, projects, actions, API) is needed.
triggers:
  - gh cli
  - github cli
  - gh command
  - route github operation
  - auto-route gh task
---
```

### `gh-cli-actions`

```yaml
---
name: gh-cli-actions
description: >-
  Use when triggering, monitoring, listing, enabling, disabling, or managing
  GitHub Actions workflows, runs, secrets, variables, or caches via the CLI.
triggers:
  - gh actions
  - trigger workflow
  - monitor workflow run
  - manage github actions
  - workflow secrets
  - workflow variables
---
```

### `gh-cli-api`

```yaml
---
name: gh-cli-api
description: >-
  Use when no dedicated gh subcommand covers the operation — raw REST GET/POST/PATCH/DELETE
  or GraphQL queries and mutations against the GitHub API via gh api.
triggers:
  - gh api
  - raw github api
  - graphql query github
  - github rest api call
  - no dedicated gh subcommand
  - bulk api interaction
---
```

### `gh-cli-issues`

```yaml
---
name: gh-cli-issues
description: >-
  Use when creating, listing, viewing, editing, commenting on, closing, or
  transferring GitHub issues via the gh issue subcommand.
triggers:
  - gh issue
  - create github issue
  - list issues
  - edit issue
  - close issue
  - comment on issue
---
```

### `gh-cli-pr`

```yaml
---
name: gh-cli-pr
description: >-
  Use when listing, viewing, diffing, or checking status of pull requests, or
  when auto-routing a PR write operation (create, merge, review, comment) to
  the correct sub-skill.
triggers:
  - gh pr
  - list pull requests
  - view pr
  - pr diff
  - check pr status
  - route pr operation
---
```

### `gh-cli-pr-comments`

```yaml
---
name: gh-cli-pr-comments
description: >-
  Use when adding, editing, or deleting a general (non-inline) comment on a
  pull request via GitHub CLI.
triggers:
  - add pr comment
  - edit pr comment
  - delete pr comment
  - gh pr comment
  - pull request comment
---
```

### `gh-cli-pr-create`

```yaml
---
name: gh-cli-pr-create
description: >-
  Use when opening a new pull request via GitHub CLI — handles draft PRs,
  labels, assignees, reviewers, and body from file.
triggers:
  - create pull request
  - open pr
  - gh pr create
  - new pull request
  - open draft pr
---
```

### `gh-cli-pr-file-viewed`

```yaml
---
name: gh-cli-pr-file-viewed
description: >-
  Use when marking or unmarking files as viewed in a GitHub PR review UI —
  handles single file, multiple files, or all changed files via GraphQL mutations.
triggers:
  - mark file viewed
  - unmark file viewed
  - pr file viewed state
  - mark files reviewed
  - gh pr file viewed
  - bulk mark viewed
---
```

### `gh-cli-pr-inline-comment`

```yaml
---
name: gh-cli-pr-inline-comment
description: >-
  Use when posting, editing, or deleting an inline code review comment on a
  PR diff line — routes to post, edit, or delete sub-skill automatically.
triggers:
  - inline pr comment
  - post inline comment
  - edit inline comment
  - delete inline comment
  - pr diff comment
---
```

### `gh-cli-pr-inline-comment-delete`

```yaml
---
name: gh-cli-pr-inline-comment-delete
description: >-
  Use when deleting an existing inline PR review comment by comment ID via
  the GitHub CLI REST API.
triggers:
  - delete inline pr comment
  - remove inline comment
  - delete pr review comment
  - gh api delete pulls comment
---
```

### `gh-cli-pr-inline-comment-edit`

```yaml
---
name: gh-cli-pr-inline-comment-edit
description: >-
  Use when editing the body of an existing inline PR review comment by comment
  ID via the GitHub CLI REST API.
triggers:
  - edit inline pr comment
  - update inline comment body
  - patch pr review comment
  - modify pr inline comment
---
```

### `gh-cli-pr-inline-comment-post`

```yaml
---
name: gh-cli-pr-inline-comment-post
description: >-
  Use when posting a new inline or multi-line review comment on a PR diff line —
  handles SHA lookup, diff verification, deduplication, and POST via GitHub CLI.
triggers:
  - post inline pr comment
  - add inline review comment
  - comment on pr diff line
  - multi-line pr comment
  - gh api post pulls comment
---
```

### `gh-cli-pr-merge`

```yaml
---
name: gh-cli-pr-merge
description: >-
  Use when merging, squashing, rebasing, updating branch, reverting, or closing
  a pull request via GitHub CLI.
triggers:
  - merge pull request
  - squash pr
  - rebase pr
  - gh pr merge
  - update branch
  - revert pr
---
```

### `gh-cli-pr-review`

```yaml
---
name: gh-cli-pr-review
description: >-
  Use when approving, requesting changes on, or dismissing a pull request
  review via GitHub CLI.
triggers:
  - approve pr
  - request changes on pr
  - dismiss pr review
  - gh pr review
  - submit pr review
---
```

### `gh-cli-projects`

```yaml
---
name: gh-cli-projects
description: >-
  Use when creating, listing, editing, or managing GitHub Projects v2 boards,
  items, and fields via GitHub CLI.
triggers:
  - gh projects
  - github projects v2
  - create project board
  - add item to project
  - manage project fields
---
```

### `gh-cli-releases`

```yaml
---
name: gh-cli-releases
description: >-
  Use when creating, publishing, listing, editing, uploading assets to, or
  deleting GitHub releases via the gh release subcommand.
triggers:
  - gh release
  - create github release
  - publish release
  - upload release assets
  - list releases
  - delete release
---
```

### `gh-cli-repos`

```yaml
---
name: gh-cli-repos
description: >-
  Use when creating, cloning, forking, syncing, editing, or deleting a GitHub
  repository via the gh repo subcommand.
triggers:
  - gh repo
  - create github repo
  - clone repo
  - fork repo
  - sync repo
  - delete repo
---
```

### `gh-cli-setup`

```yaml
---
name: gh-cli-setup
description: >-
  Use when installing the GitHub CLI, authenticating with gh auth login,
  configuring defaults, or diagnosing why gh commands are failing.
triggers:
  - install github cli
  - gh auth login
  - configure gh cli
  - gh not found
  - gh setup
  - authenticate github cli
---
```

### `hash-record`

```yaml
---
name: hash-record
version: 0.1
description: >-
  Use when consumer skills need a content-hash-keyed durable record store —
  probe, read, write, or invalidate cached operation results keyed by file hash.
triggers:
  - hash record store
  - content hash cache
  - probe hash record
  - write hash record
  - invalidate hash record
  - durable record by hash
---
```

### `hash-stamp`

```yaml
---
name: hash-stamp
description: >-
  Use when writing or updating SHA-256 companion files alongside target files —
  after editing stamped files, or when stamping new files for integrity tracking.
triggers:
  - write sha256 stamp
  - update stamp
  - stamp this file
  - create sha256 companion
  - hash stamp file
---
```

### `iteration-safety`

```yaml
---
name: iteration-safety
description: >-
  Reference when implementing an audit, compression, hygiene, or review loop —
  enforces fix-before-repass and no-repass-on-unchanged-content rules.
triggers:
  - iteration safety
  - re-pass rules
  - fix before repass
  - audit loop rules
  - re-audit guard
  - compression loop guard
---
```

### `markdown-hygiene-result`

```yaml
---
name: markdown-hygiene-result
description: >-
  Use when checking cache state of a markdown-hygiene sub-document (report, lint,
  or analysis) before running a hygiene pass — returns HIT/MISS/CLEAN with path.
triggers:
  - markdown hygiene cache check
  - hygiene result probe
  - check lint cache
  - check analysis cache
  - skip if hygiene cached
---
```

### `session-logging`

```yaml
---
name: session-logging
description: >-
  Use when writing any session log entry, recording a Telegram session, creating
  a session start log, or structuring workspace session summaries in logs/session/
  or logs/telegram/.
triggers:
  - write session log
  - log session entry
  - session start log
  - telegram session recording
  - workspace session summary
---
```

### `spec-writing`

```yaml
---
name: spec-writing
description: >-
  Use when writing a new spec document, formalizing requirements, converting design
  notes into a normative spec, or when a document needs explicit scope, stable
  terminology, and enforceable requirements.
triggers:
  - write spec
  - write specification
  - formalize requirements
  - create normative document
  - spec document needed
  - convert design to spec
---
```

### `tool-writing`

```yaml
---
name: tool-writing
description: >-
  Use when writing a new tool script (Bash or PowerShell), adding a companion
  spec, building a tool trio, or following the spec-first tool authoring pipeline.
triggers:
  - write tool script
  - create bash tool
  - create powershell tool
  - tool trio
  - spec first tool
  - author tool companion spec
---
```
