{ lib
, stdenvNoCC
, fetchurl
}:

stdenvNoCC.mkDerivation rec {
  pname = "codex";
  version = "0.154.0";

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-aarch64-apple-darwin.tar.gz";
    hash = "sha256-NEMQoKWRwbGS4E/v8wQyGmmQfJSYuqrDMcp+FuvO+dc=";
  };

  sourceRoot = ".";
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 codex-aarch64-apple-darwin "$out/bin/codex"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    "$out/bin/codex" --version | grep -F "${version}"
  '';

  meta = {
    description = "OpenAI Codex CLI";
    homepage = "https://github.com/openai/codex";
    license = lib.licenses.asl20;
    mainProgram = "codex";
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
