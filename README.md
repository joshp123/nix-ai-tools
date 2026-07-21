---
written_by: ai
---

# nix-ai-tools

Nix flake of fast-moving AI tools with hourly auto-bumps. GitHub Actions builds
changed packages and publishes successful outputs to the public
`joshp123-nix-ai-tools.cachix.org` binary cache.

## Usage

```bash
# build a tool
nix build .#pi-coding-agent

# use overlay from another flake
inputs.nix-ai-tools.url = "github:joshp123/nix-ai-tools";
outputs = { self, nixpkgs, nix-ai-tools, ... }: {
  overlays.default = nix-ai-tools.overlays.default;
};
```

## Add a tool

1. Create `pkgs/<name>.nix`
2. Add it in `flake.nix` under `packagesFor`
3. Add to `scripts/auto-bump.sh` if it can update safely
4. Commit and push — GitHub Actions builds and publishes to Cachix

## Manual bump

```bash
./scripts/bump.sh <package>
```

## CI

- **GitHub Actions** builds packages on native runners and publishes to Cachix
- **Auto-bump** workflow checks upstream hourly and pushes commits when versions move
- `scripts/auto-bump.sh` covers packages that `nix-update` can safely bump.
