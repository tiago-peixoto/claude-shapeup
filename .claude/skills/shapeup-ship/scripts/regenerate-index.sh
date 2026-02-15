#!/bin/bash
# regenerate-index.sh — Scan .shapeup/ and produce index.md dashboard
# Usage: regenerate-index.sh <shapeup-dir>

SHAPEUP_DIR="$1"

if [ -z "$SHAPEUP_DIR" ] || [ ! -d "$SHAPEUP_DIR" ]; then
  echo "Usage: regenerate-index.sh <shapeup-dir>" >&2
  exit 1
fi

INDEX="$SHAPEUP_DIR/index.md"

cat > "$INDEX" << HEADER
# Shape Up Project Dashboard

**Generated**: $(date +%Y-%m-%d)

HEADER

# Collect folders by status
BUILDING=""
SHAPED=""
FRAMING=""
SHIPPED=""
DISCARDED=""

for dir in "$SHAPEUP_DIR"/[0-9][0-9][0-9]-*/; do
  [ -d "$dir" ] || continue
  NAME=$(basename "$dir")

  case "$NAME" in
    *-building)  BUILDING="$BUILDING $dir";;
    *-shaped)    SHAPED="$SHAPED $dir";;
    *-framing)   FRAMING="$FRAMING $dir";;
    *-shipped)   SHIPPED="$SHIPPED $dir";;
    *-discarded) DISCARDED="$DISCARDED $dir";;
  esac
done

# Active (Building)
if [ -n "$BUILDING" ]; then
  echo "## Active — Building" >> "$INDEX"
  echo "" >> "$INDEX"
  for dir in $BUILDING; do
    NAME=$(basename "$dir")
    ID=$(echo "$NAME" | grep -oP '^\d{3}')
    SLUG=$(echo "$NAME" | sed 's/^[0-9]*-//;s/-building$//')
    echo "### $ID: $SLUG" >> "$INDEX"
    if [ -f "$dir/frame.md" ]; then
      PROBLEM=$(grep -A2 "^## Problem" "$dir/frame.md" | tail -1 | head -c 200)
      echo "- **Problem**: $PROBLEM" >> "$INDEX"
    fi
    if [ -f "$dir/hillchart.md" ]; then
      echo "- **Hill Chart**: See \`$NAME/hillchart.md\`" >> "$INDEX"
    fi
    echo "" >> "$INDEX"
  done
fi

# Ready to Build (Shaped)
if [ -n "$SHAPED" ]; then
  echo "## Ready to Build — Shaped" >> "$INDEX"
  echo "" >> "$INDEX"
  for dir in $SHAPED; do
    NAME=$(basename "$dir")
    ID=$(echo "$NAME" | grep -oP '^\d{3}')
    SLUG=$(echo "$NAME" | sed 's/^[0-9]*-//;s/-shaped$//')
    echo "### $ID: $SLUG" >> "$INDEX"
    echo "" >> "$INDEX"
  done
fi

# In Progress (Framing)
if [ -n "$FRAMING" ]; then
  echo "## In Progress — Framing" >> "$INDEX"
  echo "" >> "$INDEX"
  for dir in $FRAMING; do
    NAME=$(basename "$dir")
    ID=$(echo "$NAME" | grep -oP '^\d{3}')
    SLUG=$(echo "$NAME" | sed 's/^[0-9]*-//;s/-framing$//')
    echo "### $ID: $SLUG" >> "$INDEX"
    echo "" >> "$INDEX"
  done
fi

# Completed (Shipped)
if [ -n "$SHIPPED" ]; then
  echo "## Completed — Shipped" >> "$INDEX"
  echo "" >> "$INDEX"
  for dir in $SHIPPED; do
    NAME=$(basename "$dir")
    ID=$(echo "$NAME" | grep -oP '^\d{3}')
    SLUG=$(echo "$NAME" | sed 's/^[0-9]*-//;s/-shipped$//')
    echo "### $ID: $SLUG" >> "$INDEX"
    if [ -f "$dir/decisions.md" ]; then
      echo "- Decisions: \`$NAME/decisions.md\`" >> "$INDEX"
    fi
    echo "" >> "$INDEX"
  done
fi

# Discarded
if [ -n "$DISCARDED" ]; then
  echo "## Discarded" >> "$INDEX"
  echo "" >> "$INDEX"
  for dir in $DISCARDED; do
    NAME=$(basename "$dir")
    ID=$(echo "$NAME" | grep -oP '^\d{3}')
    SLUG=$(echo "$NAME" | sed 's/^[0-9]*-//;s/-discarded$//')
    echo "### $ID: $SLUG" >> "$INDEX"
    if [ -f "$dir/discard-reason.md" ]; then
      echo "- Reason: \`$NAME/discard-reason.md\`" >> "$INDEX"
    fi
    echo "" >> "$INDEX"
  done
fi

echo "Dashboard regenerated at $INDEX"
