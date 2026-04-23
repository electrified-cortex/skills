# Claude Code marketplace packaging for electrified-cortex

**Status:** Draft — design approved 2026-04-23
**Owner:** Kyle Craviotto
**Scope:** v0.1.0 internal release

## Problem

The `electrified-cortex/skills` repo currently ships 15 skills under the Agent Skills open standard, plus two dispatch agents and skill-indexing artifacts. Teammates install them by cloning the repo and pointing an agent runtime at the root. There is no first-class install path for Claude Code, which expects plugins with a specific manifest and directory layout.

Goal: make the repo installable as a Claude Code plugin marketplace, usable by internal teammates with two CLI commands, without breaking the repo's platform-agnostic posture for non-Claude-Code runtimes.

## Non-goals

- Public distribution outside the organization.
- Splitting the skills into multiple plugins (themed bundles or per-skill packages).
- Publishing slash commands (`commands/`), hooks, or MCP servers. The plugin in v0.1.0 ships skills and agents only.
- Automated versioning, release tagging, or changelog generation.
- Re-authoring any skill content. This is a packaging change only.

## Decisions

### Granularity: single plugin

One plugin (`electrified-cortex`) bundles all 15 skills and both dispatch agents. The skills are tightly cross-referenced (e.g., `skill-writing` calls `skill-auditing`, which calls `markdown-hygiene`), so splitting them across plugins would create install-ordering and dependency headaches for internal users with no offsetting benefit.

### Distribution: existing GitHub repo

The marketplace manifest and plugin contents live in the same repo (`github.com/electrified-cortex/skills`). Users add the marketplace by referencing the repo directly — no second publish step, no separate distribution repo, no internal file share. Internal access is controlled by GitHub org membership.

### Repo layout: restructure, not overlay

All 15 skill directories move from the repo root into a new top-level `skills/` subdirectory. This matches Claude Code's plugin loader expectation (`skills/<skill-name>/SKILL.md`) and avoids maintaining Windows-unfriendly symlinks or duplicated copies. The one-time path churn is accepted in exchange for a clean, spec-compliant layout.

## Target layout

```
skills/  (GitHub: electrified-cortex/skills)
├── .claude-plugin/
│   ├── marketplace.json
│   └── plugin.json
├── skills/
│   ├── audit-reporting/
│   ├── code-review/
│   ├── compression/
│   ├── dispatch/
│   ├── gh-cli/
│   ├── hash-stamp/
│   ├── markdown-hygiene/
│   ├── session-logging/
│   ├── skill-auditing/
│   ├── skill-index/
│   ├── skill-writing/
│   ├── spec-auditing/
│   ├── spec-writing/
│   ├── tool-auditing/
│   └── tool-writing/
├── agents/
│   ├── claude-dispatch.md
│   └── vscode-dispatch.md
├── README.md
├── skill.index
├── skill.index.md
├── skill.index.sha256
├── LICENSE
└── .gitignore, .gitattributes, .markdownlint.json
```

Each skill directory moves with `git mv`. Companion files (`SKILL.md`, `spec.md`, `uncompressed.md`, all `.sha256` stamps) travel intact. The `.claude-plugin/` folder is additive. The two dispatch agents are promoted from `skills/dispatch/agents/*.agent.md` to top-level `agents/*.md` so Claude Code auto-registers them as subagent types; the filename suffix drops from `.agent.md` to `.md` to match Claude Code's convention.

## Marketplace manifest

`.claude-plugin/marketplace.json`:

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

- `"source": "./"` — plugin lives in the same repo as the marketplace manifest. (Claude Code CLI requires the trailing slash.)
- Plugin name matches the GitHub org (`electrified-cortex`) to keep the install incantation memorable.
- Version starts at `0.1.0` to signal that marketplace packaging is new and may shift; skill content itself is stable.

## Plugin manifest

`.claude-plugin/plugin.json`:

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

Claude Code auto-discovers `skills/`, `agents/`, `commands/`, and `hooks/` relative to the plugin root, so the manifest stays small and declarative.

Companion files (`spec.md`, `uncompressed.md`, `.sha256` stamps) are inert from Claude Code's perspective — it only reads `SKILL.md`. They ride along in the git clone to preserve the cross-platform skill contract documented in `skills/skill-writing/spec.md`. The plugin manifest does not mention them; that belongs in the skill-writing spec, not the loading contract.

## Migration plan

1. `git mv <skill>/ skills/<skill>/` for all 15 skill directories (audit-reporting, code-review, compression, dispatch, gh-cli, hash-stamp, markdown-hygiene, session-logging, skill-auditing, skill-index, skill-writing, spec-auditing, spec-writing, tool-auditing, tool-writing).
2. `git mv skills/dispatch/agents/claude-dispatch.agent.md agents/claude-dispatch.md` and the same for `vscode-dispatch`.
3. Create `.claude-plugin/marketplace.json` and `.claude-plugin/plugin.json` per the shapes above.
4. Rebuild `skill.index`, `skill.index.md`, and `skill.index.sha256` against the new `skills/` subtree. If the existing builder in `skills/skill-index/` hardcodes a root scan, add a root-override parameter — that fix is in-scope for this migration.
5. Update `README.md`:
   - Rewrite the skill table links from `[code-review](code-review/)` to `[code-review](skills/code-review/)` and similar for every row.
   - Rewrite the agent table links to the new `agents/` paths.
   - Add a new "Install as a Claude Code plugin" section with the two-command install sequence.
6. Grep-sweep `SKILL.md`, `spec.md`, and `uncompressed.md` files for cross-skill path references (`../<skill>`, `<skill>/...`) and update any that break under the new layout.

All steps are mechanical. No skill content changes.

## Install instructions (new README section)

```bash
# One-time, per teammate
claude plugin marketplace add electrified-cortex/skills
claude plugin install electrified-cortex@electrified-cortex

# To pull updates later
claude plugin marketplace update electrified-cortex
```

Requires the teammate's GitHub account to have read access to `electrified-cortex/skills`.

## Verification

Success criteria for the v0.1.0 migration:

1. `claude plugin marketplace add` run against a **local clone** (not the remote) resolves both manifests without error. This catches manifest syntax or schema issues before anything is pushed.
2. After install, `/plugin` lists `electrified-cortex` and all 15 skills are discoverable by their namespaced names (`electrified-cortex:code-review`, etc.).
3. Both dispatch agents appear in the subagent type list available to the `Agent` tool.
4. One skill is smoke-tested end-to-end — invoking `electrified-cortex:markdown-hygiene` on a known-dirty `.md` fixture must fix it, proving file path resolution works inside the plugin sandbox.
5. A `hash-stamp` audit across the moved `skills/` tree returns zero drift, confirming no companion stamps were corrupted by `git mv`.

## Risks and mitigations

- **Broken cross-references inside skill files** — mitigated by the grep-sweep in migration step 6. If a reference is missed, the smoke test in verification step 4 should surface it; if not, an affected skill fails at invoke time with a clear "file not found" error.
- **skill-index builder assumes root scan** — mitigated by treating this as in-scope for the migration. If the fix is larger than anticipated, it becomes a blocker and gets its own follow-up spec rather than hiding inside this one.
- **Teammates on older Claude Code versions missing `/plugin marketplace`** — document the minimum Claude Code version in the new README section. Not mitigated in the repo; handled by team comms.
- **External consumers pointing runtimes at the repo root** — the README update signals the new layout, and old clones continue to work until re-cloned. Cross-platform consumers re-point at `skills/`.

## Open questions

None at design time. Any issues discovered during migration become new specs or plan items.
