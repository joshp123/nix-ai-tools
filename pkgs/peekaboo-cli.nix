{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "peekaboo-cli";
  version = "2.0.3";

  src = fetchurl {
    url = "https://github.com/steipete/Peekaboo/releases/download/v${version}/peekaboo-macos-universal.tar.gz";
    hash = "sha256-+Ot6iWJZEoh3sjsf5iNftUDqLql6XJgoiOTF1tuwxJw=";
  };

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp peekaboo-macos-universal/peekaboo "$out/bin/peekaboo"
    chmod 0755 "$out/bin/peekaboo"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Peekaboo macOS CLI (prebuilt)";
    homepage = "https://github.com/steipete/peekaboo";
    license = licenses.mit;
    platforms = platforms.darwin;
    mainProgram = "peekaboo";
  };
}
