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

## Foundational journey

A small set of skills are load-bearing — everything else builds on them.

- **[compression](compression/)** — the first skill. Cuts token waste in
  agent contexts via three tiers (Lite / Full / Ultra). Inspired by
  [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) (MIT);
  extended with safety gates and companion specs.
- **[spec-writing](spec-writing/)** — the contract layer. Any file, feature,
  or system can have a behavioral spec; specs are the source code, runtime
  files the compiled program.
- **[skill-writing](skill-writing/)** — the authoring pipeline. Spec first,
  derive uncompressed, compress to runtime, audit. Encodes the inline-vs-
  dispatch test and the rule that `SKILL.md` is never edited directly.
- **[spec-auditing](spec-auditing/)** + **[skill-auditing](skill-auditing/)**
  — the governance pair. Spec drift and skill quality are caught by
  zero-context dispatched audits before anything ships.
- **[dispatch](dispatch/)** — the architectural primitive. When to spawn a
  sub-agent, what model tier, what prompt shape; everything that delegates
  rests on this.

## License

MIT — see [LICENSE](LICENSE).
