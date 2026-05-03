{ lib
, stdenvNoCC
, fetchurl
}:

let
  version = "0.4.1";
  asset =
    {
      aarch64-darwin = {
        name = "cass-darwin-arm64.tar.gz";
        hash = "sha256-9AnanbdiA1qf5wqecrHNuwsE1DUfXNOvyDgu5hIA/OM=";
      };
      x86_64-linux = {
        name = "cass-linux-amd64.tar.gz";
        hash = "sha256-dwpj+ytObt4uYb5+5x3RNxT/o9/n3WSz7XpnCc/zGtM=";
      };
      aarch64-linux = {
        name = "cass-linux-arm64.tar.gz";
        hash = "sha256-5NPmb24jyKpWALR94uFR/uTju5y+dgChu80IJ++cyPY=";
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
