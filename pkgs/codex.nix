{ lib
, stdenvNoCC
, fetchurl
}:

stdenvNoCC.mkDerivation rec {
  pname = "codex";
  version = "0.166.0";

  src = fetchurl {
    # The package layout ships codex-code-mode-host, which the shell tool spawns
    # from the directory codex was invoked from, plus the bundled rg.
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-aarch64-apple-darwin.tar.gz";
    hash = "sha256-VaRAy1eflwq+fHmrGB5UsOpMQZvpnzM7vYaO66ycIfA=";
  };

  sourceRoot = ".";
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -R bin codex-path codex-resources codex-package.json "$out/"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    "$out/bin/codex" --version | grep -F "${version}"
    test -x "$out/bin/codex-code-mode-host"
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
