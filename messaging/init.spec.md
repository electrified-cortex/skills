# init — Tool Specification

## Purpose

Register an agent's identity in the shared inbox space. Creates the agent's inbox
directory, archive subdirectory, and signal file. Fails if the name is already taken,
giving agents an atomic name-claim primitive.

Must be called once on agent startup, before entering the monitoring loop or draining.

## Parameters

| Flag | Required | Description |
| --- | --- | --- |
| `--name` | Yes | Agent's canonical name to register (kebab-case) |
| `--workspace` | No | Workspace root path. Defaults to `$PWD`. |
| `--force` | No | Reclaim an existing inbox (for agent restart). See Behavior. |
| `--help` | No | Print usage and exit zero. |

## Behavior

### Normal (first registration)

1. Resolve inbox path: `<workspace>/.inbox/<name>/`.
2. Attempt to create the inbox directory **without** `-Force` / `--exist-ok`. The
   directory creation must fail if the directory already exists.
3. If creation fails because directory already exists → exit 2 with error on stderr:
   `inbox '<name>' is already registered`.
4. If creation succeeds → create `archive/` subdirectory.
5. Touch signal file `<workspace>/.inbox/<name>/.signal` (empty or timestamp content).
6. Exit zero.

### With --force (agent restart / reclaim)

1. Resolve inbox path.
2. If directory already exists, skip creation (treat as already owned).
3. If directory does not exist, create it (and `archive/`).
4. Touch signal file unconditionally.
5. Exit zero. **Never** fails due to pre-existing inbox.

`--force` does not drain or delete any existing messages.

## Output

No output on success (stdout empty). Tool writes errors to stderr.

## Exit Codes

| Code | Meaning |
| --- | --- |
| 0 | Inbox registered (or reclaimed with --force) |
| 1 | Missing required argument |
| 2 | Name already taken (inbox exists, --force not set) |
| 3 | Filesystem error (cannot create directory or write signal file) |

## Constraints

- MUST use atomic directory creation (fail-if-exists, not create-or-open).
- MUST NOT delete or modify any existing message files when `--force` is used.
- MUST write an error to stderr on exit 2 naming the taken inbox.
- Signal file write MUST succeed on init (unlike `post` where it is tolerated); failure
  exits 3 because the watcher cannot attach without a signal file.
