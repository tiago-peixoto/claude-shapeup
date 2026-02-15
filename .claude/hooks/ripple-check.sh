#!/bin/bash
# ripple-check.sh — PostToolUse hook for Shape Up document consistency
# Fires after Write/Edit on .shapeup/**/*.md files
# Reminds the agent to check cross-document consistency

# Read hook input from stdin
INPUT=$(cat)

# Extract the file path
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only process files in .shapeup directories
if [[ ! "$FILE_PATH" =~ \.shapeup/.*\.md$ ]]; then
  exit 0
fi

# Determine which document was modified
BASENAME=$(basename "$FILE_PATH")
FEATURE_DIR=$(dirname "$FILE_PATH")

# Build context about what other documents exist in this feature
SIBLINGS=""
if [ -d "$FEATURE_DIR" ]; then
  for f in "$FEATURE_DIR"/*.md; do
    [ -f "$f" ] && SIBLINGS="$SIBLINGS $(basename "$f")"
  done
fi

# Check for scopes directory
HAS_SCOPES="no"
if [ -d "$FEATURE_DIR/scopes" ]; then
  HAS_SCOPES="yes"
fi

# Generate ripple-check reminder based on what was modified
case "$BASENAME" in
  frame.md)
    cat >&2 <<EOF
RIPPLE CHECK — frame.md was modified.
If a package.md exists, verify: Does the package's Problem section still match the frame?
If requirements changed, the package's R table and fit check may need updating.
Sibling docs:$SIBLINGS
EOF
    ;;
  package.md)
    cat >&2 <<EOF
RIPPLE CHECK — package.md was modified.
If scopes exist ($HAS_SCOPES), verify: Do scope must-haves still align with the package's elements?
If elements changed, verify the fit check matrix still has full R coverage.
If rabbit holes changed, check if any scope tasks reference resolved risks.
Sibling docs:$SIBLINGS
EOF
    ;;
  hillchart.md)
    cat >&2 <<EOF
RIPPLE CHECK — hillchart.md was modified.
Verify: Do scope file hill positions match the hillchart summary?
If a scope moved to done, check if its must-have tasks are all checked off.
Sibling docs:$SIBLINGS
EOF
    ;;
  scope-*.md)
    cat >&2 <<EOF
RIPPLE CHECK — scope file was modified: $BASENAME
Verify: Does hillchart.md reflect the current hill position of this scope?
If must-haves were added/removed, check if the package's fit check still holds.
Sibling docs:$SIBLINGS
EOF
    ;;
  handover-*.md)
    # Handovers are append-only chronicles, no ripple needed
    exit 0
    ;;
  *)
    # Other .md files in .shapeup — light reminder
    cat >&2 <<EOF
RIPPLE CHECK — $BASENAME was modified in a Shape Up feature folder.
Consider: Does this change affect frame.md, package.md, or any scope files?
Sibling docs:$SIBLINGS
EOF
    ;;
esac

# Exit 0 — this is advisory, not blocking
exit 0
