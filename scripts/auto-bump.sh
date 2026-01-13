#!/usr/bin/env bash
set -euo pipefail

DEFAULT_PACKAGES=(peekaboo-cli peekaboo-mcp oracle spogo dash-mcp-server xcodebuildmcp dev-browser summarize zagi pi-coding-agent)
AUTO_SYSTEM=${AUTO_BUMP_SYSTEM:-aarch64-darwin}
AUTO_BUILD=${AUTO_BUMP_BUILD:-}
if [[ $# -gt 0 ]]; then
  PACKAGES=("$@")
else
  IFS=' ' read -r -a PACKAGES <<<"${AUTO_PACKAGES:-${DEFAULT_PACKAGES[*]}}"
fi

updated=0
for pkg in "${PACKAGES[@]}"; do
  if [[ -z "$pkg" ]]; then
    continue
  fi
  echo "==> checking ${pkg}"
  build_flags=()
  if [[ -n "$AUTO_BUILD" ]]; then
    build_flags+=(--build)
  fi
  if nix run nixpkgs#nix-update -- -F --system "$AUTO_SYSTEM" "${build_flags[@]}" "$pkg"; then
    continue
  else
    echo "warn: ${pkg} update failed" >&2
  fi
done

if ! git diff --quiet; then
  updated=1
fi

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  if [[ $updated -eq 1 ]]; then
    echo "has_updates=true" >>"$GITHUB_OUTPUT"
  else
    echo "has_updates=false" >>"$GITHUB_OUTPUT"
  fi
fi

if [[ $updated -eq 1 ]]; then
  echo "updates found"
else
  echo "no updates"
fi
