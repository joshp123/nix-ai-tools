{ lib, buildNpmPackage, fetchFromGitHub, nodejs, nodejs-slim_22, removeReferencesTo }:

let
  version = "0.5.3";
  src = fetchFromGitHub {
    owner = "Michaelliv";
    repo = "markit";
    rev = "v${version}";
    hash = "sha256-7TDou6PJ04ZN0hmfOlXRUCLzIF5JNfUAGlyNVpcoUQg=";
  };
in
buildNpmPackage {
  pname = "markit";
  inherit version src nodejs;

  npmDepsHash = "sha256-+WqB0NV+d2YEHfnv2fuyMaqB3YI0vR3PcB6Bu4QUcK4=";
  npmBuildScript = "build";

  # The upstream v0.5.0 tag ships an outdated package-lock.json. Use a lockfile
  # regenerated from the tagged package.json so the build matches the published
  # CLI behavior.
  postPatch = ''
    cp ${./markit-package-lock.json} package-lock.json
  '';

  env = { CI = "1"; };

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
    description = "Convert documents and media to Markdown with layout-aware PDF support";
    homepage = "https://github.com/Michaelliv/markit";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "markit";
  };
}
