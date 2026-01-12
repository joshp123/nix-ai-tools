{ lib }:
let
  systems = [
    "aarch64-darwin"
    "x86_64-darwin"
    "x86_64-linux"
    "aarch64-linux"
  ];
  forAllSystems = f: lib.genAttrs systems (system: f system);
in {
  inherit systems forAllSystems;
}
