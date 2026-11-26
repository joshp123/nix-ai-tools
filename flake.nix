{
  description = "Nix packages for fast-moving AI tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    bun2nix.url = "github:nix-community/bun2nix";
  };

  outputs = { self, nixpkgs, bun2nix }:
    let
      lib = nixpkgs.lib;
      helpers = import ./lib/helpers.nix { inherit lib; };
      inherit (helpers) systems forAllSystems;

      packageSystems = {
        claude-code = [ "aarch64-darwin" ];
        codex = [ "aarch64-darwin" ];
        cass = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
        cm = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
        qmd = [ "aarch64-darwin" "x86_64-darwin" ];
        herdr = [ "aarch64-darwin" ];
        agent-browser = [ "aarch64-darwin" ];
        cua-driver = [ "aarch64-darwin" ];
      };

      supports = system: name: lib.elem system (packageSystems.${name} or systems);

      mkPackageSet = final: prev:
        let
          markitdownPythonPackages = import ./pkgs/markitdown-python-packages.nix {
            inherit (prev) ffmpeg-headless python3Packages;
          };
          markitdownBasePkg = prev.callPackage ./pkgs/markitdown-base.nix {
            python3Packages = markitdownPythonPackages;
          };
          markitdownOcrPkg = prev.callPackage ./pkgs/markitdown-ocr.nix {
            python3Packages = markitdownPythonPackages;
            markitdown-base = markitdownBasePkg;
          };
        in {
          claude-code = prev.callPackage ./pkgs/claude-code.nix {};
          codex = prev.callPackage ./pkgs/codex.nix {};
          pi-coding-agent = prev.callPackage ./pkgs/pi-coding-agent.nix { inherit (prev) path; };
          pi-diff-review = prev.callPackage ./pkgs/pi-diff-review.nix { nodejs = prev.nodejs_22; };
          pi-autoresearch = prev.callPackage ./pkgs/pi-autoresearch.nix {};
          dash-mcp-server = prev.callPackage ./pkgs/dash-mcp-server.nix {};
          markit = prev.callPackage ./pkgs/markit.nix {};
          markitdown-base = markitdownBasePkg;
          markitdown = prev.callPackage ./pkgs/markitdown.nix {
            markitdown-base = markitdownBasePkg;
            markitdown-ocr = markitdownOcrPkg;
          };
          markitdown-ocr = markitdownOcrPkg;
          xcodebuildmcp = prev.callPackage ./pkgs/xcodebuildmcp.nix { nodejs = prev.nodejs_22; };
          spogo = prev.callPackage ./pkgs/spogo.nix {};
          qmd = prev.callPackage ./pkgs/qmd.nix {
            bun2nix = (nixpkgs.legacyPackages.${prev.stdenv.hostPlatform.system}.extend bun2nix.overlays.default).bun2nix;
          };
          cass = prev.callPackage ./pkgs/cass.nix {};
          cm = prev.callPackage ./pkgs/cm.nix { cass = final.cass; };
          herdr = prev.callPackage ./pkgs/herdr.nix {};
          agent-browser = prev.callPackage ./pkgs/agent-browser.nix {};
          cua-driver = prev.callPackage ./pkgs/cua-driver.nix {};
          pi-web-search = prev.callPackage ./pkgs/pi-web-search.nix {
            pi-coding-agent = final.pi-coding-agent;
          };
          pi-agent-browser-native = prev.callPackage ./pkgs/pi-agent-browser-native.nix {
            pi-coding-agent = final.pi-coding-agent;
          };
        };

      packagesFor = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfreePredicate = pkg: lib.getName pkg == "claude-code";
          };
          allPkgs = lib.fix (selfPkgs: mkPackageSet selfPkgs pkgs);
        in
        (lib.filterAttrs (name: _: supports system name) allPkgs)
        // { default = allPkgs.pi-coding-agent; };
    in {
      packages = forAllSystems packagesFor;

      overlays.default = mkPackageSet;

      checks = self.packages;
    };
}
