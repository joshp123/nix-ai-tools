{ lib
, stdenvNoCC
, fetchurl
}:

let
  version = "0.6.21";
  asset =
    {
      aarch64-darwin = {
        name = "cass-darwin-arm64.tar.gz";
        hash = "sha256-MpgQXNZmZSJ2m77tR+l8P/mVWKOKWnrHjIuVBpkmyJ0=";
      };
      x86_64-linux = {
        name = "cass-linux-amd64.tar.gz";
        hash = "sha256-PIBw8FPMUUQPhHcPd/y9/269U7Krr1mT2J5DipSM5RE=";
      };
      aarch64-linux = {
        name = "cass-linux-arm64.tar.gz";
        hash = "sha256-VY65CqZ0qrjMAHPPLnwdOYKn9zVW/gh3KMCZ+ghwq/Q=";
      };
    }.${stdenvNoCC.hostPlatform.system} or (throw "cass: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "cass";
  inherit version;

  src = fetchurl {
    url = "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v${version}/${asset.name}";
    inherit (asset) hash;
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm755 cass "$out/bin/cass"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Cross-agent session search CLI";
    homepage = "https://github.com/Dicklesworthstone/coding_agent_session_search";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
    mainProgram = "cass";
  };
}
