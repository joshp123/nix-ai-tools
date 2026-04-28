{ lib
, stdenvNoCC
, fetchFromGitHub
}:

let
  rev = "37a611f460f07be353c86dc4596542c03946a2a7";
  shortRev = builtins.substring 0 7 rev;
  version = "unstable-${shortRev}";
in
stdenvNoCC.mkDerivation {
  pname = "pi-autoresearch";
  inherit version;

  src = fetchFromGitHub {
    owner = "davebcn87";
    repo = "pi-autoresearch";
    rev = rev;
    hash = "sha256-1KeUUN6odbKv/Z/S6rUQa9k1vcIJYVOeTvRpX8dDAoY=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -d "$out/share/pi-autoresearch"
    cp -R extensions skills README.md package.json package-lock.json LICENSE \
      "$out/share/pi-autoresearch/"

    runHook postInstall
  '';

  meta = with lib; {
    description = "pi extension and skill for autonomous experiment loops";
    homepage = "https://github.com/davebcn87/pi-autoresearch";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
