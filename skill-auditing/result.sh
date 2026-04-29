#!/usr/bin/env bash
# result.sh — skill-auditing result tool
# Wraps hash-record-manifest and translates HIT into the cached audit verdict.
# Usage: result <skill_dir>
# Outputs one of:
#   PASS: <abs-path>            (HIT, result: pass)         (exit 0)
#   NEEDS_REVISION: <abs-path>  (HIT, result: findings)     (exit 0)
#   FAIL: <abs-path>            (HIT, result: error)        (exit 0)
#   MISS: <abs-path>            (no cache; this is the report path) (exit 0)
#   ERROR: <reason>             (argument or runtime error) (exit 1)
set -e

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  cat <<'USAGE'
Usage: result <skill_dir>

Wraps hash-record-manifest for skill-auditing and translates a HIT into
the cached audit verdict by reading the report's frontmatter.

Arguments:
  skill_dir  Absolute path to the skill folder being audited.
             Tool enumerates spec.md, uncompressed.md,
             instructions.uncompressed.md (whichever exist).

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
  echo "ERROR: missing argument -- expected <skill_dir> [--uncompressed]"
  exit 1
fi

SKILL_DIR="$1"
shift

# Parse optional --uncompressed flag
OP_KIND="skill-auditing/v1.2-compiled"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --uncompressed)
      OP_KIND="skill-auditing/v1.2-uncompressed"
      shift
      ;;
    *)
      echo "ERROR: unknown argument: $1"
      exit 1
      ;;
  esac
done

if [ ! -d "$SKILL_DIR" ]; then
  echo "ERROR: skill_dir not found: $SKILL_DIR"
  exit 1
fi

# Enumerate ALL regular files in skill_dir, recursively, skipping any file
# whose path passes through a dot-prefixed DIRECTORY (e.g. .hash-record/,
# .tests/, .worktrees/). Dot-prefixed FILES (e.g. .gitignore) ARE included.
FILES=()
while IFS= read -r -d '' F; do
  # Strip leading "./" then check each directory component for dot-prefix.
  # The leaf filename is excluded from this check (dotfiles allowed at leaf).
  REL="${F#./}"
  DIR_PART="$(dirname "$REL")"
  if [ "$DIR_PART" != "." ]; then
    # Walk each segment of the directory path.
    SKIP=0
    IFS='/' read -ra SEGS <<< "$DIR_PART"
    for SEG in "${SEGS[@]}"; do
      case "$SEG" in
        .*) SKIP=1; break ;;
      esac
    done
    [ "$SKIP" -eq 1 ] && continue
  fi
  FILES+=("$F")
done < <(cd "$SKILL_DIR" && find . -type f -print0 | LC_ALL=C sort -z)

# Convert relative paths back to absolute by prepending skill_dir
ABS_FILES=()
for F in "${FILES[@]}"; do
  # Strip leading "./"
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

# Invoke manifest with computed op_kind + record_filename=report.md
MANIFEST_OUT=$(bash "$MANIFEST_SH" "$OP_KIND" "report.md" "${FILES[@]}" 2>/dev/null) || {
  echo "ERROR: hash-record-manifest failed for: $SKILL_DIR"
  exit 1
}

# Branch on manifest stdout
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
    # Parse frontmatter result: line.
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
