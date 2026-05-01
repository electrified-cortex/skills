---
file_paths:
  - swarm/SKILL.md
  - swarm/spec.md
  - swarm/uncompressed.md
operation_kind: skill-auditing
model: sonnet-class
result: findings
---

# Result

FAIL

## Skill Audit: swarm

**Verdict:** FAIL
**Type:** inline
**Path:** swarm/
**Failed phase:** 1

### Phase 1 — Spec Gate

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | `swarm/spec.md` found |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Extensive use of must/shall/required throughout normative sections |
| Internal consistency | FAIL | Four distinct contradictions within spec.md (see Issues) |
| Completeness | SKIP | Not evaluated — internal consistency failed |

### Phase 2 — Skill Smoke Check

Not evaluated — Phase 1 failed.

### Phase 3 — Spec Compliance

Not evaluated — Phase 1 failed.

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| `SKILL.md` | Not empty | PASS | |
| `SKILL.md` | Frontmatter | PASS | name + description present |
| `SKILL.md` | No abs-path leaks | PASS | |
| `spec.md` | Not empty | PASS | |
| `spec.md` | Frontmatter | N/A | Not SKILL.md or agent.md |
| `spec.md` | No abs-path leaks | PASS | |
| `uncompressed.md` | Not empty | PASS | |
| `uncompressed.md` | Frontmatter | N/A | Not required for uncompressed.md |
| `uncompressed.md` | No abs-path leaks | PASS | |
| `reviewers/devils-advocate.md` | Not empty | PASS | |
| `reviewers/devils-advocate.md` | No abs-path leaks | PASS | |
| `reviewers/index.md` | Not empty | PASS | |
| `reviewers/index.md` | No abs-path leaks | PASS | |
| `reviewers/security-auditor.md` | Not empty | PASS | |
| `reviewers/security-auditor.md` | No abs-path leaks | PASS | |
| `specs/arbitrator.md` | Not empty | PASS | |
| `specs/arbitrator.md` | No abs-path leaks | PASS | |
| `specs/dispatch-integration.md` | Not empty | PASS | |
| `specs/dispatch-integration.md` | No abs-path leaks | PASS | |
| `specs/glossary.md` | Not empty | PASS | |
| `specs/glossary.md` | No abs-path leaks | PASS | |
| `specs/personality-file.md` | Not empty | PASS | |
| `specs/personality-file.md` | No abs-path leaks | PASS | |
| `specs/registry-format.md` | Not empty | PASS | |
| `specs/registry-format.md` | No abs-path leaks | PASS | |

### Issues

**[Phase 1 — Internal consistency] Contradiction 1: Registry authority — static table vs. runtime crawl**

`spec.md` "Personality Registry" section declares "The registry is normative. All built-in personalities must appear in this table." The section lists 9 built-in personalities as normative. This directly contradicts `spec.md` Don'ts DN2 ("Must not use a fixed roster; selection must evaluate trigger conditions against the artifact") and the spirit of Requirements R1 ("runtime-crawled from the built-in table"). It also contradicts `swarm/SKILL.md`'s own Don'ts ("Don't embed normative registry as static table — registry is `reviewers/` dir") and `uncompressed.md`'s explicit statement "Not a static table" alongside the runtime crawl approach. The spec cannot simultaneously declare its own table normative and instruct implementors not to treat it as normative. Fix: resolve which is authoritative — if registry is the `reviewers/` directory, relabel the Personality Registry table in spec.md as informative and remove the "The registry is normative" declaration and "All built-in personalities must appear in this table" statement.

**[Phase 1 — Internal consistency] Contradiction 2: Integer index stability**

`spec.md` line 69 states "Registry entries must not be re-ordered; the integer index is stable across invocations and used in disagreement tracking." This conflicts with the runtime-crawl approach adopted throughout the implementation (`swarm/SKILL.md` crawls `reviewers/` at runtime; `swarm/uncompressed.md` states "The integer index is informative only. The stable runtime index is assigned by alphabetical crawl (1-based). Personality renames change the index"). An alphabetical directory crawl produces an index that changes on rename or file addition, contradicting the spec's "stable across invocations" requirement. Fix: either spec.md must drop the stability guarantee and acknowledge alphabetical-crawl ordering, or the implementation must enforce a fixed-order index file that spec.md also normatively defines.

**[Phase 1 — Internal consistency] Contradiction 3: Stale path in spec.md**

`spec.md` Step 4 (line 137) states reviewer prompts are stored under `swarm-protocol/reviewers/<name>.md`. The actual skill folder is `swarm`, not `swarm-protocol`. This path is wrong and misleading. `swarm/uncompressed.md` correctly uses `swarm/reviewers/<name>.md`. The `spec.md` Open Questions section (OQ1) notes the name was undecided between `swarm-review` and `swarm-protocol`; the implementation settled on `swarm`, but spec.md was not updated. Fix: replace all `swarm-protocol` path references in spec.md with the actual folder name `swarm`.

**[Phase 1 — Internal consistency] Contradiction 4: Definitions section registry definition conflicts with Requirements**

`spec.md` Definitions (line 29) defines "Personality registry" as "the built-in ordered table of personalities defined in this skill." This definition treats the registry as a static structure inside the skill. Requirements R1 states the registry "must be runtime-crawled from the built-in table plus any caller-supplied custom menu." These two are irreconcilable: a table defined within the skill cannot simultaneously be runtime-crawled from an external directory. The sub-spec `specs/registry-format.md` gives a third incompatible definition: an external index file. Fix: align the Definitions section with the chosen implementation model (external `reviewers/index.md` file crawled at runtime).

**[Additional — not blocking Phase 1] `reviewers/index.md` vendor contradiction with SKILL.md/uncompressed.md**

`swarm/SKILL.md` B8 states "Devil's Advocate is natural diversity carrier (`vendor: openai` in frontmatter, non-Anthropic `suggested_models` preference)." `swarm/uncompressed.md` F7 states "Devil's Advocate should carry `vendor: openai`." However, the actual `reviewers/index.md` entry for Devil's Advocate has `vendor: anthropic`. This is a factual mismatch between the skill's runtime instructions and its data. If Devil's Advocate carries `vendor: anthropic`, the B8 diversity mechanism will not route it to a non-Anthropic model, defeating the stated purpose.

**[Additional — not blocking Phase 1] `reviewers/index.md` uses `gpt-class` model class not defined in spec.md**

`spec.md` Definition of "model class" enumerates exactly three values: `haiku-class`, `sonnet-class`, `opus-class`. The `reviewers/index.md` Devil's Advocate entry uses `gpt-class` in `suggested_models`. `specs/glossary.md` also documents `gpt-class` as a fourth tier. This term is absent from the primary spec and from `swarm/SKILL.md`. The model class definition in spec.md must be expanded to include `gpt-class` (or the index.md entry must be corrected to use only defined terms).

**[Additional — not blocking Phase 1] `specs/dispatch-integration.md` pre-implementation gate violated in index.md**

`specs/dispatch-integration.md` states: "No personality in `reviewers/index.md` may use `copilot-cli` as its backend in the live registry" until task 10-0845 reaches PASS. The live `reviewers/index.md` Devil's Advocate entry has `suggested_backends: [dispatch-sonnet, copilot-cli]`. `copilot-cli` appears as the second backend preference, placing it in the live index before 10-0845 is resolved.

**[Additional — not blocking Phase 1] Spec name drift — OQ1 unresolved**

`spec.md` uses `swarm-protocol` as the skill identity throughout (title, Purpose, Definitions, Step 4 path). The compiled artifacts (`SKILL.md`, `uncompressed.md`) settled on the name `swarm` and the folder is `swarm`. The spec's Open Question OQ1 flagged this name decision as unresolved. The spec was not updated after the name was chosen. This creates confusion about which name governs; an implementor reading spec.md will see `swarm-protocol` as the canonical name.

**[Additional — not blocking Phase 1] `specs/glossary.md` cross-references `uncompressed.md` as normative source**

`specs/glossary.md` line 3 states "See `uncompressed.md` for normative rules." This is a pointer from a spec sub-file to the uncompressed runtime artifact, inverting the normal authority chain (spec is authoritative; runtime artifacts are subordinate). Fix: remove the pointer or replace with a pointer to `spec.md`.

### Recommendation

Resolve the four Phase 1 internal consistency failures in `spec.md` — particularly the registry authority contradiction and the stale `swarm-protocol` path references — then re-audit.
