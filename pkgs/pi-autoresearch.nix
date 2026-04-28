{ lib
, stdenvNoCC
, fetchFromGitHub
}:

let
  rev = "3c407b25bb11814f38bdc94c9f0566d62cdd9780";
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
    hash = "sha256-5c+668B4Pp6m27QLCWUPPjUDpFoZev/0yIgrnZnonjE=";
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
