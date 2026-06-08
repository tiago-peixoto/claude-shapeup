#!/bin/bash
# test-build-scope-format.sh — Unit tests for the scope-file template in skills/build/SKILL.md
# Asserts the build prompt emits behavioral-test vocabulary ([RED]/[GREEN]) rather than
# the legacy task-checkbox template.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL="$PROJECT_ROOT/skills/build/SKILL.md"

PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); echo "  ✓ $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  ✗ $1"; }

assert_file_contains() {
  local file="$1"
  local expected="$2"
  local desc="$3"
  if grep -qF "$expected" "$file"; then
    pass "$desc"
  else
    fail "$desc (expected '$expected' in $file)"
  fi
}

assert_file_lacks_line() {
  local file="$1"
  local pattern="$2"
  local desc="$3"
  if grep -qxF "$pattern" "$file"; then
    fail "$desc (found forbidden line '$pattern' in $file)"
  else
    pass "$desc"
  fi
}

echo "=== Build scope-file format: behavioral-test template ==="

assert_file_contains "$SKILL" "## Behaviors (must-have)" "emits must-have behaviors heading"
assert_file_contains "$SKILL" "## Behaviors (nice-to-have, ~)" "emits nice-to-have behaviors heading"
assert_file_contains "$SKILL" "[RED]" "uses [RED] marker"
assert_file_contains "$SKILL" "[GREEN]" "uses [GREEN] marker"
assert_file_lacks_line "$SKILL" "## Must-Haves" "no legacy '## Must-Haves' heading in scope template"

echo ""
echo "=== Results ==="
echo "  PASS: $PASS"
echo "  FAIL: $FAIL"
[ "$FAIL" -eq 0 ] && echo "All build scope-format tests passed." || echo "$FAIL test(s) failed."
exit "$FAIL"
