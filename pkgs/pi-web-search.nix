{ lib, callPackage, pi-coding-agent }:

((callPackage ./pi-package.nix {
  inherit pi-coding-agent;
}) {
  pname = "pi-web-search";
  version = "1.3.1";
  url = "https://registry.npmjs.org/pi-web-search/-/pi-web-search-1.3.1.tgz";
  hash = "sha256-178Besvg0ClNikqGzwzE3K/jZicvNGSZoo+9Re9ACKs=";

  meta = with lib; {
    description = "Provider-native web search and URL context extension for Pi";
    homepage = "https://github.com/ttttmr/pi-web-search";
    license = licenses.mit;
    platforms = platforms.unix;
  };
})
