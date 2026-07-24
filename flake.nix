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
        herdr = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
        agent-browser = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
        pi-computer-use = [ "aarch64-darwin" "x86_64-darwin" ];
      };

      supports = system: name: lib.elem system (packageSystems.${name} or systems);

      mkPackages = pkgs:
        let
          system = pkgs.stdenv.hostPlatform.system;
          optional = name: value: lib.optionalAttrs (supports system name) value;
          cassPkg = if supports system "cass" then pkgs.callPackage ./pkgs/cass.nix {} else null;
          markitdownPythonPackages = import ./pkgs/markitdown-python-packages.nix {
            inherit (pkgs) ffmpeg-headless python3Packages;
          };
          markitdownBasePkg = pkgs.callPackage ./pkgs/markitdown-base.nix {
            python3Packages = markitdownPythonPackages;
          };
          markitdownOcrPkg = pkgs.callPackage ./pkgs/markitdown-ocr.nix {
            python3Packages = markitdownPythonPackages;
            markitdown-base = markitdownBasePkg;
          };
          piPkg = pkgs.callPackage ./pkgs/pi-coding-agent.nix { inherit (pkgs) path; };
          pkgSet =
            optional "claude-code" { claude-code = pkgs.callPackage ./pkgs/claude-code.nix {}; }
            // optional "codex" { codex = pkgs.callPackage ./pkgs/codex.nix {}; }
            // optional "dash-mcp-server" { dash-mcp-server = pkgs.callPackage ./pkgs/dash-mcp-server.nix {}; }
            // optional "markit" { markit = pkgs.callPackage ./pkgs/markit.nix { nodejs = pkgs.nodejs_22; }; }
            // optional "markitdown-base" { markitdown-base = markitdownBasePkg; }
            // optional "markitdown" { markitdown = pkgs.callPackage ./pkgs/markitdown.nix { markitdown-base = markitdownBasePkg; markitdown-ocr = markitdownOcrPkg; }; }
            // optional "markitdown-ocr" { markitdown-ocr = markitdownOcrPkg; }
            // optional "xcodebuildmcp" { xcodebuildmcp = pkgs.callPackage ./pkgs/xcodebuildmcp.nix { nodejs = pkgs.nodejs_22; }; }
            // optional "spogo" { spogo = pkgs.callPackage ./pkgs/spogo.nix {}; }
            // optional "nanobanana" { nanobanana = pkgs.callPackage ./pkgs/nanobanana.nix {}; }
            // optional "pi-coding-agent" { pi-coding-agent = piPkg; }
            // optional "pi-diff-review" { pi-diff-review = pkgs.callPackage ./pkgs/pi-diff-review.nix { nodejs = pkgs.nodejs_22; }; }
            // optional "pi-autoresearch" { pi-autoresearch = pkgs.callPackage ./pkgs/pi-autoresearch.nix {}; }
            // optional "qmd" { qmd = pkgs.callPackage ./pkgs/qmd.nix { inherit (pkgs) bun2nix; }; }
            // optional "cass" (if cassPkg != null then { cass = cassPkg; } else {})
            // optional "cm" (if cassPkg != null then { cm = pkgs.callPackage ./pkgs/cm.nix { cass = cassPkg; }; } else {})
            // optional "herdr" { herdr = pkgs.callPackage ./pkgs/herdr.nix {}; }
            // optional "agent-browser" { agent-browser = pkgs.callPackage ./pkgs/agent-browser.nix {}; }
            // optional "pi-web-search" { pi-web-search = pkgs.callPackage ./pkgs/pi-web-search.nix { pi-coding-agent = piPkg; }; }
            // optional "pi-agent-browser-native" { pi-agent-browser-native = pkgs.callPackage ./pkgs/pi-agent-browser-native.nix { pi-coding-agent = piPkg; }; }
            // optional "pi-computer-use" { pi-computer-use = pkgs.callPackage ./pkgs/pi-computer-use.nix { pi-coding-agent = piPkg; }; }
            // { default = piPkg; };
        in lib.removeAttrs pkgSet [ "override" "overrideDerivation" ];

      packagesFor = system: mkPackages (import nixpkgs {
        inherit system;
        overlays = [ bun2nix.overlays.default ];
        config.allowUnfreePredicate = pkg: lib.getName pkg == "claude-code";
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
          markit = prev.callPackage ./pkgs/markit.nix { nodejs = prev.nodejs_22; };
          markitdown-base = markitdownBasePkg;
          markitdown = prev.callPackage ./pkgs/markitdown.nix { markitdown-base = markitdownBasePkg; markitdown-ocr = markitdownOcrPkg; };
          markitdown-ocr = markitdownOcrPkg;
          xcodebuildmcp = prev.callPackage ./pkgs/xcodebuildmcp.nix { nodejs = prev.nodejs_22; };
          spogo = prev.callPackage ./pkgs/spogo.nix {};
          nanobanana = prev.callPackage ./pkgs/nanobanana.nix {};
          qmd = prev.callPackage ./pkgs/qmd.nix { inherit (bunPkgs) bun2nix; };
          cass = cassPkg;
          cm = prev.callPackage ./pkgs/cm.nix { cass = cassPkg; };
          herdr = prev.callPackage ./pkgs/herdr.nix {};
          agent-browser = prev.callPackage ./pkgs/agent-browser.nix {};
          pi-web-search = prev.callPackage ./pkgs/pi-web-search.nix { pi-coding-agent = final.pi-coding-agent; };
          pi-agent-browser-native = prev.callPackage ./pkgs/pi-agent-browser-native.nix { pi-coding-agent = final.pi-coding-agent; };
          pi-computer-use = prev.callPackage ./pkgs/pi-computer-use.nix { pi-coding-agent = final.pi-coding-agent; };
        };

      checks = self.packages;
    };
}
