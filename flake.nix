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

      packagesFor = system:
        let
          pkgs = import nixpkgs { inherit system; };
          optional = name: value: lib.optionalAttrs (supports system name) value;
          cassPkg = if supports system "cass" then pkgs.callPackage ./pkgs/cass.nix {} else null;
          piPkg = pkgs.callPackage ./pkgs/pi-coding-agent.nix { inherit (pkgs) path; };

          pkgSet =
            optional "ccusage" (pkgs.callPackage ./pkgs/ccusage.nix { pkgs = pkgs; })
            // optional "dash-mcp-server" { dash-mcp-server = pkgs.callPackage ./pkgs/dash-mcp-server.nix {}; }
            // optional "xcodebuildmcp" { xcodebuildmcp = pkgs.callPackage ./pkgs/xcodebuildmcp.nix { nodejs = pkgs.nodejs_22; }; }
            // optional "peekaboo-cli" { peekaboo-cli = pkgs.callPackage ./pkgs/peekaboo-cli.nix {}; }
            // optional "peekaboo-mcp" { peekaboo-mcp = pkgs.callPackage ./pkgs/peekaboo-mcp.nix { nodejs = pkgs.nodejs_22; }; }
            // optional "spogo" { spogo = pkgs.callPackage ./pkgs/spogo.nix {}; }
            // optional "oracle" { oracle = pkgs.callPackage ./pkgs/oracle-cli.nix { pkgs = pkgs; }; }
            // optional "nanobanana" { nanobanana = pkgs.callPackage ./pkgs/nanobanana.nix {}; }
            // optional "smaug" (pkgs.callPackage ./pkgs/smaug.nix {})
            // optional "pi-coding-agent" { pi-coding-agent = piPkg; }
            // optional "ubs" { ubs = pkgs.callPackage ./pkgs/ubs.nix {}; }
            // optional "cass" (if cassPkg != null then { cass = cassPkg; } else {})
            // optional "cm" (if cassPkg != null then { cm = pkgs.callPackage ./pkgs/cm.nix { cass = cassPkg; }; } else {})
            // optional "zagi" { zagi = pkgs.callPackage ./pkgs/zagi.nix {}; }
            // {
              default = piPkg;
            };
        in
          lib.removeAttrs pkgSet [ "override" "overrideDerivation" ];
    in {
      packages = forAllSystems packagesFor;

      overlays.default = final: prev:
        let
          tools = self.packages.${final.system};
        in tools;

      checks = forAllSystems (system: self.packages.${system});
    };
}
