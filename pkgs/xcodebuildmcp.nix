{ lib, buildNpmPackage, fetchFromGitHub, nodejs }:

let
  version = "1.9.0";
  npmDepsHash = "sha256-y8ZN9/Nc4g3l872ZpV/oTWcDfAf7TkU9103Iplr13VI=";
  src = fetchFromGitHub {
    owner = "cameroncooke";
    repo = "XcodeBuildMCP";
    rev = "v${version}";
    hash = "sha256-p4uqfWTJYBWX6Ehx3FYXy1DhXyRuOgTH1rroEizgY3M=";
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
