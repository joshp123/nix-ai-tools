{ lib, callPackage, pi-coding-agent }:

((callPackage ./pi-package.nix {
  inherit pi-coding-agent;
}) rec {
  pname = "pi-web-search";
  version = "1.7.0";
  url = "https://registry.npmjs.org/pi-web-search/-/pi-web-search-${version}.tgz";
  hash = "sha256-+Ku4Hes13cN/pqA0Nzf+gLEF92X28u0Xdbuf1N3+uI0=";

  meta = with lib; {
    description = "Provider-native web search and URL context extension for Pi";
    homepage = "https://github.com/ttttmr/pi-web-search";
    license = licenses.mit;
    platforms = platforms.unix;
  };
})
