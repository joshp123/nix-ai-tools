{ lib
, stdenvNoCC
, fetchurl
}:

let
  version = "0.7.5";
  sources = {
    aarch64-darwin = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-macos-aarch64";
      hash = "sha256-NzUFRrABJVWUO5Lq+WJmXeTiZDlbrrRCJ7gBXo/1sNY=";
    };
    x86_64-darwin = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-macos-x86_64";
      hash = "sha256-P+UMSmPcgQIwaxMiF4Yo3bNlXNOuVteE8JQVNAjWnmI=";
    };
    aarch64-linux = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-aarch64";
      hash = "sha256-MudjoUmaa2lLHXCOTwYrdDvh2p80/PpNIS1ttv4JqLk=";
    };
    x86_64-linux = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-x86_64";
      hash = "sha256-PcgyiAc+TC08Z5ow576XvMqRQcb9F9u7khkULpXFklM=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system}
    or (throw "herdr ${version} has no release binary for ${stdenvNoCC.hostPlatform.system}");
  piIntegration = fetchurl {
    url = "https://raw.githubusercontent.com/ogulcancelik/herdr/v${version}/src/integration/assets/pi/herdr-agent-state.ts";
    hash = "sha256-Eu/SdZL78YU0PwNe5P0rGZnpNW4yPksBIl99a8ibFt4=";
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
