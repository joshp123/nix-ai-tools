{ lib
, stdenvNoCC
, fetchurl
}:

let
  version = "0.7.3";
  sources = {
    aarch64-darwin = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-macos-aarch64";
      hash = "sha256-sxNFOS0ATsHxssgh4a1gEBn6g4X+HkxpMTIetYqSB3M=";
    };
    x86_64-darwin = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-macos-x86_64";
      hash = "sha256-m1810oOwh37toM9muh7x2VrkDzLoWKBNoAQfOiDfAnw=";
    };
    aarch64-linux = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-aarch64";
      hash = "sha256-6kkAlPLHw5CZhwhX0Axkxijve166GWffQlgDNFXuLLE=";
    };
    x86_64-linux = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-x86_64";
      hash = "sha256-BD70Psur2ihGXc/x7sMYRRgVDVZ7i48gzanGyIdwZB0=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system}
    or (throw "herdr ${version} has no release binary for ${stdenvNoCC.hostPlatform.system}");
  piIntegration = fetchurl {
    url = "https://raw.githubusercontent.com/ogulcancelik/herdr/v${version}/src/integration/assets/pi/herdr-agent-state.ts";
    hash = "sha256-9V5YmMiqvdt79H+jkKNd41KA4SGS1t8rU0DDXT836W8=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "herdr";
  inherit version;

  src = fetchurl source;
  dontUnpack = true;
  inherit piIntegration;

  installPhase = builtins.readFile ./herdr/install.sh;

  meta = with lib; {
    description = "Agent multiplexer that lives in your terminal";
    homepage = "https://herdr.dev";
    license = licenses.agpl3Plus;
    platforms = builtins.attrNames sources;
    mainProgram = "herdr";
  };
}
