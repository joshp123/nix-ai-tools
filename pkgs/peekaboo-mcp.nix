{ lib, stdenv, fetchurl, makeWrapper, nodejs }:

stdenv.mkDerivation rec {
  pname = "peekaboo-mcp";
  version = "3.0.0-beta4";

  src = fetchurl {
    url = "https://github.com/steipete/Peekaboo/releases/download/v${version}/steipete-peekaboo-${version}.tgz";
    hash = "sha256-Gq3wlx1Zo9fAc1z7VRd1F9aP9U+KKI2yiOXKKdUUGqk=";
  };

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/libexec/peekaboo-mcp" "$out/bin"
    cp -R package/. "$out/libexec/peekaboo-mcp/"
    chmod 0755 "$out/libexec/peekaboo-mcp/peekaboo" "$out/libexec/peekaboo-mcp/peekaboo-mcp.js"
    makeWrapper ${nodejs}/bin/node "$out/bin/peekaboo-mcp" \
      --add-flags "$out/libexec/peekaboo-mcp/peekaboo-mcp.js"
    runHook postInstall
  '';

  nativeBuildInputs = [ makeWrapper ];

  meta = with lib; {
    description = "Peekaboo MCP server for macOS automation";
    homepage = "https://github.com/steipete/peekaboo";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "peekaboo-mcp";
  };
}
