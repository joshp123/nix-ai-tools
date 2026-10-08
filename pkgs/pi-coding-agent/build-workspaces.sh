#!/usr/bin/env bash
set -euo pipefail

# Build workspace dependencies in upstream's offline build order. The
# coding-agent workspace itself is built afterwards by buildNpmPackage.
# Offline build scripts skip live provider catalog generation; the Nix package
# supplies the generated model data from the published pi-ai release.
order=$(node -p 'require("./package.json").scripts["build:offline"]' |
  grep -oE 'cd (packages/|\.\./)[^ ]+' | sed -E 's#.*/##')
if [[ -z "$order" ]]; then
  echo "error: could not read workspace build order from package.json" >&2
  exit 1
fi

for dir in $order; do
  if [[ "$dir" == coding-agent ]]; then
    continue
  fi
  script=$(node -p "require('./packages/$dir/package.json').scripts['build:offline'] ? 'build:offline' : 'build'")
  (cd "packages/$dir" && npm run "$script")
done
