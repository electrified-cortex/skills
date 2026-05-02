#!/usr/bin/env bash
# result.sh — skill-auditing result tool
# Usage: result.sh <skill_dir> <mode>
#   mode: report | uncompressed
# Outputs one of:
#   PASS: <abs-path>            (HIT, result: pass)         (exit 0)
#   NEEDS_REVISION: <abs-path>  (HIT, result: findings)     (exit 0)
#   FAIL: <abs-path>            (HIT, result: error)        (exit 0)
#   MISS: <abs-path>            (no cache; this is the report path) (exit 0)
#   ERROR: <reason>             (argument or runtime error) (exit 1)
set -e

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  cat <<'USAGE'
Usage: result.sh <skill_dir> <mode>

Wraps hash-record-manifest for skill-auditing and translates a HIT into
the cached audit verdict by reading the report's frontmatter.

Arguments:
  skill_dir  Absolute path to the skill folder being audited.
             Tool enumerates all files recursively, excluding
             dot-prefixed directories and optimize-log.md.
  mode       report       — compiled artifacts cache (SKILL.md + instructions.txt)
             uncompressed — source artifacts cache (uncompressed.md + instructions.uncompressed.md + spec.md)

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

if [ "$#" -lt 2 ]; then
  echo "ERROR: missing arguments -- expected <skill_dir> <mode>"
  exit 1
fi

SKILL_DIR="$1"
MODE="$2"

case "$MODE" in
  report)
    RECORD_FILE="report.md"
    ;;
  uncompressed)
    RECORD_FILE="uncompressed.md"
    ;;
  *)
    echo "ERROR: invalid mode: $MODE (expected: report | uncompressed)"
    exit 1
    ;;
esac

if [ ! -d "$SKILL_DIR" ]; then
  echo "ERROR: skill_dir not found: $SKILL_DIR"
  exit 1
fi

# Enumerate ALL regular files in skill_dir, recursively, skipping any file
# whose path passes through a dot-prefixed DIRECTORY (e.g. .hash-record/,
# .tests/, .worktrees/). Dot-prefixed FILES (e.g. .gitignore) ARE included.
FILES=()
while IFS= read -r -d '' F; do
  REL="${F#./}"
  DIR_PART="$(dirname "$REL")"
  if [ "$DIR_PART" != "." ]; then
    SKIP=0
    IFS='/' read -ra SEGS <<< "$DIR_PART"
    for SEG in "${SEGS[@]}"; do
      case "$SEG" in
        .*) SKIP=1; break ;;
      esac
    done
    [ "$SKIP" -eq 1 ] && continue
  fi
  [ "${REL##*/}" = "optimize-log.md" ] && continue
  FILES+=("$F")
done < <(cd "$SKILL_DIR" && find . -type f -print0 | LC_ALL=C sort -z)

ABS_FILES=()
for F in "${FILES[@]}"; do
  REL="${F#./}"
  ABS_FILES+=("$SKILL_DIR/$REL")
done
FILES=("${ABS_FILES[@]}")

if [ "${#FILES[@]}" -eq 0 ]; then
  echo "ERROR: no files found in skill_dir"
  exit 1
fi

# Locate sibling manifest tool
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MANIFEST_SH="${SCRIPT_DIR}/../hash-record/hash-record-manifest/manifest.sh"

if [ ! -f "$MANIFEST_SH" ]; then
  echo "ERROR: cannot locate hash-record-manifest at: $MANIFEST_SH"
  exit 1
fi

# Invoke manifest
MANIFEST_OUT=$(bash "$MANIFEST_SH" "skill-auditing/v2" "$RECORD_FILE" "${FILES[@]}" 2>/dev/null) || {
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
