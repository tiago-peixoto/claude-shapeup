#!/bin/bash
# test-session-budget.sh — Unit tests for skills/build/scripts/check-session-budget.sh
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BUDGET="$PROJECT_ROOT/skills/build/scripts/check-session-budget.sh"

PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); echo "  ✓ $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  ✗ $1"; }

assert_output_contains() {
  local output="$1"
  local expected="$2"
  local desc="$3"
  if echo "$output" | grep -q "$expected"; then
    pass "$desc"
  else
    fail "$desc (expected '$expected' in output)"
  fi
}

echo "=== Session Budget: Small Batch ==="

TMPDIR=$(mktemp -d)
mkdir -p "$TMPDIR/scopes"
echo "**Appetite**: Small Batch (1 session)" > "$TMPDIR/package.md"
OUTPUT=$(bash "$BUDGET" "$TMPDIR")
assert_output_contains "$OUTPUT" "sessions_used=1" "first session = 1"
assert_output_contains "$OUTPUT" "appetite_label=Small Batch" "detects Small Batch"
assert_output_contains "$OUTPUT" "appetite_max=1" "max sessions = 1"
assert_output_contains "$OUTPUT" "sessions_remaining=0" "no sessions remaining"
rm -rf "$TMPDIR"

echo ""
echo "=== Session Budget: Big Batch with handovers ==="

TMPDIR=$(mktemp -d)
mkdir -p "$TMPDIR/scopes"
echo "**Appetite**: Big Batch (4-5 sessions)" > "$TMPDIR/package.md"
touch "$TMPDIR/handover-01.md" "$TMPDIR/handover-02.md"
cat > "$TMPDIR/scopes/scope-filtering.md" <<'SCOPE'
## Must-Haves
- [x] Done task
- [ ] Remaining task
## Nice-to-Haves (~)
- [ ] ~ Nice thing 1
- [ ] ~ Nice thing 2
- [ ] ~ Nice thing 3
SCOPE
OUTPUT=$(bash "$BUDGET" "$TMPDIR")
assert_output_contains "$OUTPUT" "sessions_used=3" "2 handovers + 1 current = 3"
assert_output_contains "$OUTPUT" "appetite_label=Big Batch" "detects Big Batch"
assert_output_contains "$OUTPUT" "appetite_max=5" "max sessions = 5"
assert_output_contains "$OUTPUT" "sessions_remaining=2" "2 sessions remaining"
assert_output_contains "$OUTPUT" "nice_to_haves=3" "counts 3 nice-to-haves"
assert_output_contains "$OUTPUT" "must_haves_remaining=1" "counts 1 remaining must-have"
rm -rf "$TMPDIR"

echo ""
echo "=== Session Budget: Medium Batch ==="

TMPDIR=$(mktemp -d)
mkdir -p "$TMPDIR/scopes"
echo "**Appetite**: Medium Batch (2-3 sessions)" > "$TMPDIR/package.md"
OUTPUT=$(bash "$BUDGET" "$TMPDIR")
assert_output_contains "$OUTPUT" "appetite_label=Medium Batch" "detects Medium Batch"
assert_output_contains "$OUTPUT" "appetite_max=3" "max sessions = 3"
rm -rf "$TMPDIR"

echo ""
echo "=== Session Budget: all must-haves done ==="

TMPDIR=$(mktemp -d)
mkdir -p "$TMPDIR/scopes"
echo "**Appetite**: Small Batch (1 session)" > "$TMPDIR/package.md"
cat > "$TMPDIR/scopes/scope-export.md" <<'SCOPE'
## Must-Haves
- [x] Add export endpoint
- [x] Wire download button
## Nice-to-Haves (~)
- [ ] ~ Custom filename
SCOPE
OUTPUT=$(bash "$BUDGET" "$TMPDIR")
assert_output_contains "$OUTPUT" "must_haves_remaining=0" "no must-haves remaining"
assert_output_contains "$OUTPUT" "nice_to_haves=1" "1 nice-to-have remaining"
rm -rf "$TMPDIR"

echo ""
echo "=== Session Budget: no scopes directory ==="

TMPDIR=$(mktemp -d)
echo "**Appetite**: Small Batch (1 session)" > "$TMPDIR/package.md"
OUTPUT=$(bash "$BUDGET" "$TMPDIR")
assert_output_contains "$OUTPUT" "nice_to_haves=0" "0 nice-to-haves without scopes dir"
assert_output_contains "$OUTPUT" "must_haves_remaining=0" "0 must-haves without scopes dir"
rm -rf "$TMPDIR"

echo ""
echo "=== Session Budget: behavioral-test syntax ([RED]/[GREEN]) ==="

TMPDIR=$(mktemp -d)
mkdir -p "$TMPDIR/scopes"
echo "**Appetite**: Medium Batch (2-3 sessions)" > "$TMPDIR/package.md"
cat > "$TMPDIR/scopes/scope-filtering.md" <<'SCOPE'
## Behaviors (must-have)
- [GREEN] User filters invoices by date
- [RED] User exports the filtered list
## Behaviors (nice-to-have, ~)
- [RED] ~ User can save a filter preset
- [RED] ~ User reorders columns
SCOPE
OUTPUT=$(bash "$BUDGET" "$TMPDIR")
assert_output_contains "$OUTPUT" "must_haves_remaining=1" "counts 1 RED must-have behavior as remaining"
assert_output_contains "$OUTPUT" "nice_to_haves=2" "counts 2 RED nice-to-have behaviors"
rm -rf "$TMPDIR"

echo ""
echo "=== Session Budget: legacy + new syntax coexist ==="

TMPDIR=$(mktemp -d)
mkdir -p "$TMPDIR/scopes"
echo "**Appetite**: Big Batch (4-5 sessions)" > "$TMPDIR/package.md"
cat > "$TMPDIR/scopes/scope-legacy.md" <<'SCOPE'
## Must-Haves
- [x] Old done task
- [ ] Old remaining task
## Nice-to-Haves (~)
- [ ] ~ Old nice thing
SCOPE
cat > "$TMPDIR/scopes/scope-modern.md" <<'SCOPE'
## Behaviors (must-have)
- [GREEN] User sees the new behavior
- [RED] User sees the other new behavior
## Behaviors (nice-to-have, ~)
- [RED] ~ Modern nice thing
SCOPE
OUTPUT=$(bash "$BUDGET" "$TMPDIR")
assert_output_contains "$OUTPUT" "must_haves_remaining=2" "sums 1 legacy + 1 new RED must-have"
assert_output_contains "$OUTPUT" "nice_to_haves=2" "sums 1 legacy + 1 new RED nice-to-have"
rm -rf "$TMPDIR"

echo ""
echo "=== Results ==="
echo "  PASS: $PASS"
echo "  FAIL: $FAIL"
[ "$FAIL" -eq 0 ] && echo "All session budget tests passed." || echo "$FAIL test(s) failed."
exit "$FAIL"
