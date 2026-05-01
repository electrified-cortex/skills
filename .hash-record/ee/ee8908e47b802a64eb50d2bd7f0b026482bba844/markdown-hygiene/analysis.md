---
file_path: gh-cli/gh-cli-actions/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 38: `stdin` in plain prose without backticks
  Note: "stdin" is a shell/system literal and appears unbackticked in the Requirements section alongside backtick-wrapped flags and commands.

- SA010 [WARN] line 44: `stdin` in plain prose without backticks
  Note: Same term recurs unbackticked in the Behavior paragraph; both occurrences are consistent with each other but inconsistent with the surrounding backtick discipline.

- SA014 [SUGGEST] line 38: "never" unemphasized in directive sentence
  Note: "never hard-coding the secret value in a command argument" issues a hard prohibition with no visual emphasis on the prohibitive term.

- SA014 [SUGGEST] line 44: "always" and "never" unemphasized in directive sentence
  Note: "must always be piped" and "never passed as command arguments" both carry constraint weight in this directive but receive no emphasis.

- SA014 [SUGGEST] line 48: "must not" unemphasized in directive sentence
  Note: "the agent must not assume success" issues a constraint without emphasis on the negation.

- SA018 [WARN] line 44: passive voice in directive — "Secret values must always be piped from stdin"
  Note: The subject "Secret values" is acted upon rather than acting; rephrasing with the agent as subject ("the agent must always pipe secret values from stdin…") would make the directive more direct.

- SA028 [WARN] line 63: "Operator approval required before execution" appears verbatim 10 times in the Safety Classification table
  Note: Expected in a table context but the phrase is identical across all 10 destructive-operation rows with no variation; a table footnote with a single canonical statement and a marker per row would eliminate the repetition.

- SA032 [WARN] line 9: "environment variables" used in Scope where the rest of the document uses "variables"
  Note: "setting or deleting secrets and environment variables" in the Scope paragraph may be read as referring to a different concept than "secrets and variables" used consistently elsewhere; the Definitions section distinguishes repository-level vs environment-level variables, neither of which is synonymous with "environment variables" as a general term.

- SA035 [WARN] line 52: action stated before gate condition in Precedence Rules
  Note: "Repository-level secrets and variables take precedence in scope resolution unless the environment name is explicitly specified" places the outcome before the exception condition; inverting to "Unless the environment name is explicitly specified, repository-level secrets and variables take precedence" follows the gate-then-action pattern.

- SA036 [WARN] line 44: Behavior directive sentence has 5 coordinating conjunctions
  Note: The sentence enumerates the full operation lifecycle with "and"/"or" connectors — "listing and enabling", "triggering a run and capturing its run ID", "full run or specific job", "and managing", "repository or environment scope"; splitting into multiple sentences or a bullet list would reduce cognitive load.

- SA038 [FAIL] lines 26 and 48: contradictory log-viewing instructions
  Note: The Intent section (line 26) lists "View logs for a failed run to diagnose the cause" while the Error Handling section (line 48) states "the agent must view logs for the specific failed job rather than the full run" — one requires run-level logs, the other explicitly forbids them in favour of job-level logs for failure diagnosis.
