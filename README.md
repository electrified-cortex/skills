# Electrified Cortex — Skills

A human curated collection of AI agent skills for workspace automation, quality
assurance, and token efficiency.

Every skill here has been through a deliberate human-AI refinement process —
not just generated, but iterated, reviewed, externally validated, and audited
against companion specs until the drift count hits zero. The git history tells
the full story.

| Skill | Description |
| --- | --- |
| [agent-optimizer](agent-optimizer/) | Analyze agent files for per-turn token cost — recommend content placement across three tiers (agent file, manifest, skills) |
| [compression](compression/) | Token-saving compression for `.md` files — three tiers (Lite, Full, Ultra) for different audiences |
| [spec-writing](spec-writing/) | Write behavioral specs (`.spec.md` files) for any file, feature, or system — plus specialized sub-skills for compiling specs into agent and skill files |

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

## License

MIT — see [LICENSE](LICENSE).
