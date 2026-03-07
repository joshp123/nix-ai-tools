{ lib, buildNpmPackage, fetchFromGitHub, nodejs }:

let
  version = "2.2.0";
  npmDepsHash = "sha256-rfB+XqcxJxBL+lx2P5yA7ZU/mCBV2/pHKLe9iwNxRgk=";
  src = fetchFromGitHub {
    owner = "cameroncooke";
    repo = "XcodeBuildMCP";
    rev = "v${version}";
    hash = "sha256-fSxYdlIcsvS1i7VB4lQ71AASIBVbWKEdt3ny/dj+Y1M=";
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
