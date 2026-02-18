{ lib, stdenv, fetchurl }:

let
  version = "0.1.8";
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/mattzcarey/zagi/releases/download/v${version}/zagi-macos-aarch64.tar.gz";
      hash = "sha256-gcfibTpUoFdSDt4PdPw90OHoiV1dy7MU9quVtTA5bv0=";
    };
    "x86_64-darwin" = {
      url = "https://github.com/mattzcarey/zagi/releases/download/v${version}/zagi-macos-x86_64.tar.gz";
      hash = "sha256-Z0zt4ghGJwichl/nNQENPToezOkALCZ+T0MVjW59C9E=";
    };
    "aarch64-linux" = {
      url = "https://github.com/mattzcarey/zagi/releases/download/v${version}/zagi-linux-aarch64.tar.gz";
      hash = "sha256-TxcAs/jBuFxIkwHgHXCZQ4bobuYrKqNPlrs8RVNe3/Y=";
    };
    "x86_64-linux" = {
      url = "https://github.com/mattzcarey/zagi/releases/download/v${version}/zagi-linux-x86_64.tar.gz";
      hash = "sha256-7Rr49UHdNjQzpc5SCc//GA4CD+18tlw1BR/s4DBBDCY=";
    };
  };
in
stdenv.mkDerivation {
  pname = "zagi";
  inherit version;

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp zagi "$out/bin/zagi"
    chmod 0755 "$out/bin/zagi"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Git-compatible CLI with guardrails";
    homepage = "https://github.com/mattzcarey/zagi";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "zagi";
  };
}
