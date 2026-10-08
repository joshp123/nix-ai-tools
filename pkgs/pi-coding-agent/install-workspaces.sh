#!/usr/bin/env bash
set -euo pipefail

# Replace workspace symlinks with copies of every published workspace package.
for manifest in packages/*/package.json; do
  dir=${manifest%/package.json}
  name=$(node -p "const p = require('./$manifest'); p.private ? '' : p.name")
  if [[ -z "$name" ]]; then
    continue
  fi
  rm -rf "$1/node_modules/$name"
  mkdir -p "$(dirname "$1/node_modules/$name")"
  cp -R "$dir" "$1/node_modules/$name"
done
