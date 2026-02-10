{ lib, buildNpmPackage, fetchFromGitHub, nodejs }:

let
  version = "2.0.5";
  npmDepsHash = "sha256-L4btNmqgEfaxhbwQj0ulFQwu40DR/NaRkSCj6U2jpSc=";
  src = fetchFromGitHub {
    owner = "cameroncooke";
    repo = "XcodeBuildMCP";
    rev = "v${version}";
    hash = "sha256-SqbloWiRK8gdvS9/+0jC18lpdd+1VCiipGvJxuBzreg=";
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
