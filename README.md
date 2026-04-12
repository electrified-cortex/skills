# Electrified Cortex — Skills

A human curated collection of AI agent skills for workspace automation, quality
assurance, and token efficiency.

Every skill here has been through a deliberate human-AI refinement process —
not just generated, but iterated, reviewed, externally validated, and audited
against companion specs until the drift count hits zero. The git history tells
the full story.

| Skill | Description |
| --- | --- |
| [compression](compression/) | Token-saving compression for `.md` files — three tiers (Lite, Full, Ultra) for different audiences |

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

[Read more →](compression/README.md)

## License

MIT — see [LICENSE](LICENSE).
