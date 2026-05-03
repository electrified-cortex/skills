#!/usr/bin/env bash
# rekey.sh — hash-record re-key after file content change
# Usage: rekey <file_path> <op_kind> <record_filename> [source_hash]
# Outputs one of:
#   REKEYED: <new_abs_path>
#   CURRENT: <abs_path>
#   NOT_FOUND: no record for <op_kind>/<record_filename>
#   AMBIGUOUS: <n> records found -- manual resolution required
#   ERROR: <reason>
set -e

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  cat <<'USAGE'
Usage: rekey <file_path> <op_kind> <record_filename> [source_hash]

Re-key a hash-record entry after the source file content changes.

Arguments:
  file_path        Absolute path to the changed file (new content, not yet committed).
  op_kind          Operation kind, e.g. "markdown-hygiene" or "skill-auditing/v2". May contain /.
  record_filename  Leaf filename, e.g. "claude-haiku.md". No path separators or ...
  source_hash      (Optional) The known old content hash to rekey from. Skips full-tree search when provided.

Output (stdout, one line):
  REKEYED: <abs-path>   Record moved to new hash path.
  CURRENT: <abs-path>   Old hash == new hash. No move needed.
  NOT_FOUND: ...        No record exists for this op_kind/record_filename.
  AMBIGUOUS: <n> ...    Multiple records found -- manual resolution required.
  ERROR: <reason>       Argument or runtime error.

Exit codes:
  0   Success (REKEYED, CURRENT, or NOT_FOUND).
  1   Error (AMBIGUOUS or ERROR).
USAGE
  exit 0
fi

if [ "$#" -lt 3 ]; then
  printf 'ERROR: missing arguments -- expected <file_path> <op_kind> <record_filename>\n'
  exit 1
fi

FILE_PATH="$1"
OP_KIND="$2"
RECORD_FILENAME="$3"
SOURCE_HASH="$4"

case "$OP_KIND" in
  *..* | *\\*)
    printf 'ERROR: invalid op_kind: %s\n' "$OP_KIND"
    exit 1
    ;;
esac

case "$RECORD_FILENAME" in
  *..* | */* | *\\*)
    printf 'ERROR: invalid record_filename: %s\n' "$RECORD_FILENAME"
    exit 1
    ;;
esac

TARGET_DIR=$(dirname "$FILE_PATH")
REPO_ROOT=$(git -C "$TARGET_DIR" rev-parse --show-toplevel 2>/dev/null) || true
if [ -z "$REPO_ROOT" ]; then
  REPO_ROOT="$TARGET_DIR"
  printf 'WARN: not in a git repo; falling back to file parent dir: %s\n' "$REPO_ROOT" >&2
fi

NEW_HASH=$(git hash-object "$FILE_PATH" 2>/dev/null) || {
  printf 'ERROR: git hash-object failed for: %s\n' "$FILE_PATH"
  exit 1
}
[ -z "$NEW_HASH" ] && { printf 'ERROR: git hash-object returned empty hash\n'; exit 1; }
NEW_SHARD="${NEW_HASH:0:2}"

HASH_RECORD_ROOT="$REPO_ROOT/.hash-record"

if [ ! -d "$HASH_RECORD_ROOT" ]; then
  printf 'NOT_FOUND: no record for %s/%s\n' "$OP_KIND" "$RECORD_FILENAME"
  exit 0
fi

if [ -n "$SOURCE_HASH" ]; then
  OLD_RECORD_PATH="$HASH_RECORD_ROOT/${SOURCE_HASH:0:2}/$SOURCE_HASH/$OP_KIND/$RECORD_FILENAME"
  if [ ! -f "$OLD_RECORD_PATH" ]; then
    printf 'NOT_FOUND: no record for %s/%s at %s\n' "$OP_KIND" "$RECORD_FILENAME" "$SOURCE_HASH"
    exit 0
  fi
  OLD_HASH="$SOURCE_HASH"
else
  FOUND=()
  while IFS= read -r -d '' candidate; do
    FOUND+=("$candidate")
  done < <(find "$HASH_RECORD_ROOT" -type f -path "*/${OP_KIND}/${RECORD_FILENAME}" -print0 2>/dev/null)

  COUNT="${#FOUND[@]}"

  if [ "$COUNT" -eq 0 ]; then
    printf 'NOT_FOUND: no record for %s/%s\n' "$OP_KIND" "$RECORD_FILENAME"
    exit 0
  fi

  if [ "$COUNT" -gt 1 ]; then
    printf 'AMBIGUOUS: %d records found -- manual resolution required\n' "$COUNT"
    exit 1
  fi

  OLD_RECORD_PATH="${FOUND[0]}"
  AFTER_PREFIX="${OLD_RECORD_PATH#${HASH_RECORD_ROOT}/}"
  OLD_SHARD="${AFTER_PREFIX%%/*}"
  AFTER_SHARD="${AFTER_PREFIX#*/}"
  OLD_HASH="${AFTER_SHARD%%/*}"
fi

if [ "$OLD_HASH" = "$NEW_HASH" ]; then
  printf 'CURRENT: %s\n' "$OLD_RECORD_PATH"
  exit 0
fi

NEW_RECORD_DIR="$HASH_RECORD_ROOT/$NEW_SHARD/$NEW_HASH/$OP_KIND"
NEW_RECORD_PATH="$NEW_RECORD_DIR/$RECORD_FILENAME"

mkdir -p "$NEW_RECORD_DIR"

OLD_REL="${OLD_RECORD_PATH#${REPO_ROOT}/}"
NEW_REL="${NEW_RECORD_PATH#${REPO_ROOT}/}"

git -C "$REPO_ROOT" mv "$OLD_REL" "$NEW_REL"

printf 'REKEYED: %s\n' "$NEW_RECORD_PATH"
exit 0
