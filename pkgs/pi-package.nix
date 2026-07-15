{ lib
, stdenvNoCC
, fetchurl
, makeWrapper
, nodejs_22
, pi-coding-agent
}:
{ pname
, version
, url
, hash
, packageName ? pname
, binEntries ? []
, meta
}:

stdenvNoCC.mkDerivation {
  inherit pname version meta;

  src = fetchurl { inherit url hash; };
  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  piPackageName = packageName;
  piPeerNodeModules = "${pi-coding-agent}/lib/node_modules/@earendil-works/pi-coding-agent/node_modules";
  inherit binEntries nodejs_22;

  installPhase = builtins.readFile ./pi-package/install.sh;
}
