{ lib
, fetchFromGitHub
, makeWrapper
, sqlite
, bun2nix
}:

let
  version = "2.0.1";
  src = fetchFromGitHub {
    owner = "tobi";
    repo = "qmd";
    rev = "v${version}";
    hash = "sha256-UoR9iyxqbjwAbEmiC/kxS10lvdBJmDuQigS/aEgEzDs=";
  };
  sqliteWithExtensions = sqlite.overrideAttrs (old: {
    configureFlags = (old.configureFlags or []) ++ [
      "--enable-load-extension"
    ];
  });
in
bun2nix.writeBunApplication {
  pname = "qmd";
  inherit version src;

  packageJson = "${src}/package.json";
  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./generated/qmd-bun2nix.nix;
  };

  dontUseBunBuild = true;
  dontUseBunCheck = true;
  startScript = ''
    export DYLD_LIBRARY_PATH="${sqliteWithExtensions.out}/lib''${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"
    export LD_LIBRARY_PATH="${sqliteWithExtensions.out}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    exec bun src/cli/qmd.ts "$@"
  '';

  nativeBuildInputs = [ makeWrapper ];

  meta = with lib; {
    description = "Query Markup Documents";
    homepage = "https://github.com/tobi/qmd";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" "x86_64-darwin" ];
    mainProgram = "qmd";
  };
}
