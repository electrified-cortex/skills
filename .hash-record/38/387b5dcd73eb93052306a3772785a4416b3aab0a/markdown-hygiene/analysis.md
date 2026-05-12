---
file_path: messaging/spec.md
operation_kind: markdown-hygiene-analysis
result: fixed
---

# Result

## Advisory

- SA006 [FAIL] line 230: R19 input list has a single item (`--inbox`).
  Note: The list under "The drain tool MUST accept the following inputs" contains exactly one entry; a single-item list is better expressed as an inline sentence in the requirement body.

- SA006 [FAIL] line 263: R_N1 input list has a single item (`--inbox`).
  Note: The list under "The status tool MUST accept the following inputs" contains exactly one entry; same pattern as R19.

- SA003 [WARN] document-level: `MUST` appears 50+ times throughout the document.
  Note: RFC 2119 usage is intentional here, but the density is high enough to qualify as signal collapse under this rule; reviewers may find the uniform emphasis reduces salience of any one directive.

- SA009 [WARN] line 20: `**\`status\`**` definition list item spans 4 sentences.
  Note: "A lightweight, read-only probe. An agent wires this directly to its Monitor as the signal-change callback. `status` counts unclaimed messages in the inbox and outputs the pending count. Does not claim, read, or modify any files." ΓÇö four sentences as a single bullet may warrant a sub-section or collapsed form.

- SA009 [WARN] line 70: `**Init tool**` definition list item spans 4 sentences.
  Note: "the tool an agent invokes once on startup to register its identity. Creates the inbox directory, archive subdirectory, and signal file. Uses atomic directory creation to guarantee only one agent claims a given name. Supports `--force` for agent restart (reclaim without failing)." ΓÇö four sentences in one definition entry.

- SA009 [WARN] line 90: `**Signal file**` definition list item spans 4 sentences.
  Note: "the file `.inbox/<agent-name>/.signal`, used exclusively as a wake trigger. The post tool writes this file after each successful message write. The recipient's Monitor watches this file for changes. Signal file content is not meaningful; any change to it means 'at least one new message may be pending.'" ΓÇö four sentences in one definition entry.

- SA009 [WARN] line 242: R22a list sub-item spans 2 sentences.
  Note: "Claim the file before reading it. If the claim fails (file gone or already claimed by a concurrent drain), skip the file silently." ΓÇö two sentences as a single enumerated sub-item; borderline, but noted per the rule.

- SA010 [WARN] line 369: `--force` appears without backticks in the Error Handling table cell.
  Note: The cell reads "exit 2 if already taken (without --force)" ΓÇö `--force` is a shell flag and should be backtick-wrapped for consistency with every other occurrence of the same flag in the document.

- SA012 [WARN] line 106: `## Requirements` is immediately followed by `### Init Tool Interface` (line 108) with no content between.
  Note: The top-level Requirements heading has no introductory sentence or paragraph before the first sub-section heading.

- SA012 [WARN] line 315: `## Behavior` is immediately followed by `### Posting a Message` (line 317) with no content between.
  Note: Same pattern ΓÇö the Behavior section heading has no framing prose before its first sub-section.

- SA018 [WARN] line 162: directive uses passive voice: "deterministic values MUST NOT be used as the nonce."
  Note: Active form would be "The post tool MUST NOT use sequential counters, PIDs, or deterministic values as the nonce."

- SA018 [WARN] line 176: directive uses passive voice: "The JSON object MUST be compact... and UTF-8 encoded."
  Note: "UTF-8 encoded" is a passive participial; active form would specify the writer as subject: "The post tool MUST write the JSON object as compact, UTF-8-encoded text."

- SA018 [WARN] line 179: directive uses passive voice: "A message file MUST NOT be modified after it has been written to the inbox."
  Note: Active form: "No agent or tool MUST modify a message file after it has been written to the inbox." (or restructured to name the responsible party).

- SA018 [WARN] line 200: directive uses passive voice: "a human-readable error message MUST be written to stderr."
  Note: Active form: "the tool MUST write a human-readable error message to stderr." Appears at both R0e (line 131) and R14 (line 200).

- SA028 [WARN] lines 130 and 199: two-sentence block "exit with a zero exit code on success and a non-zero exit code on failure. On failure, a human-readable error message MUST be written to stderr." appears verbatim in R0e and R14.
  Note: Identical phrasing in both the init and post tool interface sections; could be extracted to a shared boilerplate note or normalised to a single referenced exit-code convention.

- SA028 [WARN] lines 22 and 81: phrase "does not claim, read, or modify any files" appears verbatim in both the Purpose list and the `**Status tool**` definition.
  Note: Minor duplication across two sections; not harmful, but noted.

- SA032 [WARN] document-level: "agent name" and "canonical name" are used as synonyms throughout.
  Note: The Definitions section defines the concept as `**Agent name**`, then R0a, R2, R11, and others use "canonical name" or "agent's canonical name" to refer to the same identifier. Consistent use of one term would reduce ambiguity.

- SA035 [WARN] line 145: action stated before gate condition in R4.
  Note: "The post tool MUST create the recipient's inbox directory if it does not already exist" ΓÇö the conditional guard ("if it does not already exist") follows the action. Preferred order: "If the recipient's inbox directory does not already exist, the post tool MUST create it before writing the message file."

- SA014 [SUGGEST] line 399: directive word "always" appears unemphasized in the Don'ts section.
  Note: "always invoke the `post` tool" ΓÇö the word "always" carries directive weight but is in plain prose; consistent with RFC 2119 style elsewhere, this could be "MUST always invoke" or written as "invoke only via the `post` tool."
