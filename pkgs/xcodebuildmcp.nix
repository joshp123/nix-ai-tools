{ lib, buildNpmPackage, fetchFromGitHub, nodejs }:

let
  version = "1.15.1";
  npmDepsHash = "sha256-GlZck/wpiGevQqQXMUQGV92ipTVAUjJ529wZRWnEYxY=";
  src = fetchFromGitHub {
    owner = "cameroncooke";
    repo = "XcodeBuildMCP";
    rev = "v${version}";
    hash = "sha256-slz5UqiFw7P2IXNa/kUXSI1g+3P3ceTvqGsUB+lc7Gg=";
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
