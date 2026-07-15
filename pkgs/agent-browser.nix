{ lib
, stdenvNoCC
, fetchurl
}:

let
  version = "0.31.2";
  sources = {
    aarch64-darwin = {
      url = "https://github.com/vercel-labs/agent-browser/releases/download/v${version}/agent-browser-darwin-arm64";
      hash = "sha256-mAQrz+6a/fYRnWgXoE71iX9RnykEkWZJEXebCErhuCo=";
    };
    x86_64-darwin = {
      url = "https://github.com/vercel-labs/agent-browser/releases/download/v${version}/agent-browser-darwin-x64";
      hash = "sha256-mISgpDziFzQjxW7AX2GNduzH5v80L3T7M99Zivm/cWg=";
    };
    aarch64-linux = {
      url = "https://github.com/vercel-labs/agent-browser/releases/download/v${version}/agent-browser-linux-arm64";
      hash = "sha256-GN/ikJ5N+jh4mdgNw2rHxB3hdXn+DVrMuZXqdUtIix8=";
    };
    x86_64-linux = {
      url = "https://github.com/vercel-labs/agent-browser/releases/download/v${version}/agent-browser-linux-x64";
      hash = "sha256-o+BmcQtFeqmjigdI/t2Y0ApibudGMdqfR8pFsb3QQQs=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system}
    or (throw "agent-browser ${version} has no release binary for ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "agent-browser";
  inherit version;

  src = fetchurl source;
  dontUnpack = true;

  installPhase = builtins.readFile ./agent-browser/install.sh;

  meta = with lib; {
    description = "Headless browser automation CLI for AI agents";
    homepage = "https://github.com/vercel-labs/agent-browser";
    license = licenses.asl20;
    platforms = builtins.attrNames sources;
    mainProgram = "agent-browser";
  };
}
