#!/usr/bin/env bash
set -euo pipefail

manifests=$(
  for file in "$@"; do
    dir=$(dirname "$file")
    while [ -n "$dir" ] && [ "$dir" != "/" ]; do
      if [ -f "$dir/Cargo.toml" ]; then
        cargo locate-project --workspace --manifest-path "$dir/Cargo.toml" 2>/dev/null |
        sed -n 's/.*"root":"\([^"]*\)".*/\1/p'
        break
      fi
      [ "$dir" = "." ] && break
      dir=$(dirname "$dir")
    done
  done | sort -u
)

success=true
if [[ -n "$manifests" ]]; then
  while IFS= read -r manifest; do
    cargo clippy --manifest-path "$manifest" --tests -- -D warnings -A dead_code || success=false
  done < <(printf '%s\n' "$manifests")
fi

if [[ "$success" != true ]]; then
  exit 1
fi
