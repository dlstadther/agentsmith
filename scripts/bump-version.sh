#!/usr/bin/env bash
set -euo pipefail

version="${NEXT_RELEASE_VERSION:?NEXT_RELEASE_VERSION is required}"
file="${1:-.claude-plugin/plugin.json}"

tmp=$(mktemp)
jq --arg v "$version" '.version = $v' "$file" > "$tmp"
mv "$tmp" "$file"
