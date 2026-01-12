# nix-ai-tools

Nix flake of fast-moving AI tools with Garnix builds and hourly auto-bumps.

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
4. Commit and push — Garnix builds + caches

## Manual bump

```bash
./scripts/bump.sh <package>
```

## CI

- **Garnix** builds all packages for macOS (arm64) and Linux (x86_64, arm64)
- **Auto-bump** workflow checks upstream hourly and pushes commits when versions move
