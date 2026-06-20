{ lib, buildNpmPackage, fetchFromGitHub, nodejs }:

let
  version = "2.6.2";
  npmDepsHash = "sha256-CnsTpxdGNS4tNOHaH6sgyIudv4xyxiAjCjVSIW/r8l4=";
  src = fetchFromGitHub {
    owner = "cameroncooke";
    repo = "XcodeBuildMCP";
    rev = "v${version}";
    hash = "sha256-Pka/3vIcQTJBqPyyG6FPYh5fKtrH23Rdal5mmzixC7A=";
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
