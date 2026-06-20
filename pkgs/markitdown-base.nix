{ fetchPypi, lib, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "markitdown";
  version = "0.1.6";
  format = "wheel";

  src = fetchPypi {
    inherit pname version format;
    dist = "py3";
    python = "py3";
    abi = "none";
    platform = "any";
    hash = "sha256-B7LVv4e1xT4TqfL9xEDfjMyF4m9AweVXeBcntwAEl3U=";
  };

  propagatedBuildInputs = with python3Packages; [
    azure-ai-documentintelligence
    azure-identity
    beautifulsoup4
    charset-normalizer
    defusedxml
    lxml
    magika
    mammoth
    markdownify
    olefile
    openai
    openpyxl
    pandas
    pdfminer-six
    pdfplumber
    pydub
    python-pptx
    requests
    speechrecognition
    xlrd
    youtube-transcript-api
  ];

  doCheck = false;
  pythonImportsCheck = [ "markitdown" ];

  meta = with lib; {
    description = "Convert files and URLs to Markdown for LLM workflows";
    homepage = "https://github.com/microsoft/markitdown";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "markitdown";
  };
}
