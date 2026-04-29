{ lib
, stdenvNoCC
, fetchFromGitHub
}:

let
  rev = "376ccc62d88345e84d524486699378eaf006f838";
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
    hash = "sha256-L7vldl+blfSkJjCn2mbhcAc6JQxESIkcoe9SitcPrEE=";
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
