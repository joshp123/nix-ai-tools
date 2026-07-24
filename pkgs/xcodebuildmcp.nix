{ lib, buildNpmPackage, fetchFromGitHub, nodejs, nodejs-slim_22, removeReferencesTo }:

let
  version = "2.7.0";
  npmDepsHash = "sha256-PWvpblzfn0yM6hRmdJXzcqyegsytBRZGr0vJQYWdcuA=";
  src = fetchFromGitHub {
    owner = "cameroncooke";
    repo = "XcodeBuildMCP";
    rev = "v${version}";
    hash = "sha256-9Vi67nXlX7JbQSbSv+z+60pfAq1NpZy+/U4mkWaSIas=";
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

  nativeBuildInputs = [ removeReferencesTo ];
  postFixup = ''
    while IFS= read -r file; do
      substituteInPlace "$file" \
        --replace-fail "${nodejs}/bin/node" "${nodejs-slim_22}/bin/node"
    done < <(grep -IlrF "${nodejs}/bin/node" "$out")
    find "$out" -type f -exec remove-references-to -t "${nodejs}" {} +
  '';

  passthru.runtimeNode = nodejs-slim_22;

  meta = with lib; {
    description = "MCP server for Xcode project and simulator management";
    homepage = "https://github.com/cameroncooke/XcodeBuildMCP";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "xcodebuildmcp";
  };
}
