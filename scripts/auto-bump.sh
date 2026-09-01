#!/usr/bin/env bash
set -euo pipefail

DEFAULT_PACKAGES=(
  claude-code
  codex
  dash-mcp-server
  markit
  markitdown-base
  markitdown-ocr
  pi-autoresearch
  pi-web-search
  pi-agent-browser-native
  pi-computer-use
  pi-diff-review
  pi-coding-agent
  qmd
  xcodebuildmcp
)
AUTO_SYSTEM=${AUTO_BUMP_SYSTEM:-aarch64-darwin}
AUTO_BUILD=${AUTO_BUMP_BUILD:-}
AUTO_TIMEOUT_SECONDS=${AUTO_BUMP_TIMEOUT_SECONDS:-600}

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

latest_npm_version() {
  python3 - "$1" <<'PY'
import json
import sys
import urllib.parse
import urllib.request

package = urllib.parse.quote(sys.argv[1], safe="")
with urllib.request.urlopen(f"https://registry.npmjs.org/{package}") as response:
    print(json.load(response)["dist-tags"]["latest"])
PY
}

latest_text_version() {
  python3 - "$1" <<'PY'
import sys
import urllib.request

with urllib.request.urlopen(sys.argv[1]) as response:
    print(response.read().decode().strip())
PY
}

# pi-coding-agent has three hashes (src, npm deps, pi-ai tgz) that nix-update
# cannot handle, so bump it with a dedicated routine.
bump_pi_coding_agent() {
  local pkg_file="pkgs/pi-coding-agent.nix"
  local latest
  latest=$(latest_npm_version @earendil-works/pi-coding-agent)
  local current
  current=$(grep -oE 'version = "[0-9.]+' "$pkg_file" | head -1 | grep -oE '[0-9.]+')
  if [[ "$latest" == "$current" ]]; then
    return 0
  fi
  echo "==> pi-coding-agent: $current -> $latest"

  local src_hash npm_hash pi_ai_hash
  src_hash=$(nix-prefetch-url --unpack "https://github.com/earendil-works/pi/archive/refs/tags/v${latest}.tar.gz")
  src_hash=$(nix hash convert --hash-algo sha256 --to sri "$src_hash")
  curl -fsSL "https://raw.githubusercontent.com/earendil-works/pi/v${latest}/package-lock.json" -o /tmp/pi-package-lock.json
  npm_hash=$(nix run nixpkgs#prefetch-npm-deps -- /tmp/pi-package-lock.json)
  pi_ai_hash=$(nix-prefetch-url "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-${latest}.tgz")
  pi_ai_hash=$(nix hash convert --hash-algo sha256 --to sri "$pi_ai_hash")

  python3 - "$pkg_file" "$latest" "$src_hash" "$npm_hash" "$pi_ai_hash" <<'PY'
import re
import sys

path, version, src_hash, npm_hash, pi_ai_hash = sys.argv[1:6]
with open(path) as f:
    content = f.read()

content = re.sub(r'version = "[0-9.]+"', f'version = "{version}"', content, count=1)
content = re.sub(
    r'(rev = "v\$\{version\}";\n\s*hash = )"sha256-[^"]*"',
    rf'\1"{src_hash}"',
    content,
)
content = re.sub(
    r'piNpmDepsHash = "sha256-[^"]*"',
    f'piNpmDepsHash = "{npm_hash}"',
    content,
)
content = re.sub(
    r'(pi-ai-\$\{version\}\.tgz";\n\s*hash = )"sha256-[^"]*"',
    rf'\1"{pi_ai_hash}"',
    content,
)

with open(path, "w") as f:
    f.write(content)
PY
}

run_with_timeout() {
  "$@" &
  local pid=$!

  (
    sleep "$AUTO_TIMEOUT_SECONDS"
    if kill -0 "$pid" 2>/dev/null; then
      echo "error: command timed out after ${AUTO_TIMEOUT_SECONDS}s: $*" >&2
      kill "$pid" 2>/dev/null || true
      sleep 5
      kill -9 "$pid" 2>/dev/null || true
    fi
  ) &
  local watchdog=$!

  local status=0
  wait "$pid" || status=$?
  kill "$watchdog" 2>/dev/null || true
  wait "$watchdog" 2>/dev/null || true
  return "$status"
}

restore_successful_updates() {
  local patch_file=$1

  git restore --source=HEAD --staged --worktree -- .
  if [[ -s "$patch_file" ]]; then
    git apply "$patch_file"
  fi
}

if ! git diff --quiet HEAD --; then
  echo "error: auto-bump requires a clean tracked worktree" >&2
  exit 2
fi

successful_patch=$(mktemp)
current_patch=$(mktemp)
trap 'rm -f "$successful_patch" "$current_patch"' EXIT

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
  git diff --binary HEAD -- >"$successful_patch"
  update_flags=()
  custom_bump=0
  case "$pkg" in
    pi-coding-agent)
      custom_bump=1
      ;;
    claude-code)
      update_flags+=(--version "$(latest_text_version https://downloads.claude.ai/claude-code-releases/latest)")
      ;;
    codex)
      update_flags+=(--version "$(latest_npm_version @openai/codex)")
      ;;
    dash-mcp-server)
      update_flags+=(--version branch)
      ;;
    markit)
      update_flags+=(--version-regex '^v([0-9].*)$')
      ;;
    markitdown-base)
      update_flags+=(--version "$(latest_pypi_version markitdown)")
      ;;
    markitdown-ocr)
      update_flags+=(--version "$(latest_pypi_version markitdown-ocr)")
      ;;
    qmd)
      update_flags+=(--override-filename pkgs/qmd.nix)
      ;;
    pi-web-search)
      update_flags+=(--version "$(latest_npm_version pi-web-search)" --override-filename pkgs/pi-web-search.nix)
      ;;
    pi-agent-browser-native)
      update_flags+=(--version "$(latest_npm_version pi-agent-browser-native)" --override-filename pkgs/pi-agent-browser-native.nix)
      ;;
    pi-computer-use)
      update_flags+=(--version "$(latest_npm_version @injaneity/pi-computer-use)" --override-filename pkgs/pi-computer-use.nix)
      ;;
  esac

  if [[ $custom_bump -eq 1 ]]; then
    if ! bump_pi_coding_agent; then
      echo "warn: ${pkg} update failed" >&2
      restore_successful_updates "$successful_patch"
      failed=1
      continue
    fi
  else
    command=(nix run nixpkgs#nix-update -- -F --system "$AUTO_SYSTEM")
    if [[ ${#update_flags[@]} -gt 0 ]]; then
      command+=("${update_flags[@]}")
    fi
    command+=("$pkg")

    if ! run_with_timeout "${command[@]}"; then
      echo "warn: ${pkg} update failed" >&2
      restore_successful_updates "$successful_patch"
      failed=1
      continue
    fi
  fi

  git diff --binary HEAD -- >"$current_patch"
  if cmp -s "$successful_patch" "$current_patch"; then
    continue
  fi

  if [[ -n "$AUTO_BUILD" ]] && ! run_with_timeout nix build ".#${pkg}" --no-link -L; then
    echo "warn: ${pkg} build failed; discarding only this package's update" >&2
    restore_successful_updates "$successful_patch"
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
  if [[ $failed -eq 1 ]]; then
    echo "has_failures=true" >>"$GITHUB_OUTPUT"
  else
    echo "has_failures=false" >>"$GITHUB_OUTPUT"
  fi
fi

if [[ $updated -eq 1 ]]; then
  echo "updates found"
else
  echo "no updates"
fi

exit 0
