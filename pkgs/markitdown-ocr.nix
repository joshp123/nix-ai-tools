{ fetchurl, lib, python3Packages, markitdown-base ? python3Packages.callPackage ./markitdown-base.nix { } }:

python3Packages.buildPythonPackage rec {
  pname = "markitdown-ocr";
  version = "0.1.0";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/92/a8/480ffd9e04dd610f57161e1555bc66bf87ee515bc80dd4819c143568b751/markitdown_ocr-0.1.0-py3-none-any.whl";
    hash = "sha256-xD9oNiexd9Ut1dl9hipxwWDT+fm3sW341mzuUC54Dd4=";
  };

  propagatedBuildInputs = with python3Packages; [
    markitdown-base
    mammoth
    openpyxl
    pandas
    pdfminer-six
    pdfplumber
    pillow
    pymupdf
    python-docx
    python-pptx
  ];

  doCheck = false;
  pythonImportsCheck = [ "markitdown_ocr" ];

  meta = with lib; {
    description = "OCR plugin for MarkItDown";
    homepage = "https://github.com/microsoft/markitdown/tree/main/packages/markitdown-ocr";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
