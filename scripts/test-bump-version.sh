#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUMP="$SCRIPT_DIR/bump-version.sh"

# Setup: temp plugin.json with no version field
tmpfile=$(mktemp)
echo '{"name":"agentsmith","description":"test"}' > "$tmpfile"

# Run
NEXT_RELEASE_VERSION="2.3.4" "$BUMP" "$tmpfile"

# Assert
result=$(jq -r '.version' "$tmpfile")
rm "$tmpfile"

if [ "$result" = "2.3.4" ]; then
  echo "PASS: version written correctly"
else
  echo "FAIL: expected 2.3.4, got $result"
  exit 1
fi
