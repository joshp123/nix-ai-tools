{ lib, makeWrapper, python3, symlinkJoin, markitdown-base ? python3.pkgs.callPackage ./markitdown-base.nix { }, markitdown-ocr ? python3.pkgs.callPackage ./markitdown-ocr.nix { inherit markitdown-base; } }:

symlinkJoin {
  pname = "markitdown";
  inherit (markitdown-base) version;
  paths = [ markitdown-base ];

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/markitdown \
      --prefix PYTHONPATH : "${markitdown-ocr}/${python3.sitePackages}"
  '';

  meta = markitdown-base.meta // {
    description = "MarkItDown CLI with the OCR plugin in the runtime Python path";
    mainProgram = "markitdown";
  };

  passthru = {
    inherit markitdown-base markitdown-ocr;
  };
}
