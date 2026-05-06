#!/usr/bin/env bash
# verify.test.sh — eval suite for verify.sh
# Usage: verify.test.sh [path/to/verify.sh]
# Exit: 0 all pass; 1 one or more fail

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFY="${1:-"$SCRIPT_DIR/../../verify.sh"}"

if [[ ! -f "$VERIFY" ]]; then
  printf 'ERROR: verify.sh not found at: %s\n' "$VERIFY" >&2
  exit 1
fi

PASS=0
FAIL=0

run_fixture() {
  local name="$1"
  local fixture="$SCRIPT_DIR/$name"
  local expected="$SCRIPT_DIR/$name.expected.txt"

  if [[ ! -f "$fixture" ]]; then
    printf 'SKIP: %s (fixture missing)\n' "$name"
    return
  fi
  if [[ ! -f "$expected" ]]; then
    printf 'SKIP: %s (expected file missing)\n' "$name"
    return
  fi

  # Both $() expansions strip trailing newlines — compare trimmed output
  local actual
  actual="$(bash "$VERIFY" "$fixture")" || true

  local exp
  exp="$(cat "$expected")"

  if [[ "$actual" == "$exp" ]]; then
    printf 'PASS: %s\n' "$name"
    (( PASS++ )) || true
  else
    printf 'FAIL: %s\n' "$name"
    printf '  expected: %s\n' "$(cat "$expected" | cat -A)"
    printf '  actual:   %s\n' "$(printf '%s' "$actual" | cat -A)"
    (( FAIL++ )) || true
  fi
}

run_fixture clean.md
run_fixture trailing-spaces.md
run_fixture tabs.md
run_fixture blanks.md
run_fixture no-frontmatter-no-h1.md
run_fixture no-trailing-newline.md
run_fixture mono-escape-bad.md
run_fixture mono-escape-good.md

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
(( FAIL == 0 ))
