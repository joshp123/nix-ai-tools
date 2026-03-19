{ lib
, stdenvNoCC
, fetchFromGitHub
}:

let
  rev = "b8130ece75718dc08e4bd840af799cdf4083eafc";
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
    hash = "sha256-X/ZRl6BAw30NJsuk9y4BRF9JODUJnejWAaJyX8yQBpo=";
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
