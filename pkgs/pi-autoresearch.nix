{ lib
, stdenvNoCC
, fetchFromGitHub
}:

let
  version = "1.8.1";
in
stdenvNoCC.mkDerivation {
  pname = "pi-autoresearch";
  inherit version;

  src = fetchFromGitHub {
    owner = "davebcn87";
    repo = "pi-autoresearch";
    rev = "v${version}";
    hash = "sha256-QnkFwHPZ55hKuoMvkqph9y3//hAO5UCme6bFjiWIN5U=";
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
