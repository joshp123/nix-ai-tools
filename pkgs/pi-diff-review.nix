{ lib, buildNpmPackage, fetchFromGitHub, nodejs }:

let
  version = "0.2.0";
  src = fetchFromGitHub {
    owner = "badlogic";
    repo = "pi-diff-review";
    rev = "v${version}";
    hash = "sha256-cCkYJJFOfP3HiAPojwRXhogGlXAiYX62uL9vmo1Lm7A=";
  };
in
buildNpmPackage {
  pname = "pi-diff-review";
  inherit version src nodejs;

  npmDepsHash = "sha256-4BeJ4Tjjpk30xBs/GZ4J3+w3WRHNTAfRk75VUf8Ee3U=";
  dontNpmBuild = true;

  # Keep Glimpse immutable in the store; we compile the native helper into
  # ~/.cache during activation and point pi at it via GLIMPSE_BINARY_PATH.
  npmFlags = [ "--ignore-scripts" ];
  npmInstallFlags = [ "--legacy-peer-deps" ];

  meta = with lib; {
    description = "Native diff review window extension for pi";
    homepage = "https://github.com/badlogic/pi-diff-review";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
