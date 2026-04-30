#!/usr/bin/env bash
# result.sh — markdown-hygiene result check
# Usage: result.sh <markdown_file_path> <filename>
# <filename>: report | lint | analysis  (bare name, no .md extension)
# Outputs one line:
#   CLEAN                        (report HIT, result: clean)
#   clean: <abs-path>            (non-report HIT, result: clean)
#   pass: <abs-path>             (HIT, result: pass)
#   findings: <abs-path>         (HIT, result: fail)
#   MISS: <abs-path>             (no cache entry)
#   ERROR: <reason>              (exit 1)
set -euo pipefail

# Help
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    echo "Usage: result.sh <markdown_file_path> <filename>"
    exit 0
fi

# Validate args
if [ "${1:-}" = "" ]; then
    echo "ERROR: missing argument -- expected <markdown_file_path>"
    exit 1
fi
if [ "${2:-}" = "" ]; then
    echo "ERROR: missing filename argument"
    exit 1
fi

FILE_PATH="$1"
FILENAME="$2"

# Validate filename — no path separators or dots
if echo "$FILENAME" | grep -qE '[/\\.]'; then
    echo "ERROR: invalid filename: $FILENAME"
    exit 1
fi

RECORD_FILE="${FILENAME}.md"

# Locate hash-record-check
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CHECK_SH="${SCRIPT_DIR}/../../hash-record/hash-record-check/check.sh"

if [ ! -f "$CHECK_SH" ]; then
    echo "ERROR: cannot locate hash-record-check at: $CHECK_SH"
    exit 1
fi

# Invoke hash-record-check
CHECK_OUT=$(bash "$CHECK_SH" "$FILE_PATH" markdown-hygiene "$RECORD_FILE" 2>/dev/null) || {
    echo "ERROR: hash-record-check failed for: $FILE_PATH"
    exit 1
}

# Branch on hash-record-check stdout
case "$CHECK_OUT" in
    "MISS: "*)
        echo "$CHECK_OUT"
        exit 0
        ;;
    "ERROR: "*)
        echo "$CHECK_OUT"
        exit 1
        ;;
    "HIT: "*)
        RECORD_PATH="${CHECK_OUT#HIT: }"
        if [ ! -f "$RECORD_PATH" ]; then
            echo "ERROR: cache record vanished at: $RECORD_PATH"
            exit 1
        fi
        RESULT_VALUE=$(grep -m1 '^result:' "$RECORD_PATH" 2>/dev/null | awk '{print $2}')
        case "$RESULT_VALUE" in
            clean)
                if [ "$FILENAME" = "report" ]; then
                    echo "CLEAN"
                else
                    echo "clean: $RECORD_PATH"
                fi
                exit 0
                ;;
            fail)
                echo "findings: $RECORD_PATH"
                exit 0
                ;;
            pass)
                echo "pass: $RECORD_PATH"
                exit 0
                ;;
            *)
                echo "ERROR: malformed cache record at $RECORD_PATH"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "ERROR: unrecognized hash-record-check output: $CHECK_OUT"
        exit 1
        ;;
esac


# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  cat <<'USAGE'
Usage: result <markdown_file_path>

Wraps hash-record-check for markdown-hygiene and translates a HIT into
the cached verdict by reading the report's frontmatter.

Arguments:
  markdown_file_path  Absolute path to the .md file (must be readable).

Output (stdout, one line):
  CLEAN                       Cached report says result: pass.
  findings: <abs-path>        Cached report says result: findings.
  MISS: <abs-path>            No cache entry; this path is where the
                              executor MUST write its report.
  ERROR: <reason>             Argument or runtime error, or malformed
                              cache record.

Exit codes:
  0  Success (CLEAN, findings, or MISS).
  1  Error.
USAGE
  exit 0
fi

# ---------------------------------------------------------------------------
# Argument validation
# ---------------------------------------------------------------------------
if [ "$#" -lt 1 ]; then
  echo "ERROR: missing argument -- expected <markdown_file_path>"
  exit 1
fi

FILE_PATH="$1"

# ---------------------------------------------------------------------------
# Locate sibling check.sh (hash-record-check)
# ---------------------------------------------------------------------------
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CHECK_SH="${SCRIPT_DIR}/../../hash-record/hash-record-check/check.sh"

if [ ! -f "$CHECK_SH" ]; then
  echo "ERROR: cannot locate hash-record-check at: $CHECK_SH"
  exit 1
fi

# ---------------------------------------------------------------------------
# Invoke hash-record-check
# ---------------------------------------------------------------------------
CHECK_OUT=$(bash "$CHECK_SH" "$FILE_PATH" markdown-hygiene report.md 2>/dev/null) || {
  echo "ERROR: hash-record-check failed for: $FILE_PATH"
  exit 1
}

# ---------------------------------------------------------------------------
# Branch on hash-record-check stdout
# ---------------------------------------------------------------------------
case "$CHECK_OUT" in
  "MISS: "*)
    echo "$CHECK_OUT"
    exit 0
    ;;
  "ERROR: "*)
    echo "$CHECK_OUT"
    exit 1
    ;;
  "HIT: "*)
    REPORT_PATH="${CHECK_OUT#HIT: }"
    if [ ! -f "$REPORT_PATH" ]; then
      echo "ERROR: cache record vanished at: $REPORT_PATH"
      exit 1
    fi
    # Parse frontmatter result: line. Take first whitespace-separated token after the colon.
    RESULT_VALUE=$(grep -m1 '^result:' "$REPORT_PATH" 2>/dev/null | awk '{print $2}')
    case "$RESULT_VALUE" in
      pass)
        echo "CLEAN"
        exit 0
        ;;
      findings)
        echo "findings: $REPORT_PATH"
        exit 0
        ;;
      *)
        echo "ERROR: malformed cache record at $REPORT_PATH"
        exit 1
        ;;
    esac
    ;;
  *)
    echo "ERROR: unrecognized hash-record-check output: $CHECK_OUT"
    exit 1
    ;;
esac
