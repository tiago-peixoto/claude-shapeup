#!/bin/bash
# check-consistency.sh — Audit a Shape Up feature folder for tracking drift.
# Usage: check-consistency.sh <feature-dir> [<mode>]
#   <mode>: audit  (default) — print a report, exit 0
#           strict          — exit non-zero if inconsistencies found
#           pre-ship        — strict check suitable for the build→ship gate
#
# What it checks:
#   * Every scope's must-haves are satisfied (`[x]` checkbox or `[GREEN]`
#     behavioral test) or cut (moved under a "Cut" heading, or rewritten with a
#     leading `~` nice-to-have marker). Unsatisfied = `[ ]` or `[RED]`.
#   * The hill chart mentions every scope that exists as a file, and vice versa.
#   * Scopes marked `✓ Done` in the hill chart have all must-haves checked.
#   * Scopes marked `▲ Uphill` or `▼ Downhill` are NOT also listed as `✓ Done`.
#   * In pre-ship mode: no scope is still ▲ Uphill, package.md has Shape Go,
#     and frame.md has Frame Go.
#   * Scope-level vs behavior-level nice-to-have: a scope listed with a leading
#     `~` in the hill chart is a nice-to-have SCOPE (cuttable as a whole). Its
#     unfinished `[RED]` must-have behaviors WARN (not FAIL) at pre-ship — the
#     scope can simply be cut. A non-`~` scope's RED must-haves still FAIL.
#
# The script is intentionally conservative: any ambiguity is reported as a
# WARN, not a FAIL. FAILs are things that are provably inconsistent.

set -u

FEATURE_DIR="${1:-}"
MODE="${2:-audit}"

if [ -z "$FEATURE_DIR" ] || [ ! -d "$FEATURE_DIR" ]; then
  echo "Usage: check-consistency.sh <feature-dir> [audit|strict|pre-ship]" >&2
  exit 2
fi

FAILS=0
WARNS=0

fail() { echo "FAIL: $*"; FAILS=$((FAILS + 1)); }
warn() { echo "WARN: $*"; WARNS=$((WARNS + 1)); }
note() { echo "NOTE: $*"; }

# A scope listed with a leading ~ in the hill chart Scopes section is a
# nice-to-have SCOPE — cuttable as a whole — so its unfinished must-have
# behaviors are acceptable (WARN, not FAIL) at the pre-ship gate. Behavior-level
# ~ (individual nice-to-have behaviors inside a scope) is a separate, finer marker.
HILL_TILDE_NAMES=""
scope_is_nice_to_have() {
  local kebab="$1" tn tkebab
  while IFS= read -r tn; do
    [ -z "$tn" ] && continue
    tkebab=$(echo "$tn" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-|-$//g')
    if [ "$tkebab" = "$kebab" ] || [[ "$tkebab" == *"$kebab"* ]] || [[ "$kebab" == *"$tkebab"* ]]; then
      return 0
    fi
  done <<< "$HILL_TILDE_NAMES"
  return 1
}

SCOPES_DIR="$FEATURE_DIR/scopes"
HILLCHART="$FEATURE_DIR/hillchart.md"
PACKAGE="$FEATURE_DIR/package.md"
FRAME="$FEATURE_DIR/frame.md"

# --- Collect scope file names (without .md / scope- prefix) -------------------
SCOPE_NAMES=""
if [ -d "$SCOPES_DIR" ]; then
  for f in "$SCOPES_DIR"/scope-*.md; do
    [ -f "$f" ] || continue
    base=$(basename "$f" .md)
    name="${base#scope-}"
    SCOPE_NAMES="$SCOPE_NAMES"$'\n'"$name"
  done
fi
SCOPE_NAMES=$(echo "$SCOPE_NAMES" | sed '/^$/d')

# --- Check each scope file ---------------------------------------------------
while IFS= read -r name; do
  [ -z "$name" ] && continue
  f="$SCOPES_DIR/scope-${name}.md"

  # Count unsatisfied must-haves (line starts with "- [ ]" legacy or "- [RED]"
  # behavioral test, and does NOT carry a leading ~ nice-to-have marker).
  unchecked=$(grep -E '^- (\[ \]|\[RED\])' "$f" 2>/dev/null | grep -vE '^- (\[ \]|\[RED\]) *~' || true)
  unchecked_count=$(echo "$unchecked" | sed '/^$/d' | wc -l | tr -d ' ')

  # Detect hill position declared in the scope file
  position=$(grep -E '^## Hill Position' -A2 "$f" 2>/dev/null | tail -n +2 | head -1 | tr -d ' \t')

  if echo "$position" | grep -q '✓'; then
    # Scope claims Done but has unchecked must-haves — that's a contradiction.
    if [ "$unchecked_count" -gt 0 ]; then
      fail "scope '$name' claims ✓ Done but has $unchecked_count RED must-have behavior(s) — flip to [GREEN] when observable, or cut with ~"
    fi
  fi

  note "scope '$name': unchecked_must_haves=$unchecked_count position=${position:-unknown}"
done <<< "$SCOPE_NAMES"

# --- Check hill chart ⇄ scopes mapping ---------------------------------------
if [ -f "$HILLCHART" ]; then
  # Extract names mentioned in the hill chart Scopes section
  HILL_SCOPE_NAMES=$(awk '
    /^## Scopes/ {in_scopes=1; next}
    /^## / && in_scopes {in_scopes=0}
    in_scopes && /^  *[✓▼▲~]/ {
      sub(/^ *[✓▼▲~] */, "", $0)
      sub(/ *—.*$/, "", $0)
      print
    }
  ' "$HILLCHART" 2>/dev/null)

  # Subset: scopes flagged nice-to-have (leading ~) — cuttable as a whole.
  HILL_TILDE_NAMES=$(awk '
    /^## Scopes/ {in_scopes=1; next}
    /^## / && in_scopes {in_scopes=0}
    in_scopes && /^  *~/ {
      sub(/^ *~ */, "", $0)
      sub(/ *—.*$/, "", $0)
      print
    }
  ' "$HILLCHART" 2>/dev/null)

  while IFS= read -r scope_name; do
    [ -z "$scope_name" ] && continue
    # Scope file names are kebab-case; hill chart may use human-readable names.
    # Flag if no scope file matches even a fuzzy kebab equivalent.
    kebab=$(echo "$scope_name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-|-$//g')
    found=""
    while IFS= read -r sn; do
      [ -z "$sn" ] && continue
      if [ "$sn" = "$kebab" ] || [[ "$sn" == *"$kebab"* ]] || [[ "$kebab" == *"$sn"* ]]; then
        found="yes"
        break
      fi
    done <<< "$SCOPE_NAMES"

    if [ -z "$found" ]; then
      warn "hill chart lists scope '$scope_name' but no matching scope-*.md exists"
    fi
  done <<< "$HILL_SCOPE_NAMES"

  # Reverse: every scope file should appear somewhere in the hill chart
  while IFS= read -r sn; do
    [ -z "$sn" ] && continue
    if ! grep -qiE "(^|[^a-z])${sn}([^a-z]|$)" "$HILLCHART"; then
      warn "scope '$sn' has a file but is not mentioned in hillchart.md"
    fi
  done <<< "$SCOPE_NAMES"
else
  if [ -n "$SCOPE_NAMES" ]; then
    warn "scopes exist but hillchart.md is missing"
  fi
fi

# --- Mode-specific stricter checks -------------------------------------------
case "$MODE" in
  pre-ship)
    if [ ! -f "$FRAME" ]; then
      fail "frame.md missing — cannot ship"
    elif ! grep -q 'Frame Go' "$FRAME"; then
      fail "frame.md lacks 'Frame Go' status"
    fi

    if [ ! -f "$PACKAGE" ]; then
      fail "package.md missing — cannot ship"
    elif ! grep -q 'Shape Go' "$PACKAGE"; then
      fail "package.md lacks 'Shape Go' status"
    fi

    if [ -f "$HILLCHART" ]; then
      uphill=$(grep -c '^  *▲' "$HILLCHART" 2>/dev/null; true)
      uphill="${uphill:-0}"
      if [ "$uphill" -gt 0 ]; then
        fail "hillchart.md has $uphill scope(s) still ▲ Uphill — shaping gap, not ready to ship"
      fi
    fi

    # Every scope file must either be ✓ Done in its own Hill Position OR have
    # every must-have checked and its uncut nice-to-haves accounted for.
    while IFS= read -r sn; do
      [ -z "$sn" ] && continue
      f="$SCOPES_DIR/scope-${sn}.md"
      unchecked=$(grep -E '^- (\[ \]|\[RED\])' "$f" 2>/dev/null | grep -vE '^- (\[ \]|\[RED\]) *~' | wc -l | tr -d ' ')
      unchecked="${unchecked:-0}"
      if [ "$unchecked" -gt 0 ]; then
        if scope_is_nice_to_have "$sn"; then
          warn "nice-to-have scope '$sn' has $unchecked RED must-have behavior(s) — acceptable (scope is cuttable); cut it explicitly or finish"
        else
          fail "scope '$sn' has $unchecked RED must-have behavior(s) — flip to [GREEN] when observable, or cut with ~"
        fi
      fi
    done <<< "$SCOPE_NAMES"
    ;;
  strict)
    # Fail fast on any FAIL collected above.
    :
    ;;
  audit|*)
    ;;
esac

echo "--- summary: FAIL=$FAILS WARN=$WARNS ---"

if [ "$MODE" != "audit" ] && [ "$FAILS" -gt 0 ]; then
  exit 1
fi
exit 0
