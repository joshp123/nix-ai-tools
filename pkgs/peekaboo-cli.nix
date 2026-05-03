{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "peekaboo-cli";
  version = "3.0.0-beta4";

  src = fetchurl {
    url = "https://github.com/steipete/Peekaboo/releases/download/v${version}/peekaboo-macos-arm64.tar.gz";
    hash = "sha256-74eXVHpRAmcs0mzK3GLh/3So78AEMZzXBvx1Zg7uOkc=";
  };

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp peekaboo-macos-arm64/peekaboo "$out/bin/peekaboo"
    chmod 0755 "$out/bin/peekaboo"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Peekaboo macOS CLI (prebuilt)";
    homepage = "https://github.com/steipete/peekaboo";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "peekaboo";
  };
}
