#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <package>" >&2
  exit 1
fi

package="$1"
shift || true

nix run nixpkgs#nix-update -- --flake . "$package" "$@"
