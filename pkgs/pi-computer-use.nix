{ lib
, stdenvNoCC
, fetchurl
, pi-coding-agent
}:

let
  version = "0.4.3";
in
stdenvNoCC.mkDerivation {
  pname = "pi-computer-use";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@injaneity/pi-computer-use/-/pi-computer-use-${version}.tgz";
    hash = "sha256-kI7DK59Mn86d43ZrC/p0+CFVW8x0SiJVtb32bgPXb8U=";
  };
  dontUnpack = true;
  outputs = [ "out" "helper" ];

  piPeerNodeModules = "${pi-coding-agent}/lib/node_modules/@earendil-works/pi-coding-agent/node_modules";

  installPhase = builtins.readFile ./pi-computer-use/install.sh;

  meta = with lib; {
    description = "Pi extension for grounded native desktop computer use";
    homepage = "https://github.com/injaneity/pi-computer-use";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}
