{ lib
, stdenvNoCC
, fetchurl
}:

# One release binary per package so nix-update can bump the hash; CI, the
# workstation and the Mac mini are all aarch64-darwin.
let
  version = "0.39.1";
in
stdenvNoCC.mkDerivation {
  pname = "agent-browser";
  inherit version;

  src = fetchurl {
    url = "https://github.com/vercel-labs/agent-browser/releases/download/v${version}/agent-browser-darwin-arm64";
    hash = "sha256-zBj6xB2dyYIZGDQKE25kMobqBVRMTdNWcbeW8ah0ze8=";
  };
  dontUnpack = true;

  installPhase = builtins.readFile ./agent-browser/install.sh;

  meta = with lib; {
    description = "Headless browser automation CLI for AI agents";
    homepage = "https://github.com/vercel-labs/agent-browser";
    license = licenses.asl20;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "agent-browser";
  };
}
