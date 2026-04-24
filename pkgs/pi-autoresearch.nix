{ lib
, stdenvNoCC
, fetchFromGitHub
}:

let
  rev = "1441dd238bf19290861209ea5f9f2ffc065479eb";
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
    hash = "sha256-j2MvEwKw93uabzWJ6R6wrlpn0RO/LOLhDXKohH+b12U=";
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
