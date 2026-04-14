---
title: Compression Agent Spec
companion: AGENT.md
model: sonnet-class
last-updated: 2026-04-13
---

## Definitions

| Term | Meaning |
| --- | --- |
| **Baseline** | The last committed or staged version of the target file, recoverable via `git show`. |
| **Blurb mode** | Compression of raw text input (no file on disk). Skips all gates. |
| **Content loss** | Any fact, rule, constraint, or technical detail present in the baseline but absent after compression. |
| **Post-flight** | Verification step comparing compressed output against the baseline. |
| **Tier** | Compression intensity level: lite, full, or ultra. See the Compression skill. |

## Relationship to the Skill

| Concern | Owner |
| --- | --- |
| What to compress (rules, preserve lists, transforms) | Skill (per tier) |
| When to compress (gates, eligibility) | Agent |
| How to verify (post-flight baseline comparison) | Agent |
| Tier selection and defaults | Agent |

The skill is pure technique. The agent is the process wrapper that decides
whether compression should happen, which tier to use, and whether the result
is acceptable.

Any agent can invoke the skill directly for raw compression with no safety
checks. The compression agent adds the safety layer.

## Why the Agent Exists

Without a dedicated agent, gate logic and verification get duplicated across
every consumer. The agent centralizes:

1. **Gate enforcement** — consistent safety checks regardless of caller
2. **Tier resolution** — default to ultra, accept overrides
3. **Verification** — git-based comparison to catch content loss
4. **Structured output** — minimal, consistent reporting

## Input

Two modes:

- **File mode:** file path + optional `--tier <lite|full|ultra>`
- **Blurb mode:** raw text (snippet, task description, chat input) + optional tier

Blurb mode skips the gate — there's no file to check.

## Flow

Order matters. Gates first, skill loading second. Don't waste context on a
file that will be rejected.

1. **Parse input** — extract file path or text, and tier if provided.
2. **If blurb** → skip to step 5.
3. **Gate: Clean baseline** — `git status --porcelain <file>`. The file
   must have a recoverable git baseline. Reject if no baseline exists.
4. **Resolve tier** — use `--tier` value if provided, otherwise **ultra**.
5. **Read and execute tier skill** — load only the relevant tier file
   (e.g. `ultra/rules.txt`) from the Compression skill directory. Do not read
   the root `SKILL.md` or other tiers. The skill lives in the skills repo
   at `<tier>/rules.txt` (co-located in this skill folder).
6. **Post-flight verification** (file mode only) — compare compressed output
   against the git baseline. Every fact, rule, and constraint must survive.
   If content was lost, restore the file and reject.
7. **Write and report.**

## Gate Design

### Clean Baseline

The file must have no unstaged working-tree changes. It can be committed or
staged — either way, a recoverable baseline exists for post-flight comparison.

Check `git status --porcelain <file>`, 2nd character (working-tree column).
Reject if not a space:

- `?` — untracked (no baseline)
- `M` — unstaged modifications
- `D` — deleted
- `MM` — staged with additional unstaged changes

Acceptable: ` ` (committed), `M` (staged, clean tree), `A` (new, staged).

**Why:** Compression modifies in-place. Without a baseline, post-flight
verification has nothing to compare against, and there's no recovery path if
compression destroys content. Historical incident: an agent compressed a file
while the operator was editing it, destroying in-progress work.

## Tier Selection

Three tiers, matching the compression skill:

| Tier | Use case | Default surface |
| --- | --- | --- |
| **Ultra** | Agent files, skills, DMs, reminders | Agent files, skills |
| **Full** | General docs, READMEs | Documentation |
| **Lite** | Operator-facing text, tasks | Human-readable content |

**Default: ultra.** Most compression targets are agent-context files where
maximum token reduction matters. Callers override with `--tier full` or
`--tier lite` when needed.

## Post-Flight Verification

Internal to the agent — the caller never sees the diff (they can run
`git diff` themselves).

Compare the compressed output against `git show HEAD:<file>` or
`git show :0:<file>` (index). Every fact, rule, constraint, and technical
detail must survive compression.

### Recovery Behavior

If content was lost during compression:

1. **Quick fix (recoverable from context):** If the lost content can be
   restored with a minor edit (e.g. a dropped rule, collapsed sentence that
   lost a condition), fix it in-place. Report what was fixed and why.
2. **Not recoverable:** Restore the original file. Report `REJECTED: content
   loss` with details.

In both cases, suggest what should change to prevent future loss:

- What about the **source file** made it fragile to compression (e.g. a rule
  buried in prose, an implicit constraint that reads like filler)

The suggestion is guidance, not a command. The caller decides what to fix.

## Output Contract

Minimal. The caller already knows what file they gave you.

**Success:**

```txt
1618→1180 bytes | 27% reduction | ultra
```

Original size → compressed size in bytes, percentage reduced, and tier.
The bytes give absolute context; the percentage gives quick readability.

**Rejection:**

```txt
REJECTED: <reason>
```

One line. If content was lost, include a brief suggestion about what the file
may need.

**Success with fixes:**

When post-flight caught and fixed minor content loss, report the fix:

```txt
1618→1180 bytes | 27% reduction | ultra
Fixed: restored dropped condition "only when gate 1 passes" in step 4
Suggest: source file buries condition in prose — elevate to explicit rule
```

**Examples:**

```txt
REJECTED: no git baseline
REJECTED: content loss — gate ordering rationale not recoverable
1618→1180 bytes | 27% reduction | ultra
2400→1488 bytes | 38% reduction | full
3200→1568 bytes | 51% reduction | ultra
```

## Constraints

- **One file per invocation.** One baseline, one post-flight check, one verdict.
  Callers chain invocations for batch work.
- **Never read more than one tier.** Load only the requested tier's skill file.
  Reading multiple tiers wastes context.
- **Blurb mode has no gate.** No file = no baseline. Just compress and return.

## Error Handling

- **Tier skill not found:** If the requested tier's rules.txt does not exist
  or is unreadable, reject: `REJECTED: tier skill not found (<tier>)`. Do not
  fall back to a different tier or improvise compression rules.
- **Git not available:** If `git` commands fail (not a repo, git not installed),
  reject: `REJECTED: git unavailable — cannot verify baseline`.
- **Empty output:** If compression produces empty or whitespace-only output,
  reject: `REJECTED: compression produced empty output`.

## Blurb Mode Output

In blurb mode, return the compressed text directly instead of a file path.
The output format is the compressed text followed by the reduction line:

```txt
<compressed text>
---
850→510 bytes | 40% reduction | ultra
```

## Non-Goals

- **Batch compression.** One file per invocation. Callers chain invocations.
- **Content restructuring.** Compression preserves structure; it does not
  reorganize, rewrite, or improve the target beyond token reduction.
- **Interactive mode.** No back-and-forth with the caller during compression.
  One input, one output.

## Agent Frontmatter Requirements

The companion `AGENT.md` must include:

| Field | Required | Value |
| --- | --- | --- |
| `name` | yes | `Compression` |
| `description` | yes | Brief single-line purpose statement |
| `model` | yes | Sonnet-class (e.g. `claude-sonnet-4-6`) |
| `tools` | yes | Minimum: `read`, `edit` |
