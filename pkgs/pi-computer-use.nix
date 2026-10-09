{ lib, callPackage, pi-coding-agent }:

((callPackage ./pi-package.nix {
  inherit pi-coding-agent;
}) rec {
  pname = "pi-computer-use";
  version = "0.5.1";
  url = "https://registry.npmjs.org/@injaneity/pi-computer-use/-/pi-computer-use-${version}.tgz";
  hash = "sha256-7H//RaP+u6srXDAtsRcfXxDWyoWqzYkqn0IgKCRty3k=";

  outputs = [ "out" "helper" ];
  postInstall = builtins.readFile ./pi-computer-use/install-helper.sh;

  meta = with lib; {
    description = "Pi extension for grounded native desktop computer use";
    homepage = "https://github.com/injaneity/pi-computer-use";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
})
