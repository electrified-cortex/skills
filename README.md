# Electrified Cortex — Skills

Source library for AI-agent skills following the
[Agent Skills](https://agentskills.io) open standard. Compatible with Claude
Code, VS Code (GitHub Copilot Chat), and any runtime that loads `SKILL.md`.

Every skill goes through a deliberate spec → write → audit cycle; the git
history tells the full story.

## Catalog

Each top-level directory is a skill. See [skill.index.md](skill.index.md) for
the structured index, or browse the directory listing.

## Using these skills

Most users want the published plugin, not this source repo. Install
instructions live in the
[skills-plugin](https://github.com/electrified-cortex/skills-plugin)
distribution repo.

## Contributing

Authoring workflow lives in [skill-writing](skill-writing/): spec first,
derive an uncompressed source, compress, audit, stamp. The
[spec-writing](spec-writing/), [skill-auditing](skill-auditing/), and
[markdown-hygiene](markdown-hygiene/) skills define the contracts
contributors must satisfy.

## Philosophy

Skills ship with companion `.spec.md` files that preserve design rationale
and constraints in full natural language. The skill tells machines *what*;
the spec tells humans and agents *why*.

## License

MIT — see [LICENSE](LICENSE).
