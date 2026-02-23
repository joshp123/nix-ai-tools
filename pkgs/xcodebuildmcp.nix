{ lib, buildNpmPackage, fetchFromGitHub, nodejs }:

let
  version = "2.1.0";
  npmDepsHash = "sha256-Y9rlr9ngAvtiqIxAQeicCDtiDESEQHhUy7lrj5IQkbI=";
  src = fetchFromGitHub {
    owner = "cameroncooke";
    repo = "XcodeBuildMCP";
    rev = "v${version}";
    hash = "sha256-Yq3uNyG6ThnJrPRqtvL+lYakf/YoDDiX6Qxhke4jro0=";
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
