{ lib, buildNpmPackage, fetchFromGitHub, nodejs }:

let
  version = "2.0.7";
  npmDepsHash = "sha256-f3viOhZm7UGtiDFV7oTsxNyadTrkfboGuAAkUkSHLjU=";
  src = fetchFromGitHub {
    owner = "cameroncooke";
    repo = "XcodeBuildMCP";
    rev = "v${version}";
    hash = "sha256-S6gQpTsAp6VNck93Ea5zsfkYcxVCvgtPVlAqgsWrtXU=";
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
