{ lib, buildNpmPackage, fetchFromGitHub, nodejs }:

let
  version = "2.0.0";
  npmDepsHash = "sha256-MfCK+K3+jEAq+40/aRGWBMUxB9azdCyQ5DR7yHbAr6c=";
  src = fetchFromGitHub {
    owner = "cameroncooke";
    repo = "XcodeBuildMCP";
    rev = "v${version}";
    hash = "sha256-jSjoTc7wJJXTIbATPWL4S+3iX6wmXnH/o54ydONcSRM=";
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
