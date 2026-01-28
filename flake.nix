{
  description = "Nix packages for fast-moving AI tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      helpers = import ./lib/helpers.nix { inherit lib; };
      inherit (helpers) systems forAllSystems;

      packageSystems = {
        peekaboo-cli = [ "aarch64-darwin" "x86_64-darwin" ];
        peekaboo-mcp = [ "aarch64-darwin" "x86_64-darwin" ];
        zagi = systems;
      };

      supports = system: name: lib.elem system (packageSystems.${name} or systems);

      mkPackages = pkgs:
        let
          system = pkgs.stdenv.hostPlatform.system;
          optional = name: value: lib.optionalAttrs (supports system name) value;
          cassPkg = if supports system "cass" then pkgs.callPackage ./pkgs/cass.nix {} else null;
          piPkg = pkgs.callPackage ./pkgs/pi-coding-agent.nix { inherit (pkgs) path; };
          pkgSet =
            optional "dash-mcp-server" { dash-mcp-server = pkgs.callPackage ./pkgs/dash-mcp-server.nix {}; }
            // optional "xcodebuildmcp" { xcodebuildmcp = pkgs.callPackage ./pkgs/xcodebuildmcp.nix { nodejs = pkgs.nodejs_22; }; }
            // optional "peekaboo-cli" { peekaboo-cli = pkgs.callPackage ./pkgs/peekaboo-cli.nix {}; }
            // optional "peekaboo-mcp" { peekaboo-mcp = pkgs.callPackage ./pkgs/peekaboo-mcp.nix { nodejs = pkgs.nodejs_22; }; }
            // optional "spogo" { spogo = pkgs.callPackage ./pkgs/spogo.nix {}; }
            // optional "oracle" { oracle = pkgs.callPackage ./pkgs/oracle-cli.nix {}; }
            // optional "nanobanana" { nanobanana = pkgs.callPackage ./pkgs/nanobanana.nix {}; }
            // optional "smaug" (pkgs.callPackage ./pkgs/smaug.nix {})
            // optional "pi-coding-agent" { pi-coding-agent = piPkg; }
            // optional "ubs" { ubs = pkgs.callPackage ./pkgs/ubs.nix {}; }
            // optional "cass" (if cassPkg != null then { cass = cassPkg; } else {})
            // optional "cm" (if cassPkg != null then { cm = pkgs.callPackage ./pkgs/cm.nix { cass = cassPkg; }; } else {})
            // optional "zagi" { zagi = pkgs.callPackage ./pkgs/zagi.nix {}; }
            // { default = piPkg; };
        in lib.removeAttrs pkgSet [ "override" "overrideDerivation" ];

      packagesFor = system: mkPackages (import nixpkgs { inherit system; });
    in {
      packages = forAllSystems packagesFor;

      # Overlay - all packages using prev.callPackage
      overlays.default = final: prev:
        let
          cassPkg = prev.callPackage ./pkgs/cass.nix {};
          smaugPkgs = prev.callPackage ./pkgs/smaug.nix {};
        in {
          pi-coding-agent = prev.callPackage ./pkgs/pi-coding-agent.nix { inherit (prev) path; };
          oracle = prev.callPackage ./pkgs/oracle-cli.nix {};
          dash-mcp-server = prev.callPackage ./pkgs/dash-mcp-server.nix {};
          xcodebuildmcp = prev.callPackage ./pkgs/xcodebuildmcp.nix { nodejs = prev.nodejs_22; };
          spogo = prev.callPackage ./pkgs/spogo.nix {};
          nanobanana = prev.callPackage ./pkgs/nanobanana.nix {};
          ubs = prev.callPackage ./pkgs/ubs.nix {};
          zagi = prev.callPackage ./pkgs/zagi.nix {};
          peekaboo-cli = prev.callPackage ./pkgs/peekaboo-cli.nix {};
          peekaboo-mcp = prev.callPackage ./pkgs/peekaboo-mcp.nix { nodejs = prev.nodejs_22; };
          cass = cassPkg;
          cm = prev.callPackage ./pkgs/cm.nix { cass = cassPkg; };
          smaug = smaugPkgs.smaug;
          smaug-moltbot = smaugPkgs.smaug-moltbot;
        };

      checks = forAllSystems (system: self.packages.${system});
    };
}
