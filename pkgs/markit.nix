{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "markit";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "Michaelliv";
    repo = "markit";
    rev = "v${version}";
    hash = "sha256-nJXuXMkOQPyjIbLL84/5eMVQc2dKjr1gBgVLJbLsH8k=";
  };

  # Since 0.6 the conversion engine is Rust and the crate ships the same
  # `markit` CLI as the npm shell, so build that directly. Cargo.lock lives
  # under rust/, which nix-update can refresh through cargoHash on bumps.
  sourceRoot = "${src.name}/rust";

  cargoHash = "sha256-XDnyP+dAaab7gxRLgF86FtZ3id1k5T7DYnPDFJkxD7U=";

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
