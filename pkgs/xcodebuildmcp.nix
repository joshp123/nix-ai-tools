{ lib, buildNpmPackage, fetchFromGitHub, nodejs, nodejs-slim_22, removeReferencesTo }:

let
  version = "2.7.1";
  npmDepsHash = "sha256-NQawuFOack6oYf+mcuVlOy3ddysW4L2Qai6R8rqlg00=";
  src = fetchFromGitHub {
    owner = "cameroncooke";
    repo = "XcodeBuildMCP";
    rev = "v${version}";
    hash = "sha256-ILc1y6LXN6F8JBoRVhR+GCEiFR0MNucqx3DEd9F9ogU=";
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
