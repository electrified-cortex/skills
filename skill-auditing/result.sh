#!/usr/bin/env bash
# result.sh — skill-auditing result tool
# Usage: result.sh [--uncompressed] <skill_dir>
# Outputs one of:
#   PASS: <abs-path>            (HIT, result: pass)         (exit 0)
#   NEEDS_REVISION: <abs-path>  (HIT, result: findings)     (exit 0)
#   FAIL: <abs-path>            (HIT, result: error)        (exit 0)
#   MISS: <abs-path>            (no cache; this is the report path) (exit 0)
#   ERROR: <reason>             (argument or runtime error) (exit 1)
set -e

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  cat <<'USAGE'
Usage: result.sh [--uncompressed] <skill_dir>

Wraps hash-record-manifest for skill-auditing and translates a HIT into
the cached audit verdict by reading the report's frontmatter.

Arguments:
  skill_dir        Absolute path to the skill folder being audited.
                   Skill dir must be inside a git repository.

Options:
  --uncompressed   Switch audit focus to uncompressed sources
                   (uses op_kind skill-auditing/v2-uncompressed instead
                   of the default skill-auditing/v2-compiled).
  --help / -h      Print usage, exit 0.

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

# Parse --uncompressed flag
UNCOMPRESSED=0
POSITIONAL=()
for ARG in "$@"; do
  case "$ARG" in
    --uncompressed)
      UNCOMPRESSED=1
      ;;
    *)
      POSITIONAL+=("$ARG")
      ;;
  esac
done

if [ "${#POSITIONAL[@]}" -lt 1 ]; then
  echo "ERROR: missing argument -- expected <skill_dir>"
  exit 1
fi

SKILL_DIR="${POSITIONAL[0]}"
RECORD_FILE="report.md"

if [ ! -d "$SKILL_DIR" ]; then
  echo "ERROR: skill_dir not found: $SKILL_DIR"
  exit 1
fi

SKILL_DIR=$(cd "$SKILL_DIR" && pwd)

# Verify skill_dir is inside a git repo — fail explicitly instead of silent fallback
git -C "$SKILL_DIR" rev-parse --show-toplevel >/dev/null 2>&1 || {
    echo "ERROR: skill_dir is not inside a git repository: $SKILL_DIR"
    exit 1
}

# Enumerate ALL regular files inside skill_dir recursively.
# Skip: (a) any file whose path passes through a dot-prefixed directory,
#        (b) any file whose leaf name is optimize-log.md.
# Dot-prefixed FILES at any depth are included.
# Sort lexically by path (byte order) for a stable hash key.
FILES=()
while IFS= read -r -d '' FILE; do
  # Check for dot-prefixed directory component in the path relative to skill_dir
  REL="${FILE#"$SKILL_DIR/"}"
  SKIP=0
  IFS='/' read -ra PARTS <<< "$REL"
  # Check all but the last component (directories)
  for (( i=0; i<${#PARTS[@]}-1; i++ )); do
    case "${PARTS[$i]}" in
      .*)
        SKIP=1
        break
        ;;
    esac
  done
  # Check leaf name
  LEAF="${PARTS[${#PARTS[@]}-1]}"
  if [ "$LEAF" = "optimize-log.md" ]; then
    SKIP=1
  fi
  if [ "$SKIP" -eq 0 ]; then
    FILES+=("$FILE")
  fi
done < <(find "$SKILL_DIR" -type f -print0 | LC_ALL=C sort -z)

if [ "${#FILES[@]}" -eq 0 ]; then
  echo "ERROR: no files found in skill_dir"
  exit 1
fi

# Select op_kind based on --uncompressed flag
if [ "$UNCOMPRESSED" -eq 1 ]; then
  OP_KIND="skill-auditing/v2-uncompressed"
else
  OP_KIND="skill-auditing/v2-compiled"
fi

# Locate sibling manifest tool
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MANIFEST_SH="${SCRIPT_DIR}/../hash-record/hash-record-manifest/manifest.sh"

if [ ! -f "$MANIFEST_SH" ]; then
  echo "ERROR: cannot locate hash-record-manifest at: $MANIFEST_SH"
  exit 1
fi

# Invoke manifest
MANIFEST_OUT=$(bash "$MANIFEST_SH" "$OP_KIND" "$RECORD_FILE" "${FILES[@]}") || {
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
