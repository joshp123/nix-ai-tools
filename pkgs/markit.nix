{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "markit";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "Michaelliv";
    repo = "markit";
    rev = "v${version}";
    hash = "sha256-Y2Ez2x29+RKO2Rv398kL6b3JIcqqfYF1RmmQ1ULnUsc=";
  };

  # Since 0.6 the conversion engine is Rust and the crate ships the same
  # `markit` CLI as the npm shell, so build that directly. Cargo.lock lives
  # under rust/, which nix-update can refresh through cargoHash on bumps.
  sourceRoot = "${src.name}/rust";

  cargoHash = "sha256-6+rqIU8IJ60xihPMmOZzZK4UZBAYRUkiCrQrOVfrxhA=";

  # The build sandbox's stdout is a pty, so color tests need NO_COLOR.
  preCheck = "export NO_COLOR=1";

  meta = with lib; {
    description = "Convert documents and media to Markdown with layout-aware PDF support";
    homepage = "https://github.com/Michaelliv/markit";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "markit";
  };
}
