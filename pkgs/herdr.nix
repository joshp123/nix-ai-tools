{ lib
, stdenvNoCC
, fetchurl
}:

# One release binary per package so nix-update can bump the hash; CI, the
# workstation and the Mac mini are all aarch64-darwin.
let
  version = "0.9.4";
  piIntegration = fetchurl {
    url = "https://raw.githubusercontent.com/ogulcancelik/herdr/v${version}/src/integration/assets/pi/herdr-agent-state.ts";
    hash = "sha256-LFJy1zK0dbv5GgJyA7H5jSX+Q9LBQCUwpEKyiK6soeQ=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "herdr";
  inherit version;

  src = fetchurl {
    url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-macos-aarch64";
    hash = "sha256-6iC//5y4yDqZYIHJJub/k3DejlQ7qoWbykjRkXXYlf8=";
  };
  dontUnpack = true;
  inherit piIntegration;

  installPhase = builtins.readFile ./herdr/install.sh;

  meta = with lib; {
    description = "Agent multiplexer that lives in your terminal";
    homepage = "https://herdr.dev";
    license = licenses.agpl3Plus;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "herdr";
  };
}
