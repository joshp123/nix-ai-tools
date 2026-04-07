{ lib, buildNpmPackage, fetchFromGitHub, nodejs }:

let
  version = "test-fixtures-v1";
  src = fetchFromGitHub {
    owner = "Michaelliv";
    repo = "markit";
    rev = "v${version}";
    hash = "sha256-prSnyyXJDpyFZiPBMeQfyxhWLvHKvzsMiyq/uX/8dHY=";
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

  meta = with lib; {
    description = "Convert documents and media to Markdown with layout-aware PDF support";
    homepage = "https://github.com/Michaelliv/markit";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "markit";
  };
}
