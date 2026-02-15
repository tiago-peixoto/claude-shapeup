#!/bin/bash
# validate-package.sh — Check a package.md for unresolved items
# Usage: validate-package.sh <path-to-package.md>
# Returns exit code 0 if clean, 1 if issues found

PACKAGE="$1"

if [ -z "$PACKAGE" ] || [ ! -f "$PACKAGE" ]; then
  echo "Usage: validate-package.sh <path-to-package.md>" >&2
  exit 1
fi

ISSUES=0

# Check for TBD/TODO/FIXME markers
if grep -qiE '(^|[^a-zA-Z])(TBD|TODO|FIXME)([^a-zA-Z]|$)' "$PACKAGE"; then
  echo "UNRESOLVED ITEMS FOUND:"
  grep -niE '(^|[^a-zA-Z])(TBD|TODO|FIXME)([^a-zA-Z]|$)' "$PACKAGE"
  ISSUES=$((ISSUES + 1))
fi

# Check required sections exist
for section in "## Problem" "## Appetite" "## Requirements" "## Solution" "## Fit Check" "## Rabbit Holes" "## No-Gos"; do
  if ! grep -q "$section" "$PACKAGE"; then
    echo "MISSING SECTION: $section"
    ISSUES=$((ISSUES + 1))
  fi
done

# Check for at least one Element
if ! grep -q "### Element:" "$PACKAGE"; then
  echo "WARNING: No solution elements defined (### Element:)"
  ISSUES=$((ISSUES + 1))
fi

# Check for unresolved flagged unknowns (⚠️)
if grep -q '⚠️' "$PACKAGE"; then
  echo "UNRESOLVED FLAGGED UNKNOWNS (⚠️) FOUND:"
  grep -n '⚠️' "$PACKAGE"
  ISSUES=$((ISSUES + 1))
fi

if [ "$ISSUES" -eq 0 ]; then
  echo "Package validation PASSED — all sections present, no unresolved items."
  exit 0
else
  echo ""
  echo "Package validation FAILED — $ISSUES issue(s) found."
  exit 1
fi
