#!/usr/bin/env bash
# lint.sh — in-place auto-fix: MD009 (trailing spaces), MD012 (consecutive blank lines), MD047 (trailing newline)
# Usage: lint.sh <file>
# Exit: 0 success; 1 error (stderr)
# Deps: bash 4.3+. No external tools.

set -euo pipefail

if [[ $# -ne 1 ]]; then
  printf 'ERROR: usage: lint.sh <file>\n' >&2
  exit 1
fi

FILE="$1"
if [[ ! -f "$FILE" ]]; then
  printf 'ERROR: file not found: %s\n' "$FILE" >&2
  exit 1
fi
if [[ ! -w "$FILE" ]]; then
  printf 'ERROR: file not writable: %s\n' "$FILE" >&2
  exit 1
fi

mapfile -t LINES < "$FILE"

result=()
prev_blank=false

for L in "${LINES[@]}"; do
  # Normalize CRLF
  L="${L%$'\r'}"
  # MD009: strip trailing whitespace
  while [[ "$L" =~ [[:space:]]$ ]]; do
    L="${L%?}"
  done
  # MD012: collapse consecutive blank lines
  if [[ "$L" =~ ^[[:space:]]*$ ]]; then
    [[ "$prev_blank" == true ]] && continue
    prev_blank=true
  else
    prev_blank=false
  fi
  result+=("$L")
done

# Write UTF-8 LF; MD047: printf '%s\n' appends LF after every line including last
if (( ${#result[@]} > 0 )); then
  printf '%s\n' "${result[@]}" > "$FILE"
else
  printf '' > "$FILE"
fi
