# Capability Cache Specification

## Purpose

Define the rules and behavior for a capability cache that short-circuits
repeated Copilot CLI invocations by caching model availability locally.
The cache also serves as an `unavailable` sentinel — recording when the
`gh` CLI is absent, authentication fails, or any probe error occurs.

Origin: task 30-0986.

## Scope

This spec covers exactly one skill: `capability-cache`. The skill manages
a single cache file per `env_key` for the `copilot-cli/models` operation.

In scope:

- Checking whether a valid cache file exists (READ path).
- Probing `gh copilot models` and writing the result (WRITE path).
- Returning a structured `{result, models, cache_hit}` tuple to callers.

Out of scope:

- General key-value caching (use a different substrate).
- Caching any operation other than `copilot-cli/models`.
- Cache eviction strategies other than manual erasure.
- Managing multiple cache files simultaneously.

## Definitions

- **Cache file**: A YAML file at `<cache_root>/<env_key>/copilot-cli/models.yaml`
  containing the last known probe result for one environment.
- **HIT**: The cache file exists and `force_refresh` is false. The skill returns
  the stored data without probing the CLI.
- **MISS**: The cache file does not exist, or `force_refresh` is true. The skill
  runs the WRITE path.
- **`available`**: The `gh copilot models` command exited zero and returned at
  least one model name.
- **`unavailable`**: The `gh copilot models` command exited non-zero, was not
  found on PATH, or produced no parseable output.
- **`env_key`**: A string that namespaces the cache file, allowing multiple
  environment configurations to coexist under the same `cache_root`.
- **READ path**: The branch of execution that reads from the cache file and
  returns its contents without invoking the CLI.
- **WRITE path**: The branch of execution that invokes the CLI, writes the
  result to the cache file, and returns the result.
- **Consumer**: Any skill or agent that calls `capability-cache` before
  invoking a Copilot CLI command. Known consumers: `copilot-cli`, `swarm`,
  `code-review`.

## Requirements

### R1 — READ path: serve from cache on HIT

When the cache file exists and `force_refresh` is `false`, the skill must
return `{result, models, cache_hit: true}` from the cache file contents
without invoking any CLI command.

### R2 — WRITE path: probe on MISS

When the cache file does not exist, or `force_refresh` is `true`, the
skill must invoke `gh copilot models` (or the detection method from the
`copilot-cli` skill) to determine model availability.

### R3 — `unavailable` is a valid HIT

When the cached `result` field is `unavailable`, the skill must return
that value as a HIT. It must not re-probe the CLI to confirm or deny
the cached `unavailable` state (unless `force_refresh` is `true`).

### R4 — Write cache file after every probe

After every WRITE path execution, the skill must write the probe result
to the cache file before returning to the caller.

### R5 — Graceful failure on probe error

When the WRITE path CLI invocation fails for any reason (not found,
auth error, non-zero exit, parsing failure), the skill must set
`result: unavailable` and `models: []`, write the cache file, and
return `{result: "unavailable", models: [], cache_hit: false}`.
The skill must not throw, halt, or propagate the error to the caller.

### R6 — Corrupt cache treated as MISS

When the cache file exists but cannot be parsed as valid YAML conforming
to the cache schema, the skill must treat the file as a MISS and proceed
to the WRITE path. The skill must not surface a parse error to the caller.

### R7 — Create cache directory if absent

Before writing the cache file, the skill must create the directory
`<cache_root>/<env_key>/copilot-cli/` if it does not already exist.

### R8 — Do not commit cache files

The skill must document that `.capability-cache/` must be listed in the
consuming repository's `.gitignore`. The skill must not commit the cache
directory or its contents.

### R9 — Return structured output

Every execution path (HIT and WRITE) must return exactly the tuple
`{result, models, cache_hit}` with types as specified in the Inputs/Outputs
section.

## Constraints

- The skill must not manage cache files for any operation other than
  `copilot-cli/models`.
- The skill must not implement a TTL or automatic expiry mechanism.
- The skill must not commit cache files to version control.
- The skill must not throw or propagate CLI errors to callers.
- The skill must not re-probe on a `unavailable` cache HIT (unless
  `force_refresh: true`).

## Inputs

| Input | Type | Default | Description |
| --- | --- | --- | --- |
| `cache_root` | path | `<repo-root>/.capability-cache/` | Root directory for cache files |
| `env_key` | string | `default` | Environment identifier for namespacing |
| `force_refresh` | boolean | `false` | When true, bypass cache and re-probe |

## Outputs

| Output | Type | Description |
| --- | --- | --- |
| `result` | string | `available` or `unavailable` |
| `models` | list | Model names; empty list when unavailable |
| `cache_hit` | boolean | `true` if served from cache, `false` if probed |

## Cache Schema

```yaml
---
operation_kind: copilot-cli/models
result: available | unavailable
models:
  - <model-name>
---
```

## Behavior

### READ path

1. Compute path: `<cache_root>/<env_key>/copilot-cli/models.yaml`.
2. If the file exists and `force_refresh` is `false`: parse the file.
   - If parsing succeeds: return `{result, models, cache_hit: true}`. Stop.
   - If parsing fails: treat as MISS; continue to WRITE path (R6).
3. If the file does not exist, or `force_refresh` is `true`: proceed to
   WRITE path.

### WRITE path

1. Invoke `gh copilot models` (or the detection method from the
   `copilot-cli` skill).
2. If the command succeeds: parse model list; set `result: available`,
   `models: [<list>]`.
3. If the command fails for any reason: set `result: unavailable`,
   `models: []` (R5).
4. Create `<cache_root>/<env_key>/copilot-cli/` if it does not exist (R7).
5. Write the cache file.
6. Return `{result, models, cache_hit: false}`.

### Invalidation

The only supported invalidation mechanism is manual erasure of the cache
file. There is no TTL. Passing `force_refresh: true` bypasses the cache
for the current call and overwrites the file with a fresh probe result.

## Content Modes

This is an **inline skill** with two operational branches. Callers execute
the procedure directly — there is no sub-agent dispatch.

| Mode | Trigger | Behavior |
| --- | --- | --- |
| READ | Cache file exists AND `force_refresh: false` | Serve from file; no CLI invocation |
| WRITE | Cache file absent OR `force_refresh: true` | Probe CLI; write file; serve result |

## Defaults and Assumptions

- `cache_root` defaults to `<repo-root>/.capability-cache/`.
- `env_key` defaults to `"default"`.
- `force_refresh` defaults to `false`.
- The consuming repository is assumed to have `.capability-cache/` in its
  `.gitignore`. If not, cache files risk being committed.

## Error Handling

| Condition | Behavior |
| --- | --- |
| Cache file unparseable | Treat as MISS; proceed to WRITE path |
| `gh` CLI not on PATH | Set `result: unavailable`; write cache; return gracefully |
| CLI exits non-zero | Set `result: unavailable`; write cache; return gracefully |
| CLI output not parseable | Set `result: unavailable`; write cache; return gracefully |
| Cache directory absent | Create it before writing; no error |

## Precedence Rules

- R3 (unavailable is a valid HIT) takes precedence over any consumer-level
  assumption that `unavailable` requires a re-probe. Consumers must respect
  the cached state.
- R5 (graceful failure) takes precedence over any error-propagation pattern.
  The skill absorbs CLI errors silently.
- `force_refresh: true` overrides R1 (READ path). When set, the WRITE path
  always runs regardless of cache state.

## Don'ts

- Must not re-probe on a cache HIT (including `unavailable` HIT) unless
  `force_refresh: true`.
- Must not commit cache files.
- Must not throw or halt on CLI probe failure.
- Must not cache any operation other than `copilot-cli/models`.
- Must not implement TTL or automatic expiry.
- Must not claim "this skill never invokes CLI commands" — the WRITE path
  explicitly invokes `gh copilot models`.

## Footguns

### F1 — `unavailable` cached indefinitely

Once `unavailable` is written to the cache, it persists until manually
erased or `force_refresh: true` is passed. If the environment later gains
a working `gh` CLI installation or valid auth, the cache will continue
reporting `unavailable` until cleared. Consumers must account for this
when diagnosing apparent capability failures.

Mitigation: pass `force_refresh: true` to force a fresh probe, or
manually delete `<cache_root>/<env_key>/copilot-cli/models.yaml`.

### F2 — Corrupted cache treated as MISS

If the cache file becomes corrupted (partial write, encoding error,
truncation), the skill silently treats it as a MISS and re-probes the CLI.
No error is surfaced. Consumers will observe `cache_hit: false` in the
return value, which is the only observable signal.

Mitigation: monitor for unexpected `cache_hit: false` results in
environments where the cache should be warm.

## Section Classification

| Section | Type | Required |
| --- | --- | --- |
| Purpose | Informative | Yes |
| Scope | Normative | Yes |
| Definitions | Normative | Yes |
| Requirements | Normative | Yes |
| Constraints | Normative | Yes |
| Inputs | Normative | Yes |
| Outputs | Normative | Yes |
| Cache Schema | Normative | Yes |
| Behavior | Normative | Yes |
| Content Modes | Normative | Yes |
| Defaults and Assumptions | Normative | Yes |
| Error Handling | Normative | Yes |
| Precedence Rules | Normative | Yes |
| Don'ts | Normative | Yes |
| Footguns | Informative | No |
