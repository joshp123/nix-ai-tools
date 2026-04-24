{ lib, python3Packages, fetchFromGitHub }:

let
  src = fetchFromGitHub {
    owner = "joshp123";
    repo = "dash-mcp-server";
    rev = "e64d58c82879ea8bdbc8f1bad5b07615f446357c";
    hash = "sha256-7R46GdhuP3DuABIqm/Ch5m0psTdxVw4jIKNPC3pRTVc=";
  };
in
python3Packages.buildPythonApplication {
  pname = "dash-mcp-server";
  version = "0-unstable-2025-09-01";
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
