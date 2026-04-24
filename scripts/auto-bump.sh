#!/usr/bin/env bash
set -euo pipefail

DEFAULT_PACKAGES=(
  codex-lb
  dash-mcp-server
  markit
  markitdown-base
  markitdown-ocr
  peekaboo-cli
  peekaboo-mcp
  pi-autoresearch
  pi-coding-agent
  pi-diff-review
  qmd
  smaug
  spogo
  ubs
  xcodebuildmcp
  zagi
)
AUTO_SYSTEM=${AUTO_BUMP_SYSTEM:-aarch64-darwin}
AUTO_BUILD=${AUTO_BUMP_BUILD:-}

latest_pypi_version() {
  python3 - "$1" <<'PY'
import json
import sys
import urllib.request

package = sys.argv[1]
with urllib.request.urlopen(f"https://pypi.org/pypi/{package}/json") as response:
    print(json.load(response)["info"]["version"])
PY
}

if [[ $# -gt 0 ]]; then
  PACKAGES=("$@")
else
  IFS=' ' read -r -a PACKAGES <<<"${AUTO_PACKAGES:-${DEFAULT_PACKAGES[*]}}"
fi

updated=0
failed=0
for pkg in "${PACKAGES[@]}"; do
  if [[ -z "$pkg" ]]; then
    continue
  fi
  echo "==> checking ${pkg}"
  build_flags=()
  if [[ -n "$AUTO_BUILD" ]]; then
    build_flags+=(--build)
  fi
  update_flags=()
  case "$pkg" in
    codex-lb)
      update_flags+=(--version "$(latest_pypi_version codex-lb)")
      ;;
    dash-mcp-server)
      update_flags+=(--version branch)
      ;;
    markitdown-base)
      update_flags+=(--version "$(latest_pypi_version markitdown)")
      ;;
    markitdown-ocr)
      update_flags+=(--version "$(latest_pypi_version markitdown-ocr)")
      ;;
    pi-autoresearch|ubs)
      update_flags+=(--version branch)
      ;;
    qmd)
      update_flags+=(--override-filename pkgs/qmd.nix)
      ;;
  esac

  command=(nix run nixpkgs#nix-update -- -F --system "$AUTO_SYSTEM")
  if [[ ${#build_flags[@]} -gt 0 ]]; then
    command+=("${build_flags[@]}")
  fi
  if [[ ${#update_flags[@]} -gt 0 ]]; then
    command+=("${update_flags[@]}")
  fi
  command+=("$pkg")

  if "${command[@]}"; then
    continue
  else
    echo "warn: ${pkg} update failed" >&2
    failed=1
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

if [[ $failed -eq 1 ]]; then
  exit 1
fi
