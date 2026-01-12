{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, symlinkJoin
, onnxruntime
}:

let
  # Pinned to 2c50eb2 (Opt 1.5) - before broken pages feature with missing coi-detector.js
  rev = "2c50eb21fed426992555759daf520718c0cc8685";
  shortRev = builtins.substring 0 7 rev;
  version = "unstable-${shortRev}";
  src = fetchFromGitHub {
    owner = "Dicklesworthstone";
    repo = "coding_agent_session_search";
    rev = rev;
    hash = "sha256-xBcAffHylI7H2DR2uTegaS1adpxmEZtQcURpr0W4vMs=";
  };
  opensslCombined = symlinkJoin {
    name = "openssl-combined";
    paths = [ openssl.out openssl.dev ];
  };
in
rustPlatform.buildRustPackage {
  pname = "cass";
  inherit version src;

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = { };
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl onnxruntime ];
  env = {
    OPENSSL_NO_VENDOR = "1";
    OPENSSL_DIR = "${opensslCombined}";
    OPENSSL_INCLUDE_DIR = "${opensslCombined}/include";
    OPENSSL_LIB_DIR = "${opensslCombined}/lib";
    PKG_CONFIG_PATH = "${opensslCombined}/lib/pkgconfig";
    ORT_LIB_LOCATION = "${onnxruntime.out}/lib";
    ORT_SKIP_DOWNLOAD = "1";
    ORT_PREFER_DYNAMIC_LINK = "1";
  };

  doCheck = false;

  meta = with lib; {
    description = "Cross-agent session search CLI";
    homepage = "https://github.com/Dicklesworthstone/coding_agent_session_search";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "cass";
  };
}
