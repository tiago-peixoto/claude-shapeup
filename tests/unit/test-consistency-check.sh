#!/bin/bash
# test-consistency-check.sh — Unit tests for hooks/lib/check-consistency.sh
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CHECK="$PROJECT_ROOT/hooks/lib/check-consistency.sh"

PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); echo "  ✓ $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  ✗ $1"; }

seed_feature() {
  # Usage: seed_feature <dir> <scope-file-contents> [hillchart-contents]
  local dir="$1"
  mkdir -p "$dir/scopes"
  cat > "$dir/frame.md" <<'EOF'
Status: Frame Go — approved 2026-04-18
EOF
  cat > "$dir/package.md" <<'EOF'
Status: Shape Go — approved 2026-04-19
EOF
}

echo "=== Consistency Check: audit mode ==="

# Clean feature with no scopes
TMPDIR=$(mktemp -d)
BASE="$TMPDIR/2026-04-20-clean-building"
seed_feature "$BASE"
bash "$CHECK" "$BASE" audit >/dev/null 2>&1 && pass "audit passes on clean feature with no scopes" || fail "audit should pass with no scopes"
rm -rf "$TMPDIR"

# Scope with unchecked must-have but not claiming Done
TMPDIR=$(mktemp -d)
BASE="$TMPDIR/2026-04-20-test-building"
seed_feature "$BASE"
cat > "$BASE/scopes/scope-foo.md" <<'EOF'
# Scope: foo
## Hill Position
▼ Downhill
## Must-Haves
- [x] Task done
- [ ] Task pending
EOF
bash "$CHECK" "$BASE" audit >/dev/null 2>&1 && pass "audit doesn't fail a downhill scope with unchecked must-have" || fail "audit mode should not fail on downhill scope"
rm -rf "$TMPDIR"

# Scope claiming Done but with unchecked must-have — audit should WARN+FAIL
TMPDIR=$(mktemp -d)
BASE="$TMPDIR/2026-04-20-test-building"
seed_feature "$BASE"
cat > "$BASE/scopes/scope-foo.md" <<'EOF'
# Scope: foo
## Hill Position
✓ Done
## Must-Haves
- [x] Task done
- [ ] Task pending
EOF
OUTPUT=$(bash "$CHECK" "$BASE" audit)
echo "$OUTPUT" | grep -q "claims ✓ Done but has" && pass "audit flags done-with-unchecked contradiction" || fail "audit should flag done scopes with unchecked items"
rm -rf "$TMPDIR"

echo ""
echo "=== Consistency Check: pre-ship mode ==="

# Clean ready-to-ship feature
TMPDIR=$(mktemp -d)
BASE="$TMPDIR/2026-04-20-ready-building"
seed_feature "$BASE"
cat > "$BASE/hillchart.md" <<'EOF'
# Hill Chart
## Scopes
  ✓ foo — Done
EOF
cat > "$BASE/scopes/scope-foo.md" <<'EOF'
# Scope: foo
## Hill Position
✓ Done
## Must-Haves
- [x] Task done
## Nice-to-Haves (~)
- [ ] ~ Nice thing deferred
EOF
bash "$CHECK" "$BASE" pre-ship >/dev/null 2>&1 && pass "pre-ship passes when scopes are all done with nice-to-haves deferred" || fail "pre-ship should accept uncut nice-to-haves"
rm -rf "$TMPDIR"

# Pre-ship with uphill scope — should fail
TMPDIR=$(mktemp -d)
BASE="$TMPDIR/2026-04-20-uphill-building"
seed_feature "$BASE"
cat > "$BASE/hillchart.md" <<'EOF'
# Hill Chart
## Scopes
  ▲ foo — Uphill
EOF
bash "$CHECK" "$BASE" pre-ship >/dev/null 2>&1 && fail "pre-ship should block when hill chart has uphill scopes" || pass "pre-ship blocks when hill chart has uphill scopes"
rm -rf "$TMPDIR"

# Pre-ship with unchecked must-have — should fail
TMPDIR=$(mktemp -d)
BASE="$TMPDIR/2026-04-20-unchecked-building"
seed_feature "$BASE"
cat > "$BASE/hillchart.md" <<'EOF'
# Hill Chart
## Scopes
  ✓ foo — Done
EOF
cat > "$BASE/scopes/scope-foo.md" <<'EOF'
# Scope: foo
## Hill Position
✓ Done
## Must-Haves
- [x] Task A done
- [ ] Task B pending
EOF
bash "$CHECK" "$BASE" pre-ship >/dev/null 2>&1 && fail "pre-ship should block unchecked must-have" || pass "pre-ship blocks on unchecked must-have"
rm -rf "$TMPDIR"

# Pre-ship with missing Frame Go — should fail
TMPDIR=$(mktemp -d)
BASE="$TMPDIR/2026-04-20-nogo-building"
mkdir -p "$BASE"
echo "Status: Framing" > "$BASE/frame.md"
echo "Status: Shape Go" > "$BASE/package.md"
bash "$CHECK" "$BASE" pre-ship >/dev/null 2>&1 && fail "pre-ship should block missing Frame Go" || pass "pre-ship blocks on missing Frame Go"
rm -rf "$TMPDIR"

echo ""
echo "=== Consistency Check: behavioral-test syntax ([RED]/[GREEN]) ==="

# audit: ✓ Done scope with a RED must-have behavior — contradiction, must FAIL
TMPDIR=$(mktemp -d)
BASE="$TMPDIR/2026-04-20-behave-building"
seed_feature "$BASE"
cat > "$BASE/scopes/scope-foo.md" <<'EOF'
# Scope: foo
## Hill Position
✓ Done
## Behaviors (must-have)
- [GREEN] User sees the filtered list update without reload
- [RED] User sees a "no results" message when nothing matches
EOF
OUTPUT=$(bash "$CHECK" "$BASE" audit)
echo "$OUTPUT" | grep -q "claims ✓ Done but has" && pass "audit flags ✓ Done scope with a RED must-have behavior" || fail "audit should flag a done scope with a RED must-have behavior"
rm -rf "$TMPDIR"

# audit: downhill scope with a RED must-have behavior — must NOT fail
TMPDIR=$(mktemp -d)
BASE="$TMPDIR/2026-04-20-behave-building"
seed_feature "$BASE"
cat > "$BASE/scopes/scope-foo.md" <<'EOF'
# Scope: foo
## Hill Position
▼ Downhill
## Behaviors (must-have)
- [GREEN] User filters invoices by date
- [RED] User clears all filters at once
EOF
bash "$CHECK" "$BASE" audit >/dev/null 2>&1 && pass "audit does not fail a downhill scope with a RED must-have behavior" || fail "audit should not fail on a downhill scope"
rm -rf "$TMPDIR"

# pre-ship: a RED must-have behavior must BLOCK the ship
TMPDIR=$(mktemp -d)
BASE="$TMPDIR/2026-04-20-behave-red-building"
seed_feature "$BASE"
cat > "$BASE/hillchart.md" <<'EOF'
# Hill Chart
## Scopes
  ✓ foo — Done
EOF
cat > "$BASE/scopes/scope-foo.md" <<'EOF'
# Scope: foo
## Hill Position
✓ Done
## Behaviors (must-have)
- [GREEN] User filters invoices by date
- [RED] User exports the filtered list
EOF
bash "$CHECK" "$BASE" pre-ship >/dev/null 2>&1 && fail "pre-ship should block on a RED must-have behavior" || pass "pre-ship blocks on a RED must-have behavior"
rm -rf "$TMPDIR"

# pre-ship: all must-have behaviors GREEN, nice-to-have RED deferred — must PASS
TMPDIR=$(mktemp -d)
BASE="$TMPDIR/2026-04-20-behave-green-building"
seed_feature "$BASE"
cat > "$BASE/hillchart.md" <<'EOF'
# Hill Chart
## Scopes
  ✓ foo — Done
EOF
cat > "$BASE/scopes/scope-foo.md" <<'EOF'
# Scope: foo
## Hill Position
✓ Done
## Behaviors (must-have)
- [GREEN] User filters invoices by date
- [GREEN] User exports the filtered list
## Behaviors (nice-to-have, ~)
- [RED] ~ User can save a filter preset
EOF
bash "$CHECK" "$BASE" pre-ship >/dev/null 2>&1 && pass "pre-ship passes when must-have behaviors are GREEN and a nice-to-have is deferred" || fail "pre-ship should accept deferred RED nice-to-haves"
rm -rf "$TMPDIR"

echo ""
echo "=== Consistency Check: legacy + new syntax coexist (back-compat) ==="

# A feature with one legacy [x] scope and one [GREEN] scope — pre-ship passes
TMPDIR=$(mktemp -d)
BASE="$TMPDIR/2026-04-20-mixed-building"
seed_feature "$BASE"
cat > "$BASE/hillchart.md" <<'EOF'
# Hill Chart
## Scopes
  ✓ legacy — Done
  ✓ modern — Done
EOF
cat > "$BASE/scopes/scope-legacy.md" <<'EOF'
# Scope: legacy
## Hill Position
✓ Done
## Must-Haves
- [x] Old-style checkbox task
EOF
cat > "$BASE/scopes/scope-modern.md" <<'EOF'
# Scope: modern
## Hill Position
✓ Done
## Behaviors (must-have)
- [GREEN] User sees the new behavior
EOF
bash "$CHECK" "$BASE" pre-ship >/dev/null 2>&1 && pass "pre-ship passes a feature mixing legacy [x] and new [GREEN] scopes" || fail "pre-ship should accept legacy and new syntax together"
rm -rf "$TMPDIR"

# Same mixed feature but the modern scope has a RED behavior — pre-ship blocks
TMPDIR=$(mktemp -d)
BASE="$TMPDIR/2026-04-20-mixed-red-building"
seed_feature "$BASE"
cat > "$BASE/hillchart.md" <<'EOF'
# Hill Chart
## Scopes
  ✓ legacy — Done
  ✓ modern — Done
EOF
cat > "$BASE/scopes/scope-legacy.md" <<'EOF'
# Scope: legacy
## Hill Position
✓ Done
## Must-Haves
- [x] Old-style checkbox task
EOF
cat > "$BASE/scopes/scope-modern.md" <<'EOF'
# Scope: modern
## Hill Position
✓ Done
## Behaviors (must-have)
- [RED] User sees the new behavior
EOF
bash "$CHECK" "$BASE" pre-ship >/dev/null 2>&1 && fail "pre-ship should block when a new-syntax scope has a RED must-have" || pass "pre-ship blocks a RED must-have even alongside legacy scopes"
rm -rf "$TMPDIR"

echo ""
echo "=== Consistency Check: nice-to-have scope precedence ==="

# A ~ (nice-to-have) scope with a RED must-have must NOT fail pre-ship — it's
# cuttable as a whole; the checker WARNs instead. A must-have ✓ core scope is
# held constant so the only variable is the extras scope's hill-chart marker.
TMPDIR=$(mktemp -d)
BASE="$TMPDIR/2026-04-20-nice-scope-building"
seed_feature "$BASE"
cat > "$BASE/hillchart.md" <<'EOF'
# Hill Chart
## Scopes
  ✓ core — Done
  ~ extras — Nice-to-have (cut if needed)
EOF
cat > "$BASE/scopes/scope-core.md" <<'EOF'
# Scope: core
## Hill Position
✓ Done
## Behaviors (must-have)
- [GREEN] User sees the core capability
EOF
cat > "$BASE/scopes/scope-extras.md" <<'EOF'
# Scope: extras
## Hill Position
▼ Downhill
## Behaviors (must-have)
- [RED] User sees the optional extra
EOF
OUTPUT=$(bash "$CHECK" "$BASE" pre-ship)
STATUS=$?
if [ "$STATUS" -eq 0 ] && echo "$OUTPUT" | grep -q "nice-to-have scope 'extras'"; then
  pass "pre-ship passes (WARN) a ~ nice-to-have scope with a RED must-have"
else
  fail "pre-ship should WARN (not FAIL) a ~ nice-to-have scope with RED must-have (status=$STATUS)"
fi
rm -rf "$TMPDIR"

# The SAME scope without the ~ marker (listed ▼) must still FAIL pre-ship.
TMPDIR=$(mktemp -d)
BASE="$TMPDIR/2026-04-20-nice-scope-neg-building"
seed_feature "$BASE"
cat > "$BASE/hillchart.md" <<'EOF'
# Hill Chart
## Scopes
  ✓ core — Done
  ▼ extras — Downhill
EOF
cat > "$BASE/scopes/scope-core.md" <<'EOF'
# Scope: core
## Hill Position
✓ Done
## Behaviors (must-have)
- [GREEN] User sees the core capability
EOF
cat > "$BASE/scopes/scope-extras.md" <<'EOF'
# Scope: extras
## Hill Position
▼ Downhill
## Behaviors (must-have)
- [RED] User sees the optional extra
EOF
bash "$CHECK" "$BASE" pre-ship >/dev/null 2>&1 && fail "pre-ship should block a non-~ scope with a RED must-have" || pass "pre-ship blocks a non-~ scope with a RED must-have"
rm -rf "$TMPDIR"

echo ""
echo "=== Results ==="
echo "  PASS: $PASS"
echo "  FAIL: $FAIL"
[ "$FAIL" -eq 0 ] && echo "All consistency-check tests passed." || echo "$FAIL test(s) failed."
exit "$FAIL"
