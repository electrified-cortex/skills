# ERROR-HANDLING — 2026-05-08

## Findings

### HASH RECORD WRITE FAILURE UNHANDLED — MEDIUM

**Severity:** MEDIUM
**Finding:** Steps 5 and 8 both write to `.hash-record/`. No E entry established that write failures are non-fatal. An implementor encountering a filesystem error at Step 5 has no instruction to log-and-continue; they may abort the swarm. A partial write (file exists, truncated) would fool B10 into treating it as complete. No recovery path defined.
**Action taken:** Added E7 to both files: hash record write failure is non-fatal — log and continue. Step 5 failure: continue dispatching; B10 re-dispatches on next run. Step 8 failure: result already returned — log normally.

### E3 PROMPT LOAD FAILURE NOT COVERED — MEDIUM

**Severity:** MEDIUM
**Finding:** E3 covered dispatch failure (Step 5 event) but not prompt load failure (Step 4 event). A file passing metadata validation can still fail to load its prompt body. An implementor reading E3 would not apply it to Step 4 events, potentially aborting the personality without noting it.
**Action taken:** Extended E3 in both files to explicitly include "prompt load failure at Step 4." Added inline note to Step 4 in both files: "If a prompt file cannot be loaded, treat the personality as non-contributing per E3 and continue."

### E3 "INCOHERENT OUTPUT" UNDEFINED — MEDIUM

**Severity:** MEDIUM
**Finding:** E3's "incoherent output" trigger was undefined. Three adjacent rules (E3, B4, Step 8 Non-contributing field) had inconsistent non-contributing triggers: E3 said "incoherent," B4 said "no findings or times out," synthesis field said "empty output or timed out." The boundary between valid "No findings" and incoherent was not specified.
**Action taken:** Added definition to E3 in both files: incoherent = cannot be parsed into structured findings list and is not a recognizable "No findings" statement. "No findings" with brief rationale is valid, not incoherent. Also aligned Non-contributing personality field in required fields list and template tooltip to include "incoherent output" alongside empty/timeout.
