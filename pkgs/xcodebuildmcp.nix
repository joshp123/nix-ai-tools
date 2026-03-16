{ lib, buildNpmPackage, fetchFromGitHub, nodejs }:

let
  version = "2.3.0";
  npmDepsHash = "sha256-kEPbIR8hxKW2MaYHBE3zVREyiBNR4qNeQ+UHudyIRQc=";
  src = fetchFromGitHub {
    owner = "cameroncooke";
    repo = "XcodeBuildMCP";
    rev = "v${version}";
    hash = "sha256-Mpya1GaW1xoBKpdf16I0KewNvJ/tKP1rovvIPcWFB7s=";
  };
  env = {
    CI = "1";
    SENTRYCLI_SKIP_DOWNLOAD = "1";
  };
in
buildNpmPackage {
  pname = "xcodebuildmcp";
  inherit version src npmDepsHash nodejs env;

  npmBuildScript = "build";

  meta = with lib; {
    description = "MCP server for Xcode project and simulator management";
    homepage = "https://github.com/cameroncooke/XcodeBuildMCP";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "xcodebuildmcp";
  };
}
