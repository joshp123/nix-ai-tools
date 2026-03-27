{ lib, buildNpmPackage, fetchFromGitHub, nodejs }:

let
  version = "2.3.1";
  npmDepsHash = "sha256-YQNB46vnhcc5PV3ILKr22UDfi4uB/+85FHMYb8jlwuM=";
  src = fetchFromGitHub {
    owner = "cameroncooke";
    repo = "XcodeBuildMCP";
    rev = "v${version}";
    hash = "sha256-6yIsn7uxGGyRh3a73Mfj8Nt5oRlm4W6VmsilMlqMPDk=";
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
