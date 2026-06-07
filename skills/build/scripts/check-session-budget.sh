#!/bin/bash
# check-session-budget.sh — Deterministic session budget calculator
# Usage: check-session-budget.sh <feature-dir>
# Outputs key=value pairs for the agent to use in capacity decisions.

FEATURE_DIR="$1"

if [ -z "$FEATURE_DIR" ] || [ ! -d "$FEATURE_DIR" ]; then
  echo "Usage: check-session-budget.sh <feature-dir>" >&2
  exit 1
fi

# Count completed sessions (each handover = one completed session)
HANDOVER_COUNT=$(ls "$FEATURE_DIR"/handover-*.md 2>/dev/null | wc -l | tr -d ' ')
# Current session counts too
SESSIONS_USED=$((HANDOVER_COUNT + 1))

# Extract appetite from package.md
APPETITE_RAW=$(grep -i 'appetite' "$FEATURE_DIR/package.md" 2>/dev/null | head -1)

# Map appetite to session range
if echo "$APPETITE_RAW" | grep -qi 'small'; then
  APPETITE_LABEL="Small Batch"
  APPETITE_MAX=1
elif echo "$APPETITE_RAW" | grep -qi 'medium'; then
  APPETITE_LABEL="Medium Batch"
  APPETITE_MAX=3
elif echo "$APPETITE_RAW" | grep -qi 'big'; then
  APPETITE_LABEL="Big Batch"
  APPETITE_MAX=5
else
  APPETITE_LABEL="Unknown"
  APPETITE_MAX=0
fi

# Count outstanding nice-to-haves across all scope files
NICE_TO_HAVES=0
if [ -d "$FEATURE_DIR/scopes" ]; then
  # Count unsatisfied nice-to-have behaviors/tasks marked ~ — legacy `- [ ] ~`
  # or behavioral-test `- [RED] ~`. GREEN/checked ones are done, not counted.
  NICE_TO_HAVES=$(grep -rE '\- (\[ \]|\[RED\]) ~' "$FEATURE_DIR/scopes/" 2>/dev/null | wc -l | tr -d ' ')
fi

# Count remaining must-haves
MUST_HAVES_REMAINING=0
if [ -d "$FEATURE_DIR/scopes" ]; then
  # Count unsatisfied must-haves that are NOT nice-to-haves — legacy `- [ ]`
  # or behavioral-test `- [RED]`. GREEN/checked ones are done, not counted.
  MUST_HAVES_REMAINING=$(grep -rE '\- (\[ \]|\[RED\])' "$FEATURE_DIR/scopes/" 2>/dev/null | grep -v '~' | wc -l | tr -d ' ')
fi

echo "sessions_used=$SESSIONS_USED"
echo "appetite_label=$APPETITE_LABEL"
echo "appetite_max=$APPETITE_MAX"
echo "sessions_remaining=$(( APPETITE_MAX > SESSIONS_USED ? APPETITE_MAX - SESSIONS_USED : 0 ))"
echo "nice_to_haves=$NICE_TO_HAVES"
echo "must_haves_remaining=$MUST_HAVES_REMAINING"
