{ lib, callPackage, pi-coding-agent }:

((callPackage ./pi-package.nix {
  inherit pi-coding-agent;
}) {
  pname = "pi-agent-browser-native";
  version = "0.2.67";
  url = "https://registry.npmjs.org/pi-agent-browser-native/-/pi-agent-browser-native-0.2.67.tgz";
  hash = "sha256-pLAsd1foG5KCunwJ5pC3jQ5RhIC9BxXy3XsUTb+MKvE=";
  binEntries = [
    "pi-agent-browser-config:scripts/config.mjs"
    "pi-agent-browser-doctor:scripts/doctor.mjs"
  ];

  meta = with lib; {
    description = "Native Pi extension for agent-browser automation";
    homepage = "https://github.com/fitchmultz/pi-agent-browser-native";
    license = licenses.mit;
    platforms = platforms.unix;
  };
})
