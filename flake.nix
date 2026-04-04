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
        codex-lb = [ "aarch64-darwin" "x86_64-darwin" ];
        peekaboo-cli = [ "aarch64-darwin" "x86_64-darwin" ];
        peekaboo-mcp = [ "aarch64-darwin" "x86_64-darwin" ];
        qmd = [ "aarch64-darwin" "x86_64-darwin" ];
        zagi = systems;
      };

      supports = system: name: lib.elem system (packageSystems.${name} or systems);

      mkPackages = pkgs:
        let
          system = pkgs.stdenv.hostPlatform.system;
          optional = name: value: lib.optionalAttrs (supports system name) value;
          cassPkg = if supports system "cass" then pkgs.callPackage ./pkgs/cass.nix {} else null;
          markitdownBasePkg = pkgs.callPackage ./pkgs/markitdown-base.nix {};
          markitdownOcrPkg = pkgs.callPackage ./pkgs/markitdown-ocr.nix { markitdown-base = markitdownBasePkg; };
          piPkg = pkgs.callPackage ./pkgs/pi-coding-agent.nix { inherit (pkgs) path; };
          pkgSet =
            optional "dash-mcp-server" { dash-mcp-server = pkgs.callPackage ./pkgs/dash-mcp-server.nix {}; }
            // optional "markit" { markit = pkgs.callPackage ./pkgs/markit.nix { nodejs = pkgs.nodejs_22; }; }
            // optional "markitdown" { markitdown = pkgs.callPackage ./pkgs/markitdown.nix { markitdown-base = markitdownBasePkg; markitdown-ocr = markitdownOcrPkg; }; }
            // optional "markitdown-ocr" { markitdown-ocr = markitdownOcrPkg; }
            // optional "xcodebuildmcp" { xcodebuildmcp = pkgs.callPackage ./pkgs/xcodebuildmcp.nix { nodejs = pkgs.nodejs_22; }; }
            // optional "peekaboo-cli" { peekaboo-cli = pkgs.callPackage ./pkgs/peekaboo-cli.nix {}; }
            // optional "peekaboo-mcp" { peekaboo-mcp = pkgs.callPackage ./pkgs/peekaboo-mcp.nix { nodejs = pkgs.nodejs_22; }; }
            // optional "spogo" { spogo = pkgs.callPackage ./pkgs/spogo.nix {}; }
            // optional "oracle" { oracle = pkgs.callPackage ./pkgs/oracle-cli.nix {}; }
            // optional "nanobanana" { nanobanana = pkgs.callPackage ./pkgs/nanobanana.nix {}; }
            // optional "smaug" (pkgs.callPackage ./pkgs/smaug.nix {})
            // optional "pi-coding-agent" { pi-coding-agent = piPkg; }
            // optional "pi-diff-review" { pi-diff-review = pkgs.callPackage ./pkgs/pi-diff-review.nix { nodejs = pkgs.nodejs_22; }; }
            // optional "pi-autoresearch" { pi-autoresearch = pkgs.callPackage ./pkgs/pi-autoresearch.nix {}; }
            // optional "qmd" { qmd = pkgs.callPackage ./pkgs/qmd.nix { inherit (pkgs) bun2nix; }; }
            // optional "ubs" { ubs = pkgs.callPackage ./pkgs/ubs.nix {}; }
            // optional "cass" (if cassPkg != null then { cass = cassPkg; } else {})
            // optional "cm" (if cassPkg != null then { cm = pkgs.callPackage ./pkgs/cm.nix { cass = cassPkg; }; } else {})
            // optional "codex-lb" { codex-lb = pkgs.callPackage ./pkgs/codex-lb.nix {}; }
            // optional "zagi" { zagi = pkgs.callPackage ./pkgs/zagi.nix {}; }
            // { default = piPkg; };
        in lib.removeAttrs pkgSet [ "override" "overrideDerivation" ];

      packagesFor = system: mkPackages (import nixpkgs {
        inherit system;
        overlays = [ bun2nix.overlays.default ];
      });
    in {
      packages = forAllSystems packagesFor;

      # Overlay - all packages using prev.callPackage
      overlays.default = final: prev:
        let
          bunPkgs = import nixpkgs {
            system = prev.stdenv.hostPlatform.system;
            overlays = [ bun2nix.overlays.default ];
          };
          cassPkg = prev.callPackage ./pkgs/cass.nix {};
          markitdownBasePkg = prev.callPackage ./pkgs/markitdown-base.nix {};
          markitdownOcrPkg = prev.callPackage ./pkgs/markitdown-ocr.nix { markitdown-base = markitdownBasePkg; };
          smaugPkgs = prev.callPackage ./pkgs/smaug.nix {};
        in {
          pi-coding-agent = prev.callPackage ./pkgs/pi-coding-agent.nix { inherit (prev) path; };
          pi-diff-review = prev.callPackage ./pkgs/pi-diff-review.nix { nodejs = prev.nodejs_22; };
          pi-autoresearch = prev.callPackage ./pkgs/pi-autoresearch.nix {};
          oracle = prev.callPackage ./pkgs/oracle-cli.nix {};
          dash-mcp-server = prev.callPackage ./pkgs/dash-mcp-server.nix {};
          markit = prev.callPackage ./pkgs/markit.nix { nodejs = prev.nodejs_22; };
          markitdown = prev.callPackage ./pkgs/markitdown.nix { markitdown-base = markitdownBasePkg; markitdown-ocr = markitdownOcrPkg; };
          markitdown-ocr = markitdownOcrPkg;
          xcodebuildmcp = prev.callPackage ./pkgs/xcodebuildmcp.nix { nodejs = prev.nodejs_22; };
          spogo = prev.callPackage ./pkgs/spogo.nix {};
          nanobanana = prev.callPackage ./pkgs/nanobanana.nix {};
          ubs = prev.callPackage ./pkgs/ubs.nix {};
          zagi = prev.callPackage ./pkgs/zagi.nix {};
          qmd = prev.callPackage ./pkgs/qmd.nix { inherit (bunPkgs) bun2nix; };
          peekaboo-cli = prev.callPackage ./pkgs/peekaboo-cli.nix {};
          peekaboo-mcp = prev.callPackage ./pkgs/peekaboo-mcp.nix { nodejs = prev.nodejs_22; };
          cass = cassPkg;
          cm = prev.callPackage ./pkgs/cm.nix { cass = cassPkg; };
          codex-lb = prev.callPackage ./pkgs/codex-lb.nix {};
          smaug = smaugPkgs.smaug;
          smaug-moltbot = smaugPkgs.smaug-moltbot;
        };

      checks = forAllSystems (system: self.packages.${system});
    };
}
