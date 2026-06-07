#!/bin/bash
# test-commit-gate.sh — Unit tests for hooks/lib/commit-gate.sh and the
# PreToolUse dispatcher at hooks/commit-gate.sh.
#
# Covers the contract: a commit that stages `.shapeup/<feature>/` changes
# must pass `check-consistency.sh audit` against every touched feature
# folder. A commit that touches no `.shapeup/` files passes through. A
# Bash tool call that isn't `git commit` passes through.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GATE_LIB="$PROJECT_ROOT/hooks/lib/commit-gate.sh"
GATE_HOOK="$PROJECT_ROOT/hooks/commit-gate.sh"

PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); echo "  ✓ $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  ✗ $1"; }

make_repo() {
  local dir="$1"
  mkdir -p "$dir"
  (cd "$dir" && git init -q && git config user.email t@t && git config user.name t)
}

seed_feature() {
  # Usage: seed_feature <repo> <feature-dirname>
  local repo="$1"
  local name="$2"
  local dir="$repo/.shapeup/$name"
  mkdir -p "$dir/scopes"
  cat > "$dir/frame.md" <<'EOF'
Status: Frame Go — approved 2026-04-18
EOF
  cat > "$dir/package.md" <<'EOF'
Status: Shape Go — approved 2026-04-19
EOF
  echo "$dir"
}

echo "=== commit-gate (library): no .shapeup/ touched ==="

TMP=$(mktemp -d)
make_repo "$TMP"
echo "hello" > "$TMP/app.txt"
(cd "$TMP" && git add app.txt)
bash "$GATE_LIB" "$TMP" >/dev/null 2>&1 \
  && pass "passes when staged diff has no .shapeup/ files" \
  || fail "should pass when nothing under .shapeup/ is staged"
rm -rf "$TMP"

echo ""
echo "=== commit-gate (library): clean done commit passes ==="

TMP=$(mktemp -d)
make_repo "$TMP"
FEAT=$(seed_feature "$TMP" "2026-04-20-clean-building")
cat > "$FEAT/hillchart.md" <<'EOF'
# Hill Chart
## Scopes
  ✓ foo — Done
EOF
cat > "$FEAT/scopes/scope-foo.md" <<'EOF'
# Scope: foo
## Hill Position
✓ Done
## Must-Haves
- [x] Task done
EOF
(cd "$TMP" && git add .shapeup)
bash "$GATE_LIB" "$TMP" >/dev/null 2>&1 \
  && pass "passes on a consistent scope-done commit" \
  || fail "should pass when scope/hillchart agree and must-haves are all checked"
rm -rf "$TMP"

echo ""
echo "=== commit-gate (library): Done-but-unchecked blocks ==="

TMP=$(mktemp -d)
make_repo "$TMP"
FEAT=$(seed_feature "$TMP" "2026-04-20-leak-building")
cat > "$FEAT/hillchart.md" <<'EOF'
# Hill Chart
## Scopes
  ✓ foo — Done
EOF
cat > "$FEAT/scopes/scope-foo.md" <<'EOF'
# Scope: foo
## Hill Position
✓ Done
## Must-Haves
- [x] Task A
- [ ] Task B still pending
EOF
(cd "$TMP" && git add .shapeup)
OUT=$(bash "$GATE_LIB" "$TMP" 2>&1)
status=$?
if [ "$status" -ne 0 ] && echo "$OUT" | grep -q "claims ✓ Done"; then
  pass "blocks when scope claims Done with unchecked must-haves"
else
  fail "should block Done-but-unchecked (status=$status, out=$OUT)"
fi
rm -rf "$TMP"

echo ""
echo "=== commit-gate (library): Done-but-RED behavior blocks ==="

TMP=$(mktemp -d)
make_repo "$TMP"
FEAT=$(seed_feature "$TMP" "2026-04-20-behaveleak-building")
cat > "$FEAT/hillchart.md" <<'EOF'
# Hill Chart
## Scopes
  ✓ foo — Done
EOF
cat > "$FEAT/scopes/scope-foo.md" <<'EOF'
# Scope: foo
## Hill Position
✓ Done
## Behaviors (must-have)
- [GREEN] User filters invoices by date
- [RED] User exports the filtered list
EOF
(cd "$TMP" && git add .shapeup)
OUT=$(bash "$GATE_LIB" "$TMP" 2>&1)
status=$?
if [ "$status" -ne 0 ] && echo "$OUT" | grep -q "claims ✓ Done"; then
  pass "blocks when scope claims Done with a RED must-have behavior"
else
  fail "should block Done-but-RED behavior (status=$status, out=$OUT)"
fi
rm -rf "$TMP"

echo ""
echo "=== commit-gate (library): hillchart/scope mismatch blocks ==="

TMP=$(mktemp -d)
make_repo "$TMP"
FEAT=$(seed_feature "$TMP" "2026-04-20-mismatch-building")
cat > "$FEAT/hillchart.md" <<'EOF'
# Hill Chart
## Scopes
  ✓ ghost — Done
EOF
# No scope-ghost.md file exists — hillchart references a phantom scope.
(cd "$TMP" && git add .shapeup)
OUT=$(bash "$GATE_LIB" "$TMP" 2>&1)
status=$?
if [ "$status" -ne 0 ] && echo "$OUT" | grep -q "no matching scope-"; then
  pass "blocks when hillchart lists a scope with no matching scope-*.md file"
else
  fail "should block hillchart/scope mismatch (status=$status, out=$OUT)"
fi
rm -rf "$TMP"

echo ""
echo "=== commit-gate (library): scope file missing from hillchart blocks ==="

TMP=$(mktemp -d)
make_repo "$TMP"
FEAT=$(seed_feature "$TMP" "2026-04-20-orphan-building")
cat > "$FEAT/hillchart.md" <<'EOF'
# Hill Chart
## Scopes
EOF
cat > "$FEAT/scopes/scope-orphan.md" <<'EOF'
# Scope: orphan
## Hill Position
▼ Downhill
## Must-Haves
- [ ] Still working
EOF
(cd "$TMP" && git add .shapeup)
OUT=$(bash "$GATE_LIB" "$TMP" 2>&1)
status=$?
if [ "$status" -ne 0 ] && echo "$OUT" | grep -q "not mentioned in hillchart"; then
  pass "blocks when a scope file is not listed in hillchart.md"
else
  fail "should block scope-missing-from-hillchart (status=$status, out=$OUT)"
fi
rm -rf "$TMP"

echo ""
echo "=== commit-gate (library): not a git repo passes through ==="

TMP=$(mktemp -d)
mkdir -p "$TMP/.shapeup/2026-04-20-bare-building"
bash "$GATE_LIB" "$TMP" >/dev/null 2>&1 \
  && pass "passes through when project root is not a git repo" \
  || fail "should not block when there's no git repo"
rm -rf "$TMP"

echo ""
echo "=== commit-gate (library): missing project root errors ==="

bash "$GATE_LIB" "" >/dev/null 2>&1
if [ $? -eq 2 ]; then
  pass "exits 2 on missing project-root argument"
else
  fail "should exit 2 when no project root given"
fi

echo ""
echo "=== commit-gate (dispatcher): non-Bash tool passes through ==="

IN='{"tool_name": "Read", "tool_input": {"file_path": "/tmp/x"}}'
echo "$IN" | bash "$GATE_HOOK" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  pass "Read tool call is ignored"
else
  fail "should ignore non-Bash tool calls"
fi

echo ""
echo "=== commit-gate (dispatcher): Bash without git commit passes through ==="

IN='{"tool_name": "Bash", "tool_input": {"command": "ls -la"}}'
echo "$IN" | bash "$GATE_HOOK" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  pass "ls passes through"
else
  fail "should ignore Bash calls that are not git commit"
fi

IN='{"tool_name": "Bash", "tool_input": {"command": "echo \"git commit message\""}}'
echo "$IN" | bash "$GATE_HOOK" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  pass "echoing the string 'git commit' does not trigger the gate"
else
  fail "string literal 'git commit' inside echo should not fire the gate"
fi

IN='{"tool_name": "Bash", "tool_input": {"command": "git commit-tree -p HEAD^"}}'
echo "$IN" | bash "$GATE_HOOK" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  pass "git commit-tree (different subcommand) passes through"
else
  fail "git commit-tree should not be intercepted"
fi

echo ""
echo "=== commit-gate (dispatcher): git commit invokes the gate ==="

TMP=$(mktemp -d)
make_repo "$TMP"
FEAT=$(seed_feature "$TMP" "2026-04-20-dispatch-building")
cat > "$FEAT/hillchart.md" <<'EOF'
# Hill Chart
## Scopes
  ✓ foo — Done
EOF
cat > "$FEAT/scopes/scope-foo.md" <<'EOF'
# Scope: foo
## Hill Position
✓ Done
## Must-Haves
- [x] done
- [ ] still pending
EOF
(cd "$TMP" && git add .shapeup)

IN='{"tool_name": "Bash", "tool_input": {"command": "git commit -m \"close foo\""}}'
OUT=$(echo "$IN" | CLAUDE_PROJECT_DIR="$TMP" bash "$GATE_HOOK" 2>&1)
status=$?
if [ "$status" -eq 2 ] && echo "$OUT" | grep -q "tracking docs"; then
  pass "blocks git commit with exit 2 when tracking docs are inconsistent"
else
  fail "dispatcher should exit 2 on drift (status=$status)"
fi
rm -rf "$TMP"

echo ""
echo "=== commit-gate (dispatcher): clean git commit passes ==="

TMP=$(mktemp -d)
make_repo "$TMP"
FEAT=$(seed_feature "$TMP" "2026-04-20-cleanpass-building")
cat > "$FEAT/hillchart.md" <<'EOF'
# Hill Chart
## Scopes
  ✓ foo — Done
EOF
cat > "$FEAT/scopes/scope-foo.md" <<'EOF'
# Scope: foo
## Hill Position
✓ Done
## Must-Haves
- [x] done
EOF
(cd "$TMP" && git add .shapeup)

IN='{"tool_name": "Bash", "tool_input": {"command": "git commit -m \"close foo\""}}'
echo "$IN" | CLAUDE_PROJECT_DIR="$TMP" bash "$GATE_HOOK" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  pass "clean scope-done commit passes through the dispatcher"
else
  fail "dispatcher should pass through when audit is clean"
fi
rm -rf "$TMP"

echo ""
echo "=== Results ==="
echo "  PASS: $PASS"
echo "  FAIL: $FAIL"
[ "$FAIL" -eq 0 ] && echo "All commit-gate tests passed." || echo "$FAIL test(s) failed."
exit "$FAIL"
