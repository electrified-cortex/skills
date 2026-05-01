# Electrified Cortex — Skills

A human curated collection of AI agent skills for workspace automation, quality
assurance, and token efficiency.

Every skill here has been through a deliberate human-AI refinement process —
not just generated, but iterated, reviewed, externally validated, and audited
against companion specs until the drift count hits zero. The git history tells
the full story.

| Skill | Description |
| --- | --- |
| [code-reviewer](code-reviewer/) | Two-tier code review — fast-cheap smoke pass, standard substantive sign-off; reviews only, never modifies |
| [compression](compression/) | Token-saving compression for `.md` files — three tiers (Lite, Full, Ultra) for different audiences |
| [dispatch](dispatch/) | Decision tree for whether, how, and at what model tier to dispatch sub-agents |
| [gh-cli](gh-cli/) | GitHub CLI operations — routes to domain-specific sub-skills via agent dispatch |
| [markdown-hygiene](markdown-hygiene/) | Fix all markdownlint violations in a `.md` file — zero-error gate before stamping or committing |
| [skill-auditing](skill-auditing/) | Audit a skill for quality, classification, cost, and compliance with the skill-writing spec |
| [skill-index](skill-index/) | Cascading per-directory index system for agent skill discovery without filesystem walks |
| [skill-writing](skill-writing/) | How to write skills — inline vs dispatch decision, folder conventions, quality criteria, audit gate |
| [spec-auditing](spec-auditing/) | Audit spec/companion pairs for drift and consistency |
| [spec-writing](spec-writing/) | Write behavioral specs (`.spec.md` files) for any file, feature, or system — plus specialized sub-skills for compiling specs into agent and skill files |
| [tool-auditing](tool-auditing/) | Audit tool scripts for companion spec, conventions, and error handling — lightweight, fast-cheap |
| [tool-writing](tool-writing/) | Write tool scripts with companion specs — Bash default, PowerShell supported, spec-first discipline |

| **Agent** | **Description** |
| --- | --- |
| [claude-dispatch](dispatch/agents/claude-dispatch.agent.md) | Minimal pass-through agent for Claude Code CLI — reads a target file, follows its instructions, returns the result |
| [vscode-dispatch](dispatch/agents/vscode-dispatch.agent.md) | Minimal pass-through agent for Claude Code in VS Code — same behavior, VS Code tool names |

## Quick Start

Unzip or clone as `electrified-cortex` in your agent's skills folder. Each
skill is self-contained — point your agent at the `SKILL.md` for the tier you
need and it works immediately.

## Philosophy

Each skill is self-contained, platform-agnostic, and follows the
[Agent Skills](https://agentskills.io) open standard. Skills work with any
AI agent runtime — VS Code Copilot, Claude Code, or custom orchestrators.

Skills ship with companion `.spec.md` files that preserve design rationale,
credits, and constraints in full natural language. The skill tells machines
*what* to do; the spec tells humans and agents *why*.

## Tiered Model Strategy

Across dispatch and audit loops, use an inexpensive/fast model for iterate
passes and a default model for final sign-off. Keep skill-specific caveats in
the individual skill docs.

## Journey

### Compression

Our first skill. Born from the need to cut token waste in agent context
windows. Inspired by
[JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) (MIT),
extended with three compression tiers, safety gates, companion specs, and a
rigorous audit pipeline. Dozens of iterations, external review, and operator
sign-off brought it to publication quality.

The compression skill ships a `.tests/` folder with a shared test plan, tier-specific
agent outputs, and input fixtures — every compression is dogfooded against
real skill files before release.

[Read more →](compression/README.md)

### Spec Writing

Our second skill. Spec writing applies to anything — any file, feature,
or system can have a behavioral spec. The parent skill defines spec
structure, governance, and the authorship workflow. Specialized sub-skills
for agents and skills encode the byte-code principle: specs are source
code, runtime files are the compiled program. These sub-skills handle
the compilation step from verbose spec to lean operational file.

[Read more →](spec-writing/)

### Skill Writing

Skills are the compiled output of specs — so a skill for writing skills was essential. The skill-writing skill codifies the full authoring pipeline: write spec first, derive an uncompressed baseline, compress to a lean runtime file, then audit. It encodes the inline-vs-dispatch decision test, folder conventions, and the requirement that `SKILL.md` is never modified directly. Refinement through the spec-auditing and skill-auditing loops burned off ambiguities until fast-cheap agents could follow the procedure without interpretation.

[Read more](skill-writing/README.md)

### Spec Auditing

Drift between a spec and its compiled companion is silent debt. Spec auditing was born to catch it — running in a zero-context isolated agent so the auditor forms its own judgment without inheriting any author bias. It supports read-only audits, pair-audits that compare spec against companion, and an optional fix mode that corrects the companion up to three passes. It became the standard gate before any stamp is written.

[Read more](spec-auditing/README.md)

### Skill Auditing

Once skill-writing established what a correct skill looks like, skill auditing was the enforcement arm. It checks the spec gate, runs a smoke pass over the skill file itself, then verifies compliance against the skill-writing spec in a single dispatched agent.

[Read more](skill-auditing/README.md)

### Markdown Hygiene

Every `.md` artifact in the pipeline passes through a markdownlint gate before it gets stamped or committed. Markdown hygiene grew out of repeated friction where auditors and operators encountered lint violations in otherwise correct files. The skill dispatches a zero-context agent that fixes violations in place (or to a side file when the source must stay clean), returning CLEAN, FIXED, or PARTIAL — so the caller always knows the gate status.

[Read more](markdown-hygiene/README.md)

### GH CLI

GitHub CLI operations sprawl across enough domains — PRs, issues, releases, repos, Actions, Projects, API, setup — that a single skill file would be unworkably large. The gh-cli skill is a pure router: it reads the request, identifies the domain, and dispatches to the appropriate sub-skill. No `gh` commands run in the router itself. This design keeps each domain skill small and independently auditable while giving callers a single entry point when the domain is ambiguous.

[Read more](gh-cli/README.md)

### Code Reviewer

Code review has two distinct jobs: fast surface-level triage and authoritative deep analysis. This skill encodes that separation formally — exactly one fast-cheap smoke pass, then one or more standard substantive passes, with the smoke pass never treated as authoritative. Review agents never edit; the calling agent decides which findings to act on between passes. The pattern emerged from experience with shallow reviews being over-trusted, and codifies the escalation path explicitly.

[Read more](code-reviewer/)

### Dispatch

Dispatching sub-agents incorrectly costs more than not dispatching at all. This skill captures the decision tree, footgun catalogue, and empirical findings (including context-inheritance tests run in April 2026) that answer when to dispatch, when to stay inline, how to pick model tier, and how to write a well-formed prompt that a cold stranger agent can execute. It is the foundation on which skill-writing's dispatch guidance and the broader agent fleet governance rest.

[Read more](dispatch/)

### Tool Writing

Scripts are a distinct artifact class from skills — they run as processes, not agent instructions. Tool writing encodes the spec-first discipline for shell scripts: write the companion spec before the script, no hardcoded paths, no interactive input, consistent output format, and placement rules for skill-embedded vs standalone tools. Bash is the default for agents; PowerShell is explicitly first-class for Windows-native work. The skill mirrors the skill-writing workflow at the script layer.

[Read more](tool-writing/)

### Tool Auditing

The complement to tool writing. Tool auditing runs a seven-check checklist — companion spec presence, parameter block, no hardcoded paths, error handling, self-documentation density, no interactive input, and consistent output format — against any tool script. It is explicitly lightweight enough for a fast-cheap model, keeping audit costs low for routine hygiene checks. Results are read-only; remediation stays with the caller.

[Read more](tool-auditing/)

### Skill Index

As the skill library grew, filesystem walks became expensive and unreliable. The skill-index toolkit introduces a cascading per-directory index system: a builder produces a raw `skill.index` and an LLM-authored `skill.index.md` overlay; an auditor validates the cascade and writes a SHA-256 stamp on PASS; a crawler consumes the cascade to locate a skill by name without touching the filesystem. The stamp is a sign-off artifact — its absence after a build signals "unaudited," not "needs rebuild."

[Read more](skill-index/)

## License

MIT — see [LICENSE](LICENSE).
