{ lib, buildNpmPackage, fetchFromGitHub, nodejs }:

let
  version = "2.0.3";
  src = fetchFromGitHub {
    owner = "steipete";
    repo = "peekaboo";
    rev = "v${version}";
    hash = "sha256-U1XtM/xtTNtPXe2E8mWSWe5+zPUKeEY3WN7vRACjwjQ=";
  };
in
buildNpmPackage {
  pname = "peekaboo-mcp";
  inherit version src;

  npmDepsHash = "sha256-wMzz3lUFgDC8an+QXVDArr1ylHYVOYEFbm98qqvEdZc=";
  npmBuildScript = "build";
  inherit nodejs;

  env = { CI = "1"; };

  meta = with lib; {
    description = "Peekaboo MCP server for macOS automation";
    homepage = "https://github.com/steipete/peekaboo";
    license = licenses.mit;
    platforms = platforms.darwin;
    mainProgram = "peekaboo-mcp";
  };
}
