#!/usr/bin/env bash
# result.sh — skill-auditing result tool
# Usage: result.sh <skill_dir>
# Outputs one of:
#   PASS: <abs-path>            (HIT, result: pass)         (exit 0)
#   NEEDS_REVISION: <abs-path>  (HIT, result: findings)     (exit 0)
#   FAIL: <abs-path>            (HIT, result: error)        (exit 0)
#   MISS: <abs-path>            (no cache; this is the report path) (exit 0)
#   ERROR: <reason>             (argument or runtime error) (exit 1)
set -e

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  cat <<'USAGE'
Usage: result.sh <skill_dir>

Wraps hash-record-manifest for skill-auditing and translates a HIT into
the cached audit verdict by reading the report's frontmatter.

Arguments:
  skill_dir  Absolute path to the skill folder being audited.
             Tool hashes only semantic content files: SKILL.md,
             instructions.txt, spec.md, uncompressed.md,
             instructions.uncompressed.md (whichever exist).
             Skill dir must be inside a git repository.

Output (stdout, one line):
  PASS: <abs-path>            Cached report says result: pass.
  NEEDS_REVISION: <abs-path>  Cached report says result: findings.
  FAIL: <abs-path>            Cached report says result: error.
  MISS: <abs-path>            No cache entry; executor MUST write here.
  ERROR: <reason>             Argument, runtime, or malformed-record error.

Exit codes:
  0  Success (PASS, NEEDS_REVISION, FAIL, or MISS).
  1  Error.
USAGE
  exit 0
fi

if [ "$#" -lt 1 ]; then
  echo "ERROR: missing argument -- expected <skill_dir>"
  exit 1
fi

SKILL_DIR="$1"
RECORD_FILE="report.md"

if [ ! -d "$SKILL_DIR" ]; then
  echo "ERROR: skill_dir not found: $SKILL_DIR"
  exit 1
fi

SKILL_DIR=$(cd "$SKILL_DIR" && pwd)

# Enumerate only the semantic content files the audit agent reads.
# Hashing all files causes indeterminism when non-semantic files are
# added/modified between the pre- and post-dispatch result calls.
# Order is intentional — hash key must be identical between pre- and post-dispatch calls.
# Do not sort or reorder this list.
SEMANTIC_NAMES=("SKILL.md" "instructions.txt" "spec.md" "uncompressed.md" "instructions.uncompressed.md")
FILES=()
for NAME in "${SEMANTIC_NAMES[@]}"; do
    CANDIDATE="$SKILL_DIR/$NAME"
    if [ -f "$CANDIDATE" ]; then
        FILES+=("$CANDIDATE")
    fi
done

if [ "${#FILES[@]}" -eq 0 ]; then
  echo "ERROR: no files found in skill_dir"
  exit 1
fi

# Verify skill_dir is inside a git repo — fail explicitly instead of silent fallback
git -C "$SKILL_DIR" rev-parse --show-toplevel >/dev/null 2>&1 || {
    echo "ERROR: skill_dir is not inside a git repository: $SKILL_DIR"
    exit 1
}

# Locate sibling manifest tool
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MANIFEST_SH="${SCRIPT_DIR}/../hash-record/hash-record-manifest/manifest.sh"

if [ ! -f "$MANIFEST_SH" ]; then
  echo "ERROR: cannot locate hash-record-manifest at: $MANIFEST_SH"
  exit 1
fi

# Invoke manifest
MANIFEST_OUT=$(bash "$MANIFEST_SH" "skill-auditing/v2" "$RECORD_FILE" "${FILES[@]}") || {
  echo "ERROR: hash-record-manifest failed for: $SKILL_DIR"
  exit 1
}

case "$MANIFEST_OUT" in
  "MISS: "*)
    echo "$MANIFEST_OUT"
    exit 0
    ;;
  "ERROR: "*)
    echo "$MANIFEST_OUT"
    exit 1
    ;;
  "HIT: "*)
    REPORT_PATH="${MANIFEST_OUT#HIT: }"
    if [ ! -f "$REPORT_PATH" ]; then
      echo "ERROR: cache record vanished at: $REPORT_PATH"
      exit 1
    fi
    RESULT_VALUE=$(grep -m1 '^result:' "$REPORT_PATH" 2>/dev/null | awk '{print $2}')
    case "$RESULT_VALUE" in
      pass)
        echo "PASS: $REPORT_PATH"
        exit 0
        ;;
      findings)
        echo "NEEDS_REVISION: $REPORT_PATH"
        exit 0
        ;;
      error)
        echo "FAIL: $REPORT_PATH"
        exit 0
        ;;
      *)
        echo "ERROR: malformed cache record at $REPORT_PATH"
        exit 1
        ;;
    esac
    ;;
  *)
    echo "ERROR: unrecognized hash-record-manifest output: $MANIFEST_OUT"
    exit 1
    ;;
esac
