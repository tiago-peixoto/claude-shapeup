#!/bin/bash
# init-feature.sh — Create a new numbered feature folder in .shapeup/
# Usage: init-feature.sh <shapeup-dir> <slug>
# Example: init-feature.sh /path/to/.shapeup "user-auth"
# Output: prints the created folder path

SHAPEUP_DIR="$1"
SLUG="$2"

if [ -z "$SHAPEUP_DIR" ] || [ -z "$SLUG" ]; then
  echo "Usage: init-feature.sh <shapeup-dir> <slug>" >&2
  exit 1
fi

mkdir -p "$SHAPEUP_DIR"

# Find the next available number
NEXT_NUM=1
for dir in "$SHAPEUP_DIR"/[0-9][0-9][0-9]-*; do
  if [ -d "$dir" ]; then
    NUM=$(basename "$dir" | grep -oE '^[0-9]{3}' | sed 's/^0*//')
    if [ "$NUM" -ge "$NEXT_NUM" ]; then
      NEXT_NUM=$((NUM + 1))
    fi
  fi
done

PADDED=$(printf "%03d" "$NEXT_NUM")
FOLDER_NAME="${PADDED}-${SLUG}-framing"
FOLDER_PATH="${SHAPEUP_DIR}/${FOLDER_NAME}"

mkdir -p "$FOLDER_PATH"
echo "$FOLDER_PATH"
