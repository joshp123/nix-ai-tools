#!/usr/bin/env bash
# Pin a pi extension package's runtime npm dependencies for pkgs/pi-package.nix.
# Writes pkgs/<pkg>/package-lock.json from the packaged npm tarball's
# `dependencies`, or removes it when the package has none. Peer and dev
# dependencies are left out: Pi provides the peers at runtime.
set -euo pipefail

pkg=$1
lock="pkgs/$pkg/package-lock.json"

src=$(nix build ".#${pkg}.src" --no-link --print-out-paths)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir "$work/src" "$work/lock"
tar -xzf "$src" --strip-components=1 -C "$work/src"

nix shell --inputs-from . nixpkgs#nodejs_22 -c bash -euo pipefail -c '
  work=$1
  node -e "
    const p = require(process.argv[1]);
    const dependencies = p.dependencies ?? {};
    if (Object.keys(dependencies).length === 0) process.exit(3);
    require(\"fs\").writeFileSync(process.argv[2],
      JSON.stringify({ name: p.name, version: p.version, dependencies }, null, 2));
  " "$work/src/package.json" "$work/lock/package.json" || exit $?
  cd "$work/lock"
  npm install --package-lock-only --legacy-peer-deps --ignore-scripts \
    --no-audit --no-fund >&2
' bash "$work" && status=0 || status=$?

case $status in
  0)
    mkdir -p "pkgs/$pkg"
    cp "$work/lock/package-lock.json" "$lock"
    # Make the new file visible to `git diff HEAD` so auto-bump keeps or
    # discards it together with the rest of this package's update.
    git add --intent-to-add "$lock"
    echo "wrote $lock"
    ;;
  3)
    rm -f "$lock"
    echo "$pkg has no runtime npm dependencies"
    ;;
  *)
    exit "$status"
    ;;
esac
