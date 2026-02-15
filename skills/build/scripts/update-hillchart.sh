#!/bin/bash
# update-hillchart.sh — Initialize or display hill chart template
# Usage: update-hillchart.sh <hillchart-path> init
#        update-hillchart.sh <hillchart-path> show

HILLCHART="$1"
ACTION="$2"

if [ -z "$HILLCHART" ] || [ -z "$ACTION" ]; then
  echo "Usage: update-hillchart.sh <hillchart-path> <init|show>" >&2
  exit 1
fi

case "$ACTION" in
  init)
    cat > "$HILLCHART" << 'TEMPLATE'
# Hill Chart
**Updated**: $(date +%Y-%m-%d)
**Session**: 01

## Scopes
  ▲ (first scope will be discovered through work)

## Risk
(to be determined after orientation)

## Next
(pick first piece: core + small + novel)
TEMPLATE
    # Fix the date
    sed -i "s/\$(date +%Y-%m-%d)/$(date +%Y-%m-%d)/" "$HILLCHART"
    echo "Hill chart initialized at $HILLCHART"
    ;;
  show)
    if [ -f "$HILLCHART" ]; then
      cat "$HILLCHART"
    else
      echo "No hill chart found at $HILLCHART" >&2
      exit 1
    fi
    ;;
  *)
    echo "Unknown action: $ACTION. Use 'init' or 'show'." >&2
    exit 1
    ;;
esac
