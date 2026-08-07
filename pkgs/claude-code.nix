{ lib
, stdenvNoCC
, fetchurl
, makeBinaryWrapper
}:

stdenvNoCC.mkDerivation rec {
  pname = "claude-code";
  version = "2.1.224";

  src = fetchurl {
    url = "https://downloads.claude.ai/claude-code-releases/${version}/darwin-arm64/claude";
    hash = "sha256-OR350qsE5M8yGZM1cgrHcVpYLpHq7P1NIZihb1fqWbM=";
  };

  dontUnpack = true;
  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/libexec/claude"
    makeBinaryWrapper "$out/libexec/claude" "$out/bin/claude" \
      --set DISABLE_AUTOUPDATER 1 \
      --set DISABLE_UPDATES 1

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    "$out/bin/claude" --version | grep -F "${version}"
  '';

  meta = {
    description = "Anthropic Claude Code CLI";
    homepage = "https://docs.anthropic.com/en/docs/claude-code";
    license = lib.licenses.unfree;
    mainProgram = "claude";
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
