# nix-ai-tools

Nix packages for fast-moving AI tools. Auto-bumped hourly via CI.

Consumer default lives in `~/code/nix/nixos-config` and should use the published GitHub input, not a tracked local path override:

```bash
cd ~/code/nix/nixos-config
nix flake lock --update-input nix-ai-tools
```

For local unpublished testing from this checkout, use one-off overrides instead of changing tracked inputs:

```bash
cd ~/code/nix/nixos-config
nix run .#build --override-input nix-ai-tools path:/Users/josh/code/nix/nix-ai-tools
nix run .#build-switch --override-input nix-ai-tools path:/Users/josh/code/nix/nix-ai-tools
```

## Golden path: add new package

1. Create `pkgs/<name>.nix`
2. Add to `flake.nix` packages
3. Add to `scripts/auto-bump.sh` list if safe
4. Push — Garnix builds + caches

## Golden path: manual bump

```bash
./scripts/bump.sh <package>
nix build .#<package>
git commit -am "chore: bump <package>"
git push
```

## Package patterns

### GitHub release with pre-built binary (fastest)
```nix
{ fetchurl, ... }:
fetchurl {
  url = "https://github.com/owner/repo/releases/download/v${version}/${name}-${system}.tar.gz";
  hash = "sha256-...";
}
```

### GitHub source build
```nix
{ fetchFromGitHub, buildGoModule, ... }:
buildGoModule {
  src = fetchFromGitHub { owner = "..."; repo = "..."; rev = "v${version}"; hash = "..."; };
}
```

### npm package
```nix
{ buildNpmPackage, fetchFromGitHub, ... }:
buildNpmPackage {
  src = fetchFromGitHub { ... };
  npmDepsHash = "sha256-...";
}
```

## CI

- **Garnix**: Builds all packages, caches binaries
- **Auto-bump**: Hourly cron calls `scripts/auto-bump.sh`

## Upstream to nixpkgs

After 1-2 weeks dogfooding:
1. Pick stable packages
2. Follow nixpkgs contribution guide
3. PR to nixpkgs
4. Once merged, remove from nix-ai-tools
