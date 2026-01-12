{ lib, python3Packages, fetchFromGitHub }:

let
  src = fetchFromGitHub {
    owner = "joshp123";
    repo = "dash-mcp-server";
    rev = "c92ebc42c31158729ae7acc4abef1fdf9eae0893";
    hash = "sha256-Ryh0VCjsXnjl4+o0MaJOsr2j3rkc6UBJE5Q/IlJB+aI=";
  };
in
python3Packages.buildPythonApplication {
  pname = "dash-mcp-server";
  version = "1.0.0";
  inherit src;
  pyproject = true;
  nativeBuildInputs = [ python3Packages.hatchling ];
  propagatedBuildInputs = [
    python3Packages.mcp
    python3Packages.pydantic
    python3Packages.httpx
  ];
  doCheck = false;

  meta = with lib; {
    description = "MCP server for Dash, the macOS documentation browser";
    homepage = "https://github.com/joshp123/dash-mcp-server";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "dash-mcp-server";
  };
}
