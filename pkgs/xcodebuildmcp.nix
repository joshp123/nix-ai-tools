{ lib, buildNpmPackage, fetchFromGitHub, nodejs }:

let
  version = "2.2.1";
  npmDepsHash = "sha256-mlhorpmN6gKLVqmZJePUAgMMS2R24E6Tra0bnZPjOB0=";
  src = fetchFromGitHub {
    owner = "cameroncooke";
    repo = "XcodeBuildMCP";
    rev = "v${version}";
    hash = "sha256-ROFmiNnaTc/ypsWgcHcuoSKbRIuZZTwlqu4toUuNBtU=";
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
