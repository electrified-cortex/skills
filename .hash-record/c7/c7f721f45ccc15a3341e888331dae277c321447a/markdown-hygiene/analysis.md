---
file_path: messaging/status.spec.md
operation_kind: markdown-hygiene-analysis
result: fixed
---

# Result

## Advisory

- SA010 [WARN] line 24: `stdout` appears unbackticked in a directive list item.
  Note: Other technical identifiers in the file (`$PWD`, `*.json`, `*.json.claimed`) use backtick formatting; `stdout` is a technical stream name of the same class.

- SA018 [WARN] line 39: "Output is written even when N is zero." uses passive voice in a specification sentence.
  Note: The passive construction "is written" describes tool behavior; the Behavior list items use active imperative form ("Resolve", "Count", "Get", "Output", "Exit").

- SA035 [WARN] line 39: Action stated before gate condition ΓÇö "Output is written even when N is zero."
  Note: The gate condition ("when N is zero") follows the action; the exceptional case appears at the end of the sentence rather than leading.

- SA037 [WARN] line 20: Behavior list item 2 is a declarative conditional rule mixed among active-imperative command items without a distinguishing signal.
  Note: Items 1 and 3ΓÇô6 are imperative commands; item 2 reads as a declarative state rule ("If ΓÇª does not exist, count is zero"), with no signal to indicate the different item type.
